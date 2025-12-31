import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Primary Color (used in both light and dark)
  static const Color primaryColor = Color(0xFF181E29);
  
  // Light Mode Colors
  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color primaryTextColor = Color(0xFF181E29);
  static const Color secondaryTextColor = Color(0xFF6C727F);
  static const Color dividerColor = Color(0xFFE9E9EC);
  static const Color successColor = Color(0xFF009E60);
  static const Color errorColor = Color(0xFFD9534F);
  static const Color warningColor = Color(0xFFFFA500);
  static const Color infoColor = Color(0xFF2196F3);
  
  // Light Mode Grey Shades
  static const Color lightGrey50 = Color(0xFFF9FAFB);
  static const Color lightGrey100 = Color(0xFFF3F4F6);
  static const Color lightGrey200 = Color(0xFFE5E7EB);
  static const Color lightGrey300 = Color(0xFFD1D5DB);
  static const Color lightGrey400 = Color(0xFF9CA3AF);
  static const Color lightGrey500 = Color(0xFF6B7280);
  
  // Dark Mode Colors - Based on primary color (0xFF181E29)
  // Using a sophisticated dark palette that complements the primary blue-gray
  static const Color darkBackgroundColor = Color(0xFF0F1217); // Slightly lighter than pure black, with blue tint
  static const Color darkSurfaceColor = Color(0xFF1A1D24); // Surface color with primary color influence
  static const Color darkCardColor = Color(0xFF232730); // Card color - slightly lighter than surface
  static const Color darkPrimaryTextColor = Color(0xFFF5F7FA); // Off-white for better readability
  static const Color darkSecondaryTextColor = Color(0xFF9CA3AF); // Muted grey for secondary text
  static const Color darkDividerColor = Color(0xFF2D3239); // Divider with primary color influence
  static const Color darkBorderColor = Color(0xFF2D3239);
  
  // Dark Mode Grey Shades
  static const Color darkGrey50 = Color(0xFF2D3239);
  static const Color darkGrey100 = Color(0xFF3A3F47);
  static const Color darkGrey200 = Color(0xFF4A4F57);
  static const Color darkGrey300 = Color(0xFF5A5F67);
  static const Color darkGrey400 = Color(0xFF6A6F77);
  static const Color darkGrey500 = Color(0xFF8A8F97);
  
  // Dark Mode Accent Colors (lighter versions for dark mode)
  static const Color darkSuccessColor = Color(0xFF00C973);
  static const Color darkErrorColor = Color(0xFFE57373);
  static const Color darkWarningColor = Color(0xFFFFB74D);
  static const Color darkInfoColor = Color(0xFF64B5F6);

  // Typography
  static const String fontFamily = 'AirbnbCereal';

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        primary: primaryColor,
        surface: backgroundColor,
        onSurface: primaryTextColor,
        secondary: secondaryTextColor,
        error: errorColor,
      ),
      textTheme: _buildTextTheme(),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: primaryTextColor,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: backgroundColor,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
      ),
      cardTheme: CardTheme(
        color: backgroundColor,
        elevation: 2,
        shadowColor: primaryColor.withOpacity(0.05),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: backgroundColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
        primary: primaryColor,
        surface: darkSurfaceColor,
        onSurface: darkPrimaryTextColor,
        secondary: darkSecondaryTextColor,
        error: darkErrorColor,
        onPrimary: darkPrimaryTextColor,
        onSecondary: darkPrimaryTextColor,
        onError: darkPrimaryTextColor,
      ),
      scaffoldBackgroundColor: darkBackgroundColor,
      textTheme: _buildDarkTextTheme(),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkSurfaceColor,
        foregroundColor: darkPrimaryTextColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: darkPrimaryTextColor),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: darkPrimaryTextColor,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      cardTheme: CardTheme(
        color: darkCardColor,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: darkDividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: darkDividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: darkErrorColor),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkSurfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: darkSecondaryTextColor,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      dividerTheme: const DividerThemeData(
        color: darkDividerColor,
        thickness: 1,
        space: 1,
      ),
      iconTheme: const IconThemeData(
        color: darkPrimaryTextColor,
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: darkPrimaryTextColor,
      ),
    );
  }
  
  // Helper methods to get theme-aware colors
  static Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkBackgroundColor
        : backgroundColor;
  }
  
  static Color getSurfaceColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkSurfaceColor
        : backgroundColor;
  }
  
  static Color getCardColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkCardColor
        : backgroundColor;
  }
  
  static Color getPrimaryTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkPrimaryTextColor
        : primaryTextColor;
  }
  
  static Color getSecondaryTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkSecondaryTextColor
        : secondaryTextColor;
  }
  
  static Color getDividerColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkDividerColor
        : dividerColor;
  }
  
  static Color getBorderColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkBorderColor
        : dividerColor;
  }
  
  static Color getGrey50(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkGrey50
        : lightGrey50;
  }
  
  static Color getGrey100(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkGrey100
        : lightGrey100;
  }
  
  static Color getGrey200(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkGrey200
        : lightGrey200;
  }
  
  static Color getGrey300(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkGrey300
        : lightGrey300;
  }
  
  static Color getSuccessColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkSuccessColor
        : successColor;
  }
  
  static Color getErrorColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkErrorColor
        : errorColor;
  }

  // Spacing
  static const double spacing2 = 2.0;
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;

  // Border Radius
  static const double borderRadius4 = 4.0;
  static const double borderRadius8 = 8.0;
  static const double borderRadius12 = 12.0;
  static const double borderRadius16 = 16.0;
  static const double borderRadius24 = 24.0;

  // Text Style Getters
  static TextStyle get displayLarge => GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: primaryTextColor,
    letterSpacing: -0.5,
  );

  static TextStyle get displayMedium => GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: primaryTextColor,
    letterSpacing: -0.5,
  );

  static TextStyle get displaySmall => GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: primaryTextColor,
    letterSpacing: -0.5,
  );

  static TextStyle get headlineLarge => GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: primaryTextColor,
    letterSpacing: 0,
  );

  static TextStyle get headlineMedium => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: primaryTextColor,
    letterSpacing: 0,
  );

  static TextStyle get headlineSmall => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: primaryTextColor,
    letterSpacing: 0,
  );

  static TextStyle get titleLarge => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: primaryTextColor,
    letterSpacing: 0,
  );

  static TextStyle get titleMedium => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: primaryTextColor,
    letterSpacing: 0,
  );

  static TextStyle get titleSmall => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: primaryTextColor,
    letterSpacing: 0,
  );

  static TextStyle get bodyLarge => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: primaryTextColor,
    letterSpacing: 0,
  );

  static TextStyle get bodyMedium => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: primaryTextColor,
    letterSpacing: 0,
  );

  static TextStyle get bodySmall => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: secondaryTextColor,
    letterSpacing: 0,
  );

  static TextStyle get labelLarge => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: primaryTextColor,
    letterSpacing: 0,
  );

  static TextStyle get labelMedium => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: secondaryTextColor,
    letterSpacing: 0,
  );

  static TextStyle get labelSmall => GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: secondaryTextColor,
    letterSpacing: 0,
  );

  // Snackbar Helper Methods
  static SnackBar successSnackBar({
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return SnackBar(
      content: Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: successColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius8),
      ),
      margin: const EdgeInsets.all(spacing16),
      action: actionLabel != null
          ? SnackBarAction(
              label: actionLabel,
              textColor: Colors.white,
              onPressed: onAction ?? () {},
            )
          : null,
    );
  }

  static SnackBar errorSnackBar({
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return SnackBar(
      content: Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: errorColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius8),
      ),
      margin: const EdgeInsets.all(spacing16),
      action: actionLabel != null
          ? SnackBarAction(
              label: actionLabel,
              textColor: Colors.white,
              onPressed: onAction ?? () {},
            )
          : null,
    );
  }

  static TextTheme _buildTextTheme() {
    return GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: primaryTextColor,
        letterSpacing: -0.5,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: primaryTextColor,
        letterSpacing: -0.5,
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: primaryTextColor,
        letterSpacing: -0.5,
      ),
      headlineLarge: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: primaryTextColor,
        letterSpacing: -0.5,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: primaryTextColor,
        letterSpacing: -0.5,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: primaryTextColor,
        letterSpacing: -0.5,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: primaryTextColor,
        letterSpacing: -0.5,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: primaryTextColor,
        letterSpacing: -0.5,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: primaryTextColor,
        letterSpacing: -0.5,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: primaryTextColor,
        letterSpacing: 0,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: primaryTextColor,
        letterSpacing: 0,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: secondaryTextColor,
        letterSpacing: 0,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: primaryTextColor,
        letterSpacing: 0,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: secondaryTextColor,
        letterSpacing: 0,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: secondaryTextColor,
        letterSpacing: 0,
      ),
    );
  }

  static TextTheme _buildDarkTextTheme() {
    return GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: darkPrimaryTextColor,
        letterSpacing: -0.5,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: darkPrimaryTextColor,
        letterSpacing: -0.5,
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: darkPrimaryTextColor,
        letterSpacing: -0.5,
      ),
      headlineLarge: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: darkPrimaryTextColor,
        letterSpacing: 0,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: darkPrimaryTextColor,
        letterSpacing: 0,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: darkPrimaryTextColor,
        letterSpacing: 0,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: darkPrimaryTextColor,
        letterSpacing: 0,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: darkPrimaryTextColor,
        letterSpacing: 0,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: darkPrimaryTextColor,
        letterSpacing: 0,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: darkPrimaryTextColor,
        letterSpacing: 0,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: darkPrimaryTextColor,
        letterSpacing: 0,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: darkSecondaryTextColor,
        letterSpacing: 0,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: darkPrimaryTextColor,
        letterSpacing: 0,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: darkSecondaryTextColor,
        letterSpacing: 0,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: darkSecondaryTextColor,
        letterSpacing: 0,
      ),
    );
  }
}
