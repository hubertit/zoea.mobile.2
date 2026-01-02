# 🔧 Text Style Fix - Find & Replace Guide

## Quick Fix for All 65 Files

Use your IDE's "Find in Files" and "Replace in Files" feature:

### Step 1: Add Import to All Files

**Find:**
```dart
import '../../../core/theme/theme_extensions.dart';
```

**Replace with:**
```dart
import '../../../core/theme/theme_extensions.dart';
import '../../../core/theme/text_theme_extensions.dart';
```

**OR if path is different, find:**
```dart
import '../../core/theme/theme_extensions.dart';
```

**Replace with:**
```dart
import '../../core/theme/theme_extensions.dart';
import '../../core/theme/text_theme_extensions.dart';
```

### Step 2: Replace All AppTheme Text Styles

Run these replacements **in order** (use regex if your IDE supports it):

1. **Replace displayLarge:**
   - Find: `AppTheme.displayLarge`
   - Replace: `context.displayLarge`

2. **Replace displayMedium:**
   - Find: `AppTheme.displayMedium`
   - Replace: `context.displayMedium`

3. **Replace displaySmall:**
   - Find: `AppTheme.displaySmall`
   - Replace: `context.displaySmall`

4. **Replace headlineLarge:**
   - Find: `AppTheme.headlineLarge`
   - Replace: `context.headlineLarge`

5. **Replace headlineMedium:**
   - Find: `AppTheme.headlineMedium`
   - Replace: `context.headlineMedium`

6. **Replace headlineSmall:**
   - Find: `AppTheme.headlineSmall`
   - Replace: `context.headlineSmall`

7. **Replace titleLarge:**
   - Find: `AppTheme.titleLarge`
   - Replace: `context.titleLarge`

8. **Replace titleMedium:**
   - Find: `AppTheme.titleMedium`
   - Replace: `context.titleMedium`

9. **Replace titleSmall:**
   - Find: `AppTheme.titleSmall`
   - Replace: `context.titleSmall`

10. **Replace bodyLarge:**
    - Find: `AppTheme.bodyLarge`
    - Replace: `context.bodyLarge`

11. **Replace bodyMedium:**
    - Find: `AppTheme.bodyMedium`
    - Replace: `context.bodyMedium`

12. **Replace bodySmall:**
    - Find: `AppTheme.bodySmall`
    - Replace: `context.bodySmall`

13. **Replace labelLarge:**
    - Find: `AppTheme.labelLarge`
    - Replace: `context.labelLarge`

14. **Replace labelMedium:**
    - Find: `AppTheme.labelMedium`
    - Replace: `context.labelMedium`

15. **Replace labelSmall:**
    - Find: `AppTheme.labelSmall`
    - Replace: `context.labelSmall`

### Step 3: Handle .copyWith() Cases

Some files already have `.copyWith(color: context.primaryTextColor)` - these can be simplified:

**Find (regex):**
```regex
context\.(titleLarge|bodyMedium|headlineSmall|etc)\.copyWith\(\s*color: context\.primaryTextColor,?\s*\)
```

**Replace with:**
```dart
context.$1
```

This removes the redundant `.copyWith(color: ...)` since the extension already includes the correct color.

### Step 4: Test

After replacements:
1. Run `flutter pub get`
2. Run `flutter analyze` to check for errors
3. Test a few screens in both light and dark mode
4. Verify text is readable in both modes

## Files That Need Updating (All 65)

### Critical Priority (29 files):
- [x] profile_screen.dart ✅ FIXED
- [ ] explore_screen.dart
- [ ] event_detail_screen.dart
- [ ] place_detail_screen.dart
- [ ] accommodation_detail_screen.dart
- [ ] accommodation_screen.dart
- [ ] accommodation_booking_screen.dart
- [ ] dining_booking_screen.dart
- [ ] dining_booking_confirmation_screen.dart
- [ ] dining_screen.dart
- [ ] category_places_screen.dart
- [ ] nightlife_screen.dart
- [ ] recommendations_screen.dart
- [ ] tour_booking_screen.dart
- [ ] category_search_screen.dart
- [ ] experiences_screen.dart
- [ ] shopping_screen.dart
- [ ] specials_screen.dart
- [ ] my_bookings_screen.dart
- [ ] favorites_screen.dart
- [ ] settings_screen.dart
- [ ] about_screen.dart
- [ ] events_attended_screen.dart
- [ ] help_center_screen.dart
- [ ] reviews_ratings_screen.dart
- [ ] reviews_written_screen.dart
- [ ] visited_places_screen.dart
- [ ] edit_profile_screen.dart
- [ ] privacy_security_screen.dart

### Medium Priority (17 files):
- [ ] login_screen.dart
- [ ] register_screen (if exists)
- [ ] request_password_reset_screen.dart
- [ ] verify_reset_code_screen.dart
- [ ] new_password_screen.dart
- [ ] maintenance_screen.dart
- [ ] splash_screen.dart
- [ ] onboarding_screen (if exists)
- [ ] events_screen.dart
- [ ] event_calendar_sheet.dart
- [ ] event_filter_sheet.dart
- [ ] All shop screens (9 files)

### Low Priority (19+ files):
- [ ] listing_detail_screen.dart
- [ ] listings_screen.dart
- [ ] All user_data_collection widgets (8 files)
- [ ] notifications_screen.dart
- [ ] search_screen.dart
- [ ] referral_screen.dart
- [ ] booking_confirmation_screen.dart
- [ ] place_card.dart
- [ ] Others

## Alternative: Script to Do It All

If you want, I can create a script to update all files automatically. Let me know!

## Summary

**Total Files:** 65  
**Estimated Time:** 15-30 minutes if using Find & Replace in Files  
**Impact:** Makes ALL text readable in dark mode  
**Priority:** CRITICAL - affects entire app usability

After this fix, your app will have perfect text readability in both light and dark modes! 🎉

