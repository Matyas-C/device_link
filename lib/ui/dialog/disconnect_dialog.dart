import 'package:device_link/notifiers/connection_manager.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DisconnectDialog extends StatelessWidget {
  final ConnectionManager connectionManager;

  const DisconnectDialog({
    super.key,
    required this.connectionManager,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Opravdu si přejete odpojit se od zařízení?',
        style: TextStyle(fontSize: 16),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(true);
                context.go('/devices');
                await connectionManager.endPeerConnection(disconnectInitiator: true);
              },
              child: const Text('Ano'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);

              },
              child: const Text('Ne'),
            ),
          ],
        ),
      ],
    );
  }
}