import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';

Future<void> initDatabase() async {
  await Hive.initFlutter("PhoneConnect/data");
  await Hive.openBox('device');
}

class DeviceBox {

  final _deviceBox = Hive.box('device');

  Future<void> initData() async {
    if (!_deviceBox.containsKey('uuid')) {
      _deviceBox.put('uuid', const Uuid().v4().toString());
    }
    if (!_deviceBox.containsKey('name')) {
      _deviceBox.put('name', 'Zařízení');
    }
    if (!_deviceBox.containsKey('default_file_path')) {
      _deviceBox.put('default_file_path', (await getDownloadsDirectory())!.path);
    }
  }
}