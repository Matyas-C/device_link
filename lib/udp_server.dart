import 'dart:convert';
import 'dart:io';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:phone_connect/util/device_type.dart';
import 'test/server_config.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:hive_ce/hive.dart';
import 'message_type.dart';

final serverConfig = ServerConfig();

class UdpServer {

  final _deviceBox = Hive.box('device');

  Future<void> startUdpServer() async {
    final String uuid = _deviceBox.get('uuid');
    final String? localAddress = await NetworkInfo().getWifiIP();

    final RawDatagramSocket socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 8081);
    print('UDP Server listening on port 8081');

    socket.listen((RawSocketEvent event) {
      if (event == RawSocketEvent.read) {
        Datagram? datagram = socket.receive();
        if (datagram != null) {
          String message = utf8.decode(datagram.data);
          Map<String, dynamic> decodedMessage = json.decode(message);
          if (decodedMessage['uuid'] == uuid) return; //ignoruje zpravy od sebe

          switch (decodedMessage['type']) {
            case MessageType.discover:
              final Map<String, dynamic> response = {
                'type': MessageType.discoverResponse,
                'uuid': uuid,
                'version': '1.0',
                'deviceType': determineDeviceType(),
                'name': 'Device Name',
                'ip': localAddress,
              };
              String jsonResponse = json.encode(response);
              socket.send(utf8.encode(jsonResponse), datagram.address, datagram.port);
              break;

            case MessageType.connectionRequest:
              //#TODO: zkontrolovat, zda chceme prijmout pripojeni, poslat odpoved jen jestli ano
              final Map<String, dynamic> response = {
                'type': MessageType.connectionResponse,
                'uuid': uuid,
                'version': '1.0',
                'wsAddress': 'ws://$localAddress:8080',
              };
              String jsonResponse = json.encode(response);
              socket.send(utf8.encode(jsonResponse), datagram.address, datagram.port);
              break;

            default:
              print('Unknown message type received');
          }
        }
      }
    });
  }
}