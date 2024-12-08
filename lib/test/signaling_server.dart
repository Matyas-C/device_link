import 'dart:io';
import 'package:network_info_plus/network_info_plus.dart';
import 'server_config.dart';

class SignalingServer {
  late final HttpServer _server;
  final List<WebSocket> _connectedClients = [];

  Future<void> start() async {
    var address = await NetworkInfo().getWifiIP();
    _server = await HttpServer.bind(address, 8080);
    print('Server started on $address:8080');

    await for (HttpRequest request in _server) {
      if (WebSocketTransformer.isUpgradeRequest(request)) {
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

  void _handleWebSocket(WebSocket socket) {
    _connectedClients.add(socket);

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
