class ConnectedDevice {
  static ConnectedDevice? _instance;

  final String uuid;
  final String name;
  final String deviceType;
  final String ip;

  ConnectedDevice._({
    required this.uuid,
    required this.name,
    required this.deviceType,
    required this.ip,
  });

  static ConnectedDevice? get instance => _instance;

  static Future<ConnectedDevice> create({
    required String uuid,
    required String name,
    required String deviceType,
    required String ip,
  }) async {
    return _instance ??= ConnectedDevice._(uuid: uuid, name: name, deviceType: deviceType, ip: ip);
  }

  static Future<void> clear() async {
    _instance = null;
  }
}