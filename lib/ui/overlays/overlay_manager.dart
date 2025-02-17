import 'package:flutter/material.dart';
import 'package:device_link/ui/overlays/file_transfer_progress_bar.dart';
import 'package:device_link/ui/notifiers/file_transfer_progress_model.dart';
import 'package:device_link/ui/router.dart';

class GlobalOverlayManager {
  static final GlobalOverlayManager _instance = GlobalOverlayManager._internal();
  factory GlobalOverlayManager() => _instance;
  GlobalOverlayManager._internal();

  final FileTransferProgressModel _fileTransferProgressModel = FileTransferProgressModel();
  final FileTransferProgressBar _fileTransferProgressBar = const FileTransferProgressBar();
  FileTransferProgressModel get fileTransferProgressModel => _fileTransferProgressModel;
  FileTransferProgressBar get fileTransferProgressBar => _fileTransferProgressBar;
  OverlayEntry? _progressOverlay;

  showProgressBar() {
    removeProgressBar();

    final overlayState = navigatorKey.currentState?.overlay;

    _progressOverlay = OverlayEntry(
      builder: (context) => const Center(
        child: FileTransferProgressBar(),
      ),
    );

    overlayState?.insert(_progressOverlay!);
  }

  void removeProgressBar() {
    _progressOverlay?.remove();
    _progressOverlay = null;
  }
}
