import 'package:flutter/material.dart';

class HomePageDeviceConnected extends StatelessWidget {
  final Function(int) onNavigate;

  const HomePageDeviceConnected({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Zařízení připojeno',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}