import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'util/window_util.dart';
import 'database.dart';
import 'udp_discovery.dart';
import 'package:device_link/ui/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initDatabase();
  final settingsBox = SettingsBox();
  settingsBox.initData();

  final udpDiscovery = UdpDiscovery();
  await udpDiscovery.initialize();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await setMinSize(400, 500);
  }

  Timer.periodic(const Duration(seconds: 1), (Timer t) => udpDiscovery.sendDiscoveryBroadcast());

  runApp(const PhoneConnect());
}

class PhoneConnect extends StatelessWidget {
  const PhoneConnect({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'DeviceLink',
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: const Color.fromRGBO(0, 171, 247, 1),
      ).copyWith(
        scaffoldBackgroundColor: Colors.grey.shade900,
      ),
      routerConfig: router, // Use the GoRouter instance
    );
  }
}