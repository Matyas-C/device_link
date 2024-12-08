import 'package:flutter/material.dart';

IconData deviceIcon(String deviceType) {
  if (deviceType.toLowerCase() == 'phone') {
    return Icons.phone_android;
  } else if (deviceType.toLowerCase() == 'computer') {
    return Icons.computer;
  } else {
    return Icons.device_unknown;
  }
}