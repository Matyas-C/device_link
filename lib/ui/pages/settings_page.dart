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

    return Center(
      child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Nastavení', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            InkWell(
              splashFactory: NoSplash.splashFactory,
              onTap: () async {
                String? path = await FilePicker.platform.getDirectoryPath();
                if (path != null) {
                  _settingsBox.put('default_file_path', path);
                  setState(() {
                    _defaultFilePath = path;
                  });
                }
              },
              child: Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Column(
                    children: [
                      const Text('Výchozí složka pro ukládání souborů:', style: TextStyle(fontSize: 16)),
                      Text(_defaultFilePath, style: const TextStyle(fontSize: 12)),
                      const SizedBox(height: 10),
                      const Text('Vybrat složku', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  ),
                ),
            ),
            InkWell(
              splashFactory: NoSplash.splashFactory,
              onTap: () {},
              child: Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(8),
                ),
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
            InkWell(
              splashFactory: NoSplash.splashFactory,
              onTap: () {},
              child: Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(8),
                ),
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
      ),
    );
  }
}
