import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/models/user.dart';

/// Widget for selecting age range
/// Uses chip-based selection with horizontal scrollable chips
class AgeRangeSelector extends StatelessWidget {
  final AgeRange? selectedRange;
  final Function(AgeRange) onRangeSelected;

  const AgeRangeSelector({
    super.key,
    required this.selectedRange,
    required this.onRangeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final allRanges = AgeRange.values;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: allRanges.map((range) {
          final isSelected = selectedRange == range;

          return Padding(
            padding: EdgeInsets.only(
              right: range != allRanges.last ? AppTheme.spacing8 : 0,
            ),
            child: FilterChip(
              label: Text(
                range.displayName,
                style: AppTheme.bodyMedium.copyWith(
                  color: isSelected
                      ? context.primaryColorTheme
                      : context.primaryTextColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              onSelected: (_) => onRangeSelected(range),
              selectedColor: context.primaryColorTheme.withOpacity(0.2),
              checkmarkColor: context.primaryColorTheme,
              backgroundColor: context.backgroundColor,
              side: BorderSide(
                color: isSelected
                    ? context.primaryColorTheme
                    : context.dividerColor,
                width: isSelected ? 2 : 1,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacing16,
                vertical: AppTheme.spacing12,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

