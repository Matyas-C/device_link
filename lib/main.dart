import 'dart:io';
import 'package:flutter/material.dart';
import 'util/window_util.dart';
import 'database.dart';
import 'udp_discovery.dart';
import 'package:device_link/ui/router.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_link/network_connectivity_status.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initDatabase();
  final settingsBox = SettingsBox();
  settingsBox.initData();

  final udpDiscovery = UdpDiscovery();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await setMinSize(400, 500);
  }

  bool isNetworkConnected;
  final List<ConnectivityResult> conResult = await (Connectivity().checkConnectivity());
  if (conResult.contains(ConnectivityResult.wifi) || conResult.contains(ConnectivityResult.ethernet)) {
    await udpDiscovery.initialize();
    udpDiscovery.sendDiscoveryBroadcastBatch(30);
    isNetworkConnected = true;
  } else {
    isNetworkConnected = false;
  }


  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<NetworkConnectivityStatus>(
          create: (_) => NetworkConnectivityStatus(udpDiscovery, isNetworkConnected),
        ),
        Provider<UdpDiscovery>.value(value: udpDiscovery),
      ],
      child: const PhoneConnect(),
    ),
  );

}

class PhoneConnect extends StatelessWidget {
  const PhoneConnect({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'DeviceLink',
      darkTheme: ThemeData(
        fontFamily: 'Geist',
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