import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

Future<void> setMinSize(double width, double height) async {
    WidgetsFlutterBinding.ensureInitialized();
    await windowManager.ensureInitialized();
    windowManager.setMinimumSize(Size(width, height));
}