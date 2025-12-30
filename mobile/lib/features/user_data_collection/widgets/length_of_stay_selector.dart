import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/user.dart';

/// Widget for selecting length of stay
/// Uses chip-based selection with horizontal scrollable chips
class LengthOfStaySelector extends StatelessWidget {
  final LengthOfStay? selectedLength;
  final Function(LengthOfStay) onLengthSelected;

  const LengthOfStaySelector({
    super.key,
    required this.selectedLength,
    required this.onLengthSelected,
  });

  @override
  Widget build(BuildContext context) {
    final allLengths = LengthOfStay.values;

    return Wrap(
      spacing: AppTheme.spacing8,
      runSpacing: AppTheme.spacing8,
      children: allLengths.map((length) {
        final isSelected = selectedLength == length;

        return FilterChip(
          avatar: Icon(
            Icons.calendar_today,
            size: 18,
            color: isSelected
                ? AppTheme.primaryColor
                : AppTheme.secondaryTextColor,
          ),
          label: Text(
            length.displayName,
            style: AppTheme.bodyMedium.copyWith(
              color: isSelected
                  ? AppTheme.primaryColor
                  : AppTheme.primaryTextColor,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          selected: isSelected,
          onSelected: (_) => onLengthSelected(length),
          selectedColor: AppTheme.primaryColor.withOpacity(0.2),
          checkmarkColor: AppTheme.primaryColor,
          backgroundColor: AppTheme.backgroundColor,
          side: BorderSide(
            color: isSelected
                ? AppTheme.primaryColor
                : AppTheme.dividerColor,
            width: isSelected ? 2 : 1,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacing16,
            vertical: AppTheme.spacing12,
          ),
        );
      }).toList(),
    );
  }
}

