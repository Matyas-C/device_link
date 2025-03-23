import 'package:device_link/ui/animated/blinking_dot.dart';
import 'package:device_link/ui/dialog/select_screen_dialog.dart';
import 'package:device_link/ui/pages/common_widgets/common_scroll_page.dart';
import 'package:device_link/ui/pages/common_widgets/gradient_bordered_container.dart';
import 'package:device_link/ui/pages/common_widgets/gradient_bordered_ink.dart';
import 'package:device_link/ui/pages/common_widgets/icon_container_button_contents.dart';
import 'package:device_link/ui/pages/common_widgets/raised_container.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:device_link/util/device_icon.dart';
import 'package:device_link/ui/dialog/disconnect_dialog.dart';
import 'package:device_link/notifiers/connection_manager.dart';
import 'package:device_link/web_rtc/webrtc_connection.dart';
import 'package:device_link/ui/overlays/file_transfer_progress_bar.dart';
import 'package:device_link/ui/overlays/overlay_manager.dart';
import 'package:device_link/notifiers/file_transfer_progress_model.dart';
import 'package:device_link/ui/constants/colors.dart';
import 'package:device_link/notifiers/battery_manager.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

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
    WebRtcConnection.instance.onScreenShareStopLocal = () {
      _connectionManager.setIsScreenSharing(false);
      _stopScreenShare();
    };

    return Stack(
      alignment: Alignment.center,
      children: [
        CommonScrollPage(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 100),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GradientBorderedContainer(
                      margin: const EdgeInsets.all(16),
                      gradientBegin: Alignment.centerLeft,
                      gradientEnd: Alignment.centerRight,
                      opacity: 0.5,
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
                      child: GradientBorderedInk(
                        gradientBegin: Alignment.topLeft,
                        gradientEnd: const Alignment(0.8, 0.5),
                        opacity: 0.5,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                                    child: const RaisedContainer(
                                      color: raisedColorLight,
                                      child: IconContainerButtonContents(
                                          icon: FluentIcons.document_16_filled,
                                          label: "Soubory"
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      WebRtcConnection.instance.transferDirectory();
                                    },
                                    borderRadius: BorderRadius.circular(8),
                                    child: const RaisedContainer(
                                      color: raisedColorLight,
                                      child: IconContainerButtonContents(
                                          icon: FluentIcons.folder_16_filled,
                                          label: "Složku"
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            InkWell(
                              onTap: () async {
                                await WebRtcConnection.instance.sendClipboardData();
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: const RaisedContainer(
                                color: raisedColorLight,
                                child: Center(
                                  child: IconContainerButtonContents(
                                      icon: FluentIcons.clipboard_16_filled,
                                      label: "Schránku"
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
                      child: GradientBorderedInk(
                        gradientBegin: Alignment.topLeft,
                        gradientEnd: const Alignment(0.2, 0.8),
                        opacity: 0.5,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListenableBuilder(
                          listenable: _connectionManager,
                          builder: (BuildContext context, Widget? child) {
                            return Column(
                              children: [
                                Visibility(
                                  visible: !_connectionManager.isScreenSharing,
                                  child: AbsorbPointer(
                                    absorbing: _connectionManager.screenShareCooldownActive,
                                    child: Opacity(
                                      opacity: _connectionManager.screenShareCooldownActive ? 0.5 : 1,
                                      child: InkWell(
                                          onTap: () {
                                            startScreenShare();
                                          },
                                          borderRadius: BorderRadius.circular(8),
                                          child: const RaisedContainer(
                                            color: raisedColorLight,
                                            child: Center(
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
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: _connectionManager.isScreenSharing,
                                  child: RaisedContainer(
                                      color: raisedColorLight,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Sdílení obrazovky aktivní',
                                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                              ),
                                              SizedBox(width: 20),
                                              BlinkingDot(color: pastelGreen),
                                            ],
                                          ),
                                          AbsorbPointer(
                                            absorbing: _connectionManager.screenShareCooldownActive,
                                            child: Opacity(
                                              opacity: _connectionManager.screenShareCooldownActive ? 0.5 : 1,
                                              child: TextButton(
                                                child: const Text(
                                                  'Zastavit',
                                                  style: TextStyle(fontSize: 12, color: pastelRed),
                                                ),
                                                onPressed: () {
                                                  print("Stopping screen share");
                                                  WebRtcConnection.instance.sendScreenShareStopMessage(isSource: true);
                                                  _connectionManager.startScreenShareCooldown();
                                                  _stopScreenShare(); //TODO: proc to neky na androidu freezne appku?
                                                },
                                              ),
                                            ),
                                          )
                                        ],
                                      )
                                  ),
                                )
                              ],
                            );
                          },
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
                      icon: const Icon(Icons.close, color: pastelRed),
                      label: const Text(
                        'Odpojit',
                        style: TextStyle(color: pastelRed),
                      ),
                    ),
                    const SizedBox(height: 50)
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 30,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: ListenableBuilder(
                  listenable: fileTransferProgressModel,
                  builder: (BuildContext context, Widget? child) {
                    return Visibility(
                      visible: fileTransferProgressModel.isVisible,
                      child: const FileTransferProgressBar(),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> startScreenShare() async {
    print('Starting screen share');
    DesktopCapturerSource? source;
    if (WebRTC.platformIsDesktop) {
      source = await showDialog<DesktopCapturerSource>(
        context: context,
        builder: (context) => ScreenSelectDialog(),
      );
      if (source == null) {
        return;
      } else {
        print("Selected source: ${source.name}");
      }
    }

    Map<String, dynamic> mediaConstraints = {
      'audio': false,
      'video': {
        'mandatory': {
          'maxFrameRate': '30',
        },
      }
    };

    if (source != null) {
      mediaConstraints['video'] = {
        ...mediaConstraints['video'],
        'deviceId': source.id,
      };

    }

    print("starting stream");
    try {
      WebRtcConnection.instance.localStream = await navigator.mediaDevices.getDisplayMedia(mediaConstraints);
    } catch (e) {
      print("Error getting display media"); //uzivatel nejspis nepovolil MediaProjection pro nasi aplikaci
      return;
    }


    for (var track in WebRtcConnection.instance.localStream.getTracks()) {
      await WebRtcConnection.instance.peerConnection.addTrack(track, WebRtcConnection.instance.localStream);
      print("Added track: ${track.kind}");
    }

    print("Stream added to peer connection, creating and sending new offer");
    await WebRtcConnection.instance.sendOffer(alreadyConnected: true);
    await WebRtcConnection.instance.sdpCompleter.future;
    print("New sdp exchange completed, sending screen share request");
    await WebRtcConnection.instance.sendScreenShareRequest();
    _connectionManager.setIsScreenSharing(true);
    _connectionManager.startScreenShareCooldown();
  }

  Future<void> _stopScreenShare() async { //TODO: proc obcas freezne
    print("Stopping screen share");
    try {
      final tracks = WebRtcConnection.instance.localStream.getTracks();
      if (tracks.isNotEmpty) {
        for (final track in tracks) {
          try {
            print("Stopping track: ${track.kind}");
            track.stop();
            print("Stopped track: ${track.kind}");
          } catch (e) {
            print('Error stopping track: $e');
          }
        }
      } else {
        print("No tracks to stop");
      }
      _connectionManager.setIsScreenSharing(false);
        } catch (e) {
      print('Error in stopScreenShare: $e');
    }
    print("Screen share stopped successfully");
  }
}