import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:device_link/notifiers/connection_manager.dart';
import 'package:device_link/ui/dialog/empty_loading_dialog.dart';
import 'package:device_link/ui/pages/screen_share_page.dart';
import 'package:device_link/ui/snackbars/error_snackbar.dart';
import 'package:device_link/util/device_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:device_link/signaling/signaling_client.dart';
import 'package:device_link/enums/message_type.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:hive_ce/hive.dart';
import 'package:media_scanner/media_scanner.dart';
import 'connected_device.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'package:device_link/notifiers/file_transfer_progress_model.dart';
import 'package:device_link/notifiers/clipboard_manager.dart';
import 'package:device_link/ui/router.dart';
import 'package:device_link/database/last_connected_device.dart';
import 'package:device_link/notifiers/battery_manager.dart';
import 'package:network_info_plus/network_info_plus.dart';

//TODO: pridat posilani primo medii a slozek
class WebRtcConnection {
  static final WebRtcConnection _instance = WebRtcConnection._internal();
  factory WebRtcConnection() => _instance;
  WebRtcConnection._internal();

  final _settingsBox = Hive.box('settings');
  final _signalingClient = SignalingClient.instance;
  static WebRtcConnection get instance => _instance;

  late RTCPeerConnection _peerConnection;
  late RTCDataChannel _statusDataChannel;
  late RTCDataChannel _infoDataChannel;
  late RTCDataChannel _fileDataChannel;
  late RTCDataChannel _clipboardDataChannel;
  late RTCSessionDescription _offer;
  late RTCSessionDescription _answer;
  Timer? _connectionTimer;
  final int _timeoutSeconds = 30;
  late File _selectedFile;
  late IOSink _selectedFileSink;
  late String _selectedDirectory;
  late String _fileName;
  late String _fileType;
  late int _fileIndex;
  late int _fileCount;
  late int _fileSize;
  late MediaStream localStream;
  late MediaStream _remoteStream ;
  late RTCRtpSender? sender;
  Function(bool) onConnectionStateChange = (bool isActive) {};
  Function() onScreenShareStopLocal = () {};
  Function() onScreenShareStopRemote = () {};
  final FileTransferProgressModel _progressBarModel = FileTransferProgressModel();
  final ClipboardManager _clipboardManager = ClipboardManager();
  final ConnectionManager _connectionManager = ConnectionManager();
  final BatteryManager _batteryManager = BatteryManager();
  Completer<void> _connectionCompleter = Completer<void>();
  Completer<void> _canSendChunk = Completer<void>();
  Completer<void> _sdpCompleter = Completer<void>();
  Completer<void> _fileInfoReceived = Completer<void>();
  Completer<void> _fileReceived = Completer<void>();
  Completer<void> _deviceInfoReceived = Completer<void>();
  Completer<void> _infoChannelReady = Completer<void>();
  Completer<void> _iceGathering = Completer<void>();

  ConnectionManager get connectionManager => _connectionManager;
  BatteryManager get batteryManager => _batteryManager;
  RTCPeerConnection get peerConnection => _peerConnection;
  MediaStream get remoteStream => _remoteStream;
  Completer<void> get sdpCompleter => _sdpCompleter;
  FileTransferProgressModel get progressBarModel => _progressBarModel;

  Future<void> initialize() async {
    if (!EmptyLoadingDialog.isShowing() && navigatorKey.currentContext != null) {
      EmptyLoadingDialog.show(navigatorKey.currentContext!);
    }
    startTimeoutCheck();

    _peerConnection = await createPeerConnection({});

    _peerConnection.onDataChannel = (RTCDataChannel dataChannel) {
      switch (dataChannel.label) {
        case 'infoChannel':
          _infoDataChannel = dataChannel;
          _setupInfoChannel();
          break;
        case 'fileChannel':
          _fileDataChannel = dataChannel;
          _setupFileChannel();
          break;
        case 'clipboardChannel':
          _clipboardDataChannel = dataChannel;
          _setupClipboardChannel();
          break;
        case 'statusChannel':
          _statusDataChannel = dataChannel;
          _setupStatusChannel();
          break;
        default:
          print('Unknown data channel');
          break;
      }
    };

    _peerConnection.onConnectionState = (state) {
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed) {
        print("Peer connection failed, disconnecting");
        _connectionManager.endPeerConnection(disconnectInitiator: false);
      }
    };

    peerConnection.onTrack = (RTCTrackEvent event) {
      if (event.streams.isNotEmpty) {
        _remoteStream = event.streams[0];
      }

      if (event.track.kind == "video") {
        event.track.onEnded = () {
          print("Screen sharing stopped by sender.");
          onScreenShareStopRemote();
        };
      }
    };
  }

  void startTimeoutCheck() async{
    _connectionTimer = Timer(Duration(seconds: _timeoutSeconds), () async {
      if (!_connectionCompleter.isCompleted) {
        print("Connection timed out, aborting");
        _connectionManager.endPeerConnection(disconnectInitiator: false);
        if (navigatorKey.currentContext == null) return;
        EmptyLoadingDialog.closeDialog(navigatorKey.currentContext!);
        ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(const SnackBar(
          content: ErrorSnackBar(
              message: "Pokus o spojení selhal, restartujte aplikaci a zkuste to znovu"
          ),
          backgroundColor: Colors.transparent,
          behavior: SnackBarBehavior.fixed,
          duration: Duration(seconds: 10),
        ));
      } else {
        print("Connection completed in time");
      }
    });
  }

  void cancelTimer() async{
    if (_connectionTimer != null && _connectionTimer!.isActive) {
      _connectionTimer!.cancel();
      print('Timer canceled.');
    }
  }

  Future<void> setLastDevice({required bool connectionInitiator}) async {
    await _connectionCompleter.future;
    await _deviceInfoReceived.future;
    await LastConnectedDevice.save(
        uuid: _connectionManager.device!.uuid,
        lastKnownName: _connectionManager.device!.name,
        initiateConnection: connectionInitiator
    );
  }

  //vytvoreni a prvotni nastaveni vlastnosti data kanalu
  Future<void> initDataChannels() async {
    _infoDataChannel = await _peerConnection.createDataChannel('infoChannel', RTCDataChannelInit());
    _setupInfoChannel();
    print('Info channel created');

    _fileDataChannel = await _peerConnection.createDataChannel('fileChannel', RTCDataChannelInit());
    _setupFileChannel();
    print('File channel created');

    _clipboardDataChannel = await _peerConnection.createDataChannel('clipboardChannel', RTCDataChannelInit());
    _setupClipboardChannel();
    print('Clipboard channel created');

    _statusDataChannel = await _peerConnection.createDataChannel('statusChannel', RTCDataChannelInit());
    _setupStatusChannel();
    print('Status channel created');

    //_handleDataChannels();
  }

  Future<void> _setupInfoChannel() async {
    _infoDataChannel.onDataChannelState = (RTCDataChannelState state) async {
      if (state == RTCDataChannelState.RTCDataChannelOpen) {
        print('Info channel open');

        _infoDataChannel.onMessage = (RTCDataChannelMessage message) async {
          Map<String, dynamic> decodedMessage = json.decode(message.text);
          var messageType = InfoChannelMessageType.values.byName(decodedMessage['type']);

          switch (messageType) {
            case InfoChannelMessageType.deviceInfo:
              print('Device info received');
              await _connectionManager.setDevice(
                ConnectedDevice(
                  uuid: decodedMessage['uuid'],
                  name: decodedMessage['deviceName'],
                  deviceType: decodedMessage['deviceType'],
                  ip: decodedMessage['ip'],
                ),
              );
              print("connected device set");
              _deviceInfoReceived.complete();
              break;
            case InfoChannelMessageType.chunkArrivedOk:
            //print('Chunk arrived ok');
              _canSendChunk.complete();
              break;
            case InfoChannelMessageType.fileInfo:
              print('File info received');
              print(decodedMessage);
              await setFileInfo(decodedMessage);
              break;
            case InfoChannelMessageType.fileInfoArrivedOk:
              print('File info arrived ok');
              _fileInfoReceived.complete();
              break;
            case InfoChannelMessageType.fileArrivedOk:
              print('File arrived ok');
              _fileReceived.complete();
              break;
            case InfoChannelMessageType.batteryLevel:
              print('Battery level received');
              _batteryManager.setPeerBatteryLevel(decodedMessage['batteryLevel']);
              break;
            case InfoChannelMessageType.openScreenShare:
              print('Screen share request received');
              if (navigatorKey.currentContext != null) {
                navigatorKey.currentContext!.go('/screen_share');
              }
              break;
            case InfoChannelMessageType.webRtcOffer:
              print('WebRTC offer received (already connected)');
              await handleOffer(decodedMessage['sdp'], alreadyConnected: true);
              break;
            case InfoChannelMessageType.webRtcAnswer:
              print('WebRTC answer received (already connected)');
              await handleAnswer(decodedMessage['sdp'], alreadyConnected: true);
              break;
            case InfoChannelMessageType.webRtcAnswerSet:
              print('WebRTC answer set on the peer side');
              _sdpCompleter.complete();
              break;
            case InfoChannelMessageType.shareScreenStop:
              print('Screen share stop message received');
              _connectionManager.setIsScreenSharing(false);
              if (decodedMessage['isSource']) {
                onScreenShareStopRemote();
              } else {
                onScreenShareStopLocal();
              }
              break;
            default:
              print('Unknown message type');
              break;
          }
        };
        _infoChannelReady.complete();
      }
    };
  }

  Future<void> _setupFileChannel() async {
    _fileDataChannel.onDataChannelState = (RTCDataChannelState state) {
      if (state == RTCDataChannelState.RTCDataChannelOpen) {
        print('File channel open');
      }

      final Map<String, String>chunkOkMap = {
        'type': InfoChannelMessageType.chunkArrivedOk.name,
      };
      String chunkOkMessage = json.encode(chunkOkMap);

      final Map <String, String>fileOkMap = {
        'type': InfoChannelMessageType.fileArrivedOk.name,
      };
      String fileOkMessage = json.encode(fileOkMap);

      int receivedBytes = 0;
      Stopwatch fileStopwatch = Stopwatch();
      bool fileTransferInProgress = false;

      _fileDataChannel.onMessage = (RTCDataChannelMessage message) async {
        _selectedFileSink.add(message.binary);
        await _selectedFileSink.flush();
        receivedBytes += message.binary.length;
        _progressBarModel.setProgress(bytesTransferred: receivedBytes);
        await _infoDataChannel.send(RTCDataChannelMessage(chunkOkMessage));
        if (receivedBytes >= _fileSize) {
          await _selectedFileSink.close();
          print("File $_fileName received and saved.");
          double transferSpeed = (_fileSize / fileStopwatch.elapsedMilliseconds) * 1000 / 1000000;
          fileStopwatch.stop();
          fileStopwatch.reset();
          fileTransferInProgress = false;
          print("Transfer speed: $transferSpeed MB/s");
          receivedBytes = 0;
          await _infoDataChannel.send(RTCDataChannelMessage(fileOkMessage));
          if (_fileIndex >= _fileCount - 1) {
            _progressBarModel.hide();
          }
          if (Platform.isAndroid) {
            MediaScanner.loadMedia(path: _selectedFile.path);
          }
        }
      };
    };
  }

  Future<void> _setupClipboardChannel() async {
    _clipboardDataChannel.onDataChannelState = (RTCDataChannelState state) {
      if (state == RTCDataChannelState.RTCDataChannelOpen) {
        print('Clipboard channel open');

        BytesBuilder clipboardDataBuilder = BytesBuilder();

        _clipboardDataChannel.onMessage = (RTCDataChannelMessage message) async {
          Map<String, dynamic> decodedMessage = json.decode(message.text);

          Uint8List chunkData = Uint8List.fromList((decodedMessage['data'] as List).cast<int>());
          clipboardDataBuilder.add(chunkData);
          bool isFinalChunk = decodedMessage['isFinalChunk'];
          print('last chunk: $isFinalChunk');

          if (decodedMessage['isFinalChunk']) {
            Uint8List completeClipboardData = clipboardDataBuilder.toBytes();

            Map<String, dynamic> clipboardData = {
              'type': decodedMessage['type'],
              'data': completeClipboardData,
            };

            await _clipboardManager.setClipboardData(clipboardData);
            print('Clipboard data received: ${decodedMessage['type']}');
            clipboardDataBuilder.clear();
          }
        };
      }
    };
  }

  Future<void> _setupStatusChannel() async {
    //status channel - mel by se inicializovat jako posledni
    _statusDataChannel.onDataChannelState = (RTCDataChannelState state) async{
      if (state == RTCDataChannelState.RTCDataChannelOpen) {
        print('Status channel open');

        _statusDataChannel.onMessage = (RTCDataChannelMessage message) async{
          var connectionState = RtcConnectionState.values.byName(message.text);

          switch (connectionState) {
            case RtcConnectionState.connected:
              await _infoChannelReady.future; //pro jistotu si jeste pockame na info kanal
              String? ip = await NetworkInfo().getWifiIP();
              final Map<String, dynamic> infoMessage = {
                'type': InfoChannelMessageType.deviceInfo.name,
                'deviceType': determineDeviceType(),
                'deviceName': _settingsBox.get('name'),
                'uuid': _settingsBox.get('uuid'),
                'ip': ip,
              };
              _infoDataChannel.send(RTCDataChannelMessage(json.encode(infoMessage)));
              await _deviceInfoReceived.future;
              _batteryManager.sendInitialBatteryLevel();

              print('signaling process finished, peer connection established');
              _connectionManager.setWasConnected(true);
              _connectionManager.setConnectionIsActive(true);
              _connectionCompleter.complete();
              if (navigatorKey.currentContext != null) {
                navigatorKey.currentContext!.go('/home');
              }
              cancelTimer();
              break;

            case RtcConnectionState.disconnected:
              print("disconnecting (request from peer)");
              await _connectionManager.endPeerConnection(disconnectInitiator: false);
              if (navigatorKey.currentContext != null) {
                navigatorKey.currentContext!.go('/devices');
              }
              break;

            default:
              print('Unknown connection state');
              break;
          }
        };

        _statusDataChannel.send(RTCDataChannelMessage(RtcConnectionState.connected.name));
      }
    };
  }

  Future<void> startIceExchange() async {
    print("Starting ICE exchange");
    _peerConnection.onIceCandidate = (candidate) {
      final Map<String, dynamic> iceCandidate = {
        'type': SignalingMessageType.iceCandidate.name,
        'candidate': candidate.toMap(),
      };
      print(candidate.candidate);
      _signalingClient.sendMessage(json.encode(iceCandidate));
    };
  }

  Future<void> sendOffer({required bool alreadyConnected}) async {
    _sdpCompleter = Completer<void>();
    _offer = await _peerConnection.createOffer({});
    await _peerConnection.setLocalDescription(_offer);

    if (_offer.sdp != null) {
      final Map<String, dynamic> offerMessage = {
        'sdp': _offer.sdp!,
      };
      if (alreadyConnected) {
        offerMessage['type'] = InfoChannelMessageType.webRtcOffer.name;
        _infoDataChannel.send(RTCDataChannelMessage(json.encode(offerMessage)));
      } else {
        offerMessage['type'] = SignalingMessageType.webRtcOffer.name;
        _signalingClient.sendMessage(json.encode(offerMessage));
      }
    }
  }

  Future<void> sendAnswer({required bool alreadyConnected}) async {
    _sdpCompleter = Completer<void>();
    _answer = await _peerConnection.createAnswer({});
    await _peerConnection.setLocalDescription(_answer);

    if (_answer.sdp != null) {
      final Map<String, dynamic> answerMessage = {
        'sdp': _answer.sdp!,
      };
      if (alreadyConnected) {
        answerMessage['type'] = InfoChannelMessageType.webRtcAnswer.name;
        _infoDataChannel.send(RTCDataChannelMessage(json.encode(answerMessage)));
      } else {
        answerMessage['type'] = SignalingMessageType.webRtcAnswer.name;
        _signalingClient.sendMessage(json.encode(answerMessage));
      }
    }
  }

  Future<void> handleOffer(String sdp, {required bool alreadyConnected}) async {
    print('Handling offer');
    await _peerConnection.setRemoteDescription(RTCSessionDescription(sdp, 'offer'));
    await sendAnswer(alreadyConnected: alreadyConnected);
  }

  Future<void> handleAnswer(String sdp, {required bool alreadyConnected}) async {
    print('Handling answer');
    await _peerConnection.setRemoteDescription(RTCSessionDescription(sdp, 'answer'));
    final Map<String, dynamic> answerOk = {
      'type': InfoChannelMessageType.webRtcAnswerSet.name
    };
    if (alreadyConnected) {
      _sdpCompleter.complete();
      _infoDataChannel.send(RTCDataChannelMessage(json.encode(answerOk)));
    }
  }

  Future<void> addCandidate(RTCIceCandidate candidate) async {
    await _peerConnection.addCandidate(candidate);
    _peerConnection.onIceGatheringState = (RTCIceGatheringState state) {
      if (state == RTCIceGatheringState.RTCIceGatheringStateComplete) {
        _iceGathering.complete();
        print("Ice gathering complete");
      }
    };
  }

  Future<void> waitForConnectionComplete() async {
    await _connectionCompleter.future;
  }

  Future<void> transferDirectory() async {
    String? directoryPath = await FilePicker.platform.getDirectoryPath();
    if (directoryPath == null) return;

    Directory directory = Directory(directoryPath);
    List<FileSystemEntity> entities = directory.listSync(followLinks: false);

    for (int i = 0; i < entities.length; i++) {
      FileSystemEntity entity = entities[i];
      if (entity is File) {
        _fileReceived = Completer<void>();
        await transferFile(
          file: entity,
          fileSize: entity.lengthSync(),
          fileName: _getDirName(entity.path),
          fileExtension: entity.path.split('.').last,
          fileIndex: i,
          fileCount: entities.length,
        );
        await _fileReceived.future;
      }
    }
  }

  String _getDirName(String path) {
    if (Platform.isWindows) {
      return path.split('\\').last;
    } else {
      return path.split('/').last;
    }
  }

  Future<void> transferFiles() async {
    FilePickerResult? results = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (results == null) return;

    for (int i = 0; i < results.files.length; i++) {
      PlatformFile f = results.files[i];
      if (f.path == null) continue;
      _fileReceived = Completer<void>();
      File file = File(f.path!);
      await transferFile(
          file: file,
          fileSize: f.size,
          fileName: f.name,
          fileExtension: f.extension,
          fileIndex: i,
          fileCount: results.files.length,
      );
      await _fileReceived.future;
    }
  }

  //TODO: lepsi implementace posilani/prijmani souboru, tahle je moc pomala (peak asi 4 MB/s)
  Future<void> transferFile({
    required File file,
    required int fileSize,
    required String fileName,
    required String? fileExtension,
    required int fileIndex,
    required int fileCount,
  }) async {

    print('Sending file: $fileName');

    final Map<String, dynamic> fileInfo = {
      'type': InfoChannelMessageType.fileInfo.name,
      'fileName': fileName,
      'fileSize': fileSize,
      'fileType': fileExtension,
      'fileIndex': fileIndex,
      'fileCount': fileCount,
    };
    _infoDataChannel.send(RTCDataChannelMessage(json.encode(fileInfo)));
    await _fileInfoReceived.future;

    int totalBytesSent = 0;
    const int targetChunkSize = 256 * 1024; // 256 KiB je maximalni velikost RTC zpravy TODO: jaka hodnota je nejlepsi?

    if (!_canSendChunk.isCompleted) {
      _canSendChunk.complete();
    }

    _progressBarModel.show();
    await _progressBarModel.setFileInfo(
      filename: fileName,
      fileIndex: fileIndex,
      fileSize: fileSize,
      totalFiles: fileCount,
      isSender: true,
    );

    List<int> buffer = [];

    await for (List<int> chunk in file.openRead()) {
      buffer.addAll(chunk);
      while (buffer.length >= targetChunkSize) {
        await _canSendChunk.future;
        List<int> dataToSend = buffer.sublist(0, targetChunkSize);
        await _fileDataChannel.send(RTCDataChannelMessage.fromBinary(Uint8List.fromList(dataToSend)));

        _canSendChunk = Completer<void>();

        totalBytesSent += dataToSend.length;
        _progressBarModel.setProgress(bytesTransferred: totalBytesSent);
        //print("Sent $totalBytesSent bytes");
        buffer = buffer.sublist(targetChunkSize);
      }
    }

    if (buffer.isNotEmpty) {
      await _canSendChunk.future;
      await _fileDataChannel.send(RTCDataChannelMessage.fromBinary(Uint8List.fromList(buffer)),);
      _canSendChunk = Completer<void>();

      totalBytesSent += buffer.length;
      //print("Sent final $totalBytesSent bytes");
      buffer.clear();
    }

    _fileInfoReceived = Completer<void>();
    _canSendChunk = Completer<void>();
    if (fileIndex >= fileCount - 1) {
      _progressBarModel.hide();
    }
    print('File sent, completers reset');
  }

  Future<void> setFileInfo(Map<String, dynamic> info) async {
    _fileName = info['fileName'];
    _fileType = info['fileType'];
    _fileSize = info['fileSize'];
    _fileIndex = info['fileIndex'];
    _fileCount = info['fileCount'];
    _selectedDirectory = _settingsBox.get('default_file_path');
    _selectedFile = File('$_selectedDirectory/$_fileName');
    //try {
    //  RandomAccessFile raf = await _selectedFile.open();
    //  await raf.close();
    //} catch (e) {
    //  if (navigatorKey.currentContext == null) return;
    //  ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(SnackBar(
    //    content: ErrorSnackBar(
    //        message: "Nepodařilo se vytvořit soubor $_fileName, vyberte jinou složku pro ukládání souborů"
    //    ),
    //    backgroundColor: Colors.transparent,
    //    behavior: SnackBarBehavior.fixed,
    //    duration: const Duration(seconds: 10),
    //  ));
    //  GlobalOverlayManager().removeProgressBar();
    //  return;
    //}
    _selectedFileSink = _selectedFile.openWrite();

    final Map<String, String> fileOkMap = {
      'type': InfoChannelMessageType.fileInfoArrivedOk.name,
    };

    print("new file info set: $_fileName, $_fileType, $_fileSize");

    await _infoDataChannel.send(RTCDataChannelMessage(json.encode(fileOkMap)));

    _progressBarModel.show();
    await _progressBarModel.setFileInfo(
      filename: _fileName,
      fileIndex: _fileIndex,
      fileSize: _fileSize,
      totalFiles: _fileCount,
      isSender: false,
    );
  }

  Future<void> sendClipboardData() async {
    Map? clipboardData = await _clipboardManager.getClipboardData();
    if (clipboardData == null) return;

    const int targetChunkSize = 16 * 1024;
    final Uint8List clipboardDataBytes = clipboardData['data'];
    final int totalSize = clipboardDataBytes.length;
    final String messageType = clipboardData['type'];

    int bytesSent = 0;

    while (bytesSent < totalSize) {
      //chunk bude mensi nez 16 KiB pokud uz nezbyva dost dat
      int endIndex = (bytesSent + targetChunkSize > totalSize) ? totalSize : (bytesSent + targetChunkSize);
      Uint8List chunkData = clipboardDataBytes.sublist(bytesSent, endIndex);

      Map<String, dynamic> clipboardDataChunk = {
        'type': messageType,
        'data': chunkData,
        'isFinalChunk': endIndex == totalSize //true pokud je to posledni chunk
      };

      _clipboardDataChannel.send(RTCDataChannelMessage(json.encode(clipboardDataChunk)));
      bytesSent += chunkData.length;
    }
  }

  Future<void> sendBatteryLevel(int batteryLevel) async {
    await _connectionCompleter.future;
    final Map<String, dynamic> batteryLevelMessage = {
      'type': InfoChannelMessageType.batteryLevel.name,
      'batteryLevel': batteryLevel,
    };
    _infoDataChannel.send(RTCDataChannelMessage(json.encode(batteryLevelMessage)));
  }

  Future<void> sendScreenShareRequest() async {
    await _connectionCompleter.future;
    final Map<String, dynamic> screenShareRequest = {
      'type': InfoChannelMessageType.openScreenShare.name,
    };
    _infoDataChannel.send(RTCDataChannelMessage(json.encode(screenShareRequest)));
  }

  Future<void> sendScreenShareStopMessage({required bool isSource}) async {
    final Map<String, dynamic> screenShareRequest = {
      'type': InfoChannelMessageType.shareScreenStop.name,
      'isSource': isSource,
    };
    _infoDataChannel.send(RTCDataChannelMessage(json.encode(screenShareRequest)));
  }

  Future<void> sendDisconnectRequest() async {
    await waitForConnectionComplete();
    _statusDataChannel.send(RTCDataChannelMessage(RtcConnectionState.disconnected.name));
  }

  Future<void> closeConnection() async {
    await _peerConnection.close();
    _connectionManager.setConnectionIsActive(false);
    _connectionCompleter = Completer<void>();
    _deviceInfoReceived = Completer<void>();
    _infoChannelReady = Completer<void>();
    _iceGathering = Completer<void>();
    print('peer connection closed');
  }
}