import 'dart:async';
import 'dart:convert';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:device_link/signaling_client.dart';
import 'package:device_link/message_type.dart';

class WebRtcConnection {
  static final WebRtcConnection _instance = WebRtcConnection._internal();
  factory WebRtcConnection() => _instance;
  WebRtcConnection._internal();

  final _signalingClient = SignalingClient.instance;
  static WebRtcConnection get instance => _instance;

  late final RTCPeerConnection _peerConnection;
  late final RTCDataChannel _fileDataChannel;
  late final RTCSessionDescription _offer;
  late final RTCSessionDescription _answer;

  Future<void> initialize() async {
    _peerConnection = await createPeerConnection({});

    _peerConnection.onDataChannel = (RTCDataChannel fileDataChannel) {
      print('Data channel created');
      _fileDataChannel = fileDataChannel;
      _handleDataChannels();
    };

    _peerConnection.onConnectionState = (state) {
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
        print('---------');
        print('Connected');
        print('---------');
      }
    };
  }

  //vytvoreni a prvotni nastaveni data kanalu (napr buffer size
  Future<void> initDataChannels() async {
    _fileDataChannel = await _peerConnection.createDataChannel('fileChannel', RTCDataChannelInit());
    print('Data channel created');
    _handleDataChannels();
  }

  Future<void> _handleDataChannels() async {
    //po inicializaci kanalu
    _fileDataChannel.onDataChannelState = (RTCDataChannelState state) {
      if (state == RTCDataChannelState.RTCDataChannelOpen) {
        print('Data channel open');

        //kdyz prijde zprava...
        _fileDataChannel.onMessage = (RTCDataChannelMessage message) {
          print('Received message: ${message.text}');
        };

        //testovaci zpravy
        for (int i = 0; i < 10; i++) {
          _fileDataChannel.send(RTCDataChannelMessage('Hello from Flutter'));
        }
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
}