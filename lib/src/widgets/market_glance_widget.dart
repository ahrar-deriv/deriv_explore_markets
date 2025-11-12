import 'dart:async';

import 'package:deriv_explore_markets/src/core/deriv_explore_markets.dart';
import 'package:deriv_explore_markets/src/models/tick_data.dart';
import 'package:deriv_explore_markets/src/services/websocket_service.dart';
import 'package:deriv_explore_markets/src/theme/default_theme.dart';
import 'package:deriv_explore_markets/src/theme/market_display_theme.dart';
import 'package:deriv_explore_markets/src/widgets/category_chip.dart';
import 'package:deriv_explore_markets/src/widgets/market_item_tile.dart';
import 'package:flutter/material.dart';

/// A compact market display widget showing
/// a glance of markets with category chips.
///
/// Displays up to 5 market items with
/// horizontal category chips for quick navigation.
/// Perfect for home pages or dashboards
/// where you want to show a preview of markets.
///
/// **Important**: Initialize the package
/// first using `DerivExploreMarkets.initialize()`.
///
/// Example usage:
/// ```dart
/// MarketGlanceWidget(
///   maxItems: 5,
///   onSymbolTap: (symbol, tickData) {
///     Navigator.push(
///       context,
///       MaterialPageRoute(
///         builder: (_) => SymbolDetailPage(symbol: symbol),
///       ),
///     );
///   },
/// )
/// ```
class MarketGlanceWidget extends StatefulWidget {
  /// Creates a new [MarketGlanceWidget].
  const MarketGlanceWidget({
    super.key,
    this.width,
    this.height,
    this.theme,
    this.maxItems = 5,
    this.initialCategory = 0,
    this.onSymbolTap,
  });

  /// Optional width constraint for the widget.
  final double? width;

  /// Optional height constraint for the widget.
  ///
  /// Default: 400.0 (recommended for showing 5 items)
  final double? height;

  /// Custom theme for styling the widget.
  final MarketDisplayTheme? theme;

  /// Maximum number of items to display.
  ///
  /// Default: 5
  final int maxItems;

  /// Initial category index to display.
  ///
  /// 0=Forex, 1=Stock indices, 2=Crypto, 3=Commodities
  final int initialCategory;

  /// Callback when a symbol is tapped.
  final void Function(String symbol, TickData? tickData)? onSymbolTap;

  @override
  State<MarketGlanceWidget> createState() => _MarketGlanceWidgetState();
}

class _MarketGlanceWidgetState extends State<MarketGlanceWidget> {
  late final WebSocketService _service;
  final Map<String, TickData> _latestTicks = {};
  final Map<String, double> _previousPrices = {};

  int _selectedCategory = 0;

  final List<_CategoryChip> _categories = const [
    _CategoryChip(label: 'Forex', market: 'forex'),
    _CategoryChip(label: 'Stock indices', market: 'indices'),
    _CategoryChip(label: 'Crypto', market: 'cryptocurrency'),
    _CategoryChip(label: 'Commodities', market: 'commodities'),
  ];

  bool _isLoading = true;
  List<String> _currentSymbols = [];

  @override
  void initState() {
    super.initState();

    if (!DerivExploreMarkets.isInitialized) {
      throw StateError(
        'DerivExploreMarkets has not been initialized. '
        'Call DerivExploreMarkets.initialize() in main()',
      );
    }

    _service = DerivExploreMarkets.websocketService;
    _selectedCategory = widget.initialCategory.clamp(0, 3);

    unawaited(_initializeDisplay());
  }

  Future<void> _initializeDisplay() async {
    _service.tickStream.listen((tickData) {
      if (mounted) {
        setState(() {
          if (_previousPrices.containsKey(tickData.symbol)) {
            _previousPrices[tickData.symbol] =
                _latestTicks[tickData.symbol]!.quote;
          }
          _latestTicks[tickData.symbol] = tickData;
        });
      }
    });

    if (_service.isConnected) {
      var attempts = 0;
      while (_service.getAllSymbols().isEmpty && attempts < 20) {
        await Future<void>.delayed(const Duration(milliseconds: 200));
        attempts++;
      }

      await _subscribeToCurrentCategory();

      setState(() {
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _subscribeToCurrentCategory() async {
    setState(() {
      _isLoading = true;
      _latestTicks.clear();
    });

    final market = _categories[_selectedCategory].market;
    final symbols = _service.getSymbolsByMarket(market);

    _currentSymbols = symbols.take(widget.maxItems).toList();

    if (_currentSymbols.isNotEmpty) {
      await _service.forgetAllTicks();
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await _service.subscribeToTicks(_currentSymbols);
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _onCategoryChanged(int index) {
    if (_selectedCategory == index) return;

    setState(() {
      _selectedCategory = index;
    });
    unawaited(_subscribeToCurrentCategory());
  }

  @override
  Widget build(BuildContext context) {
    final effectiveTheme =
        widget.theme ??
        DerivExploreMarkets.getDefaultTheme(context) ??
        DefaultMarketDisplayTheme.light(context);

    final contentHeight = widget.height ?? 400.0;

    return Container(
      width: widget.width,
      height: contentHeight,
      decoration: BoxDecoration(
        color: effectiveTheme.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categories.asMap().entries.map((entry) {
                  final index = entry.key;
                  final category = entry.value;
                  final isSelected = _selectedCategory == index;

                  return Padding(
                    padding: EdgeInsets.only(
                      right: index < _categories.length - 1 ? 8 : 0,
                    ),
                    child: CategoryChip(
                      label: category.label,
                      isSelected: isSelected,
                      onTap: () => _onCategoryChanged(index),
                      theme: effectiveTheme,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: _buildContent(effectiveTheme),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(MarketDisplayTheme theme) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: theme.primaryColor),
      );
    }

    if (_currentSymbols.isEmpty) {
      return Center(
        child: Text(
          'No symbols available',
          style: theme.bodyMedium.copyWith(color: theme.secondaryText),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          for (var i = 0; i < _currentSymbols.length; i++) ...[
            Builder(
              builder: (context) {
                final symbol = _currentSymbols[i];
                final tickData = _latestTicks[symbol];
                final activeSymbol = _service.getActiveSymbol(symbol);
                final previousPrice = _previousPrices[symbol];

                return MarketItemTile(
                  symbol: symbol,
                  tickData: tickData,
                  activeSymbol: activeSymbol,
                  previousPrice: previousPrice,
                  theme: theme,
                  onTap: widget.onSymbolTap != null
                      ? () => widget.onSymbolTap!(symbol, tickData)
                      : null,
                );
              },
            ),
            if (i < _currentSymbols.length - 1)
              Divider(height: 1, color: theme.alternate),
          ],
        ],
      ),
    );
  }
}

class _CategoryChip {
  const _CategoryChip({required this.label, required this.market});

  final String label;
  final String market;
}
