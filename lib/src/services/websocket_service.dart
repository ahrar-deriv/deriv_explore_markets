import 'dart:async';
import 'dart:convert';

import 'package:deriv_explore_markets/src/models/active_symbol.dart';
import 'package:deriv_explore_markets/src/models/tick_data.dart';
import 'package:deriv_explore_markets/src/models/websocket_response.dart';
import 'package:deriv_explore_markets/src/models/websocket_status.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Singleton WebSocket service for managing Deriv API connections.
///
/// Provides a centralized interface for connecting to the Deriv WebSocket API,
/// subscribing to market data, and managing active symbols.
///
/// Example usage:
/// ```dart
/// final service = WebSocketService();
///
/// // Listen to connection status
/// service.statusStream.listen((status) {
///   print('Connection status: $status');
/// });
///
/// // Listen to tick updates
/// service.tickStream.listen((tick) {
///   print('${tick.symbol}: ${tick.quote}');
/// });
///
/// // Connect with your API credentials
/// final connected = await service.connect(
///   'wss://ws.derivws.com/websockets/v3?app_id=YOUR_APP_ID'
/// );
///
/// if (connected) {
///   // Subscribe to forex major pairs
///   await service.subscribeBySubmarket('major_pairs');
/// }
/// ```
class WebSocketService {
  /// Returns the singleton instance of [WebSocketService].
  factory WebSocketService() => _instance;

  WebSocketService._internal();
  static final WebSocketService _instance = WebSocketService._internal();

  WebSocketChannel? _channel;
  WebSocketStatus _status = WebSocketStatus.disconnected;
  String? _currentWsUrl;

  final _tickStreamController = StreamController<TickData>.broadcast();
  final _statusStreamController = StreamController<WebSocketStatus>.broadcast();
  final _errorStreamController = StreamController<String>.broadcast();

  final Set<String> _subscribedSymbols = {};
  Map<String, ActiveSymbol> _activeSymbols = {};
  bool _activeSymbolsFetched = false;

  bool _shouldReconnect = false;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const Duration _reconnectDelay = Duration(seconds: 3);

  /// Stream of tick data updates.
  ///
  /// Emits a [TickData] whenever a new price update
  /// is received for any subscribed symbol.
  Stream<TickData> get tickStream => _tickStreamController.stream;

  /// Stream of connection status changes.
  ///
  /// Emits a [WebSocketStatus] whenever the connection state changes.
  Stream<WebSocketStatus> get statusStream => _statusStreamController.stream;

  /// Stream of error messages.
  ///
  /// Emits error descriptions when connection or API errors occur.
  Stream<String> get errorStream => _errorStreamController.stream;

  /// Current connection status.
  WebSocketStatus get status => _status;

  /// Returns true if the WebSocket is currently connected.
  bool get isConnected => _status == WebSocketStatus.connected;

  /// Set of currently subscribed symbol names.
  Set<String> get subscribedSymbols => Set.unmodifiable(_subscribedSymbols);

  /// Map of all active symbols fetched from the API.
  Map<String, ActiveSymbol> get activeSymbols =>
      Map.unmodifiable(_activeSymbols);

  /// Connects to the Deriv WebSocket API.
  ///
  /// [wsUrl] must be a complete WebSocket URL including your app_id:
  /// `wss://ws.derivws.com/websockets/v3?app_id=YOUR_APP_ID`
  ///
  /// Returns `true` if connection was successful, `false` otherwise.
  ///
  /// The service will automatically:
  /// - Fetch active symbols after connection
  /// - Emit status updates via [statusStream]
  /// - Attempt reconnection on failure (up to 5 times)
  ///
  /// Example:
  /// ```dart
  /// final success = await service.connect(
  ///   'wss://ws.derivws.com/websockets/v3?app_id=YOUR_APP_ID'
  /// );
  /// ```
  Future<bool> connect(String wsUrl) async {
    if (_status == WebSocketStatus.connected ||
        _status == WebSocketStatus.connecting) {
      return isConnected;
    }

    try {
      _updateStatus(WebSocketStatus.connecting);
      _currentWsUrl = wsUrl;

      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      await _channel!.ready;

      _updateStatus(WebSocketStatus.connected);
      _reconnectAttempts = 0;
      _shouldReconnect = true;

      _listenToMessages();

      if (!_activeSymbolsFetched) {
        await fetchActiveSymbols();
      }

      return true;
    } on Exception catch (e) {
      _handleError('Connection failed: $e');
      _updateStatus(WebSocketStatus.error);

      if (_shouldReconnect && _reconnectAttempts < _maxReconnectAttempts) {
        _scheduleReconnect(wsUrl);
      }

      return false;
    }
  }

  void _listenToMessages() {
    _channel?.stream.listen(
      (dynamic message) {
        try {
          final jsonData =
              json.decode(message as String) as Map<String, dynamic>;

          if (jsonData['msg_type'] == 'active_symbols') {
            _handleActiveSymbolsResponse(jsonData);
            return;
          }

          final response = WebSocketResponse.fromJson(jsonData);

          if (response.hasError) {
            _handleError(response.error!);
          } else if (response.hasTick) {
            _tickStreamController.add(response.tickData!);
          }
        } on Exception catch (e) {
          _handleError('Failed to parse message: $e');
        }
      },
      onError: (Object error) {
        _handleError('Stream error: $error');
        _handleDisconnection();
      },
      onDone: _handleDisconnection,
      cancelOnError: false,
    );
  }

  /// Fetches the list of active symbols from the Deriv API.
  ///
  /// Must be called after a successful connection. Returns `true` if the
  /// request was sent successfully.
  ///
  /// The symbols will be available via [activeSymbols]
  /// once the response is received.
  Future<bool> fetchActiveSymbols() async {
    if (!isConnected) {
      return false;
    }

    try {
      final request = {'active_symbols': 'full'};
      _channel?.sink.add(json.encode(request));
      return true;
    } on Exception catch (e) {
      _handleError('Failed to fetch active symbols: $e');
      return false;
    }
  }

  void _handleActiveSymbolsResponse(Map<String, dynamic> json) {
    try {
      final response = ActiveSymbolsResponse.fromJson(json);
      _activeSymbols = response.toMap();
      _activeSymbolsFetched = true;
    } on Exception catch (e) {
      _handleError('Failed to parse active symbols: $e');
    }
  }

  /// Returns the active symbol data for a specific symbol.
  ///
  /// Returns `null` if the symbol is not found
  /// or active symbols haven't been fetched yet.
  ActiveSymbol? getActiveSymbol(String symbol) {
    return _activeSymbols[symbol];
  }

  /// Returns all symbols of a specific type.
  ///
  /// [symbolType] can be 'forex', 'cryptocurrency',
  /// 'stockindex', 'commodities', etc.
  List<String> getSymbolsByType(String symbolType) {
    return _activeSymbols.values
        .where((symbol) => symbol.symbolType == symbolType)
        .map((symbol) => symbol.symbol)
        .toList();
  }

  /// Returns all symbols in a specific market.
  ///
  /// [market] can be 'forex', 'cryptocurrency', 'indices', 'commodities', etc.
  List<String> getSymbolsByMarket(String market) {
    return _activeSymbols.values
        .where((symbol) => symbol.market == market)
        .map((symbol) => symbol.symbol)
        .toList();
  }

  /// Returns all symbols in a specific submarket.
  ///
  /// [submarket] can be 'major_pairs', 'minor_pairs',
  /// 'non_stable_coin', 'metals', etc.
  List<String> getSymbolsBySubmarket(String submarket) {
    return _activeSymbols.values
        .where((symbol) => symbol.submarket == submarket)
        .map((symbol) => symbol.symbol)
        .toList();
  }

  /// Returns all symbols where the exchange
  /// is open and trading is not suspended.
  List<String> getTradeableSymbols() {
    return _activeSymbols.values
        .where((symbol) => symbol.isOpen)
        .map((symbol) => symbol.symbol)
        .toList();
  }

  /// Returns all available symbol names.
  List<String> getAllSymbols() {
    return _activeSymbols.keys.toList();
  }

  /// Subscribes to tick updates for the specified symbols.
  ///
  /// Returns `true` if the subscription request was sent successfully.
  ///
  /// Example:
  /// ```dart
  /// await service.subscribeToTicks(['frxEURUSD', 'frxGBPUSD']);
  /// ```
  Future<bool> subscribeToTicks(List<String> symbols) async {
    if (!isConnected) {
      if (_currentWsUrl == null) {
        return false;
      }
      final connected = await connect(_currentWsUrl!);
      if (!connected) {
        return false;
      }
    }

    try {
      final request = {
        'ticks': symbols,
        'subscribe': 1,
      };

      _channel?.sink.add(json.encode(request));
      _subscribedSymbols.addAll(symbols);

      return true;
    } on Exception catch (e) {
      _handleError('Subscription failed: $e');
      return false;
    }
  }

  /// Subscribes to all active symbols.
  ///
  /// Warning: This may subscribe to a large number of symbols.
  /// Consider using [subscribeByMarket] or [subscribeBySubmarket] instead.
  Future<bool> subscribeToAllSymbols() async {
    final symbols = getAllSymbols();
    if (symbols.isEmpty) {
      return false;
    }
    return subscribeToTicks(symbols);
  }

  /// Subscribes to all symbols in a specific market.
  ///
  /// [market] can be 'forex', 'cryptocurrency', 'indices', 'commodities', etc.
  Future<bool> subscribeByMarket(String market) async {
    final symbols = getSymbolsByMarket(market);
    if (symbols.isEmpty) {
      return false;
    }
    return subscribeToTicks(symbols);
  }

  /// Subscribes to all symbols of a specific type.
  ///
  /// [symbolType] can be 'forex', 'cryptocurrency',
  /// 'stockindex', 'commodities', etc.
  Future<bool> subscribeByType(String symbolType) async {
    final symbols = getSymbolsByType(symbolType);
    if (symbols.isEmpty) {
      return false;
    }
    return subscribeToTicks(symbols);
  }

  /// Subscribes to all symbols in a specific submarket.
  ///
  /// [submarket] can be 'major_pairs', 'minor_pairs',
  /// 'non_stable_coin', 'metals', etc.
  Future<bool> subscribeBySubmarket(String submarket) async {
    final symbols = getSymbolsBySubmarket(submarket);
    if (symbols.isEmpty) {
      return false;
    }
    return subscribeToTicks(symbols);
  }

  /// Subscribes to only tradeable symbols (exchange open, not suspended).
  Future<bool> subscribeToTradeableSymbols() async {
    final symbols = getTradeableSymbols();
    if (symbols.isEmpty) {
      return false;
    }
    return subscribeToTicks(symbols);
  }

  /// Unsubscribes from all active tick subscriptions.
  ///
  /// Returns `true` if the unsubscribe request was sent successfully.
  Future<bool> forgetAllTicks() async {
    if (!isConnected) {
      return false;
    }

    try {
      final request = {'forget_all': 'ticks'};
      _channel?.sink.add(json.encode(request));
      _subscribedSymbols.clear();
      return true;
    } on Exception catch (e) {
      _handleError('Unsubscribe all failed: $e');
      return false;
    }
  }

  /// Unsubscribes from specific symbols.
  ///
  /// Note: This uses `forget_all` internally as individual unsubscribe
  /// requires tracking subscription IDs.
  Future<bool> unsubscribeFromTicks(List<String> symbols) async {
    if (!isConnected) {
      return false;
    }

    try {
      final request = {'forget_all': 'ticks'};
      _channel?.sink.add(json.encode(request));
      _subscribedSymbols.removeAll(symbols);
      return true;
    } on Exception catch (e) {
      _handleError('Unsubscription failed: $e');
      return false;
    }
  }

  /// Switches subscription to a different market.
  ///
  /// Automatically unsubscribes from all current subscriptions before
  /// subscribing to the new market.
  Future<bool> switchToMarket(String market) async {
    await forgetAllTicks();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return subscribeByMarket(market);
  }

  /// Switches subscription to a different symbol type.
  Future<bool> switchToType(String symbolType) async {
    await forgetAllTicks();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return subscribeByType(symbolType);
  }

  /// Switches subscription to a different submarket.
  Future<bool> switchToSubmarket(String submarket) async {
    await forgetAllTicks();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return subscribeBySubmarket(submarket);
  }

  /// Sends a custom message to the WebSocket.
  ///
  /// For advanced use cases where you need to send custom API requests.
  Future<bool> sendMessage(Map<String, dynamic> message) async {
    if (!isConnected) {
      return false;
    }

    try {
      _channel?.sink.add(json.encode(message));
      return true;
    } on Exception catch (e) {
      _handleError('Failed to send message: $e');
      return false;
    }
  }

  /// Disconnects from the WebSocket server.
  ///
  /// Closes the connection and cleans up resources. After calling this,
  /// you can call [connect] again to establish a new connection.
  Future<void> disconnect() async {
    _shouldReconnect = false;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    try {
      await _channel?.sink.close(1000);
    } on Exception {
      // Ignore disconnect errors
    }

    _channel = null;
    _currentWsUrl = null;
    _subscribedSymbols.clear();
    _updateStatus(WebSocketStatus.disconnected);
  }

  void _handleDisconnection() {
    if (_status == WebSocketStatus.disconnected) {
      return;
    }

    _updateStatus(WebSocketStatus.disconnected);

    if (_shouldReconnect && _reconnectAttempts < _maxReconnectAttempts) {
      if (_currentWsUrl != null) {
        _scheduleReconnect(_currentWsUrl!);
      }
    } else if (_reconnectAttempts >= _maxReconnectAttempts) {
      _handleError('Max reconnection attempts reached');
      _shouldReconnect = false;
    }
  }

  void _scheduleReconnect(String wsUrl) {
    _reconnectTimer?.cancel();
    _reconnectAttempts++;

    _reconnectTimer = Timer(_reconnectDelay, () async {
      final connected = await connect(wsUrl);

      if (connected && _subscribedSymbols.isNotEmpty) {
        await subscribeToTicks(_subscribedSymbols.toList());
      }
    });
  }

  void _updateStatus(WebSocketStatus newStatus) {
    if (_status != newStatus) {
      _status = newStatus;
      _statusStreamController.add(newStatus);
    }
  }

  void _handleError(String error) {
    _errorStreamController.add(error);
  }

  /// Disposes all resources and closes all streams.
  ///
  /// Should be called when the service is no longer needed.
  Future<void> dispose() async {
    await disconnect();
    await _tickStreamController.close();
    await _statusStreamController.close();
    await _errorStreamController.close();
    _reconnectTimer?.cancel();
  }

  /// Resets the service to its initial state.
  ///
  /// Useful for testing or forcing a fresh connection.
  Future<void> reset() async {
    await disconnect();
    _reconnectAttempts = 0;
    _shouldReconnect = false;
  }
}
