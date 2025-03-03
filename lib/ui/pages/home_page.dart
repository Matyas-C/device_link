import 'package:device_link/ui/dialog/response_dialog.dart';
import 'package:flutter/material.dart';
import 'home_page_no_device.dart';
import 'home_page_device_connected.dart';
import 'package:device_link/connected_device.dart';
import 'package:device_link/webrtc_connection.dart';
import 'package:device_link/ui/dialog/connecting_dialog.dart';
import 'package:device_link/udp_discovery.dart';

class HomePage extends StatefulWidget {

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    if (ConnectedDevice.instance != null) {
      return HomePageDeviceConnected(
        initialDeviceName: ConnectedDevice.instance!.name,
        uuid: ConnectedDevice.instance!.uuid,
        deviceType: ConnectedDevice.instance!.deviceType,
      );
    } else {
      return const HomePageNoDevice();
    }
  }
}