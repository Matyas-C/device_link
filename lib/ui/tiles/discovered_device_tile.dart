import 'package:device_link/ui/constants/colors.dart';
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
          color: raisedColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(getDeviceIcon(deviceType), color: Colors.white, size: 40),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    deviceName,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.fade,
                    maxLines: 1,
                    softWrap: false,
                  ),
                  Text(
                    deviceIp,
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                        fontFamily: 'GeistMono'
                    ),
                    overflow: TextOverflow.fade,
                    maxLines: 1,
                    softWrap: false,
                  ),
                  Text(
                    uuid,
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                        fontFamily: 'GeistMono'
                    ),
                    overflow: TextOverflow.fade,
                    maxLines: 1,
                    softWrap: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}