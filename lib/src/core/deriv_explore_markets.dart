import 'package:deriv_explore_markets/src/core/deriv_explore_markets_config.dart';
import 'package:deriv_explore_markets/src/services/websocket_service.dart';
import 'package:deriv_explore_markets/src/theme/market_display_theme.dart';
import 'package:flutter/material.dart';

/// Main entry point for the Deriv Explore Markets package.
///
/// Initialize this package once in your app's main() function before using
/// any market display widgets.
///
/// Example:
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///
///   await DerivExploreMarkets.initialize(
///     DerivExploreMarketsConfig(
///       webSocketUrl: 'wss://ws.derivws.com/websockets/v3?app_id=YOUR_APP_ID',
///       defaultTheme: myCustomTheme,
///     ),
///   );
///
///   runApp(MyApp());
/// }
/// ```
class DerivExploreMarkets {

  DerivExploreMarkets._();
  static DerivExploreMarkets? _instance;
  static DerivExploreMarketsConfig? _config;
  static WebSocketService? _websocketService;

  /// Returns the singleton instance.
  static DerivExploreMarkets get instance {
    if (_instance == null) {
      throw StateError(
        'DerivExploreMarkets has not been initialized. '
        'Call DerivExploreMarkets.initialize() in main() before using '
        'the package.',
      );
    }
    return _instance!;
  }

  /// Returns the current configuration.
  static DerivExploreMarketsConfig get config {
    if (_config == null) {
      throw StateError(
        'DerivExploreMarkets has not been initialized. '
        'Call DerivExploreMarkets.initialize() in main() before using '
        'the package.',
      );
    }
    return _config!;
  }

  /// Returns the shared WebSocket service.
  static WebSocketService get websocketService {
    if (_websocketService == null) {
      throw StateError(
        'DerivExploreMarkets has not been initialized. '
        'Call DerivExploreMarkets.initialize() in main() before using '
        'the package.',
      );
    }
    return _websocketService!;
  }

  /// Checks if the package has been initialized.
  static bool get isInitialized => _instance != null;

  /// Initializes the Deriv Explore Markets package.
  ///
  /// Must be called once before using any widgets from this package.
  ///
  /// Example:
  /// ```dart
  /// await DerivExploreMarkets.initialize(
  ///   DerivExploreMarketsConfig(
  ///     webSocketUrl: 'wss://ws.derivws.com/websockets/v3?app_id=YOUR_APP_ID',
  ///     defaultTheme: customTheme,
  ///     autoConnect: true,
  ///   ),
  /// );
  /// ```
  static Future<void> initialize(DerivExploreMarketsConfig config) async {
    if (_instance != null) {
      debugPrint(
        'DerivExploreMarkets is already initialized. '
        'Call dispose() first if you want to reinitialize.',
      );
      return;
    }

    _config = config;
    _instance = DerivExploreMarkets._();
    _websocketService = WebSocketService();

    if (config.autoConnect) {
      await _websocketService!.connect(config.webSocketUrl);
    }
  }

  /// Reconnects the WebSocket with the current configuration.
  ///
  /// Useful for manual reconnection or after network changes.
  static Future<bool> reconnect() async {
    if (!isInitialized) {
      throw StateError('DerivExploreMarkets has not been initialized.');
    }

    await _websocketService!.disconnect();
    return _websocketService!.connect(_config!.webSocketUrl);
  }

  /// Disconnects the WebSocket without disposing the instance.
  ///
  /// You can reconnect later using [reconnect()].
  static Future<void> disconnect() async {
    if (!isInitialized) return;
    await _websocketService?.disconnect();
  }

  /// Disposes the package instance and all resources.
  ///
  /// Call this when you want to completely reset the package state.
  /// You'll need to call [initialize()] again before using the package.
  static Future<void> dispose() async {
    if (!isInitialized) return;

    await _websocketService?.dispose();
    _websocketService = null;
    _config = null;
    _instance = null;
  }

  /// Gets the default theme from configuration, or null if not set.
  static MarketDisplayTheme? getDefaultTheme(BuildContext? context) {
    if (!isInitialized) return null;
    return _config?.defaultTheme;
  }

  /// Updates the configuration.
  ///
  /// Note: Changing webSocketUrl will require calling [reconnect()] to take
  /// effect.
  static void updateConfig(DerivExploreMarketsConfig newConfig) {
    if (!isInitialized) {
      throw StateError('DerivExploreMarkets has not been initialized.');
    }

    _config = newConfig;
  }
}
