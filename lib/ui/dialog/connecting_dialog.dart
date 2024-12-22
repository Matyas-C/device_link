import 'package:flutter/material.dart';

class ConnectingDialog extends StatelessWidget {
  const ConnectingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      backgroundColor: Colors.blue[900],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Připojování...",
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 30),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                  "Zrušit",
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.white
                  ),
              ),
            )
          ],
        ),
      ),
    );
  }
}