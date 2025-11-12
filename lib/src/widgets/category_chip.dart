import 'package:deriv_explore_markets/src/theme/market_display_theme.dart';
import 'package:flutter/material.dart';

/// A chip widget for displaying and selecting market categories.
///
/// Used in market display widgets to show selectable category options.
class CategoryChip extends StatelessWidget {
  /// Creates a category chip.
  const CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.theme,
    super.key,
  });

  /// The text label displayed on the chip.
  final String label;

  /// Whether this chip is currently selected.
  final bool isSelected;

  /// Callback when the chip is tapped.
  final VoidCallback onTap;

  /// Theme configuration for styling the chip.
  final MarketDisplayTheme theme;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 32, maxHeight: 32),
        child: Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: ShapeDecoration(
            color: isSelected ? theme.primaryColor : Colors.transparent,
            shape: RoundedRectangleBorder(
              side: isSelected
                  ? BorderSide.none
                  : BorderSide(
                      color: theme.primaryText.withValues(alpha: 0.08),
                    ),
              borderRadius: BorderRadius.circular(96),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : theme.primaryText.withValues(alpha: 0.72),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.43,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
