import 'package:flutter/material.dart';
import 'package:phone_connect/discovered_devices_list.dart';
import 'package:phone_connect/udp_broadcast.dart';
import '../tiles/discovered_device_tile.dart';
import 'package:phone_connect/other_device.dart';

class DevicesPage extends StatefulWidget {
  const DevicesPage({super.key});

  @override
  State<DevicesPage> createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  @override
  void initState() {
    super.initState();
    UdpClient().onDeviceDiscovered = (device) {
      setState(() {
        DiscoveredDevices.addDevice(device);
      });
    };
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 200),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Devices Page",
              style: TextStyle(fontSize: 24),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: DiscoveredDevices.list.length,
                itemBuilder: (context, index) {
                  return DeviceTile(
                    deviceName: DiscoveredDevices.list[index].name,
                    deviceIp: DiscoveredDevices.list[index].ip,
                    deviceType: DiscoveredDevices.list[index].deviceType,
                    uuid: DiscoveredDevices.list[index].uuid,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}