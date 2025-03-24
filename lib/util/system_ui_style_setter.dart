import 'package:device_link/ui/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SystemUiStyleSetter {
  static void setDialogColor() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: secondaryColor,
      statusBarColor: secondaryColor,
    ));
  }

  static void setNormalColor() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: raisedColor,
      statusBarColor: backgroundColor.withOpacity(0.2),
    ));
  }

  static void setNormalMode() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: raisedColor,
      statusBarColor: backgroundColor.withOpacity(0.2),
    ));
  }

  static void setFullScreenMode() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }
}