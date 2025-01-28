import 'package:flutter/material.dart';

class ResponseDialog extends StatelessWidget {
  final String uuid;
  final String name;
  final String deviceType;

  const ResponseDialog({
    super.key,
    required this.uuid,
    required this.name,
    required this.deviceType
  });

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static void closeDialog() {
    if (navigatorKey.currentContext != null) {
      Navigator.pop(navigatorKey.currentContext!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      key: navigatorKey,
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