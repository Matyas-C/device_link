import 'package:device_link/notifiers/connection_manager.dart';
import 'package:device_link/ui/dialog/response_dialog.dart';
import 'package:flutter/material.dart';
import 'home_page_no_device.dart';
import 'home_page_device_connected.dart';
import 'package:device_link/web_rtc/connected_device.dart';
import 'package:device_link/web_rtc/webrtc_connection.dart';
import 'package:device_link/ui/dialog/connecting_dialog.dart';
import 'package:device_link/udp_discovery/udp_discovery.dart';

//TODO: updatnout kdyz se pripoji zarizeni (nejakej normalni state management)
class HomePage extends StatefulWidget {

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ConnectionManager _connectionManager = WebRtcConnection.instance.connectionManager;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _connectionManager,
      builder: (context, Widget? child) {
        if (_connectionManager.device != null) {
          return HomePageDeviceConnected(
            initialDeviceName: _connectionManager.device!.name,
            uuid: _connectionManager.device!.uuid,
            deviceType: _connectionManager.device!.deviceType,
            ip: _connectionManager.device!.ip,
          );
        } else {
          return const HomePageNoDevice();
        }
      },
    );
  }
}