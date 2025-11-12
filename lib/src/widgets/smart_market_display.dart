import 'dart:async';

import 'package:deriv_explore_markets/src/core/deriv_explore_markets.dart';
import 'package:deriv_explore_markets/src/models/tick_data.dart';
import 'package:deriv_explore_markets/src/services/websocket_service.dart';
import 'package:deriv_explore_markets/src/theme/default_theme.dart';
import 'package:deriv_explore_markets/src/theme/market_display_theme.dart';
import 'package:deriv_explore_markets/src/widgets/category_chip.dart';
import 'package:deriv_explore_markets/src/widgets/market_item_tile.dart';
import 'package:flutter/material.dart';

/// A comprehensive market display widget with built-in
/// tabs and automatic subscription management.
///
/// **Important**: You must initialize the package
/// first using `DerivExploreMarkets.initialize()`
/// in your app's main() function before using this widget.
///
/// Example usage:
/// ```dart
/// // In main.dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///
///   await DerivExploreMarkets.initialize(
///     DerivExploreMarketsConfig(
///       webSocketUrl: 'wss://ws.derivws.com/websockets/v3?app_id=YOUR_APP_ID',
///     ),
///   );
///
///   runApp(MyApp());
/// }
///
/// // In your widget
/// SmartMarketDisplay(
///   width: double.infinity,
///   height: 600,
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
class SmartMarketDisplay extends StatefulWidget {
  /// Creates a new [SmartMarketDisplay] widget.
  ///
  /// The package must be initialized
  /// first using [DerivExploreMarkets.initialize()].
  const SmartMarketDisplay({
    super.key,
    this.width,
    this.height,
    this.theme,
    this.onSymbolTap,
    this.loadingBuilder,
    this.errorBuilder,
    this.initialCategory = 0,
    this.showCategoryTabs = true,
  });

  /// Optional width constraint for the widget.
  final double? width;

  /// Optional height constraint for the widget.
  final double? height;

  /// Custom theme for styling the widget.
  ///
  /// If not provided, uses [DefaultMarketDisplayTheme.light].
  final MarketDisplayTheme? theme;

  /// Callback when a symbol is tapped.
  ///
  /// Receives the symbol code and optional tick data.
  final void Function(String symbol, TickData? tickData)? onSymbolTap;

  /// Custom builder for the loading state.
  ///
  /// If not provided, displays a default centered loading indicator.
  final Widget Function(BuildContext context)? loadingBuilder;

  /// Custom builder for error states.
  ///
  /// If not provided, displays error message text.
  final Widget Function(BuildContext context, String error)? errorBuilder;

  /// Initial category index to display.
  ///
  /// 0=Forex, 1=Stock indices, 2=Crypto, 3=Commodities
  final int initialCategory;

  /// Whether to show category tabs.
  ///
  /// Set to false to hide the main category tabs and only show content.
  final bool showCategoryTabs;

  @override
  State<SmartMarketDisplay> createState() => _SmartMarketDisplayState();
}

class _SmartMarketDisplayState extends State<SmartMarketDisplay>
    with TickerProviderStateMixin {
  late final WebSocketService _service;
  final Map<String, TickData> _latestTicks = {};
  final Map<String, double> _previousPrices = {};

  late TabController _mainTabController;
  late TabController _subTabController;
  int _selectedMainTab = 0;
  int _selectedSubTab = 0;

  final List<String> _mainCategories = [
    'Forex',
    'Stock indices',
    'Crypto',
    'Commodities',
  ];

  final List<String> _forexSubcategories = ['All', 'Major', 'Minor', 'Exotic'];

  bool _isLoading = true;
  List<String> _currentSymbols = [];
  String? _errorMessage;

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

    _selectedMainTab = widget.initialCategory.clamp(0, 3);
    _mainTabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: _selectedMainTab,
    );
    _subTabController = TabController(length: 4, vsync: this);

    _mainTabController.addListener(_onMainTabChanged);
    _subTabController.addListener(_onSubTabChanged);

    unawaited(_initializeDisplay());
  }

  @override
  void dispose() {
    _mainTabController.removeListener(_onMainTabChanged);
    _subTabController.removeListener(_onSubTabChanged);
    _mainTabController.dispose();
    _subTabController.dispose();
    super.dispose();
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

    _service.errorStream.listen((error) {
      if (mounted) {
        setState(() {
          _errorMessage = error;
        });
      }
    });

    if (_service.isConnected) {
      var attempts = 0;
      while (_service.getAllSymbols().isEmpty && attempts < 20) {
        await Future<void>.delayed(const Duration(milliseconds: 200));
        attempts++;
      }

      await _subscribeToCurrentSelection();

      setState(() {
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage =
            'Not connected to market data. Check your initialization.';
      });
    }
  }

  void _onMainTabChanged() {
    if (_mainTabController.indexIsChanging) {
      return;
    }
    setState(() {
      _selectedMainTab = _mainTabController.index;
      _selectedSubTab = 0;
      _subTabController.index = 0;
    });
    unawaited(_subscribeToCurrentSelection());
  }

  void _onSubTabChanged() {
    if (_subTabController.indexIsChanging) {
      return;
    }
    setState(() {
      _selectedSubTab = _subTabController.index;
    });
    unawaited(_subscribeToCurrentSelection());
  }

  Future<void> _subscribeToCurrentSelection() async {
    setState(() {
      _isLoading = true;
      _latestTicks.clear();
      _errorMessage = null;
    });

    var symbols = <String>[];

    switch (_selectedMainTab) {
      case 0:
        if (_selectedSubTab == 0) {
          symbols = _service.getSymbolsByMarket('forex');
        } else if (_selectedSubTab == 1) {
          symbols = _service.getSymbolsBySubmarket('major_pairs');
        } else if (_selectedSubTab == 2) {
          symbols = _service.getSymbolsBySubmarket('minor_pairs');
        } else if (_selectedSubTab == 3) {
          final allForex = _service.getSymbolsByMarket('forex');
          final major = _service.getSymbolsBySubmarket('major_pairs').toSet();
          final minor = _service.getSymbolsBySubmarket('minor_pairs').toSet();
          symbols = allForex
              .where((s) => !major.contains(s) && !minor.contains(s))
              .toList();
        }

      case 1:
        symbols = _service.getSymbolsByMarket('indices');

      case 2:
        symbols = _service.getSymbolsByMarket('cryptocurrency');

      case 3:
        symbols = _service.getSymbolsByMarket('commodities');
    }

    _currentSymbols = symbols;

    if (symbols.isNotEmpty) {
      await _service.forgetAllTicks();
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await _service.subscribeToTicks(symbols);
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final effectiveTheme =
        widget.theme ??
        DerivExploreMarkets.getDefaultTheme(context) ??
        DefaultMarketDisplayTheme.light(context);

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: effectiveTheme.secondaryBackground,
      ),
      child: Column(
        children: [
          if (widget.showCategoryTabs)
            Container(
              color: effectiveTheme.primaryBackground,
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _mainCategories.asMap().entries.map((entry) {
                    final index = entry.key;
                    final category = entry.value;
                    final isSelected = _selectedMainTab == index;

                    return Padding(
                      padding: EdgeInsets.only(
                        right: index < _mainCategories.length - 1 ? 8 : 0,
                      ),
                      child: CategoryChip(
                        label: category,
                        isSelected: isSelected,
                        onTap: () {
                          _mainTabController.index = index;
                        },
                        theme: effectiveTheme,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          if (_selectedMainTab == 0 && widget.showCategoryTabs)
            Container(
              color: effectiveTheme.secondaryBackground,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _forexSubcategories.asMap().entries.map((entry) {
                    final index = entry.key;
                    final category = entry.value;
                    final isSelected = _selectedSubTab == index;

                    return Padding(
                      padding: EdgeInsets.only(
                        right: index < _forexSubcategories.length - 1 ? 8 : 0,
                      ),
                      child: CategoryChip(
                        label: category,
                        isSelected: isSelected,
                        onTap: () {
                          _subTabController.index = index;
                        },
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
    if (_errorMessage != null && widget.errorBuilder != null) {
      return widget.errorBuilder!(context, _errorMessage!);
    }

    if (_isLoading) {
      if (widget.loadingBuilder != null) {
        return widget.loadingBuilder!(context);
      }

      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: theme.primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Loading market data...',
              style: theme.bodyMedium.copyWith(color: theme.primaryText),
            ),
          ],
        ),
      );
    }

    return _buildMarketList(theme);
  }

  Widget _buildMarketList(MarketDisplayTheme theme) {
    if (_currentSymbols.isEmpty) {
      return Center(
        child: Text(
          'No symbols available for this category',
          style: theme.bodyMedium.copyWith(color: theme.primaryText),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _currentSymbols.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        color: theme.alternate,
      ),
      itemBuilder: (context, index) {
        final symbol = _currentSymbols[index];
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
    );
  }
}
