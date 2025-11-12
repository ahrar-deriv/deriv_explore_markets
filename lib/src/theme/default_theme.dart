import 'package:deriv_explore_markets/src/theme/market_display_theme.dart';
import 'package:flutter/material.dart';

/// Default theme implementations for [MarketDisplayTheme].
///
/// Provides Material Design 3 compliant light and dark themes that work
/// well with the standard Flutter Material app.
class DefaultMarketDisplayTheme {
  /// Creates a light theme with Material Design 3 colors.
  ///
  /// Uses the provided [context] to extract theme information from the
  /// current Material theme if available.
  ///
  /// Example:
  /// ```dart
  /// final theme = DefaultMarketDisplayTheme.light(context);
  /// SmartMarketDisplay(
  ///   webSocketUrl: wsUrl,
  ///   theme: theme,
  /// );
  /// ```
  static MarketDisplayTheme light(BuildContext context) {
    final materialTheme = Theme.of(context);

    return MarketDisplayTheme(
      primaryColor: materialTheme.primaryColor,
      primaryBackground: materialTheme.colorScheme.surface,
      secondaryBackground: materialTheme.colorScheme.surfaceContainerHighest,
      primaryText: materialTheme.colorScheme.onSurface,
      secondaryText: materialTheme.colorScheme.onSurfaceVariant,
      alternate: materialTheme.colorScheme.outlineVariant,
      positiveColor: const Color(0xFF10B981),
      negativeColor: const Color(0xFFEF4444),
      bodyLarge:
          materialTheme.textTheme.bodyLarge ??
          const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
      bodyMedium:
          materialTheme.textTheme.bodyMedium ??
          const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
      bodySmall:
          materialTheme.textTheme.bodySmall ??
          const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
    );
  }

  /// Creates a dark theme with Material Design 3 colors.
  ///
  /// Uses the provided [context] to extract theme information from the
  /// current Material theme if available.
  ///
  /// Example:
  /// ```dart
  /// final theme = DefaultMarketDisplayTheme.dark(context);
  /// SmartMarketDisplay(
  ///   webSocketUrl: wsUrl,
  ///   theme: theme,
  /// );
  /// ```
  static MarketDisplayTheme dark(BuildContext context) {
    final materialTheme = Theme.of(context);

    return MarketDisplayTheme(
      primaryColor: materialTheme.primaryColor,
      primaryBackground: materialTheme.colorScheme.surface,
      secondaryBackground: materialTheme.colorScheme.surfaceContainerHighest,
      primaryText: materialTheme.colorScheme.onSurface,
      secondaryText: materialTheme.colorScheme.onSurfaceVariant,
      alternate: materialTheme.colorScheme.outlineVariant,
      positiveColor: const Color(0xFF10B981),
      negativeColor: const Color(0xFFEF4444),
      bodyLarge:
          materialTheme.textTheme.bodyLarge ??
          const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
      bodyMedium:
          materialTheme.textTheme.bodyMedium ??
          const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
      bodySmall:
          materialTheme.textTheme.bodySmall ??
          const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Colors.white70,
          ),
    );
  }
}
