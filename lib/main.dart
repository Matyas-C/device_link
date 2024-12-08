import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'ui/base_screen.dart';
import 'util/window_util.dart';
import 'database.dart';
import 'udp_broadcast.dart';
import 'udp_server.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDatabase();

  final deviceBox = DeviceBox();
  deviceBox.initData();

  final udpClient = UdpClient();
  final udpServer = UdpServer();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await setMinSize(400, 500);
  }

  await udpServer.startUdpServer();
  await udpClient.initialize();

  Timer.periodic(const Duration(seconds: 1), (Timer t) => udpClient.sendUdpDiscoveryBroadcast());

  runApp(const PhoneConnect());
}

class PhoneConnect extends StatelessWidget {
  const PhoneConnect({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PhoneConnect',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[900],
      ),
      home: const BaseScreen(),
    );
  }
}