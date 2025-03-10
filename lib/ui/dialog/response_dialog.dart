import 'package:flutter/material.dart';
import 'package:device_link/ui/dialog/empty_loading_dialog.dart';

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
      child: Padding(
        padding: const EdgeInsets.all(16.0), // Add padding to maintain distance from edges
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Požadavek na připojení od\n$name",
                style: const TextStyle(fontSize: 24),
                softWrap: true,
                maxLines: 3, // Adjust maxLines as needed
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, true);
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return const EmptyLoadingDialog();
                          });
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
      ),
    );
  }
}