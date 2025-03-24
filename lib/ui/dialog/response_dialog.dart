import 'package:device_link/util/system_ui_style_setter.dart';
import 'package:flutter/material.dart';
import 'package:device_link/ui/dialog/empty_loading_dialog.dart';
import 'package:device_link/ui/constants/colors.dart';

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
      SystemUiStyleSetter.setNormalColor();

      Navigator.pop(navigatorKey.currentContext!);
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemUiStyleSetter.setDialogColor();

    return Dialog.fullscreen(
      key: navigatorKey,
      backgroundColor: secondaryColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0), // Add padding to maintain distance from edges
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Požadavek na připojení od\n$name",
                style: const TextStyle(
                    fontSize: 24,
                    color: secondaryTextColor,
                    fontWeight: FontWeight.bold
                ),
                softWrap: true,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FilledButton(
                    onPressed: () {
                      Navigator.pop(context, true);
                      EmptyLoadingDialog.show(context);
                    },
                    child: const Text(
                      "Přijmout",
                      style: TextStyle(
                          fontSize: 18,
                          color: secondaryColor,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                          color: secondaryTextColor,
                          width: 3
                      ),
                    ),
                    child: const Text(
                      "Odmítnout",
                      style: TextStyle(
                          fontSize: 18,
                          color: secondaryTextColor,
                          fontWeight: FontWeight.bold
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