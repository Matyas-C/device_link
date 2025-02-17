import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:device_link/util/connection_manager.dart';
import 'package:device_link/util/device_type.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:device_link/signaling_client.dart';
import 'package:device_link/message_type.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:hive_ce/hive.dart';
import 'connected_device.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'package:device_link/ui/overlays/overlay_manager.dart';
import 'package:device_link/ui/notifiers/file_transfer_progress_model.dart';

class WebRtcConnection {
  static final WebRtcConnection _instance = WebRtcConnection._internal();
  factory WebRtcConnection() => _instance;
  WebRtcConnection._internal();

  final _deviceBox = Hive.box('device');
  final _signalingClient = SignalingClient.instance;
  static WebRtcConnection get instance => _instance;

  late RTCPeerConnection _peerConnection;
  late RTCDataChannel _statusDataChannel;
  late RTCDataChannel _infoDataChannel;
  late RTCDataChannel _fileDataChannel;
  late RTCSessionDescription _offer;
  late RTCSessionDescription _answer;
  late File _selectedFile;
  late IOSink _selectedFileSink;
  late String _selectedDirectory;
  late String _fileName;
  late String _fileType;
  late int _fileIndex;
  late int _fileCount;
  late int _fileSize;
  final  FileTransferProgressModel _progressBarModel = GlobalOverlayManager().fileTransferProgressModel;
  Completer<void> _connectionCompleter = Completer<void>();
  Completer<void> _canSendChunk = Completer<void>();
  Completer<void> _fileInfoReceived = Completer<void>();
  Completer<void> _fileReceived = Completer<void>();

  Future<void> Function(ConnectedDevice) onDeviceConnected = (device) async {};

  Future<void> initialize() async {
    _peerConnection = await createPeerConnection({});
    int channelCount = 3;
    int channelsReady = 0;

    _peerConnection.onDataChannel = (RTCDataChannel dataChannel) {

      switch (dataChannel.label) {
        case 'statusChannel':
          _statusDataChannel = dataChannel;
          channelsReady++;
          break;
        case 'infoChannel':
          _infoDataChannel = dataChannel;
          channelsReady++;
          break;
        case 'fileChannel':
          _fileDataChannel = dataChannel;
          channelsReady++;
          break;
        default:
          print('Unknown data channel');
          break;
      }

      if (channelsReady == channelCount) {
        _handleDataChannels();
      }
    };
  }

  //vytvoreni a prvotni nastaveni vlastnosti data kanalu
  Future<void> initDataChannels() async {
    _infoDataChannel = await _peerConnection.createDataChannel('infoChannel', RTCDataChannelInit());
    print('Info channel created');

    _fileDataChannel = await _peerConnection.createDataChannel('fileChannel', RTCDataChannelInit());
    print('File channel created');

    _statusDataChannel = await _peerConnection.createDataChannel('statusChannel', RTCDataChannelInit());
    print('Status channel created');

    _handleDataChannels();
  }

  Future<void> _handleDataChannels() async {

    _infoDataChannel.onDataChannelState = (RTCDataChannelState state) {
      if (state == RTCDataChannelState.RTCDataChannelOpen) {
        print('Info channel open');

        _infoDataChannel.onMessage = (RTCDataChannelMessage message) async {
          Map<String, dynamic> decodedMessage = json.decode(message.text);
          var messageType = InfoChannelMessageType.values.byName(decodedMessage['type']);

          switch (messageType) {
            case InfoChannelMessageType.deviceInfo:
              print('Device info received');
              await waitForConnectionComplete();
              var connectedDevice = await ConnectedDevice.create(
                uuid: decodedMessage['uuid'],
                name: decodedMessage['deviceName'],
                deviceType: decodedMessage['deviceType'],
              );
              await onDeviceConnected(connectedDevice);
              break;
            case InfoChannelMessageType.chunkArrivedOk:
              //print('Chunk arrived ok');
              _canSendChunk.complete();
              break;
            case InfoChannelMessageType.fileInfo:
              print('File info received');
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
            default:
              print('Unknown message type');
              break;
          }
        };

        final Map<String, dynamic> infoMessage = {
          'type': InfoChannelMessageType.deviceInfo.name,
          'deviceType': determineDeviceType(),
          'deviceName': _deviceBox.get('name'),
          'uuid': _deviceBox.get('uuid'),
        };
        _infoDataChannel.send(RTCDataChannelMessage(json.encode(infoMessage)));
      }
    };

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
        if (!fileTransferInProgress) {
          fileStopwatch.start();
          fileTransferInProgress = true;
        }
        _selectedFileSink.add(message.binary);
        await _selectedFileSink.flush();
        receivedBytes += message.binary.length;
        //double receivedMb = receivedBytes / 1000000;
        //print("Received $receivedMb MB");
        _progressBarModel.setProgress(bytesTransferred: receivedBytes);
        _infoDataChannel.send(RTCDataChannelMessage(chunkOkMessage));
        if (receivedBytes >= _fileSize) {
          await _selectedFileSink.close();
          print("File $_fileName received and saved.");
          print("Transfer time: ${fileStopwatch.elapsed}");
          double transferSpeed = (_fileSize / fileStopwatch.elapsedMilliseconds) * 1000 / 1000000;
          fileStopwatch.stop();
          fileStopwatch.reset();
          fileTransferInProgress = false;
          print("Transfer speed: $transferSpeed MB/s");
          receivedBytes = 0;
          await _infoDataChannel.send(RTCDataChannelMessage(fileOkMessage));
          GlobalOverlayManager().removeProgressBar();
        }
      };

      //TODO: lepsi implementace posilani/prijmani souboru, tahle je moc pomala (peak asi 4 MB/s)
      //TODO: progress bar
      //TODO: vetsi message size?
    };

    //status channel - mel by se inicializovat jako posledni
    _statusDataChannel.onDataChannelState = (RTCDataChannelState state) {
      if (state == RTCDataChannelState.RTCDataChannelOpen) {
        print('Status channel open');

        _statusDataChannel.onMessage = (RTCDataChannelMessage message) async{
          var connectionState = ConnectionState.values.byName(message.text);

          switch (connectionState) {
            case ConnectionState.connected:
              print('signaling process finished');
              _connectionCompleter.complete();
              break;

            case ConnectionState.disconnected:
              await endPeerConnection(initiator: false);
              break;

            default:
              print('Unknown connection state');
              break;
          }
        };

        _statusDataChannel.send(RTCDataChannelMessage(ConnectionState.connected.name));
      }
    };
  }

  Future<void> startIceExchange() async {
    _peerConnection.onIceCandidate = (candidate) {
      final Map<String, dynamic> iceCandidate = {
        'type': SignalingMessageType.iceCandidate.name,
        'candidate': candidate.toMap(),
      };
      _signalingClient.sendMessage(json.encode(iceCandidate));
    };
  }

  Future<void> sendOffer() async {
    _offer = await _peerConnection.createOffer({});
    await _peerConnection.setLocalDescription(_offer);

    if (_offer.sdp != null) {
      final Map<String, dynamic> offerMessage = {
        'type': SignalingMessageType.webRtcOffer.name,
        'sdp': _offer.sdp!,
      };
      _signalingClient.sendMessage(json.encode(offerMessage));
    }
  }

  Future<void> sendAnswer() async {
    _answer = await _peerConnection.createAnswer({});
    await _peerConnection.setLocalDescription(_answer);

    if (_answer.sdp != null) {
      final Map<String, dynamic> answerMessage = {
        'type': SignalingMessageType.webRtcAnswer.name,
        'sdp': _answer.sdp!,
      };
      _signalingClient.sendMessage(json.encode(answerMessage));
    }
  }

  Future<void> handleOffer(String sdp) async {
    print('Handling offer');
    await _peerConnection.setRemoteDescription(RTCSessionDescription(sdp, 'offer'));
    await sendAnswer();
  }

  Future<void> handleAnswer(String sdp) async {
    print('Handling answer');
    await _peerConnection.setRemoteDescription(RTCSessionDescription(sdp, 'answer'));
  }

  Future<void> addCandidate(RTCIceCandidate candidate) async {
    await _peerConnection.addCandidate(candidate);
  }

  Future<void> waitForConnectionComplete() async {
    await _connectionCompleter.future;
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
          fileCount: results.files.length
      );
      await _fileReceived.future;
    }
  }

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
    const int targetChunkSize = 256 * 1024; // 256 KiB je maximalni velikost RTC zpravy

    if (!_canSendChunk.isCompleted) {
      _canSendChunk.complete();
    }

    List<int> buffer = [];

    await for (List<int> chunk in file.openRead()) {
      buffer.addAll(chunk);
      while (buffer.length >= targetChunkSize) {
        await _canSendChunk.future;
        List<int> dataToSend = buffer.sublist(0, targetChunkSize);
        await _fileDataChannel.send(RTCDataChannelMessage.fromBinary(Uint8List.fromList(dataToSend)));

        _canSendChunk = Completer<void>();

        totalBytesSent += dataToSend.length;
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
    print('File sent, completers reset');
  }

  Future<void> setFileInfo(Map<String, dynamic> info) async {
    _fileName = info['fileName'];
    _fileType = info['fileType'];
    _fileSize = info['fileSize'];
    _fileIndex = info['fileIndex'];
    _fileCount = info['fileCount'];
    _selectedDirectory = _deviceBox.get('default_file_path');
    _selectedFile = File('$_selectedDirectory/$_fileName');
    _selectedFileSink = _selectedFile.openWrite();

    final Map<String, String> fileOkMap = {
      'type': InfoChannelMessageType.fileInfoArrivedOk.name,
    };

    print("new file info set: $_fileName, $_fileType, $_fileSize");

    await _infoDataChannel.send(RTCDataChannelMessage(json.encode(fileOkMap)));

    GlobalOverlayManager().showProgressBar();
    await _progressBarModel.setFileInfo(
      filename: _fileName,
      fileIndex: _fileIndex,
      fileSize: _fileSize,
      totalFiles: _fileCount,
    );
  }

  Future<void> sendDisconnectRequest() async {
    await waitForConnectionComplete();
    _statusDataChannel.send(RTCDataChannelMessage(ConnectionState.disconnected.name));
  }

  Future<void> closeConnection() async {
    await _peerConnection.close();
    _connectionCompleter = Completer<void>();
    print('peer connection closed');
  }
}