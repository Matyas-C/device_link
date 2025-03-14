import 'dart:convert';
import 'dart:io';
import '../enums/message_type.dart';
import 'package:device_link/web_rtc/webrtc_connection.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class SignalingClient {
  static final SignalingClient _instance = SignalingClient._internal();
  factory SignalingClient() => _instance;
  SignalingClient._internal();

  static SignalingClient get instance => _instance;
  WebRtcConnection get _webRtcConnection => WebRtcConnection.instance;

  WebSocket? _socket;
  bool get isConnected => _socket != null;

  Future<void> connect(String wsUrl) async {
    try {
      _socket = await WebSocket.connect(wsUrl);

      _socket!.listen(
            (message) {
          _handleMessage(message);
        },
        onError: (error) {
          print('WebSocket error: $error');
          disconnect();
        },
        onDone: () {
          print('WebSocket connection closed');
          disconnect();
        },
      );
    } catch (e) {
      print('Failed to connect: $e');
      rethrow;
    }
  }

  void sendMessage(String message) {
    _socket?.add(message);
  }

  Future<void> _handleMessage(String message) async {
    Map<String, dynamic> decodedMessage = jsonDecode(message);
    SignalingMessageType messageType = SignalingMessageType.values.byName(decodedMessage['type']);

    switch (messageType) {
      case SignalingMessageType.clientConnected:
        print('Second client connected to server');
        await _webRtcConnection.initialize();
        await _webRtcConnection.initDataChannels();
        await _webRtcConnection.sendOffer();
        _webRtcConnection.setLastDevice(connectionInitiator: false);
        break;

      case SignalingMessageType.webRtcOffer:
        print('Received WebRTC offer');
        await _webRtcConnection.initialize();
        await _webRtcConnection.handleOffer(decodedMessage['sdp']);
        await _webRtcConnection.startIceExchange();
        _webRtcConnection.setLastDevice(connectionInitiator: true);
        break;

      case SignalingMessageType.webRtcAnswer:
        print('Received WebRTC answer');
        await _webRtcConnection.handleAnswer(decodedMessage['sdp']);
        await _webRtcConnection.startIceExchange();
        break;

      case SignalingMessageType.iceCandidate:
        RTCIceCandidate candidate = RTCIceCandidate(
          decodedMessage['candidate']['candidate'],
          decodedMessage['candidate']['sdpMid'],
          decodedMessage['candidate']['sdpMLineIndex'],
        );
        await _webRtcConnection.addCandidate(candidate);
        break;
    }
  }

  Future<void> disconnect() async{
    _socket?.close();
    _socket = null;
  }
}