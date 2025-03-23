import 'package:device_link/signaling/signaling_client.dart';
import 'package:device_link/web_rtc/webrtc_connection.dart';
import 'package:device_link/web_rtc/connected_device.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';

class ConnectionManager extends ChangeNotifier {
  bool _wasConnected = false;
  bool _boolConnectionIsActive = false;
  bool _isScreenSharing = false;
  bool _screenShareCooldownActive = false;
  late Timer _screenShareCooldownTimer;
  ConnectedDevice? _device;

  bool get wasConnected => _wasConnected;
  bool get connectionIsActive => _boolConnectionIsActive;
  bool get isScreenSharing => _isScreenSharing;
  bool get screenShareCooldownActive => _screenShareCooldownActive;
  ConnectedDevice? get device => _device;

  Future<void> endPeerConnection({required bool disconnectInitiator}) async {
    await SignalingClient.instance.disconnect();
    await clearDevice();
    if (disconnectInitiator) {
      await WebRtcConnection.instance.sendDisconnectRequest();
    }
    if (isScreenSharing) {
      WebRtcConnection.instance.onScreenShareStopLocal;
      setIsScreenSharing(false);
    }
    await WebRtcConnection.instance.closeConnection();
  }

  void setWasConnected(bool wasConnected) {
    _wasConnected = wasConnected;
    notifyListeners();
  }

  void setConnectionIsActive(bool connectionIsActive) {
    _boolConnectionIsActive = connectionIsActive;
    notifyListeners();
  }

  Future<void> setDevice(ConnectedDevice? connectedDevice) async {
    _device = connectedDevice;
    notifyListeners();
  }

  Future<void> clearDevice() async {
    _device = null;
    notifyListeners();
  }

  void setIsScreenSharing(bool isScreenSharing) async {
    _isScreenSharing = isScreenSharing;
    notifyListeners();
  }

  void startScreenShareCooldown() async {
    _screenShareCooldownActive = true;
    notifyListeners();
    _screenShareCooldownTimer = Timer(const Duration(seconds: 5), () {
      _screenShareCooldownActive = false;
      notifyListeners();
    });
  }
}