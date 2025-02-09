import 'dart:async';
import 'dart:convert';
import 'package:device_link/util/connection_manager.dart';
import 'package:device_link/util/device_type.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:device_link/signaling_client.dart';
import 'package:device_link/message_type.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:hive_ce/hive.dart';
import 'connected_device.dart';

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
  late RTCSessionDescription _offer;
  late RTCSessionDescription _answer;
  Completer<void> _connectionCompleter = Completer<void>();

  Future<void> Function(ConnectedDevice) onDeviceConnected = (device) async {};

  Future<void> initialize() async {
    _peerConnection = await createPeerConnection({});
    int channelCount = 2;
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
        default:
          print('Unknown data channel');
          break;
      }

      if (channelsReady == channelCount) {
        _handleDataChannels();
      }
    };

    /*
     * _peerConnection.onConnectionState = (state) {
     *   if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
     *    print('Connected');
     *   }
     * };
     */
  }

  //vytvoreni a prvotni nastaveni data kanalu (napr buffer size)
  Future<void> initDataChannels() async {
    _infoDataChannel = await _peerConnection.createDataChannel('infoChannel', RTCDataChannelInit());
    print('Info channel created');
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