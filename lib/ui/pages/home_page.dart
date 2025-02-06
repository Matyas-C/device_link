import 'package:flutter/material.dart';
import 'home_page_no_device.dart';
import 'home_page_device_connected.dart';
import 'package:device_link/connected_device.dart';

class HomePage extends StatefulWidget {
  final Function(int) onNavigate;

  const HomePage({super.key, required this.onNavigate});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    if (ConnectedDevice.instance != null) {
      return HomePageDeviceConnected(
        onNavigate: widget.onNavigate,
      );
    } else {
      return HomePageNoDevice(
        onNavigate: widget.onNavigate,
      );
    }
  }
}