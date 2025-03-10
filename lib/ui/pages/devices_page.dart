import 'dart:io';

import 'package:device_link/util/connection_manager.dart';
import 'package:device_link/webrtc_connection.dart';
import 'package:flutter/material.dart';
import 'package:device_link/discovered_devices_list.dart';
import 'package:device_link/udp_discovery.dart';
import '../tiles/discovered_device_tile.dart';
import 'package:device_link/util/device_type.dart';
import 'package:device_link/util/device_icon.dart';
import 'package:device_link/ui/other/device_name_text_controller.dart';
import 'package:device_link/network_connectivity_status.dart';
import 'package:provider/provider.dart';
import 'package:device_link/ui/snackbars/error_snackbar.dart';
import 'package:device_link/ui/notifiers/searching_model.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:device_link/ui/other/absorb_pointer_opacity.dart';

class DevicesPage extends StatefulWidget {
  const DevicesPage({super.key});

  @override
  State<DevicesPage> createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  late NetworkConnectivityStatus _connectivityStatus;
  late UdpDiscovery _udpDiscovery;
  late SearchingModel _searchingNotifier;
  final ConnectionManager _connectionManager = WebRtcConnection.instance.connectionManager;

  @override
  void initState() {
    super.initState();
    UdpDiscovery().onDeviceDiscovered = (device) {
      DiscoveredDevices.addDevice(device);
      if (mounted) {
        setState(() {});
      }
    };

    _connectivityStatus = Provider.of<NetworkConnectivityStatus>(context, listen: false);
    _udpDiscovery = Provider.of<UdpDiscovery>(context, listen: false);
    _searchingNotifier = _udpDiscovery.searchingModel;
  }

  //TODO: disablenout device tile pokud uz je spojeni aktivni
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
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      if (_connectivityStatus.isConnectedToNetwork) {
                        _udpDiscovery.sendDiscoveryBroadcastBatch(30);
                        DiscoveredDevices.clearDevices();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: ErrorSnackBar(
                              message: 'Vaše zařízení není připojeno k síti'
                            ),
                            backgroundColor: Colors.transparent,
                            behavior: SnackBarBehavior.fixed,
                            duration: Duration(seconds: 3),
                          ),
                        );
                      }
                    });
                  },
                  icon: Icon(Icons.repeat, size: 30, color: Colors.grey.shade400),
                )
              ],
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: AbsorbPointerOpacity(
                connectionManager: _connectionManager,
                networkManager: _connectivityStatus,
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
            ),
            const SizedBox(height: 50),
            ListenableBuilder(
              listenable: _searchingNotifier,
              builder: (context, child) {
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      Visibility(
                        visible: DiscoveredDevices.list.isEmpty && !_searchingNotifier.isSearching,
                        child: Text(
                          "Žádná zařízení nebyla nalezena",
                          style: TextStyle(fontSize: 18, color: Colors.grey.shade400),
                        ),
                      ),
                      Visibility(
                        visible: _searchingNotifier.isSearching,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Hledání",
                              style: TextStyle(fontSize: 18, color: Colors.grey.shade400),
                            ),
                            const SizedBox(width: 20),
                            LoadingAnimationWidget.progressiveDots(
                              color: Colors.grey.shade400,
                              size: 30,
                            )
                          ],
                        )
                      ),
                    ],
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}