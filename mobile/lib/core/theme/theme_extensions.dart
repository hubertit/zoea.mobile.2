import 'package:flutter/material.dart';
import 'app_theme.dart';

/// Extension methods for easy access to theme-aware colors
extension ThemeColors on BuildContext {
  /// Get background color based on current theme
  Color get backgroundColor => AppTheme.getBackgroundColor(this);
  
  /// Get surface color based on current theme
  Color get surfaceColor => AppTheme.getSurfaceColor(this);
  
  /// Get card color based on current theme
  Color get cardColor => AppTheme.getCardColor(this);
  
  /// Get primary text color based on current theme
  Color get primaryTextColor => AppTheme.getPrimaryTextColor(this);
  
  /// Get secondary text color based on current theme
  Color get secondaryTextColor => AppTheme.getSecondaryTextColor(this);
  
  /// Get divider color based on current theme
  Color get dividerColor => AppTheme.getDividerColor(this);
  
  /// Get border color based on current theme
  Color get borderColor => AppTheme.getBorderColor(this);
  
  /// Get grey50 color based on current theme
  Color get grey50 => AppTheme.getGrey50(this);
  
  /// Get grey100 color based on current theme
  Color get grey100 => AppTheme.getGrey100(this);
  
  /// Get grey200 color based on current theme
  Color get grey200 => AppTheme.getGrey200(this);
  
  /// Get grey300 color based on current theme
  Color get grey300 => AppTheme.getGrey300(this);
  
  /// Get success color based on current theme
  Color get successColor => AppTheme.getSuccessColor(this);
  
  /// Get error color based on current theme
  Color get errorColor => AppTheme.getErrorColor(this);
  
  /// Check if current theme is dark
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
  
  /// Check if current theme is light
  bool get isLightMode => Theme.of(this).brightness == Brightness.light;
}

/// Extension for ColorScheme to get theme-aware colors
extension ColorSchemeExtension on ColorScheme {
  /// Get card color based on brightness
  Color get cardColor => brightness == Brightness.dark
      ? AppTheme.darkCardColor
      : AppTheme.backgroundColor;
  
  /// Get surface variant color
  Color get surfaceVariant => brightness == Brightness.dark
      ? AppTheme.darkGrey50
      : AppTheme.lightGrey100;
}

