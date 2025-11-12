import 'package:deriv_explore_markets/deriv_explore_markets.dart'
    show SmartMarketDisplay;
import 'package:deriv_explore_markets/src/widgets/smart_market_display.dart'
    show SmartMarketDisplay;
import 'package:flutter/material.dart';

/// Theme configuration for market display widgets.
///
/// Provides customizable colors and
/// text styles for the [SmartMarketDisplay] widget.
/// This allows complete visual customization without depending on any specific
/// theme framework.
///
/// Example usage:
/// ```dart
/// final customTheme = MarketDisplayTheme(
///   primaryColor: Colors.purple,
///   primaryBackground: Colors.white,
///   secondaryBackground: Colors.grey[50]!,
///   primaryText: Colors.black87,
///   secondaryText: Colors.grey[600]!,
///   alternate: Colors.grey[300]!,
///   positiveColor: Colors.green[600]!,
///   negativeColor: Colors.red[600]!,
///   bodyLarge: TextStyle(fontSize: 16),
///   bodyMedium: TextStyle(fontSize: 14),
///   bodySmall: TextStyle(fontSize: 12),
/// );
///
/// SmartMarketDisplay(
///   webSocketUrl: wsUrl,
///   theme: customTheme,
/// );
/// ```
class MarketDisplayTheme {
  /// Creates a new [MarketDisplayTheme] with the
  /// specified colors and text styles.
  const MarketDisplayTheme({
    required this.primaryColor,
    required this.primaryBackground,
    required this.secondaryBackground,
    required this.primaryText,
    required this.secondaryText,
    required this.alternate,
    required this.positiveColor,
    required this.negativeColor,
    required this.bodyLarge,
    required this.bodyMedium,
    required this.bodySmall,
  });

  /// Primary accent color for indicators, highlights, and selected states.
  final Color primaryColor;

  /// Primary background color for main containers.
  final Color primaryBackground;

  /// Secondary background color for nested containers and cards.
  final Color secondaryBackground;

  /// Primary text color for headings and important text.
  final Color primaryText;

  /// Secondary text color for descriptions and less important text.
  final Color secondaryText;

  /// Alternate color for borders, dividers, and subtle UI elements.
  final Color alternate;

  /// Color used for positive values (price increases, gains).
  final Color positiveColor;

  /// Color used for negative values (price decreases, losses).
  final Color negativeColor;

  /// Text style for large body text (symbol names, prices).
  final TextStyle bodyLarge;

  /// Text style for medium body text (labels, general content).
  final TextStyle bodyMedium;

  /// Text style for small body text (descriptions, metadata).
  final TextStyle bodySmall;

  /// Creates a copy of this theme with the specified properties replaced.
  ///
  /// Example:
  /// ```dart
  /// final darkTheme = lightTheme.copyWith(
  ///   primaryBackground: Colors.black,
  ///   primaryText: Colors.white,
  /// );
  /// ```
  MarketDisplayTheme copyWith({
    Color? primaryColor,
    Color? primaryBackground,
    Color? secondaryBackground,
    Color? primaryText,
    Color? secondaryText,
    Color? alternate,
    Color? positiveColor,
    Color? negativeColor,
    TextStyle? bodyLarge,
    TextStyle? bodyMedium,
    TextStyle? bodySmall,
  }) {
    return MarketDisplayTheme(
      primaryColor: primaryColor ?? this.primaryColor,
      primaryBackground: primaryBackground ?? this.primaryBackground,
      secondaryBackground: secondaryBackground ?? this.secondaryBackground,
      primaryText: primaryText ?? this.primaryText,
      secondaryText: secondaryText ?? this.secondaryText,
      alternate: alternate ?? this.alternate,
      positiveColor: positiveColor ?? this.positiveColor,
      negativeColor: negativeColor ?? this.negativeColor,
      bodyLarge: bodyLarge ?? this.bodyLarge,
      bodyMedium: bodyMedium ?? this.bodyMedium,
      bodySmall: bodySmall ?? this.bodySmall,
    );
  }
}
