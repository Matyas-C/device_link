import 'package:flutter/material.dart';

class FileTransferProgressModel extends ChangeNotifier {
  String _filename = "";
  int _fileIndex = 1;
  int _fileSize = 0;
  int _totalFiles = 0;
  String _bytesTransferredFormatted = "";
  String _fileSizeFormatted = "";
  double _progress = 0.0;
  bool _isVisible = false;
  bool _isSender = false;
  String _dataUnits = "";

  String get filename => _filename;
  int get fileIndex => _fileIndex;
  int get totalFiles => _totalFiles;
  String get bytesTransferredFormatted => _bytesTransferredFormatted;
  String get fileSizeFormatted => _fileSizeFormatted;
  double get progress => _progress;
  bool get isVisible => _isVisible;
  bool get isSender => _isSender;

  void show() {
    _isVisible = true;
    notifyListeners();
  }

  void hide() {
    _isVisible = false;
    notifyListeners();
  }

  Future<void> setFileInfo({
    required String filename,
    required int fileIndex,
    required int fileSize,
    required int totalFiles,
    required bool isSender,
  }) async {

    String formatFileSize(int fileSize) {
      if (fileSize < 1024) {
        return "$fileSize B";
      } else if (fileSize < 1024 * 1024) {
        return "${(fileSize / 1024).toStringAsFixed(2)} KB";
      } else if (fileSize < 1024 * 1024 * 1024) {
        return "${(fileSize / (1024 * 1024)).toStringAsFixed(2)} MB";
      } else {
        return "${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB";
      }
    }

    String getDataUnits(int fileSize) {
      if (fileSize < 1024) {
        return "B";
      } else if (fileSize < 1024 * 1024) {
        return "KB";
      } else if (fileSize < 1024 * 1024 * 1024) {
        return "MB";
      } else {
        return "GB";
      }
    }

    _filename = filename;
    _fileIndex = fileIndex + 1;
    _fileSize = fileSize;
    _fileSizeFormatted = formatFileSize(fileSize);
    _totalFiles = totalFiles;
    _dataUnits = getDataUnits(fileSize);
    _isSender = isSender;
    notifyListeners();
  }

  void setProgress({
    required int bytesTransferred,
  }) {

    String formatBytes(int bytes) {
      switch (_dataUnits) {
        case "B":
          return "$bytes";
        case "KB":
          return (bytes / 1024).toStringAsFixed(2);
        case "MB":
          return (bytes / (1024 * 1024)).toStringAsFixed(2);
        case "GB":
          return (bytes / (1024 * 1024 * 1024)).toStringAsFixed(2);
        default:
          return "$bytes COOOO";
      }
    }

    _bytesTransferredFormatted = formatBytes(bytesTransferred);
    _progress = _fileSize == 0 ? 0.0 : bytesTransferred / _fileSize.toDouble();
    notifyListeners();
  }

  void resetValues() {
    _filename = "";
    _fileIndex = 1;
    _fileSize = 0;
    _totalFiles = 0;
    _bytesTransferredFormatted = "";
    _fileSizeFormatted = "";
    _progress = 0.0;
    notifyListeners();
  }
}