/// WebSocket connection status states.
///
/// Represents the current state of the WebSocket connection to the Deriv API.
enum WebSocketStatus {
  /// The WebSocket is disconnected and not attempting to connect.
  disconnected,

  /// The WebSocket is currently attempting to establish a connection.
  connecting,

  /// The WebSocket is successfully connected and ready to send/receive data.
  connected,

  /// The WebSocket encountered an error during connection or communication.
  error,
}
