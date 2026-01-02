import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme_extensions.dart';

/// Extension methods for theme-aware text styles
/// These automatically adapt to light/dark mode by using context
extension TextThemeExtensions on BuildContext {
  // Display Styles
  TextStyle get displayLarge => GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: primaryTextColor,  // Uses context.primaryTextColor
    letterSpacing: -0.5,
  );

  TextStyle get displayMedium => GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: primaryTextColor,
    letterSpacing: -0.5,
  );

  TextStyle get displaySmall => GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: primaryTextColor,
    letterSpacing: -0.5,
  );

  // Headline Styles
  TextStyle get headlineLarge => GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: primaryTextColor,
    letterSpacing: 0,
  );

  TextStyle get headlineMedium => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: primaryTextColor,
    letterSpacing: 0,
  );

  TextStyle get headlineSmall => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: primaryTextColor,
    letterSpacing: 0,
  );

  // Title Styles
  TextStyle get titleLarge => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: primaryTextColor,
    letterSpacing: 0,
  );

  TextStyle get titleMedium => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: primaryTextColor,
    letterSpacing: 0,
  );

  TextStyle get titleSmall => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: primaryTextColor,
    letterSpacing: 0,
  );

  // Body Styles
  TextStyle get bodyLarge => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: primaryTextColor,
    letterSpacing: 0,
  );

  TextStyle get bodyMedium => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: primaryTextColor,
    letterSpacing: 0,
  );

  TextStyle get bodySmall => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: secondaryTextColor,
    letterSpacing: 0,
  );

  // Label Styles
  TextStyle get labelLarge => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: primaryTextColor,
    letterSpacing: 0,
  );

  TextStyle get labelMedium => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: secondaryTextColor,
    letterSpacing: 0,
  );

  TextStyle get labelSmall => GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: secondaryTextColor,
    letterSpacing: 0,
  );
}

