import 'package:device_link/notifiers/file_transfer_progress_model.dart';

//TODO: asi nahranit necim lepsim? (asi ne singletonem)
class GlobalOverlayManager {
  static final GlobalOverlayManager _instance = GlobalOverlayManager._internal();
  factory GlobalOverlayManager() => _instance;
  GlobalOverlayManager._internal();

  final FileTransferProgressModel _fileTransferProgressModel = FileTransferProgressModel();
  FileTransferProgressModel get fileTransferProgressModel => _fileTransferProgressModel;

  void showProgressBar() {
    fileTransferProgressModel.show();
  }

  void removeProgressBar() {
    fileTransferProgressModel.hide();
  }
}
