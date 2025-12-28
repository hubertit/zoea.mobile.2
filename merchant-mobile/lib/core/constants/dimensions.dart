import 'package:flutter/material.dart';

/// Standardized dimensions matching the consumer app
class Dimensions {
  // Screen padding (horizontal)
  static const double screenPadding = 16.0;
  
  // Card internal padding
  static const double cardPadding = 12.0;
  static const double cardPaddingLarge = 16.0;
  static const double cardPaddingXLarge = 20.0;
  
  // Bottom sheet padding
  static const double bottomSheetPadding = 24.0;
  
  // List item spacing
  static const double listItemSpacing = 12.0;
  static const double listItemSpacingLarge = 16.0;
  
  // Horizontal list item margin
  static const double horizontalListItemMargin = 12.0;
  
  // Badge padding
  static const double badgePaddingH = 8.0;
  static const double badgePaddingV = 4.0;
  static const double badgePaddingHSmall = 6.0;
  static const double badgePaddingVSmall = 2.0;
  
  // Icon sizes
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 20.0;
  static const double iconSizeLarge = 24.0;
  static const double iconSizeXLarge = 32.0;
  
  // Avatar sizes
  static const double avatarSizeSmall = 32.0;
  static const double avatarSizeMedium = 40.0;
  static const double avatarSizeLarge = 48.0;
  static const double avatarSizeXLarge = 64.0;
  
  // Border radius
  static const double radiusSmall = 4.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 12.0;
  static const double radiusXLarge = 16.0;
  static const double radiusXXLarge = 24.0;
  
  // Common EdgeInsets
  static const EdgeInsets screenHorizontal = EdgeInsets.symmetric(horizontal: screenPadding);
  static const EdgeInsets screenAll = EdgeInsets.all(screenPadding);
  static const EdgeInsets cardAll = EdgeInsets.all(cardPadding);
  static const EdgeInsets cardAllLarge = EdgeInsets.all(cardPaddingLarge);
  static const EdgeInsets bottomSheetAll = EdgeInsets.all(bottomSheetPadding);
  
  // Common spacing SizedBoxes
  static const SizedBox vSpace4 = SizedBox(height: 4);
  static const SizedBox vSpace8 = SizedBox(height: 8);
  static const SizedBox vSpace12 = SizedBox(height: 12);
  static const SizedBox vSpace16 = SizedBox(height: 16);
  static const SizedBox vSpace20 = SizedBox(height: 20);
  static const SizedBox vSpace24 = SizedBox(height: 24);
  static const SizedBox vSpace32 = SizedBox(height: 32);
  
  static const SizedBox hSpace4 = SizedBox(width: 4);
  static const SizedBox hSpace8 = SizedBox(width: 8);
  static const SizedBox hSpace12 = SizedBox(width: 12);
  static const SizedBox hSpace16 = SizedBox(width: 16);
}

