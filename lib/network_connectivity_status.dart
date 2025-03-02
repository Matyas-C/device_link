import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_link/udp_discovery.dart';

class NetworkConnectivityStatus extends ChangeNotifier {
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  late bool isConnectedToNetwork;
  final UdpDiscovery _udpDiscovery;

  NetworkConnectivityStatus(this._udpDiscovery, bool isNetworkConnected) {
    Future.microtask(() => initializeNetworkListener());
    isConnectedToNetwork = isNetworkConnected;
  }

  Future<void> initializeNetworkListener() async {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) async {
      if (result.contains(ConnectivityResult.wifi) || result.contains(ConnectivityResult.ethernet)) {
        if (!_udpDiscovery.initialized.isCompleted) {
          await _udpDiscovery.initialize();
        }
        isConnectedToNetwork = true;
        _udpDiscovery.sendDiscoveryBroadcastBatch(30);
      } else {
        isConnectedToNetwork = false;
      }
      notifyListeners();
    });
  }

  @override
  dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }
}
