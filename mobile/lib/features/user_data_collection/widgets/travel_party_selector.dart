import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/user.dart';

/// Widget for selecting travel party
/// Uses icon-based cards (Solo, Couple, Family, Group)
class TravelPartySelector extends StatelessWidget {
  final TravelParty? selectedParty;
  final Function(TravelParty) onPartySelected;

  const TravelPartySelector({
    super.key,
    required this.selectedParty,
    required this.onPartySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildPartyCard(
                party: TravelParty.solo,
                icon: Icons.person,
                label: 'Solo',
                emoji: '👤',
              ),
            ),
            const SizedBox(width: AppTheme.spacing12),
            Expanded(
              child: _buildPartyCard(
                party: TravelParty.couple,
                icon: Icons.favorite,
                label: 'Couple',
                emoji: '👥',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacing12),
        Row(
          children: [
            Expanded(
              child: _buildPartyCard(
                party: TravelParty.family,
                icon: Icons.family_restroom,
                label: 'Family',
                emoji: '👨‍👩‍👧',
              ),
            ),
            const SizedBox(width: AppTheme.spacing12),
            Expanded(
              child: _buildPartyCard(
                party: TravelParty.group,
                icon: Icons.groups,
                label: 'Group',
                emoji: '👥👥',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPartyCard({
    required TravelParty party,
    required IconData icon,
    required String label,
    required String emoji,
  }) {
    final isSelected = selectedParty == party;

    return GestureDetector(
      onTap: () => onPartySelected(party),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withOpacity(0.1)
              : AppTheme.backgroundColor,
          borderRadius: BorderRadius.circular(AppTheme.borderRadius16),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : AppTheme.dividerColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(height: AppTheme.spacing8),
            Text(
              label,
              style: AppTheme.bodyMedium.copyWith(
                color: isSelected
                    ? AppTheme.primaryColor
                    : AppTheme.primaryTextColor,
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
                color: AppTheme.primaryColor,
              ),
          ],
        ),
      ),
    );
  }
}

