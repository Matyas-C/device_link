import 'dart:io';

//TODO: prepsat na enum
String determineDeviceType() {
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    return 'computer';
  } else if (Platform.isAndroid || Platform.isIOS) {
    return 'phone';
  } else {
    return 'unknown';
  }
}