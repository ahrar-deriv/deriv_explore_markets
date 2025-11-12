import 'package:deriv_explore_markets/src/models/tick_data.dart';

/// Wrapper for WebSocket responses from the Deriv API.
///
/// Provides a unified interface for handling different types of responses
/// including ticks, errors, and subscription confirmations.
///
/// Example usage:
/// ```dart
/// final response = WebSocketResponse.fromJson({
///   'msg_type': 'tick',
///   'tick': {
///     'symbol': 'frxEURUSD',
///     'quote': 1.08953,
///     // ... other tick fields
///   }
/// });
///
/// if (response.hasTick) {
///   print('Received tick: ${response.tickData?.quote}');
/// }
///
/// if (response.hasError) {
///   print('Error: ${response.error}');
/// }
/// ```
class WebSocketResponse {
  /// Creates a new [WebSocketResponse] instance.
  WebSocketResponse({
    required this.msgType,
    this.echoReq,
    this.subscription,
    this.tickData,
    this.error,
  });

  /// Creates a [WebSocketResponse] from a JSON message from the Deriv API.
  ///
  /// Automatically parses tick data if present in the response.
  factory WebSocketResponse.fromJson(Map<String, dynamic> json) {
    TickData? tickData;
    if (json.containsKey('tick')) {
      tickData = TickData.fromJson(json);
    }

    return WebSocketResponse(
      msgType: json['msg_type'] as String,
      echoReq: json['echo_req'] as Map<String, dynamic>?,
      subscription: json['subscription'] as Map<String, dynamic>?,
      tickData: tickData,
      error: (json['error'] as Map<String, dynamic>?)?['message'] as String?,
    );
  }

  /// The original request that this response is for (echo from server).
  final Map<String, dynamic>? echoReq;

  /// The type of message (e.g., 'tick', 'active_symbols', 'error').
  final String msgType;

  /// Subscription information if this is a subscription response.
  final Map<String, dynamic>? subscription;

  /// Tick data if this response contains a price update.
  final TickData? tickData;

  /// Error message if this response indicates an error.
  final String? error;

  /// Returns true if this response contains an error.
  bool get hasError => error != null;

  /// Returns true if this response contains tick data.
  bool get hasTick => tickData != null;
}
