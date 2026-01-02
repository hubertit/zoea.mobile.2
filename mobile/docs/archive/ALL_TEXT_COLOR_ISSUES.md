# All Text Color Issues - Dark Mode Readability

## Summary
**Total Issues Found: 664 instances** across 50+ files

## Problem
Text using `AppTheme` styles with `copyWith()` that includes `fontWeight` but NOT `color` will use static hardcoded colors that don't adapt to dark mode, making them unreadable.

## Pattern to Fix
```dart
// ❌ Problem - no color specified
style: AppTheme.titleMedium.copyWith(
  fontWeight: FontWeight.w600,
)

// ✅ Fixed - explicit theme-aware color
style: AppTheme.titleMedium.copyWith(
  fontWeight: FontWeight.w600,
  color: context.primaryTextColor,
)
```

## Files by Issue Count (Top 30)

1. **privacy_security_screen.dart** - 42 instances
2. **accommodation_detail_screen.dart** - 42 instances
3. **my_bookings_screen.dart** - 33 instances
4. **listing_detail_screen.dart** - 33 instances
5. **accommodation_screen.dart** - 32 instances
6. **explore_screen.dart** - 28 instances
7. **accommodation_booking_screen.dart** - 25 instances
8. **help_center_screen.dart** - 24 instances
9. **dining_booking_screen.dart** - 24 instances
10. **place_detail_screen.dart** - 22 instances
11. **about_screen.dart** - 21 instances
12. **search_screen.dart** - 19 instances
13. **category_search_screen.dart** - 19 instances
14. **profile_screen.dart** - 18 instances
15. **category_places_screen.dart** - 17 instances
16. **events_screen.dart** - 17 instances
17. **booking_confirmation_screen.dart** - 16 instances
18. **favorites_screen.dart** - 14 instances
19. **edit_profile_screen.dart** - 14 instances
20. **dining_screen.dart** - 14 instances
21. **event_detail_screen.dart** - 14 instances
22. **referral_screen.dart** - 13 instances
23. **dining_booking_confirmation_screen.dart** - 13 instances
24. **onboarding_data_screen.dart** - 12 instances
25. **reviews_written_screen.dart** - 11 instances
26. **experiences_screen.dart** - 11 instances
27. **nightlife_screen.dart** - 9 instances
28. **visited_places_screen.dart** - 8 instances
29. **reviews_ratings_screen.dart** - 8 instances
30. **events_attended_screen.dart** - 7 instances

## Categories

### High Priority (User-Facing Screens)
- Profile screens (privacy_security, my_bookings, favorites, edit_profile, etc.)
- Explore screens (accommodation_detail, accommodation_screen, place_detail, etc.)
- Booking screens (accommodation_booking, dining_booking, booking_confirmation)
- Auth screens (login, password reset, etc.)
- User data collection screens

### Medium Priority
- Event screens
- Listing screens
- Search screens

## Status
- **Fixed**: 7 critical screens (help_center, about, favorites, place_card, dining_booking_confirmation, events_attended, accommodation_booking)
- **Remaining**: 664 instances across 50+ files
- **Next Steps**: Fix systematically, starting with highest count files
