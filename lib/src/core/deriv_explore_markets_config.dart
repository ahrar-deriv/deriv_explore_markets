import 'package:deriv_explore_markets/src/theme/market_display_theme.dart';

/// Configuration class for the Deriv Explore Markets package.
///
/// Contains all package-level settings including WebSocket URL,
/// default theme, and other configuration options.
class DerivExploreMarketsConfig {
  /// Creates a new package configuration.
  const DerivExploreMarketsConfig({
    required this.webSocketUrl,
    this.defaultTheme,
    this.autoConnect = true,
    this.maxReconnectAttempts = 5,
    this.reconnectDelay = const Duration(seconds: 3),
  });

  /// WebSocket URL for connecting to Deriv API.
  ///
  /// Must include your app_id:
  /// `wss://ws.derivws.com/websockets/v3?app_id=YOUR_APP_ID`
  final String webSocketUrl;

  /// Default theme to use for all market display widgets.
  ///
  /// If not provided, widgets will use Material Design 3 theme.
  final MarketDisplayTheme? defaultTheme;

  /// Whether to automatically connect to WebSocket on initialization.
  ///
  /// Default: true
  final bool autoConnect;

  /// Maximum number of reconnection attempts.
  ///
  /// Default: 5
  final int maxReconnectAttempts;

  /// Delay between reconnection attempts.
  ///
  /// Default: 3 seconds
  final Duration reconnectDelay;

  /// Creates a copy of this configuration with the specified properties
  /// replaced.
  DerivExploreMarketsConfig copyWith({
    String? webSocketUrl,
    MarketDisplayTheme? defaultTheme,
    bool? autoConnect,
    int? maxReconnectAttempts,
    Duration? reconnectDelay,
  }) {
    return DerivExploreMarketsConfig(
      webSocketUrl: webSocketUrl ?? this.webSocketUrl,
      defaultTheme: defaultTheme ?? this.defaultTheme,
      autoConnect: autoConnect ?? this.autoConnect,
      maxReconnectAttempts: maxReconnectAttempts ?? this.maxReconnectAttempts,
      reconnectDelay: reconnectDelay ?? this.reconnectDelay,
    );
  }
}
