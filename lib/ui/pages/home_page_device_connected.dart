import 'package:flutter/material.dart';
import 'package:device_link/util/device_icon.dart';
import 'package:device_link/ui/dialog/disconnect_dialog.dart';
import 'package:device_link/util/connection_manager.dart';
import 'package:device_link/webrtc_connection.dart';

class HomePageDeviceConnected extends StatefulWidget {
  final String uuid;
  final String deviceType;
  final String initialDeviceName;

  final Function(int) navigateTo;

  const HomePageDeviceConnected({
    super.key,
    required this.initialDeviceName,
    required this.uuid,
    required this.deviceType,
    required this.navigateTo,
  });

  @override
  State<HomePageDeviceConnected> createState() => _HomePageDeviceConnectedState();
}

class _HomePageDeviceConnectedState extends State<HomePageDeviceConnected> {
  late String deviceName;
  bool autoSendClipboard = false;

  @override
  void initState() {
    super.initState();
    deviceName = widget.initialDeviceName;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              getDeviceIcon(widget.deviceType),
              size: 50,
            ),
            const SizedBox(height: 20),
            Text(
              deviceName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            InkWell(
              onTap: () {
                WebRtcConnection.instance.transferFiles();
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    'Poslat soubor',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: () {
                // TODO: posilani schranky
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        'Poslat schránku',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Automatické posílaní schránky',
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                        Switch(
                          value: autoSendClipboard,
                          onChanged: (value) {
                            setState(() {
                              autoSendClipboard = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: () async {
                bool? result = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return const DisconnectDialog();
                  },
                );
                if (result == true) {
                  await endPeerConnection(initiator: true);
                  await widget.navigateTo(1);
                }
              },
              icon: const Icon(Icons.close, color: Colors.red),
              label: const Text(
                'Odpojit',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}