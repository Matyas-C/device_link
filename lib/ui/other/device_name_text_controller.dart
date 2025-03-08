import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:hive_ce/hive.dart';

class DeviceNameTextController {
  final TextEditingController textController = TextEditingController();
  final _settingsBox = Hive.box('settings');

  DeviceNameTextController() {
    textController.text = _settingsBox.get('name');

    textController.addListener(() {
      _settingsBox.put('name', textController.text);
    });
  }

  void dispose() {
    textController.dispose();
  }
}

