import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'util/window_util.dart';
import 'database/database.dart';
import 'udp_discovery/udp_discovery.dart';
import 'package:device_link/ui/router.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_link/notifiers/network_connectivity_status.dart';
import 'package:provider/provider.dart';
import 'package:device_link/foreground_task/foreground_task_notification.dart';
import 'package:device_link/services/screen_capture_intent_service.dart';

//TODO: otestovat na linuxu
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initDatabase();
  final settingsBox = SettingsBox();
  await settingsBox.initData();

  final udpDiscovery = UdpDiscovery();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await setMinSize(400, 400);
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

 /*
  * Po prvnim spusteni na androidu je potreba zavolat createScreenCaptureIntent() jeste pred spustenim foreground servicu
  * (Jinak to hodi SecurityException)
  * Potom uz ne a funguje to rovnou...
  * Kdo vi proc to tak funguje
  */

  if (Platform.isAndroid) {
    print("creating temporary box");
    Box tempBox = await Hive.openBox('settings');
    bool screenCapIntentGranted = tempBox.get('screen_capture_intent_granted', defaultValue: false);

    if (!screenCapIntentGranted) {
      bool screenCapResult = await ScreenCaptureService.requestScreenCapture();
      if (screenCapResult) {
        print("Screen capture permission granted");
        tempBox.put('screen_capture_intent_granted', true);
      } else {
        print("Screen capture permission denied");
      }
    }
  }


  final ForegroundTaskNotification foregroundTask = ForegroundTaskNotification();
  if (Platform.isAndroid || Platform.isIOS) {
    FlutterForegroundTask.initCommunicationPort();
    await foregroundTask.initService();
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<NetworkConnectivityStatus>(
          create: (_) => NetworkConnectivityStatus(udpDiscovery, isNetworkConnected),
        ),
        Provider<UdpDiscovery>.value(value: udpDiscovery),
        Provider<ForegroundTaskNotification>.value(value: foregroundTask),
      ],
      child: const PhoneConnect(),
    ),
  );


  if (!Platform.isAndroid && !Platform.isIOS) return;

  WidgetsBinding.instance.addPostFrameCallback((_) async {
    ServiceRequestResult result = await foregroundTask.startService();
    if (result is ServiceRequestSuccess) {
      print("Foreground service started");
    } else if (result is ServiceRequestFailure) {
      print("Foreground service failed to start with error: ${result.error}");
    }
  });
}

class PhoneConnect extends StatelessWidget {
  const PhoneConnect({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'DeviceLink',
      darkTheme: ThemeData(
        fontFamily: 'Geist',
        useMaterial3: true,
        brightness: Brightness.dark,
        hoverColor: Colors.white.withOpacity(0.2),
        colorSchemeSeed: const Color.fromRGBO(54, 97, 255, 1),
      ).copyWith(
        scaffoldBackgroundColor: Colors.grey.shade900,
        dividerColor: Colors.transparent,
      ),
      routerConfig: router,
    );
  }
}