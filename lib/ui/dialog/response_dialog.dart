import 'package:flutter/material.dart';

class ResponseDialog extends StatelessWidget {
  final dynamic uuid;
  final dynamic name;
  final dynamic deviceType;

  const ResponseDialog({super.key, required this.uuid, required this.name, required this.deviceType});

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      backgroundColor: Colors.blue[900],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Požadavek na připojení od $name",
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  child: const Text(
                    "Přijmout",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: const Text(
                    "Odmítnout",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}