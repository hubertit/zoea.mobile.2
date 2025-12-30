import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/user.dart';

/// Widget for selecting visit purpose (Leisure, Business, MICE)
/// Uses large card-based selection
class VisitPurposeSelector extends StatelessWidget {
  final VisitPurpose? selectedPurpose;
  final Function(VisitPurpose) onPurposeSelected;

  const VisitPurposeSelector({
    super.key,
    required this.selectedPurpose,
    required this.onPurposeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildPurposeCard(
          purpose: VisitPurpose.leisure,
          icon: Icons.beach_access,
          title: 'Leisure',
          subtitle: 'Exploring and enjoying Rwanda',
          color: AppTheme.successColor,
        ),
        const SizedBox(height: AppTheme.spacing16),
        _buildPurposeCard(
          purpose: VisitPurpose.business,
          icon: Icons.business_center,
          title: 'Business',
          subtitle: 'Work and professional travel',
          color: AppTheme.primaryColor,
        ),
        const SizedBox(height: AppTheme.spacing16),
        _buildPurposeCard(
          purpose: VisitPurpose.mice,
          icon: Icons.event,
          title: 'MICE',
          subtitle: 'Meetings, Incentives, Conferences, Exhibitions',
          color: const Color(0xFF9C27B0), // Purple for MICE
        ),
      ],
    );
  }

  Widget _buildPurposeCard({
    required VisitPurpose purpose,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    final isSelected = selectedPurpose == purpose;

    return GestureDetector(
      onTap: () => onPurposeSelected(purpose),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppTheme.spacing24),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.1)
              : AppTheme.backgroundColor,
          borderRadius: BorderRadius.circular(AppTheme.borderRadius16),
          border: Border.all(
            color: isSelected ? color : AppTheme.dividerColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacing12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.borderRadius12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 32,
              ),
            ),
            const SizedBox(width: AppTheme.spacing16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.headlineMedium.copyWith(
                      color: isSelected ? color : AppTheme.primaryTextColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing4),
                  Text(
                    subtitle,
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: color,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}

