import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:hive_ce/hive.dart';

class DeviceNameTextController {
  final TextEditingController textController = TextEditingController();
  final _deviceBox = Hive.box('device');

  DeviceNameTextController() {
    textController.text = _deviceBox.get('name');

    textController.addListener(() {
      _deviceBox.put('name', textController.text);
    });
  }

  void dispose() {
    textController.dispose();
  }
}

