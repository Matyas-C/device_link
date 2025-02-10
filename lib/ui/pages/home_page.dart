import 'package:flutter/material.dart';
import 'home_page_no_device.dart';
import 'home_page_device_connected.dart';
import 'package:device_link/connected_device.dart';
import 'package:device_link/webrtc_connection.dart';
import 'package:device_link/ui/dialog/connecting_dialog.dart';

class HomePage extends StatefulWidget {
  final Function(int) navigateTo;

  const HomePage({super.key, required this.navigateTo});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WebRtcConnection.instance.onDeviceConnected = (device) async{
      await widget.navigateTo(0);
      ConnectingDialog.closeDialog();
      return;
    };
  }
  @override
  Widget build(BuildContext context) {
    if (ConnectedDevice.instance != null) {
      return HomePageDeviceConnected(
        navigateTo: widget.navigateTo,
        initialDeviceName: ConnectedDevice.instance!.name,
        uuid: ConnectedDevice.instance!.uuid,
        deviceType: ConnectedDevice.instance!.deviceType,
      );
    } else {
      return HomePageNoDevice(
        navigateTo: widget.navigateTo,
      );
    }
  }
}