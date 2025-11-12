/// Represents an active trading symbol from the Deriv API.
///
/// Contains metadata about a tradeable symbol including its display name,
/// market classification, trading status, and formatting information.
///
/// Example usage:
/// ```dart
/// final symbol = ActiveSymbol.fromJson({
///   'symbol': 'frxEURUSD',
///   'display_name': 'EUR/USD',
///   'symbol_type': 'forex',
///   'market': 'forex',
///   'market_display_name': 'Forex',
///   'submarket': 'major_pairs',
///   'submarket_display_name': 'Major Pairs',
///   'pip': 0.00001,
///   'exchange_is_open': 1,
///   'is_trading_suspended': 0,
/// });
///
/// print(symbol.isOpen); // true
/// print(symbol.description); // "Major Pairs"
/// ```
class ActiveSymbol {
  /// Creates a new [ActiveSymbol] instance.
  ActiveSymbol({
    required this.symbol,
    required this.displayName,
    required this.symbolType,
    required this.market,
    required this.marketDisplayName,
    required this.pip,
    required this.exchangeIsOpen,
    required this.isTradingSuspended,
    this.submarket,
    this.submarketDisplayName,
  });

  /// Creates an [ActiveSymbol] from a JSON response from the Deriv API.
  ///
  /// Handles fallback values for missing or alternative field names
  /// in the API response.
  factory ActiveSymbol.fromJson(Map<String, dynamic> json) {
    return ActiveSymbol(
      symbol: json['symbol'] as String? ?? json['underlying_symbol'] as String,
      displayName:
          json['display_name'] as String? ??
          json['symbol'] as String? ??
          json['underlying_symbol'] as String,
      symbolType:
          json['symbol_type'] as String? ??
          json['underlying_symbol_type'] as String? ??
          '',
      market: json['market'] as String,
      marketDisplayName:
          json['market_display_name'] as String? ?? json['market'] as String,
      submarket: json['submarket'] as String?,
      submarketDisplayName: json['submarket_display_name'] as String?,
      pip:
          (json['pip'] as num?)?.toDouble() ??
          (json['pip_size'] as num?)?.toDouble() ??
          0.001,
      exchangeIsOpen: json['exchange_is_open'] as int,
      isTradingSuspended: json['is_trading_suspended'] as int,
    );
  }

  /// The unique symbol identifier (e.g., 'frxEURUSD', 'BTCUSD').
  final String symbol;

  /// Human-readable name for display (e.g., 'EUR/USD', 'Bitcoin').
  final String displayName;

  /// The type of symbol (e.g., 'forex', 'cryptocurrency', 'stockindex').
  final String symbolType;

  /// The primary market category (e.g., 'forex', 'indices', 'commodities').
  final String market;

  /// Human-readable market name (e.g., 'Forex', 'Stock indices').
  final String marketDisplayName;

  /// Optional subcategory within the market (e.g., 'major_pairs')
  final String? submarket;

  /// Human-readable submarket name (e.g., 'Major Pairs', 'Minor Pairs').
  final String? submarketDisplayName;

  /// The pip size for price formatting (e.g., 0.00001 for forex).
  final double pip;

  /// Indicates if the exchange is currently open (1) or closed (0).
  final int exchangeIsOpen;

  /// Indicates if trading is suspended (1) or active (0).
  final int isTradingSuspended;

  /// Converts this [ActiveSymbol] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'display_name': displayName,
      'symbol_type': symbolType,
      'market': market,
      'market_display_name': marketDisplayName,
      'submarket': submarket,
      'submarket_display_name': submarketDisplayName,
      'pip': pip,
      'exchange_is_open': exchangeIsOpen,
      'is_trading_suspended': isTradingSuspended,
    };
  }

  /// Returns true if the symbol is currently available for trading.
  ///
  /// A symbol is considered open when the exchange
  /// is open AND trading is not suspended.
  bool get isOpen => exchangeIsOpen == 1 && isTradingSuspended == 0;

  /// Returns a descriptive text for the symbol's category.
  ///
  /// Prefers the submarket display name if available,
  /// otherwise uses the market display name.
  ///
  /// Example:
  /// ```dart
  /// // For a major forex pair:
  /// print(symbol.description); // "Major Pairs"
  ///
  /// // For a symbol without submarket:
  /// print(cryptoSymbol.description); // "Cryptocurrency"
  /// ```
  String get description {
    if (submarketDisplayName != null && submarketDisplayName!.isNotEmpty) {
      return submarketDisplayName!;
    }
    return marketDisplayName;
  }

  @override
  String toString() {
    return '''ActiveSymbol(symbol: $symbol, '''
        '''displayName: $displayName, type: $symbolType)''';
  }
}

/// Response wrapper for the active_symbols API call.
///
/// Contains a list of all active symbols returned from the Deriv API.
///
/// Example usage:
/// ```dart
/// final response = ActiveSymbolsResponse.fromJson({
///   'msg_type': 'active_symbols',
///   'active_symbols': [
///     {
///       'symbol': 'frxEURUSD',
///       'display_name': 'EUR/USD',
///       // ... other fields
///     },
///     // ... more symbols
///   ]
/// });
///
/// final symbolMap = response.toMap();
/// final eurUsd = symbolMap['frxEURUSD'];
/// ```
class ActiveSymbolsResponse {
  /// Creates a new [ActiveSymbolsResponse] instance.
  ActiveSymbolsResponse({
    required this.symbols,
    required this.msgType,
  });

  /// Creates an [ActiveSymbolsResponse] from a JSON response from the Deriv API
  ///
  /// Handles error responses gracefully by returning an empty symbols list.
  factory ActiveSymbolsResponse.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('error')) {
      return ActiveSymbolsResponse(
        symbols: [],
        msgType: json['msg_type'] as String,
      );
    }

    final activeSymbols = json['active_symbols'] as List<dynamic>?;

    if (activeSymbols == null) {
      return ActiveSymbolsResponse(
        symbols: [],
        msgType: json['msg_type'] as String,
      );
    }

    return ActiveSymbolsResponse(
      symbols: activeSymbols
          .map(
            (symbolJson) =>
                ActiveSymbol.fromJson(symbolJson as Map<String, dynamic>),
          )
          .toList(),
      msgType: json['msg_type'] as String,
    );
  }

  /// List of all active symbols.
  final List<ActiveSymbol> symbols;

  /// The message type from the API (should be 'active_symbols').
  final String msgType;

  /// Converts the symbols list to a Map with symbol codes as keys.
  ///
  /// Useful for quick lookup by symbol name.
  ///
  /// Example:
  /// ```dart
  /// final map = response.toMap();
  /// final eurUsd = map['frxEURUSD'];
  /// if (eurUsd != null) {
  ///   print(eurUsd.displayName); // "EUR/USD"
  /// }
  /// ```
  Map<String, ActiveSymbol> toMap() {
    return {for (final symbol in symbols) symbol.symbol: symbol};
  }
}
