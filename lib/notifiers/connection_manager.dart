import 'package:device_link/signaling/signaling_client.dart';
import 'package:device_link/web_rtc/webrtc_connection.dart';
import 'package:device_link/web_rtc/connected_device.dart';
import 'package:flutter/cupertino.dart';

class ConnectionManager extends ChangeNotifier {
  bool _wasConnected = false;
  bool _boolConnectionIsActive = false;
  ConnectedDevice? _device;

  bool get wasConnected => _wasConnected;
  bool get connectionIsActive => _boolConnectionIsActive;
  ConnectedDevice? get device => _device;

  Future<void> endPeerConnection({required bool disconnectInitiator}) async {
    await SignalingClient.instance.disconnect();
    await clearDevice();
    if (disconnectInitiator) {
      await WebRtcConnection.instance.sendDisconnectRequest();
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

  Future<void> setDevice(ConnectedDevice? connectedDevice) async{
    _device = connectedDevice;
    notifyListeners();
  }

  Future<void> clearDevice() async{
    _device = null;
    notifyListeners();
  }
}