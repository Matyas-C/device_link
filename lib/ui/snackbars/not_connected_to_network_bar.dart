import 'package:flutter/material.dart';

class NotConnectedToNetworkBar extends StatelessWidget {
  const NotConnectedToNetworkBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(8),
      ),
      constraints: const BoxConstraints(
        maxWidth: 100
      ),
      child: const Padding(
        padding: EdgeInsets.all(12.0),
        child: Center(
          child: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Vaše zařízení není připojeno k síti',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}