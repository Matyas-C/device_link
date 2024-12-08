class ServerConfig {
  static final ServerConfig _instance = ServerConfig._internal();
  factory ServerConfig() => _instance;
  ServerConfig._internal();

  String? serverUrl;

  String? getServerUrl() {
    return serverUrl;
  }

  void setServerUrl(String url) {
    serverUrl = url;
  }
}
