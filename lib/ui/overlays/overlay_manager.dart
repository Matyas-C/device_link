import 'package:flutter/material.dart';
import 'package:device_link/ui/overlays/file_transfer_progress_bar.dart';

class GlobalOverlayManager {
  static final GlobalOverlayManager _instance = GlobalOverlayManager._internal();
  factory GlobalOverlayManager() => _instance;
  GlobalOverlayManager._internal();

  OverlayEntry? _progressOverlay;

  void showProgressBar(BuildContext context) {
    removeProgressBar();

    final overlayState = Overlay.of(context);

    _progressOverlay = OverlayEntry(
      builder: (context) => const Positioned(
        top: 50,
        left: 0,
        right: 0,
        child: Center(child: FileTransferProgressBar()),
      ),
    );

    overlayState.insert(_progressOverlay!);
  }

  void removeProgressBar() {
    _progressOverlay?.remove();
    _progressOverlay = null;
  }
}
