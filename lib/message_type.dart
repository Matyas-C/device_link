enum MessageType {
  dlDiscover,
  dlDiscoverResponse,
  dlConnectionRequest,
  dlConnectionAccept,
  dlConnectionRefuse,
  dlRequestCancel,
}

enum SignalingMessageType {
  clientConnected,
  webRtcOffer,
  webRtcAnswer,
  iceCandidate,
}

enum ConnectionState {
  connected,
}

enum infoChannelMessageType {
  deviceInfo,
}
