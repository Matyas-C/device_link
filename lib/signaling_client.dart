import 'dart:io';
import 'message_type.dart';

class SignalingClient {
  static final SignalingClient _instance = SignalingClient._internal();
  factory SignalingClient() => _instance;
  SignalingClient._internal();

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
    if (message == SignalingMessageType.clientConnected.name) {
      print('Second client connected to server');
    }
  }

  void disconnect() {
    _socket?.close();
    _socket = null;
  }
}
