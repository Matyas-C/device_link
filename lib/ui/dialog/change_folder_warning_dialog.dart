import 'package:device_link/notifiers/folder_manager.dart';
import 'package:device_link/ui/constants/colors.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

class ChangeFolderWarningDialog extends StatefulWidget {
  final Box settingsBox;
  final FolderManager folderManager;

  const ChangeFolderWarningDialog({
    super.key,
    required this.settingsBox,
    required this.folderManager,
  });

  @override
  State<ChangeFolderWarningDialog> createState() => _ChangeFolderWarningDialogState();
}

class _ChangeFolderWarningDialogState extends State<ChangeFolderWarningDialog> {
  late Box _settingsBox;
  late String _defaultFilePath;
  late FolderManager _folderManager;
  
  @override
  void initState() {
    _settingsBox = Hive.box('settings');
    _defaultFilePath = _settingsBox.get('default_file_path');
    _folderManager = widget.folderManager;
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      backgroundColor: raisedColor,
      title: const Text("Změna složky", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: mainTextColor)),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(FluentIcons.warning_24_regular, color: pastelRed, size: 36),
              SizedBox(width: 20),
              Expanded(
                child: Text(
                    "Na některých platformách aplikace nemá přístup ke všem složkám,\npokud narazíte na problémy při přenosu souborů, doporučujeme použít výchozí složku.",
                    style: TextStyle(fontSize: 12, color: darkerTextColor),
                    textAlign: TextAlign.center,
                    softWrap: true
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
        ],
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actionsOverflowAlignment: OverflowBarAlignment.start,
      actions: [
        TextButton(
          onPressed: () async {
            _folderManager.setDefaultFolder(reset: false);
            Navigator.pop(context);
          },
          child: const Text("Vybrat složku"),
        ),
        TextButton(
          onPressed: () {
            _folderManager.setDefaultFolder(reset: true);
            Navigator.pop(context);
          },
          child: const Text("Resetovat na výchozí"),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Zavřít"),
        ),
      ],
    );
  }
}