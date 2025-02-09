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
  disconnected,
}

enum InfoChannelMessageType {
  deviceInfo,
}
