import 'package:device_link/signaling_client.dart';
import 'package:device_link/webrtc_connection.dart';
import 'package:device_link/connected_device.dart';
import 'package:device_link/ui/pages/home_page_device_connected.dart';

Future<void> endPeerConnection({required bool initiator}) async {
  await SignalingClient.instance.disconnect();
  await ConnectedDevice.clear();
  if (initiator) {
    await WebRtcConnection.instance.sendDisconnectRequest();
  }
  await WebRtcConnection.instance.closeConnection();
}