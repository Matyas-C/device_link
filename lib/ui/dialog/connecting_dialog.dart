import 'package:device_link/udp_discovery.dart';
import 'package:flutter/material.dart';

class ConnectingDialog extends StatelessWidget {
  final String deviceIp;

  const ConnectingDialog({
    super.key,
    required this.deviceIp
  });

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static void closeDialog() {
    if (navigatorKey.currentContext != null) {
      Navigator.pop(navigatorKey.currentContext!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      key: navigatorKey,
      backgroundColor: Colors.blue[900],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Připojování...",
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 30),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                UdpDiscovery().sendCancelRequest(deviceIp);
              },
              child: const Text(
                "Zrušit",
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.white
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}