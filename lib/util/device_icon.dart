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