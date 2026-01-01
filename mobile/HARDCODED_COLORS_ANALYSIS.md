# Comprehensive Hardcoded Colors Analysis

## Summary
This report identifies ALL remaining hardcoded colors in the codebase that need to be replaced with theme-aware colors.

**Total Files with Hardcoded Colors:** 40+ files
**Total AppTheme Hardcoded Colors:** 284 instances
**Total Colors.* Hardcoded Colors:** 294 instances

---

## Files with Most Issues

### 🔴 Critical Priority (High Usage Screens)

1. **place_detail_screen.dart** - 17 AppTheme instances
   - AppTheme.primaryColor (multiple)
   - AppTheme.backgroundColor (multiple)
   - AppTheme.secondaryTextColor
   - AppTheme.primaryTextColor

2. **dining_booking_screen.dart** - 17 AppTheme instances
   - AppTheme.primaryColor (multiple)
   - AppTheme.primaryTextColor
   - AppTheme.secondaryTextColor
   - Colors.grey[400], Colors.grey[300]

3. **accommodation_booking_screen.dart** - 16 AppTheme instances
   - AppTheme.primaryColor (multiple)
   - AppTheme.backgroundColor (multiple)

4. **User Data Collection Widgets** - 23+ instances across multiple files
   - age_range_selector.dart
   - gender_selector.dart
   - country_selector.dart
   - language_selector.dart
   - length_of_stay_selector.dart
   - travel_party_selector.dart
   - visit_purpose_selector.dart
   - interests_chips.dart

### 🟡 Medium Priority

5. **explore_screen.dart** - 6 AppTheme instances + Colors.*
6. **accommodation_screen.dart** - 1 AppTheme + Colors.*
7. **accommodation_detail_screen.dart** - 1 AppTheme + Colors.*
8. **listing_detail_screen.dart** - 1 AppTheme + Colors.*
9. **my_bookings_screen.dart** - 2 AppTheme + Colors.*
10. **profile_screen.dart** - Colors.*
11. **events_screen.dart** - Colors.*
12. **event_detail_screen.dart** - Colors.*

### 🟢 Lower Priority (Widgets & Less Used Screens)

13. **Core Widgets:**
   - place_card.dart
   - fade_in_image.dart

14. **Specialized Screens:**
   - specials_screen.dart
   - map_screen.dart
   - dining_booking_confirmation_screen.dart
   - transaction_history_screen.dart
   - zoea_card_screen.dart
   - referral_screen.dart
   - settings_screen.dart

---

## Common Patterns Found

### Pattern 1: AppTheme.primaryColor
```dart
// ❌ WRONG
color: AppTheme.primaryColor
backgroundColor: AppTheme.backgroundColor
backgroundColor: AppTheme.backgroundColor
// ✅ CORRECT
color: context.primaryColorTheme
backgroundColor: context.backgroundColor
```

### Pattern 2: AppTheme Text Colors
```dart
// ❌ WRONG
color: AppTheme.primaryTextColor
color: AppTheme.secondaryTextColor
// ✅ CORRECT
color: context.primaryTextColor
color: context.secondaryTextColor
```

### Pattern 3: Colors.grey
```dart
// ❌ WRONG
Colors.grey[300]
Colors.grey[400]
// ✅ CORRECT
context.grey300
context.grey400
```

### Pattern 4: Colors.white/black with Opacity
```dart
// ❌ WRONG (on dark backgrounds)
Colors.white
Colors.black.withOpacity(0.1)
// ✅ CORRECT
context.isDarkMode ? Colors.white : Colors.white
context.isDarkMode ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.05)
```

---

## Next Steps

1. Fix place_detail_screen.dart (17 instances)
2. Fix dining_booking_screen.dart (17 instances)
3. Fix accommodation_booking_screen.dart (16 instances)
4. Fix all user data collection widgets (23+ instances)
5. Fix remaining screens systematically

