class ConnectedDevice {
  static ConnectedDevice? _instance;

  final String uuid;
  final String name;
  final String deviceType;

  ConnectedDevice._({
    required this.uuid,
    required this.name,
    required this.deviceType,
  });

  static ConnectedDevice? get instance => _instance;

  static ConnectedDevice create({
    required String uuid,
    required String name,
    required String deviceType,
  }) => _instance ??= ConnectedDevice._(uuid: uuid, name: name, deviceType: deviceType);

  static void clear() => _instance = null;
}