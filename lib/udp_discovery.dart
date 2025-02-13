import 'dart:convert';
import 'dart:io';
import 'package:device_link/ui/dialog/connecting_dialog.dart';
import 'package:device_link/ui/dialog/response_dialog.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:device_link/discovered_devices_list.dart';
import 'package:device_link/util/device_type.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:hive_ce/hive.dart';
import 'other_device.dart';
import 'message_type.dart';
import 'signaling_server.dart';
import 'signaling_client.dart';
import 'webrtc_connection.dart';

class UdpDiscovery {
  static final UdpDiscovery _instance = UdpDiscovery._internal();
  factory UdpDiscovery() => _instance;
  UdpDiscovery._internal();

  final _deviceBox = Hive.box('device');
  late final String uuid;
  late final String deviceName;
  late final String? broadcastAddress;
  late final RawDatagramSocket socket;
  final SignalingServer _signalingServer = SignalingServer();
  final SignalingClient _signalingClient = SignalingClient();

  Function(OtherDevice) onDeviceDiscovered = (device) {};
  late Future<bool?> Function(String uuid, String name, String deviceType)
      onConnectionRequest;

  Future<void> initialize() async {
    uuid = _deviceBox.get('uuid');
    deviceName = _deviceBox.get('name');
    broadcastAddress = await NetworkInfo().getWifiBroadcast();
    socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 8081);
    await startListener(socket);
  }

  Future<void> sendDiscoveryBroadcast() async {
    final Map<String, dynamic> discoveryMessage = {
      'type': MessageType.dlDiscover.name,
      'uuid': uuid,
      'version': '1.0',
    };

    socket.broadcastEnabled = true;
    socket.send(utf8.encode(json.encode(discoveryMessage)), InternetAddress(broadcastAddress!), 8081); //hazi error kdyz neni internet, pridat nejakej null check
  }



  Future<void> sendConnectionRequest(String ip) async {
    final Map<String, dynamic> connectionRequestMessage = {
      'type': MessageType.dlConnectionRequest.name,
      'uuid': uuid,
      'version': '1.0',
      'deviceType': determineDeviceType(),
      'name': deviceName,
    };

    socket.send(utf8.encode(json.encode(connectionRequestMessage)),
        InternetAddress(ip), 8081);
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
              socket.send(
                  utf8.encode(jsonResponse), datagram.address, datagram.port);
              break;

            case MessageType.dlDiscoverResponse:
              final OtherDevice device = OtherDevice(
                uuid: decodedMessage['uuid'],
                deviceType: decodedMessage['deviceType'],
                name: decodedMessage['name'],
                ip: decodedMessage['ip'],
              );
              if (DiscoveredDevices.list.any((d) => d.uuid == device.uuid))
                return;
              onDeviceDiscovered(device);
              break;

            case MessageType.dlConnectionRequest:
              bool? wasAccepted = await onConnectionRequest(
                  decodedMessage['uuid'],
                  decodedMessage['name'],
                  decodedMessage['deviceType']);

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
                await _signalingClient.connect('ws://${await NetworkInfo().getWifiIP()}:8080');
                response['type'] = MessageType.dlConnectionAccept.name;
                response['wsAddress'] =
                    'ws://${await NetworkInfo().getWifiIP()}:8080';
              } else {
                response['type'] = MessageType.dlConnectionRefuse.name;
              }

              String jsonResponse = json.encode(response);
              socket.send(
                  utf8.encode(jsonResponse), datagram.address, datagram.port);
              break;

            case MessageType.dlConnectionAccept:
              print('Connection accepted by peer: ${decodedMessage['uuid']}');
              await _signalingClient.connect(decodedMessage['wsAddress']);
              break;

            case MessageType.dlConnectionRefuse:
              ConnectingDialog.closeDialog();
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
