import 'package:flutter/material.dart';

class FileTransferProgressModel extends ChangeNotifier {
  String _filename = "";
  int _fileIndex = 1;
  int _fileSize = 0;
  int _totalFiles = 45;
  String _bytesTransferredFormatted = "";
  String _fileSizeFormatted = "";
  double _progress = 0.0;

  String get filename => _filename;
  int get fileIndex => _fileIndex;
  int get totalFiles => _totalFiles;
  String get bytesTransferredFormatted => _bytesTransferredFormatted;
  String get fileSizeFormatted => _fileSizeFormatted;
  double get progress => _progress;

  Future<void> setFileInfo({
    required String filename,
    required int fileIndex,
    required int fileSize,
    required int totalFiles,
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

    _filename = filename;
    _fileIndex = fileIndex + 1;
    _fileSize = fileSize;
    _fileSizeFormatted = formatFileSize(fileSize);
    _totalFiles = totalFiles;
    notifyListeners();
  }

  void setProgress({
    required int bytesTransferred,
  }) {

    String formatBytes(int bytes) {
      if (_fileSizeFormatted.endsWith("B")) {
        return "$bytes";
      } else if (_fileSizeFormatted.endsWith("KB")) {
        return (bytes / 1024).toStringAsFixed(2);
      } else if (_fileSizeFormatted.endsWith("MB")) {
        return (bytes / (1024 * 1024)).toStringAsFixed(2);
      } else {
        return (bytes / (1024 * 1024 * 1024)).toStringAsFixed(2);
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