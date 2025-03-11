import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:device_link/webrtc_connection.dart';

//TODO: aktualizovat home page pred zavrenim dialogu
class EmptyLoadingDialog extends StatefulWidget {
  const EmptyLoadingDialog({super.key});

  static void closeDialog(BuildContext context) {
    Navigator.pop(context);
    context.go('/home');
  }

  @override
  State<EmptyLoadingDialog> createState() => _EmptyLoadingDialogState();
}

class _EmptyLoadingDialogState extends State<EmptyLoadingDialog> {
  Future<void> _closeWhenConnected() async {
    await WebRtcConnection.instance.waitForConnectionComplete();
    if (mounted) {
      EmptyLoadingDialog.closeDialog(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _closeWhenConnected();
    });
    return Scaffold(
        body: Dialog.fullscreen(
          backgroundColor: Colors.blue[900],
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LoadingAnimationWidget.threeRotatingDots(color: Colors.white, size: 70),
              ],
            ),
          ),
        )
    );
  }
}