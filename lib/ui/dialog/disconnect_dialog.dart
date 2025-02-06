import 'package:flutter/material.dart';

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
                Navigator.of(context).pop(true); // Return true if "Ano" is pressed
              },
              child: const Text('Ano'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Return false if "Ne" is pressed
              },
              child: const Text('Ne'),
            ),
          ],
        ),
      ],
    );
  }
}