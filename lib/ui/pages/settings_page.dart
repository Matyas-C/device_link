import 'dart:io';
import 'package:device_link/ui/constants/colors.dart';
import 'package:device_link/ui/pages/common_widgets/common_scroll_page.dart';
import 'package:device_link/ui/pages/common_widgets/raised_container.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hive_ce/hive.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  final _settingsBox = Hive.box('settings');
  late String _defaultFilePath;
  late bool _autoSendClipboard;
  late bool _autoReconnect;

  @override
  void initState() {
    super.initState();
    _defaultFilePath = _settingsBox.get('default_file_path');
    _autoSendClipboard = _settingsBox.get('auto_send_clipboard');
    _autoReconnect = _settingsBox.get('auto_reconnect');
  }

  @override
  Widget build(BuildContext context) {

    return CommonScrollPage(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Nastavení', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          InkWell(
            onTap: () async {
              String? path = await FilePicker.platform.getDirectoryPath();
              if (path != null) {
                _settingsBox.put('default_file_path', path);
                setState(() {
                  _defaultFilePath = path;
                });
              }
            },
            borderRadius: BorderRadius.circular(8),
            child: RaisedContainer(
              color: raisedColor,
              child: Center(
                child: Column(
                  children: [
                    const Text('Výchozí složka pro ukládání souborů:', style: TextStyle(fontSize: 16)),
                    Text(_defaultFilePath, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    const SizedBox(height: 10),
                    const Text('Vybrat složku', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), //TODO: pridat varovani
                  ],
                ),
              ),
            ),
          ),
          Visibility(
            visible: !Platform.isAndroid,
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(8),
              child: RaisedContainer(
                color: raisedColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Automatické posílaní schránky',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Switch(
                      value: _autoSendClipboard,
                      onChanged: (value) {
                        setState(() {
                          _autoSendClipboard = value;
                          _settingsBox.put('auto_send_clipboard', value);
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(8),
            child: RaisedContainer(
              color: raisedColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Automatické znovupřipojení',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Switch(
                    value: _autoReconnect,
                    onChanged: (value) {
                      setState(() {
                        _autoReconnect = value;
                        _settingsBox.put('auto_reconnect', value);
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
