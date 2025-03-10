import 'package:flutter/material.dart';
import 'package:device_link/util/device_icon.dart';
import 'package:device_link/ui/dialog/disconnect_dialog.dart';
import 'package:device_link/util/connection_manager.dart';
import 'package:device_link/webrtc_connection.dart';
import 'package:go_router/go_router.dart';
import 'package:device_link/ui/overlays/file_transfer_progress_bar.dart';
import 'package:device_link/ui/overlays/overlay_manager.dart';
import 'package:device_link/ui/notifiers/file_transfer_progress_model.dart';

class HomePageDeviceConnected extends StatefulWidget {
  final String uuid;
  final String deviceType;
  final String initialDeviceName;

  const HomePageDeviceConnected({
    super.key,
    required this.initialDeviceName,
    required this.uuid,
    required this.deviceType,
  });

  @override
  State<HomePageDeviceConnected> createState() => _HomePageDeviceConnectedState();
}

class _HomePageDeviceConnectedState extends State<HomePageDeviceConnected> {
  final ConnectionManager _connectionManager = WebRtcConnection.instance.connectionManager;
  late String deviceName;
  bool autoSendClipboard = false;
  bool progressBarVisible = true;

  @override
  void initState() {
    super.initState();
    deviceName = widget.initialDeviceName;
  }

  @override
  Widget build(BuildContext context) {
    final FileTransferProgressModel fileTransferProgressModel = GlobalOverlayManager().fileTransferProgressModel;

    return Center(
      child: Stack(
        children: [
          ConstrainedBox(
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
                  onTap: () async {
                    await WebRtcConnection.instance.sendClipboardData();
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            'Poslat schránku',
                            style: TextStyle(fontSize: 18),
                          ),
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
                      await _connectionManager.endPeerConnection(disconnectInitiator: true);
                      if (context.mounted) {
                        context.go('/devices');
                      }
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
          Positioned(
            left: 0,
            right: 0,
            bottom: 20,
            child: ListenableBuilder(
              listenable: fileTransferProgressModel,
              builder: (BuildContext context, Widget? child) {
                return Visibility(
                  visible: fileTransferProgressModel.isVisible,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: FileTransferProgressBar(),
                  ),
                );
              },
            ),
          ),
        ],
      )
    );
  }
}