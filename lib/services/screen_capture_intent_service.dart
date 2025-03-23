import 'package:flutter/services.dart';

class ScreenCaptureService {
  static const MethodChannel _channel = MethodChannel('com.example/screen_capture');

  static Future<bool> requestScreenCapture() async {
    try {
      final bool result = await _channel.invokeMethod('requestScreenCapture');
      return result;
    } on PlatformException catch (e) {
      print("Failed to start screen capture: '${e.message}'.");
      return false;
    }
  }
}
