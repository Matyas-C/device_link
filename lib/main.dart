import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'ui/base_screen.dart';
import 'util/window_util.dart';
import 'database.dart';
import 'udp_discovery.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDatabase();

  final deviceBox = DeviceBox();
  deviceBox.initData();

  final udpDiscovery = UdpDiscovery();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await setMinSize(400, 500);
  }
  await udpDiscovery.initialize();

  Timer.periodic(const Duration(seconds: 1), (Timer t) => udpDiscovery.sendDiscoveryBroadcast());

  runApp(const PhoneConnect());
}

class PhoneConnect extends StatelessWidget {
  const PhoneConnect({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DeviceLink',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[900],
      ),
      home: const BaseScreen(),
    );
  }
}