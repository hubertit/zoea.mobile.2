import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Widget for selecting interests (multi-select)
/// Uses chip-based selection with wrap layout
class InterestsChips extends StatelessWidget {
  final List<String> selectedInterests;
  final Function(List<String>) onInterestsChanged;

  const InterestsChips({
    super.key,
    required this.selectedInterests,
    required this.onInterestsChanged,
  });

  // Common interests for tourism
  static const List<Map<String, String>> _allInterests = [
    {'id': 'adventure', 'name': 'Adventure', 'icon': '🏔️'},
    {'id': 'culture', 'name': 'Culture', 'icon': '🎭'},
    {'id': 'nature', 'name': 'Nature', 'icon': '🌿'},
    {'id': 'wildlife', 'name': 'Wildlife', 'icon': '🦁'},
    {'id': 'food', 'name': 'Food & Dining', 'icon': '🍽️'},
    {'id': 'nightlife', 'name': 'Nightlife', 'icon': '🌃'},
    {'id': 'shopping', 'name': 'Shopping', 'icon': '🛍️'},
    {'id': 'beaches', 'name': 'Beaches', 'icon': '🏖️'},
    {'id': 'history', 'name': 'History', 'icon': '🏛️'},
    {'id': 'photography', 'name': 'Photography', 'icon': '📸'},
    {'id': 'wellness', 'name': 'Wellness & Spa', 'icon': '🧘'},
    {'id': 'sports', 'name': 'Sports', 'icon': '⚽'},
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppTheme.spacing8,
      runSpacing: AppTheme.spacing8,
      children: _allInterests.map((interest) {
        final interestId = interest['id']!;
        final isSelected = selectedInterests.contains(interestId);

        return FilterChip(
          avatar: Text(
            interest['icon']!,
            style: const TextStyle(fontSize: 18),
          ),
          label: Text(
            interest['name']!,
            style: AppTheme.bodyMedium.copyWith(
              color: isSelected
                  ? AppTheme.primaryColor
                  : AppTheme.primaryTextColor,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          selected: isSelected,
          onSelected: (selected) {
            final updated = List<String>.from(selectedInterests);
            if (selected) {
              if (!updated.contains(interestId)) {
                updated.add(interestId);
              }
            } else {
              updated.remove(interestId);
            }
            onInterestsChanged(updated);
          },
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
            horizontal: AppTheme.spacing12,
            vertical: AppTheme.spacing8,
          ),
        );
      }).toList(),
    );
  }
}

