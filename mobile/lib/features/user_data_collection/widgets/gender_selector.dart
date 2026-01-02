import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/theme/text_theme_extensions.dart';
import '../../../core/models/user.dart';

/// Widget for selecting gender
/// Uses icon-based cards with "Prefer not to say" option
class GenderSelector extends StatelessWidget {
  final Gender? selectedGender;
  final Function(Gender) onGenderSelected;

  const GenderSelector({
    super.key,
    required this.selectedGender,
    required this.onGenderSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildGenderCard(
                context: context,
                gender: Gender.male,
                icon: Icons.person,
                label: 'Male',
              ),
            ),
            const SizedBox(width: AppTheme.spacing12),
            Expanded(
              child: _buildGenderCard(
                context: context,
                gender: Gender.female,
                icon: Icons.person_outline,
                label: 'Female',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacing12),
        Row(
          children: [
            Expanded(
              child: _buildGenderCard(
                context: context,
                gender: Gender.other,
                icon: Icons.person_outline_rounded,
                label: 'Other',
              ),
            ),
            const SizedBox(width: AppTheme.spacing12),
            Expanded(
              child: _buildGenderCard(
                context: context,
                gender: Gender.preferNotToSay,
                icon: Icons.block,
                label: 'Prefer not to say',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderCard({
    required BuildContext context,
    required Gender gender,
    required IconData icon,
    required String label,
  }) {
    final isSelected = selectedGender == gender;

    return GestureDetector(
      onTap: () => onGenderSelected(gender),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        decoration: BoxDecoration(
          color: isSelected
              ? context.primaryColorTheme.withOpacity(0.1)
              : context.backgroundColor,
          borderRadius: BorderRadius.circular(AppTheme.borderRadius16),
          border: Border.all(
            color: isSelected ? context.primaryColorTheme : context.dividerColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected
                  ? context.primaryColorTheme
                  : context.secondaryTextColor,
            ),
            const SizedBox(height: AppTheme.spacing8),
            Text(
              label,
              style: context.bodyMedium.copyWith(
                color: isSelected
                    ? context.primaryColorTheme
                    : context.primaryTextColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
            if (isSelected)
              const SizedBox(height: AppTheme.spacing4),
            if (isSelected)
              Icon(
                Icons.check_circle,
                size: 16,
                color: context.primaryColorTheme,
              ),
          ],
        ),
      ),
    );
  }
}

