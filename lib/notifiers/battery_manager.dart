import 'dart:async';
import 'package:device_link/web_rtc/webrtc_connection.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/material.dart';


//TODO: co se stane kdyz zarizeni nema baterku?
class BatteryManager extends ChangeNotifier {
  late final Battery _battery;
  late int _peerBatteryLevel;
  StreamSubscription<int>? _batterySubscription;

  BatteryManager() {
    _battery = Battery();
    _peerBatteryLevel = 0;
    _startPeriodicSubscription();
  }

  Future<void> sendInitialBatteryLevel() async {
    await WebRtcConnection.instance.sendBatteryLevel(await _battery.batteryLevel);
  }

  Future<void> _startPeriodicSubscription() async {
    _batterySubscription = Stream.periodic(const Duration(seconds: 5))
        .asyncMap((_) => _battery.batteryLevel)
        .distinct()
        .listen((level) {
      WebRtcConnection.instance.sendBatteryLevel(level);
    });
  }

  void setPeerBatteryLevel(int level) {
    _peerBatteryLevel = level;
    notifyListeners();
  }

  int get peerBatteryLevel => _peerBatteryLevel;
}