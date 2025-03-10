import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DisconnectDialog extends StatelessWidget {
  const DisconnectDialog({super.key});

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
              onPressed: () {
                Navigator.of(context).pop(true);
                context.go('/devices');
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