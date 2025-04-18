import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:device_link/ui/dialog/connecting_dialog.dart';
import 'package:device_link/ui/dialog/response_dialog.dart';
import 'package:device_link/notifiers/searching_model.dart';
import 'package:device_link/ui/router.dart';
import 'package:device_link/notifiers/connection_manager.dart';
import 'package:device_link/web_rtc/webrtc_connection.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:device_link/udp_discovery/discovered_devices_list.dart';
import 'package:device_link/util/device_type.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'other_device.dart';
import '../enums/message_type.dart';
import '../signaling/signaling_server.dart';
import '../signaling/signaling_client.dart';
import 'package:flutter/material.dart';
import 'package:device_link/database/last_connected_device.dart';

class UdpDiscovery {
  static final UdpDiscovery _instance = UdpDiscovery._internal();
  factory UdpDiscovery() => _instance;
  UdpDiscovery._internal();

  final _settingsBox = Hive.box('settings');
  final _lastDeviceBox = Hive.box('last_connected_device');
  late final String uuid;
  late final String deviceName;
  late final String? broadcastAddress;
  late final RawDatagramSocket socket;
  late bool _autoReconnect;
  bool _reconnectRequestSent = false;
  final SignalingServer _signalingServer = SignalingServer();
  final SignalingClient _signalingClient = SignalingClient();
  final SearchingModel _searchingModel = SearchingModel();
  final ConnectionManager _connectionManager = WebRtcConnection.instance.connectionManager;

  Function(OtherDevice) onDeviceDiscovered = (device) {};
  late Future<bool?> Function(String uuid, String name, String deviceType) onConnectionRequest;

  final Completer _initialized = Completer<void>();
  Completer get initialized => _initialized;
  SearchingModel get searchingModel => _searchingModel;

  Future<void> initialize() async {
    uuid = _settingsBox.get('uuid');
    deviceName = _settingsBox.get('name');
    broadcastAddress = await NetworkInfo().getWifiBroadcast();
    socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 8081);
    socket.broadcastEnabled = true;
    await startListener(socket);
    _autoReconnect = _settingsBox.get('auto_reconnect');
    _startDatabaseListener();
    _startPeriodicDiscovery();
    _initialized.complete();
  }

  void _startDatabaseListener() async {
    final autoReconnectListener = _settingsBox.listenable(keys: ['auto_reconnect']);
    autoReconnectListener.addListener(() {
      _autoReconnect = _settingsBox.get('auto_reconnect');
    });
  }

  //periodicky hledani zarizeni. pomalejsi, ale bezi porad
  void _startPeriodicDiscovery() async {
    Timer.periodic(const Duration(seconds: 5), (timer) {
      _sendDiscoveryBroadcast();
    });
  }

  Future<void> _sendDiscoveryBroadcast() async {
    final Map<String, dynamic> discoveryMessage = {
      'type': MessageType.dlDiscover.name,
      'uuid': uuid,
      'version': '1.0',
    };

    socket.send(utf8.encode(json.encode(discoveryMessage)), InternetAddress(broadcastAddress!), 8081);
  }

  Future<void> sendDiscoveryBroadcastBatch(int times) async {
    searchingModel.startSearching();
    for (int i = 0; i < times; i++) {
      await _sendDiscoveryBroadcast();
      await Future.delayed(const Duration(milliseconds: 500));
      if (i == times - 1) {
        searchingModel.stopSearching();
      }
    }
  }

  Future<void> sendConnectionRequest({required String ip, required bool isReconnect}) async {
    final Map<String, dynamic> connectionRequestMessage = {
      'type': MessageType.dlConnectionRequest.name,
      'uuid': uuid,
      'version': '1.0',
      'deviceType': determineDeviceType(),
      'name': deviceName,
      'isReconnect': isReconnect,
    };

    socket.send(utf8.encode(json.encode(connectionRequestMessage)), InternetAddress(ip), 8081);
    print('Sent connection request: ${json.encode(connectionRequestMessage)}');
  }

  Future<void> sendCancelRequest(String ip) async {
    final Map<String, dynamic> cancelRequestMessage = {
      'type': MessageType.dlRequestCancel.name,
      'uuid': uuid,
      'version': '1.0',
    };

    _signalingClient.disconnect();
    socket.send(utf8.encode(json.encode(cancelRequestMessage)), InternetAddress(ip), 8081);
    print('Sent cancel request: ${json.encode(cancelRequestMessage)}');
  }

  bool decideReconnection({
    required String messageUuid,
    required String lastDeviceUuid,
    required bool autoReconnect,
    required bool wasConnected,
  }) {
    return !wasConnected && autoReconnect && messageUuid == lastDeviceUuid;
  }


  Future<void> startListener(RawDatagramSocket socket) async {
    socket.listen((RawSocketEvent event) async {
      if (event == RawSocketEvent.read) {
        Datagram? datagram = socket.receive();
        if (datagram != null) {
          String message = utf8.decode(datagram.data);
          Map<String, dynamic> decodedMessage = json.decode(message);
          if (decodedMessage['uuid'] == uuid) return;

          MessageType messageType = MessageType.values.byName(decodedMessage['type']);

          switch (messageType) {
            case MessageType.dlDiscover:
              final Map<String, dynamic> response = {
                'type': MessageType.dlDiscoverResponse.name,
                'uuid': uuid,
                'version': '1.0',
                'deviceType': determineDeviceType(),
                'name': deviceName,
                'ip': await NetworkInfo().getWifiIP(),
              };
              String jsonResponse = json.encode(response);
              socket.send(utf8.encode(jsonResponse), datagram.address, datagram.port);
              break;

            case MessageType.dlDiscoverResponse:
              final OtherDevice device = OtherDevice(
                uuid: decodedMessage['uuid'],
                deviceType: decodedMessage['deviceType'],
                name: decodedMessage['name'],
                ip: decodedMessage['ip'],
              );

              if (!DiscoveredDevices.list.any((d) => d.uuid == device.uuid)) {
                onDeviceDiscovered(device);
              }

              if (!LastConnectedDevice.exists()) break;

              bool canReconnect = decideReconnection(
                  messageUuid: decodedMessage['uuid'],
                  lastDeviceUuid: _lastDeviceBox.get('uuid'),
                  autoReconnect: _autoReconnect,
                  wasConnected: _connectionManager.wasConnected
              );

              if (canReconnect && _lastDeviceBox.get('initiate_connection') && !_reconnectRequestSent) {
                sendConnectionRequest(ip: decodedMessage['ip'], isReconnect: true);
                _reconnectRequestSent = true;
              }

              break;

            case MessageType.dlConnectionRequest:

              bool canReconnect = false;
              if (LastConnectedDevice.exists()) {
                canReconnect = decideReconnection(
                    messageUuid: decodedMessage['uuid'],
                    lastDeviceUuid: _lastDeviceBox.get('uuid'),
                    autoReconnect: _autoReconnect,
                    wasConnected: _connectionManager.wasConnected
                );
              }

              //pokud se muzeme znovupripojit, ani se neukazuje dialog a rovnou prijmame pozadavek na pripojeni
              bool? wasAccepted;
              bool isReconnectRequest = decodedMessage['isReconnect'];
              if (canReconnect && isReconnectRequest) {
                wasAccepted = true;
              } else if (!isReconnectRequest) {
                wasAccepted = await showDialog(
                  context: navigatorKey.currentContext!,
                  builder: (BuildContext context) {
                    return ResponseDialog(
                        uuid: decodedMessage['uuid'],
                        name: decodedMessage['name'],
                        deviceType: decodedMessage['deviceType']
                    );
                  },
                );
              } else {
                wasAccepted = false;
              }

              final Map<String, dynamic> response = {
                'uuid': uuid,
                'version': '1.0',
              };

              if (wasAccepted == null) {
                break;
              }

              bool serverReady = await _signalingServer.isServerReady;
              if (wasAccepted) {
                if (!serverReady) {
                  _signalingServer.start();
                  await _signalingServer.waitForServerReady();
                }
                print('connecting to own signaling server');
                await _signalingClient.connect('ws://${await NetworkInfo().getWifiIP()}:8080');
                response['type'] = MessageType.dlConnectionAccept.name;
                response['wsAddress'] = 'ws://${await NetworkInfo().getWifiIP()}:8080';
              } else {
                response['type'] = MessageType.dlConnectionRefuse.name;
              }

              String jsonResponse = json.encode(response);
              socket.send(utf8.encode(jsonResponse), datagram.address, datagram.port);
              if (isReconnectRequest) {
                await WebRtcConnection.instance.waitForConnectionComplete();
              }
              break;

            case MessageType.dlConnectionAccept:
              print('Connection accepted by peer: ${decodedMessage['uuid']}');
              ConnectingDialog.closeDialog(false);
              print('connecting to peer signaling server');
              await _signalingClient.connect(decodedMessage['wsAddress']);
              break;

            case MessageType.dlConnectionRefuse:
              ConnectingDialog.closeDialog(true);
              print('Connection refused by peer');
              break;

            case MessageType.dlRequestCancel:
              ResponseDialog.closeDialog();
              _signalingClient.disconnect();
              print('Connection request cancelled by peer');
              break;

            default:
              print('Unknown message type received');
          }
        }
      }
    });
  }
}
