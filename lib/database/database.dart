import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';

Future<void> initDatabase() async {
  await Hive.initFlutter("PhoneConnect/data");
  await Hive.openBox('settings');
  await Hive.openBox('last_connected_device');
}

class SettingsBox {

  final _settingsBox = Hive.box('settings');

  Future<void> initData() async {
    if (!_settingsBox.containsKey('uuid')) {
      _settingsBox.put('uuid', const Uuid().v4().toString());
    }
    if (!_settingsBox.containsKey('name')) {
      _settingsBox.put('name', 'Zařízení');
    }
    if (!_settingsBox.containsKey('default_file_path')) {
      _settingsBox.put('default_file_path', (await getDownloadsDirectory())!.path);
    }
    if (!_settingsBox.containsKey('auto_send_clipboard')) {
      _settingsBox.put('auto_send_clipboard', false);
    }
    //TODO: pridat?
    //if (!_settingsBox.containsKey('auto_receive_clipboard')) {
    //  _settingsBox.put('auto_receive_clipboard', false);
    //}
    if (!_settingsBox.containsKey('auto_reconnect')) {
      _settingsBox.put('auto_reconnect', false);
    }
  }
}