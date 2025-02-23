import 'dart:async';

import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:super_clipboard/super_clipboard.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:device_link/message_type.dart';

class ClipboardManager {
  final _settingsBox = Hive.box('settings');
  late bool _autoSendClipboard;

  ClipboardManager() {
    _autoSendClipboard = _settingsBox.get('auto_send_clipboard', defaultValue: false);
    _startDatabaseListener();
  }

  //aktualizuje hodnotu autoSendClipboard pokazdy, co se zmeni v databazi
  void _startDatabaseListener() {
    final autoSendListener = _settingsBox.listenable(keys: ['auto_send_clipboard']);
    autoSendListener.addListener(() {
      _autoSendClipboard = _settingsBox.get('auto_send_clipboard');
    });
  }

  Future<Map?> getClipboardData() async {
    final clipboard = SystemClipboard.instance;
    if (clipboard == null) return null;

    final reader = await clipboard.read();
    Map<String, dynamic> dataAnnotated = {};

    if (reader.canProvide(Formats.png)) {
      final bytesBuilder = BytesBuilder();
      final imgReadCompleter = Completer<void>();

      reader.getFile(Formats.png, (file) async {
        final stream = file.getStream();
        await for (var chunk in stream) {
          bytesBuilder.add(chunk);
        }
        imgReadCompleter.complete();
      });
      await imgReadCompleter.future;

      dataAnnotated['type'] = ClipboardMessageType.clipboardImg.name;
      dataAnnotated['data'] = bytesBuilder.toBytes();
      return dataAnnotated;
    }

    if (reader.canProvide(Formats.plainText)) {
      final text = await reader.readValue(Formats.plainText);
      final data = Uint8List.fromList(utf8.encode(text!));
      dataAnnotated['type'] = ClipboardMessageType.clipboardText.name;
      dataAnnotated['data'] = data;
      return dataAnnotated;
    }

    return null;
  }

  Future<void> setClipboardData(Map dataAnnotated) async {
    final clipboard = SystemClipboard.instance;
    if (clipboard == null) return;

    final Uint8List data = Uint8List.fromList(List<int>.from(dataAnnotated['data']));
    final ClipboardMessageType type = ClipboardMessageType.values.byName(dataAnnotated['type']);
    print('Setting clipboard data: $type');
    final item = DataWriterItem();

    switch (type) {
      case ClipboardMessageType.clipboardImg:
        item.add(Formats.png(data));
        print('Image added to clipboard');
        break;
      case ClipboardMessageType.clipboardText:
        item.add(Formats.plainText(utf8.decode(data)));
        print('Text added to clipboard');
        break;
      default:
        return;
    }
    await clipboard.write([item]);
  }

}