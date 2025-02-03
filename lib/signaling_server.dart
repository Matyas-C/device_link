import 'dart:io';
import 'package:network_info_plus/network_info_plus.dart';
import 'message_type.dart';
import 'dart:async';

class SignalingServer {
  static final SignalingServer _instance = SignalingServer._internal();
  factory SignalingServer() => _instance;
  SignalingServer._internal();

  late final HttpServer _server;
  final List<WebSocket> _connectedClients = [];
  final Completer<void> _serverReady = Completer<void>();

  Future<void> start() async {
    var address = await NetworkInfo().getWifiIP();
    _server = await HttpServer.bind(address, 8080);
    print('Server started on $address:8080');
    _serverReady.complete();

    await for (HttpRequest request in _server) {
      if (WebSocketTransformer.isUpgradeRequest(request)) {
        if (_connectedClients.length >= 2) {
          request.response
            ..statusCode = HttpStatus.serviceUnavailable
            ..write('Connection limit reached')
            ..close();
          continue;
        }
        WebSocket socket = await WebSocketTransformer.upgrade(request);
        _handleWebSocket(socket);
      } else {
        request.response
          ..statusCode = HttpStatus.forbidden
          ..write('WebSocket connections only')
          ..close();
      }
    }
  }

  Future<void> waitForServerReady() => _serverReady.future;

  void _handleWebSocket(WebSocket socket) {
    _connectedClients.add(socket);
    print('Client connected to server');

    if (_connectedClients.length == 2) {
      _connectedClients[0].add(SignalingMessageType.clientConnected.name);
    }

    socket.listen((message) {
      _broadcastMessage(socket, message);
    }, onDone: () {
      _connectedClients.remove(socket);
    });
  }

  void _broadcastMessage(WebSocket sender, String message) {
    for (var client in _connectedClients) {
      if (client != sender) {
        client.add(message);
      }
    }
  }

  Future<void> stop() async {
    await _server.close();
    print('Server stopped');
  }
}
