import 'dart:convert';
import 'dart:io';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:phone_connect/discovered_devices_list.dart';
import 'package:phone_connect/util/device_type.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:hive_ce/hive.dart';
import 'other_device.dart';
import 'message_type.dart';

class UdpDiscovery {
  static final UdpDiscovery _instance = UdpDiscovery._internal();
  factory UdpDiscovery() => _instance;
  UdpDiscovery._internal();

  final _deviceBox = Hive.box('device');
  late final String uuid;
  late final String? broadcastAddress;
  late final RawDatagramSocket socket;

  Function(OtherDevice) onDeviceDiscovered = (device) {};

  Future<void> initialize() async {
    uuid = _deviceBox.get('uuid');
    broadcastAddress = await NetworkInfo().getWifiBroadcast();
    socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 8081);
    startListener(socket);
  }

  Future<void> sendDiscoveryBroadcast() async {
    final Map<String, dynamic> discoveryMessage = {
      'type': MessageType.discover,
      'uuid': uuid,
      'version': '1.0',
    };

    socket.broadcastEnabled = true;
    socket.send(utf8.encode(json.encode(discoveryMessage)), InternetAddress(broadcastAddress!), 8081);
  }

  Future<void> sendConnectionRequest(String ip) async {
    final Map<String, dynamic> connectionRequestMessage = {
      'type': MessageType.connectionRequest,
      'uuid': uuid,
      'version': '1.0',
      'deviceType': determineDeviceType(),
      'name': 'Device Name',
    };

    socket.send(utf8.encode(json.encode(connectionRequestMessage)), InternetAddress(ip), 8081);
    print('Sent connection request: ${json.encode(connectionRequestMessage)}');
  }

  void startListener(RawDatagramSocket socket) {
    socket.listen((RawSocketEvent event) async {
      if (event == RawSocketEvent.read) {
        Datagram? datagram = socket.receive();
        if (datagram != null) {
          String message = utf8.decode(datagram.data);
          Map<String, dynamic> decodedMessage = json.decode(message);
          if (decodedMessage['uuid'] == uuid) return;

          switch (decodedMessage['type']) {
            case MessageType.discover:
              final Map<String, dynamic> response = {
                'type': MessageType.discoverResponse,
                'uuid': uuid,
                'version': '1.0',
                'deviceType': determineDeviceType(),
                'name': 'Device Name',
                'ip': await NetworkInfo().getWifiIP(),
              };
              String jsonResponse = json.encode(response);
              socket.send(utf8.encode(jsonResponse), datagram.address, datagram.port);
              break;

            case MessageType.discoverResponse:
              final OtherDevice device = OtherDevice(
                uuid: decodedMessage['uuid'],
                deviceType: decodedMessage['deviceType'],
                name: decodedMessage['name'],
                ip: decodedMessage['ip'],
              );
              if (DiscoveredDevices.list.any((d) => d.uuid == device.uuid)) return;
              onDeviceDiscovered(device);
              break;

            case MessageType.connectionRequest:
              final Map<String, dynamic> response = {
                'type': MessageType.connectionResponse,
                'uuid': uuid,
                'version': '1.0',
                'wsAddress': 'ws://${await NetworkInfo().getWifiIP()}:8080',
              };
              String jsonResponse = json.encode(response);
              socket.send(utf8.encode(jsonResponse), datagram.address, datagram.port);
              break;

            case MessageType.connectionResponse:
              print('Connection accepted by peer: ${decodedMessage['accept']}');
              break;

            default:
              print('Unknown message type received');
          }
        }
      }
    });
  }
}