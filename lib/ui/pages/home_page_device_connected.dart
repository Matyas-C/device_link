import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:device_link/util/device_icon.dart';
import 'package:device_link/ui/dialog/disconnect_dialog.dart';
import 'package:device_link/notifiers/connection_manager.dart';
import 'package:device_link/web_rtc/webrtc_connection.dart';
import 'package:go_router/go_router.dart';
import 'package:device_link/ui/overlays/file_transfer_progress_bar.dart';
import 'package:device_link/ui/overlays/overlay_manager.dart';
import 'package:device_link/notifiers/file_transfer_progress_model.dart';
import 'package:device_link/ui/constants/colors.dart';
import 'package:gradient_borders/gradient_borders.dart';
import 'package:device_link/notifiers/battery_manager.dart';

class HomePageDeviceConnected extends StatefulWidget {
  final String uuid;
  final String deviceType;
  final String initialDeviceName;
  final String ip;


  const HomePageDeviceConnected({
    super.key,
    required this.initialDeviceName,
    required this.uuid,
    required this.deviceType,
    required this.ip,
  });

  @override
  State<HomePageDeviceConnected> createState() => _HomePageDeviceConnectedState();
}

class _HomePageDeviceConnectedState extends State<HomePageDeviceConnected> {
  final ConnectionManager _connectionManager = WebRtcConnection.instance.connectionManager;
  final BatteryManager _batteryManager = WebRtcConnection.instance.batteryManager;
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

    return Container(
      color: Colors.transparent,
      child: Center(
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Stack(
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Padding(
                    padding: EdgeInsets.only(top: 100),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          margin: const EdgeInsets.all(8),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: raisedColor,
                            borderRadius: BorderRadius.circular(8),
                            border: GradientBoxBorder(
                                gradient: LinearGradient(
                                    colors: [tertiaryColor.withOpacity(0.5), raisedColor],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight
                                ),
                                width: 3
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const SizedBox(width: 20),
                                  Icon(
                                    getDeviceIcon(widget.deviceType),
                                    color: tertiaryColor,
                                    size: 72,
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: Text(
                                      deviceName,
                                      style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: tertiaryColor
                                      ),
                                      overflow: TextOverflow.fade,
                                      maxLines: 1,
                                      softWrap: false,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  ListenableBuilder(
                                    listenable: _batteryManager,
                                    builder: (BuildContext context, Widget? child) {
                                      return Row(
                                        children: [
                                          Text("${_batteryManager.peerBatteryLevel.toString()}%", style: const TextStyle(fontSize: 16, color: Colors.white)),
                                          const SizedBox(width: 5),
                                          Icon(getBatteryIcon(_batteryManager.peerBatteryLevel), color:Colors.white),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Tooltip(
                                  message: "Informace o zařízení:\nUUID: ${widget.uuid}\nIP: ${widget.ip}",
                                  textStyle: TextStyle(color: Colors.grey.shade400),
                                  decoration: BoxDecoration(
                                    color: raisedColorLight,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(FluentIcons.info_24_regular, color: raisedColorHighlight),
                                ),
                              )
                            ]
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          margin: const EdgeInsets.all(8),
                          child: Ink(
                            padding: const EdgeInsets.fromLTRB(32, 8, 32, 8),
                            decoration: BoxDecoration(
                              color: raisedColor,
                              borderRadius: BorderRadius.circular(8),
                              border: GradientBoxBorder(
                                  gradient: LinearGradient(
                                      colors: [tertiaryColor.withOpacity(0.5), raisedColor],
                                      begin: Alignment.topLeft,
                                      end: const Alignment(0.8, 0.5)
                                  ),
                                  width: 3
                              ),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  margin: const EdgeInsets.all(8),
                                  child: const Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Icon(FluentIcons.send_24_filled, size: 36,),
                                        SizedBox(width: 12),
                                        Text(
                                          'Poslat',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.white
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade500,
                                    borderRadius: BorderRadius.circular(1),
                                  ),
                                  height: 2,
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          WebRtcConnection.instance.transferFiles();
                                        },
                                        borderRadius: BorderRadius.circular(8),
                                        child: Container(
                                          margin: const EdgeInsets.all(8),
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: raisedColorLight,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Center(
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(FluentIcons.document_16_filled),
                                                    SizedBox(width: 8),
                                                    Text(
                                                      'Soubory',
                                                      style: TextStyle(fontSize: 18),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          WebRtcConnection.instance.transferDirectory();
                                        },
                                        borderRadius: BorderRadius.circular(8),
                                        child: Container(
                                          margin: const EdgeInsets.all(8),
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: raisedColorLight,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Center(
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(FluentIcons.folder_16_filled),
                                                    SizedBox(width: 8),
                                                    Text(
                                                      'Složku',
                                                      style: TextStyle(fontSize: 18),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                InkWell(
                                  onTap: () async {
                                    await WebRtcConnection.instance.sendClipboardData();
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    margin: const EdgeInsets.all(8),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: raisedColorLight,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Center(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Icon(FluentIcons.clipboard_16_filled),
                                          SizedBox(width: 8),
                                          Text(
                                            'Schránku',
                                            style: TextStyle(fontSize: 18),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          margin: const EdgeInsets.all(8),
                          child: Ink(
                            padding: const EdgeInsets.fromLTRB(32, 8, 32, 8),
                            decoration: BoxDecoration(
                              color: raisedColor,
                              borderRadius: BorderRadius.circular(8),
                              border: GradientBoxBorder(
                                  gradient: LinearGradient(
                                      colors: [tertiaryColor.withOpacity(0.5), raisedColor],
                                      begin: Alignment.topLeft,
                                      end: const Alignment(0.2, 0.8)
                                  ),
                                  width: 3
                              ),
                            ),
                            child: InkWell(
                              onTap: () {
                                print("tapped");
                              },
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  margin: const EdgeInsets.all(8),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: raisedColorLight,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Center(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Icon(FluentIcons.share_screen_start_16_filled),
                                        SizedBox(width: 8),
                                        Text(
                                          'Sdílet obrazovku',
                                          style: TextStyle(fontSize: 18),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                            ),
                          )
                        ),
                        const SizedBox(height: 20),
                        TextButton.icon(
                          onPressed: () async {
                            await showDialog<bool>(
                              context: context,
                              builder: (BuildContext context) {
                                return DisconnectDialog(connectionManager: _connectionManager);
                              },
                            );
                          },
                          icon: const Icon(Icons.close, color: Colors.red),
                          label: const Text(
                            'Odpojit',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                        const SizedBox(height: 30)
                      ],
                    ),
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
            ),
          ),
        ),
      ),
    );
  }
}