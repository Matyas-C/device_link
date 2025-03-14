import 'package:device_link/signaling/signaling_client.dart';
import 'package:device_link/web_rtc/webrtc_connection.dart';
import 'package:device_link/web_rtc/connected_device.dart';
import 'package:flutter/cupertino.dart';

class ConnectionManager extends ChangeNotifier {
  bool _wasConnected = false;
  bool _boolConnectionIsActive = false;

  bool get wasConnected => _wasConnected;
  bool get connectionIsActive => _boolConnectionIsActive;

  Future<void> endPeerConnection({required bool disconnectInitiator}) async {
    await SignalingClient.instance.disconnect();
    await ConnectedDevice.clear();
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
}