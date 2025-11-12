import 'package:deriv_explore_markets/deriv_explore_markets.dart'
    show MarketGlanceWidget, SmartMarketDisplay;
import 'package:deriv_explore_markets/src/models/active_symbol.dart';
import 'package:deriv_explore_markets/src/models/tick_data.dart';
import 'package:deriv_explore_markets/src/theme/market_display_theme.dart';
import 'package:flutter/material.dart';

/// A reusable tile widget for displaying market symbol information.
///
/// Used by both [SmartMarketDisplay] and [MarketGlanceWidget] to ensure
/// consistent design across all market widgets.
class MarketItemTile extends StatelessWidget {
  /// Creates a market item tile.
  const MarketItemTile({
    required this.symbol,
    required this.theme,
    super.key,
    this.tickData,
    this.activeSymbol,
    this.previousPrice,
    this.onTap,
  });

  /// The symbol code (e.g., 'frxEURUSD').
  final String symbol;

  /// Current tick data for this symbol (null if loading).
  final TickData? tickData;

  /// Active symbol metadata (for display name, description, icon).
  final ActiveSymbol? activeSymbol;

  /// Previous price for calculating percentage change.
  final double? previousPrice;

  /// Theme for styling the tile.
  final MarketDisplayTheme theme;

  /// Callback when the tile is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (tickData == null) {
      return _buildLoadingTile();
    }
    return _buildTickTile();
  }

  Widget _buildLoadingTile() {
    final displayName = activeSymbol?.displayName ?? symbol;
    final description = activeSymbol?.description ?? 'Loading...';

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            _buildSymbolIcon(activeSymbol?.symbolType),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: theme.bodyLarge.copyWith(
                      color: theme.primaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.bodySmall.copyWith(
                      color: theme.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTickTile() {
    final percentageChange = _calculatePercentageChange();
    final isPositive = percentageChange >= 0;
    final displayName = activeSymbol?.displayName ?? tickData!.symbol;
    final description = activeSymbol?.description ?? '';

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            _buildSymbolIcon(activeSymbol?.symbolType),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: theme.bodyLarge.copyWith(
                      color: theme.primaryText,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.bodySmall.copyWith(
                      color: theme.secondaryText,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatPrice(tickData!.quote, tickData!.pipSize),
                  style: theme.bodyLarge.copyWith(
                    color: theme.primaryText,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '''${isPositive ? '+' : ''}'''
                  '''${percentageChange.toStringAsFixed(2)}%''',
                  style: theme.bodySmall.copyWith(
                    color: isPositive
                        ? theme.positiveColor
                        : theme.negativeColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSymbolIcon(String? symbolType) {
    IconData icon;
    switch (symbolType) {
      case 'forex':
        icon = Icons.currency_exchange;
      case 'cryptocurrency':
        icon = Icons.currency_bitcoin;
      case 'stockindex':
        icon = Icons.trending_up;
      case 'commodities':
        icon = Icons.local_fire_department;
      default:
        icon = Icons.show_chart;
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.alternate,
        ),
      ),
      child: Icon(
        icon,
        color: theme.primaryColor,
        size: 24,
      ),
    );
  }

  String _formatPrice(double price, int pipSize) {
    if (price >= 1000) {
      return price.toStringAsFixed(0);
    } else if (price >= 100) {
      return price.toStringAsFixed(pipSize.clamp(0, 3));
    } else {
      return price.toStringAsFixed(pipSize);
    }
  }

  double _calculatePercentageChange() {
    if (tickData == null || previousPrice == null) {
      return 0;
    }

    if (previousPrice! == 0) return 0;

    final change = tickData!.quote - previousPrice!;
    return (change / previousPrice!) * 100;
  }
}
