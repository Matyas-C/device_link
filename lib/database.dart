import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

Future<void> initDatabase() async {
  await Hive.initFlutter("PhoneConnect/data");
  await Hive.openBox('device');
}

class DeviceBox {

  final _deviceBox = Hive.box('device');

  void initData() {
    if (!_deviceBox.containsKey('uuid')) {
      _deviceBox.put('uuid', const Uuid().v4().toString());
    }
  }
}