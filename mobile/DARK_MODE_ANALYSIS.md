# Dark Mode Compatibility Analysis Report

## Summary
This report identifies all screens in the codebase that lack proper dark mode compatibility. Screens are flagged when they use:
- Hardcoded `AppTheme.backgroundColor`, `AppTheme.primaryTextColor`, etc. instead of theme-aware extensions
- Direct `Colors.white`, `Colors.black`, `Colors.grey[50]`, etc. without theme context
- Hardcoded `Color(0x...)` values that don't adapt to dark mode

## Screens Lacking Dark Mode Support

### 🔴 Auth Screens (8 screens)

#### 1. **splash_screen.dart**
- **Issues:**
  - Line 228: Uses `AppTheme.backgroundColor` directly → Should use `context.backgroundColor`
  - Line 263: Uses `AppTheme.primaryColor` directly (acceptable, but could use theme-aware version)
  - Line 275: Uses `AppTheme.secondaryTextColor` directly → Should use `context.secondaryTextColor`

#### 2. **onboarding_screen.dart**
- **Issues:**
  - Line 41: Uses `AppTheme.backgroundColor` directly → Should use `context.backgroundColor`
  - Line 93: Uses `AppTheme.secondaryTextColor` directly → Should use `context.secondaryTextColor`
  - Line 120: Uses `AppTheme.primaryColor` directly
  - Line 121: Uses `AppTheme.dividerColor` directly → Should use `context.dividerColor`
  - Line 159: Uses `AppTheme.secondaryTextColor` directly → Should use `context.secondaryTextColor`

#### 3. **login_screen.dart**
- **Issues:**
  - Line 460: Uses `Colors.white` directly → Should use theme-aware color
  - Line 479: Uses `Colors.white` directly → Should use theme-aware color
  - Multiple places use `AppTheme.dividerColor` directly → Should use `context.dividerColor`

#### 4. **register_screen.dart**
- **Issues:**
  - Line 89: Uses `AppTheme.backgroundColor` directly → Should use `context.backgroundColor`
  - Line 91: Uses `AppTheme.backgroundColor` directly → Should use `context.backgroundColor`
  - Line 145: Uses `AppTheme.dividerColor` directly → Should use `context.dividerColor`
  - Line 149: Uses `AppTheme.primaryColor` directly
  - Line 181: Uses `AppTheme.dividerColor` directly → Should use `context.dividerColor`
  - Line 230: Uses `AppTheme.dividerColor` directly → Should use `context.dividerColor`
  - Line 280: Uses `AppTheme.dividerColor` directly → Should use `context.dividerColor`
  - Line 361: Uses `Colors.white` directly → Should use theme-aware color
  - Line 382: Uses `AppTheme.secondaryTextColor` directly → Should use `context.secondaryTextColor`

#### 5. **request_password_reset_screen.dart**
- **Issues:**
  - Line 51: Uses `AppTheme.backgroundColor` directly → Should use `context.backgroundColor`
  - Line 64: Uses hardcoded `Color(0xFF8C98A8).withOpacity(0.2)` → Should use theme-aware color
  - Line 138: Uses `AppTheme.backgroundColor` directly → Should use `context.backgroundColor`
  - Line 140: Uses `AppTheme.backgroundColor` directly → Should use `context.backgroundColor`
  - Line 198: Uses `AppTheme.backgroundColor` directly → Should use `context.backgroundColor`
  - Line 201: Uses `AppTheme.dividerColor` directly → Should use `context.dividerColor`
  - Line 221: Uses `Colors.grey[300]` directly → Should use `context.grey300`
  - Line 266: Uses `Colors.grey[300]` directly → Should use `context.grey300`
  - Line 319: Uses `AppTheme.backgroundColor` directly → Should use `context.backgroundColor`
  - Line 322: Uses `AppTheme.dividerColor` directly → Should use `context.dividerColor`
  - Line 460: Uses `Colors.white` directly → Should use theme-aware color
  - Line 475: Uses `Colors.white` directly → Should use theme-aware color
  - Line 482: Uses `Colors.white` directly → Should use theme-aware color

#### 6. **verify_reset_code_screen.dart**
- **Issues:**
  - Line 107: Uses `AppTheme.backgroundColor` directly → Should use `context.backgroundColor`
  - Line 109: Uses `AppTheme.backgroundColor` directly → Should use `context.backgroundColor`
  - Line 202: Uses `AppTheme.backgroundColor` directly → Should use `context.backgroundColor`
  - Line 283: Uses `Colors.white` directly → Should use theme-aware color
  - Line 290: Uses `Colors.white` directly → Should use theme-aware color

#### 7. **new_password_screen.dart**
- **Issues:**
  - Line 87: Uses `AppTheme.backgroundColor` directly → Should use `context.backgroundColor`
  - Line 89: Uses `AppTheme.backgroundColor` directly → Should use `context.backgroundColor`
  - Line 168: Uses `AppTheme.dividerColor` directly → Should use `context.dividerColor`
  - Line 214: Uses `AppTheme.dividerColor` directly → Should use `context.dividerColor`
  - Line 239: Uses `Colors.white` directly → Should use theme-aware color
  - Line 254: Uses `Colors.white` directly → Should use theme-aware color
  - Line 261: Uses `Colors.white` directly → Should use theme-aware color

#### 8. **maintenance_screen.dart**
- **Issues:**
  - Line 63: Uses `AppTheme.backgroundColor` directly → Should use `context.backgroundColor`
  - Line 105: Uses `AppTheme.backgroundColor` directly → Should use `context.backgroundColor`
  - Line 201: Uses `Colors.white` directly → Should use theme-aware color
  - Line 221: Uses `Colors.white` directly → Should use theme-aware color

### 🔴 Explore Screens (10 screens)

#### 9. **nightlife_screen.dart**
- **Issues:**
  - Line 36: Uses `Colors.grey[50]` directly → Should use `context.grey50`
  - Line 38: Uses `AppTheme.backgroundColor` directly → Should use `context.backgroundColor`
  - Line 161: Uses `AppTheme.backgroundColor` directly → Should use `context.backgroundColor`
  - Line 285: Uses `AppTheme.backgroundColor` directly → Should use `context.backgroundColor`
  - Line 358: Uses `Colors.white` directly → Should use theme-aware color
  - Line 367: Uses `AppTheme.primaryColor` directly
  - Line 368: Uses `AppTheme.backgroundColor` directly → Should use `context.backgroundColor`
  - Line 369: Uses `AppTheme.dividerColor` directly → Should use `context.dividerColor`

#### 10. **recommendations_screen.dart**
- **Issues:**
  - Line 34: Uses `Colors.grey[50]` directly → Should use `context.grey50`
  - Line 36: Uses `AppTheme.backgroundColor` directly → Should use `context.backgroundColor`
  - Line 246: Uses `AppTheme.backgroundColor` directly → Should use `context.backgroundColor`
  - Line 349: Uses `AppTheme.backgroundColor` directly → Should use `context.backgroundColor`

#### 11. **category_search_screen.dart**
- **Issues:**
  - Line 49: Uses `Colors.grey[50]` directly → Should use `context.grey50`
  - Line 504: Uses `Colors.grey[200]` directly → Should use `context.grey200`
  - Line 569: Uses `Colors.amber` directly (acceptable for star ratings, but could be theme-aware)

#### 12. **explore_screen.dart**
- **Issues:**
  - Line 94-95: Uses `Colors.orange[300]` and `Colors.orange[700]` directly (intentional for animation)
  - Line 180: Uses `Colors.red` directly → Should use theme-aware error color
  - Line 273-274: Uses `Colors.black.withOpacity()` → Should check dark mode
  - Line 338: Uses `Colors.orange[600]` directly
  - Line 360-361: Uses `Colors.black.withOpacity()` → Should check dark mode
  - Line 391: Uses `Colors.red[600]` directly → Should use `context.errorColor`
  - Line 423-424: Uses `Colors.red[900]` and `Colors.red[100]` directly
  - Line 429: Uses `Colors.red[600]` directly → Should use `context.errorColor`
  - Line 451-452: Uses `Colors.black.withOpacity()` → Should check dark mode
  - Line 551: Uses `Colors.white` directly (on overlay, may be intentional)
  - Line 607: Uses `Colors.white` directly (on overlay, may be intentional)
  - Line 625: Uses `Colors.white` directly (on overlay, may be intentional)
  - Line 1306: Uses `Colors.black.withOpacity(0.1)` → Should check dark mode
  - Line 1326: Uses `Colors.grey` directly → Should use theme-aware grey
  - Line 1341: Uses `Colors.black.withOpacity(0.7)` → Should check dark mode
  - Line 1360: Uses `Colors.white` directly (on overlay)
  - Line 1371: Uses `Colors.white.withOpacity(0.8)` → Should check dark mode
  - Line 1399: Uses `Colors.black.withOpacity(0.1)` → Should check dark mode
  - Line 1419: Uses `Colors.grey` directly → Should use theme-aware grey
  - Line 1435: Uses `Colors.black.withOpacity(0.7)` → Should check dark mode
  - Line 1454: Uses `Colors.white` directly (on overlay)
  - Line 1464: Uses `Colors.white.withOpacity(0.9)` → Should check dark mode
  - Line 1473: Uses `Colors.white.withOpacity(0.8)` → Should check dark mode
  - Line 1857-1858: Uses `Colors.black.withOpacity()` → Should check dark mode
  - Line 1910: Uses `Colors.white` directly (on overlay)
  - Line 1927: Uses `Colors.black.withOpacity(0.7)` → Should check dark mode
  - Line 1935: Uses `Colors.amber` directly (star rating, acceptable)
  - Line 1942: Uses `Colors.white` directly (on overlay)
  - Line 2030: Uses `Colors.red` directly → Should use `context.errorColor`
  - Line 2217: Uses `Colors.black.withOpacity(0.05)` → Should check dark mode
  - Line 2414-2415: Uses `Colors.black.withOpacity()` → Should check dark mode

#### 13. **accommodation_screen.dart**
- **Issues:**
  - Multiple uses of `Colors.black.withOpacity(0.05)` → Should check dark mode
  - Multiple uses of `Colors.white` on overlays
  - Uses `Colors.amber` for star ratings (acceptable)
  - Uses `Colors.red` for favorites → Should use `context.errorColor`

#### 14. **dining_screen.dart**
- **Issues:**
  - Line 650: Uses `Colors.black.withOpacity(0.05)` → Should check dark mode

#### 15. **category_places_screen.dart**
- **Issues:**
  - Multiple uses of `Colors.black.withOpacity(0.05)` → Should check dark mode
  - Multiple uses of `Colors.white` on overlays
  - Uses `Colors.amber` for star ratings (acceptable)
  - Uses `Colors.red` for favorites → Should use `context.errorColor`

#### 16. **accommodation_detail_screen.dart**
- **Issues:**
  - Multiple uses of `Colors.black.withOpacity()` → Should check dark mode
  - Multiple uses of `Colors.white` on overlays (may be intentional)
  - Uses `Colors.amber` for star ratings (acceptable)
  - Line 1201: Uses `Colors.white` directly → Should use theme-aware color
  - Line 1204: Uses `Colors.white` directly → Should use theme-aware color
  - Line 1312: Uses `Colors.black.withOpacity(0.1)` → Should check dark mode
  - Line 1367: Uses `Colors.white` directly → Should use theme-aware color
  - Line 1841: Uses `Colors.white` directly → Should use theme-aware color
  - Line 1848: Uses `Colors.white` directly → Should use theme-aware color

#### 17. **place_detail_screen.dart**
- **Issues:**
  - Multiple uses of `Colors.black.withOpacity()` → Should check dark mode
  - Multiple uses of `Colors.white` on overlays
  - Uses `Colors.amber` for star ratings (acceptable)

#### 18. **listing_detail_screen.dart**
- **Issues:**
  - Line 197-199: Uses `Colors.black.withOpacity()` → Should check dark mode
  - Line 222: Uses `Colors.black.withOpacity(0.5)` → Should check dark mode
  - Line 228: Uses `Colors.white` directly (on overlay, may be intentional)
  - Line 271: Uses `Colors.black.withOpacity(0.5)` → Should check dark mode
  - Line 277: Uses `Colors.white` directly (on overlay, may be intentional)
  - Line 294: Uses `Colors.black.withOpacity(0.5)` → Should check dark mode
  - Line 300: Uses `Colors.white` directly (on overlay, may be intentional)
  - Line 421: Uses `Colors.amber` directly (star rating, acceptable)
  - Line 1186: Uses `Colors.amber` directly (star rating, acceptable)
  - Line 1563: Uses `Colors.amber` directly (star rating, acceptable)

### 🔴 Profile Screens (8 screens)

#### 19. **about_screen.dart**
- **Issues:**
  - Line 19: Uses `AppTheme.backgroundColor` directly → Should use `context.backgroundColor`
  - Line 25: Uses `AppTheme.backgroundColor` directly → Should use `context.backgroundColor`
  - Line 92: Uses `Colors.white` directly → Should use theme-aware color
  - Line 154: Uses `Colors.black.withOpacity(0.05)` → Should check dark mode
  - Line 257: Uses `Colors.black.withOpacity(0.05)` → Should check dark mode
  - Line 365: Uses `Colors.black.withOpacity(0.05)` → Should check dark mode
  - Line 470: Uses `Colors.black.withOpacity(0.05)` → Should check dark mode
  - Line 572: Uses `Colors.black.withOpacity(0.05)` → Should check dark mode

#### 20. **favorites_screen.dart**
- **Issues:**
  - Line 37: Uses `AppTheme.backgroundColor` directly → Should use `context.backgroundColor`
  - Line 43: Uses `AppTheme.backgroundColor` directly → Should use `context.backgroundColor`
  - Line 271: Uses `AppTheme.backgroundColor` directly → Should use `context.backgroundColor`
  - Line 275: Uses `Colors.black.withOpacity(0.05)` → Should check dark mode
  - Line 429: Uses `Colors.black.withOpacity(0.05)` → Should check dark mode
  - Line 564: Uses `Colors.black.withOpacity(0.05)` → Should check dark mode
  - Line 728: Uses `Colors.black.withOpacity(0.05)` → Should check dark mode
  - Line 876: Uses `Colors.black.withOpacity(0.05)` → Should check dark mode

#### 21. **events_attended_screen.dart**
- **Issues:**
  - Line 164: Uses `Colors.white` directly → Should use theme-aware color
  - Line 185: Uses `Colors.black.withOpacity(0.05)` → Should check dark mode
  - Line 239: Uses `Colors.white` directly → Should use theme-aware color
  - Line 245: Uses `Colors.white` directly → Should use theme-aware color

#### 22. **help_center_screen.dart**
- **Issues:**
  - Line 85: Uses `Colors.black.withOpacity()` with dark mode check (GOOD!)
  - Line 145: Uses `Colors.black.withOpacity()` with dark mode check (GOOD!)
  - Line 324: Uses `Colors.black.withOpacity()` with dark mode check (GOOD!)
  - Line 433: Uses `Colors.black.withOpacity()` with dark mode check (GOOD!)
  - Line 554: Uses `Colors.black.withOpacity()` with dark mode check (GOOD!)
  - Line 655: Uses `Colors.white` directly → Should use theme-aware color
  - Line 818: Uses `Colors.grey[50]` directly → Should use `context.grey50`
  - Line 820: Uses `Colors.grey[200]` directly → Should use `context.grey200`
  - Line 859: Uses `Colors.white` directly → Should use theme-aware color

#### 23. **privacy_security_screen.dart**
- **Issues:**
  - Line 301: Uses `Colors.black.withOpacity()` with dark mode check (GOOD!)
  - Line 357: Uses `Colors.black.withOpacity()` with dark mode check (GOOD!)

#### 24. **reviews_ratings_screen.dart**
- **Issues:**
  - Needs full file review (not fully analyzed)

#### 25. **reviews_written_screen.dart**
- **Issues:**
  - Needs full file review (not fully analyzed)

#### 26. **visited_places_screen.dart**
- **Issues:**
  - Needs full file review (not fully analyzed)

### 🔴 User Data Collection Screens (3 screens)

#### 27. **complete_profile_screen.dart**
- **Issues:**
  - Line 188: Uses `Colors.white` directly → Should use theme-aware color

#### 28. **onboarding_data_screen.dart**
- **Issues:**
  - Line 503: Uses `Colors.white` directly → Should use theme-aware color

#### 29. **progressive_prompt_screen.dart**
- **Issues:**
  - Line 184: Uses `Colors.white` directly → Should use theme-aware color

### 🔴 Other Screens (Needs Review)

#### 30. **shopping_screen.dart**
- **Status:** Needs full file review

#### 31. **experiences_screen.dart**
- **Status:** Needs full file review

#### 32. **specials_screen.dart**
- **Status:** Needs full file review

#### 33. **map_screen.dart**
- **Status:** Needs full file review

#### 34. **dining_booking_screen.dart**
- **Status:** Needs full file review

#### 35. **accommodation_booking_screen.dart**
- **Status:** Needs full file review

#### 36. **dining_booking_confirmation_screen.dart**
- **Status:** Needs full file review

#### 37. **booking_screen.dart**
- **Status:** Needs full file review

#### 38. **booking_confirmation_screen.dart**
- **Status:** Needs full file review

#### 39. **events_screen.dart**
- **Status:** Needs full file review

#### 40. **event_detail_screen.dart**
- **Status:** Partially reviewed - uses some theme-aware colors but may have issues

#### 41. **listings_screen.dart**
- **Status:** Needs full file review

#### 42. **webview_screen.dart**
- **Status:** Needs full file review

#### 43. **search_screen.dart**
- **Status:** Needs full file review

#### 44. **notifications_screen.dart**
- **Status:** Needs full file review

#### 45. **referral_screen.dart**
- **Status:** Needs full file review

#### 46. **zoea_card_screen.dart**
- **Status:** Needs full file review

#### 47. **transaction_history_screen.dart**
- **Status:** Needs full file review

#### 48. **my_bookings_screen.dart**
- **Status:** Needs full file review

#### 49. **edit_profile_screen.dart**
- **Status:** Needs full file review

#### 50. **profile_screen.dart**
- **Status:** Needs full file review

#### 51. **settings_screen.dart**
- **Status:** Needs full file review

## Common Patterns to Fix

### Pattern 1: Direct AppTheme Color Usage
**Problem:**
```dart
backgroundColor: AppTheme.backgroundColor
```

**Solution:**
```dart
backgroundColor: context.backgroundColor
```

### Pattern 2: Hardcoded Colors
**Problem:**
```dart
color: Colors.white
color: Colors.black.withOpacity(0.05)
color: Colors.grey[50]
```

**Solution:**
```dart
color: context.isDarkMode ? Colors.white : Colors.white  // For overlays
color: context.isDarkMode ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.05)
color: context.grey50
```

### Pattern 3: Error Colors
**Problem:**
```dart
color: Colors.red
color: Colors.red[600]
```

**Solution:**
```dart
color: context.errorColor
```

## Recommendations

1. **Replace all `AppTheme.backgroundColor`** with `context.backgroundColor`
2. **Replace all `AppTheme.primaryTextColor`** with `context.primaryTextColor`
3. **Replace all `AppTheme.secondaryTextColor`** with `context.secondaryTextColor`
4. **Replace all `AppTheme.dividerColor`** with `context.dividerColor`
5. **Replace all `Colors.grey[XX]`** with `context.greyXX`
6. **Replace all `Colors.red`** with `context.errorColor`
7. **Review all `Colors.white` and `Colors.black.withOpacity()`** usages and make them theme-aware
8. **Keep `Colors.amber` for star ratings** (acceptable as it's semantic)

## Priority

1. **High Priority:** Auth screens (users see these first)
2. **High Priority:** Explore screens (main app screens)
3. **Medium Priority:** Profile screens
4. **Low Priority:** User data collection screens (seen less frequently)

## Notes

- Some `Colors.white` usages on image overlays may be intentional for contrast
- `Colors.amber` for star ratings is acceptable as it's a semantic color
- Some screens already have partial dark mode support (help_center_screen.dart, privacy_security_screen.dart)

