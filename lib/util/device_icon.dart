import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';


IconData getDeviceIcon(String deviceType) {
  if (deviceType.toLowerCase() == 'phone') {
    return FluentIcons.phone_24_regular;
  } else if (deviceType.toLowerCase() == 'computer') {
    return FluentIcons.laptop_24_regular;
  } else {
    return FluentIcons.question_24_regular;
  }
}

IconData getBatteryIcon(int batteryLevel) {
  final batteryIcons = {
    100: FluentIcons.battery_10_24_regular,
    90: FluentIcons.battery_9_24_regular,
    80: FluentIcons.battery_8_24_regular,
    70: FluentIcons.battery_7_24_regular,
    60: FluentIcons.battery_6_24_regular,
    50: FluentIcons.battery_5_24_regular,
    40: FluentIcons.battery_4_24_regular,
    30: FluentIcons.battery_3_24_regular,
    20: FluentIcons.battery_2_24_regular,
    10: FluentIcons.battery_1_24_regular,
    0: FluentIcons.battery_0_24_regular,
  };

  for (int level in batteryIcons.keys) {
    if (batteryLevel >= level) {
      return batteryIcons[level]!;
    }
  }
  return FluentIcons.battery_0_24_regular;
}