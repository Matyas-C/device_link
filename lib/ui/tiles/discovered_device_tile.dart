import 'package:flutter/material.dart';
import 'package:device_link/util/device_icon.dart';
import 'package:device_link/ui/dialog/connecting_dialog.dart';
import 'package:device_link/udp_discovery.dart';

class DeviceTile extends StatelessWidget {
  final String deviceName;
  final String deviceIp;
  final String deviceType;
  final String uuid;

  const DeviceTile({
    super.key,
    required this.deviceName,
    required this.deviceIp,
    required this.deviceType,
    required this.uuid,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return ConnectingDialog(deviceIp: deviceIp);
            }
        );
        UdpDiscovery().sendConnectionRequest(ip: deviceIp, isReconnect: false);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black45, // Dark blue background
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(getDeviceIcon(deviceType), color: Colors.white, size: 40), // Larger icon
            const SizedBox(width: 10), // Space between icon and text
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  deviceName,
                  style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(
                  deviceIp,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade300),
                ),
                Text(
                  uuid,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade300),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}