import 'other_device.dart';

class DiscoveredDevices {
  static final List<OtherDevice> list = [];

  static void addDevice(OtherDevice device) {
    list.add(device);
  }

  static void clearDevices() {
    list.clear();
  }
}