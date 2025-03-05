import 'package:hive_ce/hive.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

class LastConnectedDevice {

  static Future<void> save({
    required String uuid,
    required String lastKnownName,
    required bool initiateConnection
  }) async {
    var box = Hive.box('last_connected_device');
    box.put('uuid', uuid);
    box.put('name', lastKnownName);
    box.put('initiate_connection', initiateConnection);
    print('Saved last connected device: $uuid, $lastKnownName, initConnection: $initiateConnection');
  }

  static bool exists() {
    var box = Hive.box('last_connected_device');
    return box.containsKey('uuid') && box.containsKey('name') && box.containsKey('initiate_connection');
  }
}