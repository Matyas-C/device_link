import 'package:flutter/material.dart';

class DeviceDiscoveredModel extends ChangeNotifier {
  String? _deviceName;
  String? _deviceAddress;

  String? get deviceName => _deviceName;
  String? get deviceAddress => _deviceAddress;

  void setDeviceName(String name) {
    _deviceName = name;
    notifyListeners();
  }

  void setDeviceAddress(String address) {
    _deviceAddress = address;
    notifyListeners();
  }
}