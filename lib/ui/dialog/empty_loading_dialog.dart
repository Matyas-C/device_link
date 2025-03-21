import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:device_link/web_rtc/webrtc_connection.dart';
import 'package:device_link/ui/constants/colors.dart';

class EmptyLoadingDialog extends StatefulWidget {
  const EmptyLoadingDialog({super.key});

  static bool isDialogOpen = false;
  static bool isShowing() => isDialogOpen;

  static void closeDialog(BuildContext context) {
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      isDialogOpen = false;
      Navigator.of(context, rootNavigator: true).pop();
      context.go('/home');
    }
  }

  static Future<void> show(BuildContext context) {
    isDialogOpen = true;
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const EmptyLoadingDialog(),
    );
  }

  @override
  State<EmptyLoadingDialog> createState() => _EmptyLoadingDialogState();
}

class _EmptyLoadingDialogState extends State<EmptyLoadingDialog> {
  @override
  void initState() {
    super.initState();
    EmptyLoadingDialog.isDialogOpen = true;
    _closeWhenConnected();
  }

  @override
  void dispose() {
    EmptyLoadingDialog.isDialogOpen = false;
    super.dispose();
  }

  Future<void> _closeWhenConnected() async {
    await WebRtcConnection.instance.waitForConnectionComplete();
    if (mounted) {
      EmptyLoadingDialog.closeDialog(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Dialog.fullscreen(
          backgroundColor: secondaryColor,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LoadingAnimationWidget.threeRotatingDots(color: secondaryTextColor, size: 70),
              ],
            ),
          ),
        )
    );
  }
}