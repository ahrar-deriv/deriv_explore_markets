/// Represents a single tick (price update) from the Deriv API.
///
/// A tick contains real-time market data including the current price (quote),
/// bid/ask prices if available, timestamp, and formatting information.
///
/// Example usage:
/// ```dart
/// final tickData = TickData.fromJson({
///   'tick': {
///     'symbol': 'frxEURUSD',
///     'quote': 1.08953,
///     'ask': 1.08955,
///     'bid': 1.08951,
///     'epoch': 1699876543,
///     'id': 'abc123',
///     'pip_size': 5,
///   }
/// });
///
/// print(tickData.formattedQuote); // "1.08953"
/// print(tickData.spread); // 0.00004
/// ```
class TickData {
  /// Creates a new [TickData] instance.
  TickData({
    required this.symbol,
    required this.quote,
    required this.epoch,
    required this.id,
    required this.pipSize,
    this.ask,
    this.bid,
  });

  /// Creates a [TickData] from a JSON response from the Deriv API.
  ///
  /// The JSON should have the structure:
  /// ```json
  /// {
  ///   "tick": {
  ///     "symbol": "frxEURUSD",
  ///     "quote": 1.08953,
  ///     "ask": 1.08955,
  ///     "bid": 1.08951,
  ///     "epoch": 1699876543,
  ///     "id": "abc123",
  ///     "pip_size": 5
  ///   }
  /// }
  /// ```
  factory TickData.fromJson(Map<String, dynamic> json) {
    final tick = json['tick'] as Map<String, dynamic>;
    return TickData(
      symbol: tick['symbol'] as String,
      ask: tick['ask'] as double?,
      bid: tick['bid'] as double?,
      quote: tick['quote'] as double,
      epoch: tick['epoch'] as int,
      id: tick['id'] as String,
      pipSize: tick['pip_size'] as int,
    );
  }

  /// The trading symbol (e.g., 'frxEURUSD', 'BTCUSD').
  final String symbol;

  /// The current ask price (price at which you can buy).
  ///
  /// May be null for symbols that don't have bid/ask spreads.
  final double? ask;

  /// The current bid price (price at which you can sell).
  ///
  /// May be null for symbols that don't have bid/ask spreads.
  final double? bid;

  /// The current market price (quote).
  ///
  /// This is the main price value for the symbol.
  final double quote;

  /// Unix timestamp in seconds when this tick was generated.
  final int epoch;

  /// Unique identifier for this tick.
  final String id;

  /// Number of decimal places to use when formatting the price.
  ///
  /// Typically ranges from 2 (for stock indices) to 5 (for forex pairs).
  final int pipSize;

  /// Converts this [TickData] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'ask': ask,
      'bid': bid,
      'quote': quote,
      'epoch': epoch,
      'id': id,
      'pip_size': pipSize,
    };
  }

  /// Returns the quote formatted according to [pipSize].
  ///
  /// Example:
  /// ```dart
  /// final tick = TickData(quote: 1.08953, pipSize: 5, ...);
  /// print(tick.formattedQuote); // "1.08953"
  /// ```
  String get formattedQuote {
    return quote.toStringAsFixed(pipSize);
  }

  /// Returns the tick timestamp as a [DateTime] object.
  ///
  /// Converts the Unix epoch timestamp (in seconds) to a DateTime.
  DateTime get timestamp {
    return DateTime.fromMillisecondsSinceEpoch(epoch * 1000);
  }

  /// Returns the spread (difference between ask and bid prices).
  ///
  /// Returns null if either ask or bid is not available.
  ///
  /// Example:
  /// ```dart
  /// final tick = TickData(ask: 1.08955, bid: 1.08951, ...);
  /// print(tick.spread); // 0.00004
  /// ```
  double? get spread {
    if (ask != null && bid != null) {
      return ask! - bid!;
    }
    return null;
  }

  @override
  String toString() {
    return '''TickData(symbol: $symbol, quote: $quote'''
        ''', ask: $ask, bid: $bid, epoch: $epoch)''';
  }

  /// Creates a copy of this [TickData] with the given fields replaced.
  ///
  /// Example:
  /// ```dart
  /// final updated = original.copyWith(quote: 1.09000);
  /// ```
  TickData copyWith({
    String? symbol,
    double? ask,
    double? bid,
    double? quote,
    int? epoch,
    String? id,
    int? pipSize,
  }) {
    return TickData(
      symbol: symbol ?? this.symbol,
      ask: ask ?? this.ask,
      bid: bid ?? this.bid,
      quote: quote ?? this.quote,
      epoch: epoch ?? this.epoch,
      id: id ?? this.id,
      pipSize: pipSize ?? this.pipSize,
    );
  }
}
