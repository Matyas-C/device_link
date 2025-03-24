import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

class FolderManager extends ChangeNotifier {
  final Box settingsBox;
  late String defaultFilePath;

  FolderManager({
    required this.settingsBox,
    required this.defaultFilePath,
  });

  void setDefaultFolder({required bool reset}) async {
    if (reset) {
      settingsBox.put('default_file_path', (await getDownloadsDirectory())!.path);
      defaultFilePath = (await getDownloadsDirectory())!.path;
      notifyListeners();
    } else {
      String? path = await FilePicker.platform.getDirectoryPath();
      if (path != null) {
        settingsBox.put('default_file_path', path);
        defaultFilePath = path;
        notifyListeners();
      }
    }
  }
}