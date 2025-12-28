import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/booking.dart';

/// Reusable status badge widget
class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final bool outlined;
  final bool isSmall;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.outlined = false,
    this.isSmall = false,
  });

  /// Factory constructor for booking status
  factory StatusBadge.booking(BookingStatus status) {
    return StatusBadge(
      label: status.displayName,
      color: _getBookingStatusColor(status),
    );
  }

  static Color _getBookingStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.confirmed:
        return Colors.blue;
      case BookingStatus.checkedIn:
        return AppTheme.successColor;
      case BookingStatus.completed:
        return Colors.grey;
      case BookingStatus.cancelled:
      case BookingStatus.noShow:
        return AppTheme.errorColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = isSmall ? 6.0 : 8.0;
    final verticalPadding = isSmall ? 2.0 : 4.0;
    final fontSize = isSmall ? 10.0 : 11.0;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: outlined ? Colors.transparent : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(isSmall ? 4 : 12),
        border: outlined ? Border.all(color: color) : null,
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

/// Simple pill-style badge for categories, tags, etc.
class PillBadge extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;

  const PillBadge({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTheme.secondaryTextColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: AppTheme.labelSmall.copyWith(
          color: textColor ?? AppTheme.secondaryTextColor,
        ),
      ),
    );
  }
}

