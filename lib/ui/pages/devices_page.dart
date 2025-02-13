import 'package:flutter/material.dart';
import 'package:device_link/discovered_devices_list.dart';
import 'package:device_link/udp_discovery.dart';
import '../tiles/discovered_device_tile.dart';
import 'package:device_link/other_device.dart';
import 'package:device_link/util/device_type.dart';
import 'package:device_link/util/device_icon.dart';
import 'package:device_link/ui/other/device_name_text_controller.dart';

class DevicesPage extends StatefulWidget {
  const DevicesPage({super.key});

  @override
  State<DevicesPage> createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  @override
  void initState() {
    super.initState();
    UdpDiscovery().onDeviceDiscovered = (device) {
      if (!mounted) return;
      setState(() {
        DiscoveredDevices.addDevice(device);
      });
    };
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Toto zařízení",
              style: TextStyle(fontSize: 24),
            ),
            Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    getDeviceIcon(determineDeviceType()),
                    size: 50,
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: TextField(
                      controller: DeviceNameTextController().textController,
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        hintText: "Název zařízení",
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Nalezená zařízení",
                  style: TextStyle(fontSize: 24),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      DiscoveredDevices.clearDevices();
                    });
                  },
                  icon: const Icon(Icons.repeat),
                )
              ],
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