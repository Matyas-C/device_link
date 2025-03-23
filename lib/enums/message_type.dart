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

enum RtcConnectionState {
  connected,
  disconnected,
}

enum InfoChannelMessageType {
  deviceInfo,
  chunkArrivedOk,
  fileInfo,
  fileInfoArrivedOk,
  fileArrivedOk,
  batteryLevel,
  openScreenShare,
  webRtcOffer,
  webRtcAnswer,
  webRtcAnswerSet,
  shareScreenStop
}

enum ClipboardMessageType {
  clipboardText,
  clipboardImg,
}
