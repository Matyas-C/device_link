import 'dart:io';

enum DeviceType {
  computer,
  phone,
  unknown
}

String determineDeviceType() {
  if (Platform.isAndroid || Platform.isIOS) {
    return DeviceType.phone.name;
  } else if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
    return DeviceType.computer.name;
  } else {
    return DeviceType.unknown.name;
  }
}