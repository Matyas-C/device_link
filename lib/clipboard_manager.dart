import 'dart:async';
import 'dart:io';
import 'package:device_link/webrtc_connection.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:super_clipboard/super_clipboard.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:device_link/message_type.dart';
import 'package:clipboard_watcher/clipboard_watcher.dart';

class ClipboardManager with ClipboardListener {
  final _settingsBox = Hive.box('settings');
  late bool _autoSendClipboard;

  ClipboardManager() {
    _autoSendClipboard = _settingsBox.get('auto_send_clipboard', defaultValue: false);
    _startDatabaseListener();
    clipboardWatcher.addListener(this);
    clipboardWatcher.start();
  }

  //aktualizuje hodnotu autoSendClipboard pokazdy, co se zmeni v databazi
  void _startDatabaseListener() async{
    if (Platform.isAndroid) { //na androidu se to neda pouzit
      return;
    }
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

    final Uint8List data = Uint8List.fromList((dataAnnotated['data'] as List).cast<int>());
    final ClipboardMessageType type = ClipboardMessageType.values.byName(dataAnnotated['type']);
    print('Setting clipboard data: $type');
    final item = DataWriterItem(suggestedName: 'clipboardItem');

    switch (type) {
      case ClipboardMessageType.clipboardImg:
        item.add(Formats.png(data));
        print('Image added to clipboard');
        break;
      case ClipboardMessageType.clipboardText:
        item.add(Formats.plainText(utf8.decode(data)));
        print('Text added to clipboard');;
        break;
      default:
        return;
    }
    //TODO: proc super_clipboard haze java error kdyz jsou data nad cca 64KiB?
    await clipboard.write([item]);
  }

  @override
  void onClipboardChanged() async {
    if (_autoSendClipboard && !Platform.isAndroid) {
      WebRtcConnection.instance.sendClipboardData();
    }
  }

  void dispose() {
    clipboardWatcher.removeListener(this);
    clipboardWatcher.stop();
  }
}