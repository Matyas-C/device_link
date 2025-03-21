import 'package:device_link/udp_discovery/udp_discovery.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:device_link/ui/dialog/empty_loading_dialog.dart';
import 'package:device_link/ui/constants/colors.dart';

class ConnectingDialog extends StatelessWidget {
  final String deviceIp;

  const ConnectingDialog({
    super.key,
    required this.deviceIp
  });

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static void closeDialog(bool cancelled) {
    if (navigatorKey.currentContext != null) {
      Navigator.pop(navigatorKey.currentContext!);

      if (!cancelled) {
        EmptyLoadingDialog.show(navigatorKey.currentContext!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      key: navigatorKey,
      backgroundColor: secondaryColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Připojování",
              style: TextStyle(
                  fontSize: 24,
                  color: secondaryTextColor,
                  fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(height: 30),
            LoadingAnimationWidget.threeRotatingDots(color: secondaryTextColor, size: 70),
            const SizedBox(height: 30),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(
                    color: secondaryTextColor,
                    width: 3
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                UdpDiscovery().sendCancelRequest(deviceIp);
              },
              child: const Text(
                "Zrušit",
                style: TextStyle(
                    fontSize: 18,
                    color: secondaryTextColor,
                    fontWeight: FontWeight.bold
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}