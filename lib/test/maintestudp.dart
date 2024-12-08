import 'package:flutter/material.dart';
import 'server_config.dart';
import 'dart:async';
import '../udp_server.dart';
import '../udp_broadcast.dart';

final serverConfig = ServerConfig();
final pcUdpServer = UdpServer();
final phoneUdpClient = UdpClient();

void main() {
  runApp(const MyApp());
  startUdpServer();
}

Future<void> startUdpServer() async {
  //await serverConfig.initialize();
  pcUdpServer.startUdpServer();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UDP Test App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _serverUrl = 'No server found';
  bool _isSearching = false; // To show loading state

  Future<void> _sendUdpBroadcast() async {
    setState(() {
      _isSearching = true;
    });

    await phoneUdpClient.sendUdpDiscoveryBroadcast();

    await Future.delayed(const Duration(milliseconds: 500)); // Wait for server response
    String? serverUrl = serverConfig.getServerUrl();

    setState(() {
      _serverUrl = serverUrl ?? 'No server found';
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UDP Test App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _serverUrl,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 20),
            if (_isSearching)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: _sendUdpBroadcast,
                child: const Text('Send UDP Discovery Broadcast'),
              ),
          ],
        ),
      ),
    );
  }
}
