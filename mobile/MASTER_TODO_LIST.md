# 🎯 COMPLETE DARK MODE FIX - TODO LIST

**Project:** Zoea2 Mobile App Dark Mode Implementation  
**Goal:** Fix all dark mode issues for a clean, consistent, modern app  
**Estimated Total Time:** 4-6 hours

---

## 📋 PHASE 1: FIX CRITICAL TEXT READABILITY BUG (PRIORITY 1)
**Status:** In Progress ⏳  
**Time Estimate:** 2-3 hours  
**Impact:** Makes text readable in dark mode (currently unreadable!)

### ✅ Completed:
- [x] Create `text_theme_extensions.dart` with theme-aware text styles
- [x] Fix profile_screen.dart AppBar title
- [x] Fix favorites_screen.dart AppBar title
- [x] Fix recommendations_screen.dart all instances

### 🔴 TODO - Critical Screens (29 files):

#### Explore Screens (16 files):
- [ ] 1.1 Fix explore_screen.dart (54 instances)
- [ ] 1.2 Fix place_detail_screen.dart (28 instances)
- [ ] 1.3 Fix accommodation_screen.dart (45 instances)
- [ ] 1.4 Fix accommodation_detail_screen.dart (50 instances)
- [ ] 1.5 Fix accommodation_booking_screen.dart (32 instances)
- [ ] 1.6 Fix dining_booking_screen.dart (27 instances)
- [ ] 1.7 Fix dining_booking_confirmation_screen.dart (15 instances)
- [ ] 1.8 Fix dining_screen.dart (18 instances)
- [ ] 1.9 Fix category_places_screen.dart (24 instances)
- [ ] 1.10 Fix category_search_screen.dart (23 instances)
- [ ] 1.11 Fix nightlife_screen.dart (11 instances)
- [ ] 1.12 Fix tour_booking_screen.dart (26 instances)
- [ ] 1.13 Fix experiences_screen.dart (17 instances)
- [ ] 1.14 Fix shopping_screen.dart (6 instances)
- [ ] 1.15 Fix specials_screen.dart (7 instances)
- [ ] 1.16 Fix map_screen.dart (2 TextStyle instances - needs review)

#### Profile Screens (11 files):
- [ ] 1.17 Fix my_bookings_screen.dart (44 instances)
- [ ] 1.18 Fix favorites_screen.dart - Complete remaining instances (36 total)
- [ ] 1.19 Fix settings_screen.dart (4 instances)
- [ ] 1.20 Fix about_screen.dart (27 instances)
- [ ] 1.21 Fix events_attended_screen.dart (9 instances)
- [ ] 1.22 Fix help_center_screen.dart (25 instances)
- [ ] 1.23 Fix reviews_ratings_screen.dart (15 instances)
- [ ] 1.24 Fix reviews_written_screen.dart (21 instances)
- [ ] 1.25 Fix visited_places_screen.dart (13 instances)
- [ ] 1.26 Fix edit_profile_screen.dart (18 instances)
- [ ] 1.27 Fix privacy_security_screen.dart (47 instances)

#### Events & Listings:
- [ ] 1.28 Fix event_detail_screen.dart (23 instances)
- [ ] 1.29 Fix listing_detail_screen.dart (54 instances + 2 TextStyle)

**For each file above:**
- Add import: `import '../../../core/theme/text_theme_extensions.dart';`
- Replace `AppTheme.XXX` → `context.XXX` for all 15 text styles
- Test in both light and dark modes

---

## 📋 PHASE 2: FIX MEDIUM PRIORITY TEXT STYLES
**Status:** Pending ⏳  
**Time Estimate:** 1-2 hours  
**Impact:** Complete text readability across entire app

### 🟡 TODO - Auth Screens (8 files):
- [ ] 2.1 Fix login_screen.dart (10 instances)
- [ ] 2.2 Fix register_screen.dart (3 TextStyle instances - needs review)
- [ ] 2.3 Fix request_password_reset_screen.dart (12 instances)
- [ ] 2.4 Fix verify_reset_code_screen.dart (7 instances)
- [ ] 2.5 Fix new_password_screen.dart (4 instances)
- [ ] 2.6 Fix maintenance_screen.dart (4 instances)
- [ ] 2.7 Fix splash_screen.dart (2 instances)
- [ ] 2.8 Fix onboarding_screen.dart (1 TextStyle instance - needs review)

### 🟡 TODO - Events Screens (3 files):
- [ ] 2.9 Fix events_screen.dart (22 instances)
- [ ] 2.10 Fix event_calendar_sheet.dart (14 instances + 1 TextStyle)
- [ ] 2.11 Fix event_filter_sheet.dart (7 instances + 2 TextStyle)

### 🟡 TODO - Shop Screens (9 files):
- [ ] 2.12 Fix products_screen.dart (15 instances)
- [ ] 2.13 Fix product_detail_screen.dart (16 instances)
- [ ] 2.14 Fix services_screen.dart (17 instances)
- [ ] 2.15 Fix service_detail_screen.dart (15 instances)
- [ ] 2.16 Fix menus_screen.dart (5 instances)
- [ ] 2.17 Fix menu_detail_screen.dart (20 instances)
- [ ] 2.18 Fix cart_screen.dart (14 instances + 1 TextStyle)
- [ ] 2.19 Fix checkout_screen.dart (19 instances)
- [ ] 2.20 Fix order_confirmation_screen.dart (9 instances)

### 🟡 TODO - Bookings:
- [ ] 2.21 Fix booking_confirmation_screen.dart (16 instances)

---

## 📋 PHASE 3: FIX LOW PRIORITY TEXT STYLES
**Status:** Pending ⏳  
**Time Estimate:** 30-60 minutes  
**Impact:** Complete all remaining screens

### 🟢 TODO - Remaining Screens (16 files):
- [ ] 3.1 Fix listings_screen.dart (10 instances)
- [ ] 3.2 Fix search_screen.dart (27 instances)
- [ ] 3.3 Fix notifications_screen.dart (10 instances)
- [ ] 3.4 Fix referral_screen.dart (18 instances + 1 TextStyle)
- [ ] 3.5 Fix webview_screen.dart (4 TextStyle instances - needs review)
- [ ] 3.6 Fix zoea_card_screen.dart (1 TextStyle instance - needs review)
- [ ] 3.7 Fix transaction_history_screen.dart (1 TextStyle instance - needs review)
- [ ] 3.8 Fix complete_profile_screen.dart (7 instances)
- [ ] 3.9 Fix onboarding_data_screen.dart (15 instances)
- [ ] 3.10 Fix progressive_prompt_screen.dart (3 instances)

### 🟢 TODO - User Data Collection Widgets (8 files):
- [ ] 3.11 Fix interests_chips.dart (1 instance)
- [ ] 3.12 Fix visit_purpose_selector.dart (2 instances)
- [ ] 3.13 Fix travel_party_selector.dart (1 instance)
- [ ] 3.14 Fix length_of_stay_selector.dart (1 instance)
- [ ] 3.15 Fix language_selector.dart (3 instances)
- [ ] 3.16 Fix country_selector.dart (5 instances)
- [ ] 3.17 Fix gender_selector.dart (1 instance)
- [ ] 3.18 Fix age_range_selector.dart (1 instance)

### 🟢 TODO - Core Widgets:
- [ ] 3.19 Fix place_card.dart (6 instances)

---

## 📋 PHASE 4: FIX BACKGROUND COLOR CONSISTENCY
**Status:** Pending ⏳  
**Time Estimate:** 1-2 hours  
**Impact:** Consolidate to 3 background colors for clean, modern UI

### Background System Fixes:
- [ ] 4.1 Update app_theme.dart - Add documentation for 3-level system
- [ ] 4.2 Ensure theme properly defines 3 levels:
  - Level 1: `context.backgroundColor` (scaffold/main)
  - Level 2: `context.cardColor` (elevated surfaces)
  - Level 3: `context.grey100` (inputs/subtle)

### Replace Hardcoded Backgrounds (36 instances across 20 files):
- [ ] 4.3 Fix category_places_screen.dart (2 instances)
- [ ] 4.4 Fix dining_screen.dart (2 instances)
- [ ] 4.5 Fix listing_detail_screen.dart (3 instances)
- [ ] 4.6 Fix onboarding_data_screen.dart (1 instance)
- [ ] 4.7 Fix my_bookings_screen.dart (3 instances)
- [ ] 4.8 Fix progressive_prompt_screen.dart (1 instance)
- [ ] 4.9 Fix event_detail_screen.dart (3 instances)
- [ ] 4.10 Fix help_center_screen.dart (3 instances)
- [ ] 4.11 Fix new_password_screen.dart (1 instance)
- [ ] 4.12 Fix complete_profile_screen.dart (1 instance)
- [ ] 4.13 Fix maintenance_screen.dart (1 instance)
- [ ] 4.14 Fix request_password_reset_screen.dart (1 instance)
- [ ] 4.15 Fix nightlife_screen.dart (2 instances)
- [ ] 4.16 Fix accommodation_screen.dart (1 instance)
- [ ] 4.17 Fix referral_screen.dart (2 instances)
- [ ] 4.18 Fix events_attended_screen.dart (1 instance)
- [ ] 4.19 Fix accommodation_detail_screen.dart (2 instances)
- [ ] 4.20 Fix category_search_screen.dart (2 instances)
- [ ] 4.21 Fix onboarding_screen.dart (3 instances)
- [ ] 4.22 Fix theme_extensions.dart (1 instance - already defined)

**Action:** Replace all `AppTheme.backgroundColor` → `context.backgroundColor`

---

## 📋 PHASE 5: FIX HARDCODED COLORS
**Status:** Pending ⏳  
**Time Estimate:** 2-3 hours  
**Impact:** Consistent colors throughout app, proper dark mode support

### Replace Hardcoded Colors (343 instances across 49 files):

#### Colors.white → Theme-aware (check context):
- [ ] 5.1 Review and fix all `Colors.white` usages
  - Keep if on image overlays
  - Replace with `context.primaryTextColor` or `context.cardColor` elsewhere

#### Colors.black.withOpacity() → Theme-aware:
- [ ] 5.2 Replace shadow opacities:
  ```dart
  // From: Colors.black.withOpacity(0.05)
  // To: context.isDarkMode ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.05)
  ```

#### Colors.grey[XX] → context.greyXX:
- [ ] 5.3 Replace all `Colors.grey[50]` → `context.grey50`
- [ ] 5.4 Replace all `Colors.grey[100]` → `context.grey100`
- [ ] 5.5 Replace all `Colors.grey[200]` → `context.grey200`
- [ ] 5.6 Replace all `Colors.grey[300]` → `context.grey300`
- [ ] 5.7 Replace all `Colors.grey[400]` → `context.grey400`
- [ ] 5.8 Replace all `Colors.grey[500]` → `context.grey500`
- [ ] 5.9 Replace all `Colors.grey[600]` → `context.grey600`

#### Colors.red → context.errorColor:
- [ ] 5.10 Replace all `Colors.red` → `context.errorColor`

#### Colors.orange (in explore_screen.dart):
- [ ] 5.11 Fix animation colors to be theme-aware

#### Files with most hardcoded colors (prioritize these):
- [ ] 5.12 Fix explore_screen.dart (39 hardcoded colors)
- [ ] 5.13 Fix place_detail_screen.dart (31 hardcoded colors)
- [ ] 5.14 Fix accommodation_detail_screen.dart (23 hardcoded colors)
- [ ] 5.15 Fix accommodation_screen.dart (22 hardcoded colors)
- [ ] 5.16 Fix my_bookings_screen.dart (19 hardcoded colors)
- [ ] 5.17 Fix dining_booking_confirmation_screen.dart (19 hardcoded colors)
- [ ] 5.18 Fix accommodation_booking_screen.dart (16 hardcoded colors)
- [ ] 5.19 Fix reviews_written_screen.dart (16 hardcoded colors)
- [ ] 5.20 Fix listing_detail_screen.dart (15 hardcoded colors)
- [ ] ... Continue with remaining 40 files

---

## 📋 PHASE 6: TESTING & VALIDATION
**Status:** Pending ⏳  
**Time Estimate:** 1-2 hours  
**Impact:** Ensure everything works perfectly

### Code Quality Checks:
- [ ] 6.1 Run `flutter pub get`
- [ ] 6.2 Run `flutter analyze` - Fix any errors
- [ ] 6.3 Run `flutter test` (if you have tests)
- [ ] 6.4 Check for any import errors
- [ ] 6.5 Verify no linter warnings related to colors

### Visual Testing - Light Mode ☀️:
- [ ] 6.6 Test Explore screens - All text readable (dark)
- [ ] 6.7 Test Profile screens - All text readable (dark)
- [ ] 6.8 Test Auth screens - All text readable (dark)
- [ ] 6.9 Test Shop screens - All text readable (dark)
- [ ] 6.10 Test Events screens - All text readable (dark)
- [ ] 6.11 Verify 3 background colors are consistent
- [ ] 6.12 Check all shadows are visible
- [ ] 6.13 Check all borders are visible

### Visual Testing - Dark Mode 🌙:
- [ ] 6.14 Test Explore screens - All text readable (light)
- [ ] 6.15 Test Profile screens - All text readable (light)
- [ ] 6.16 Test Auth screens - All text readable (light)
- [ ] 6.17 Test Shop screens - All text readable (light)
- [ ] 6.18 Test Events screens - All text readable (light)
- [ ] 6.19 Verify 3 background colors are consistent
- [ ] 6.20 Check all shadows have proper depth
- [ ] 6.21 Check all borders are visible
- [ ] 6.22 Verify no "dark on dark" text anywhere

### Theme Toggle Testing:
- [ ] 6.23 Toggle light → dark → light multiple times
- [ ] 6.24 Verify instant color adaptation
- [ ] 6.25 Check no flickering or delays
- [ ] 6.26 Test on different screens during toggle

### Critical User Flows:
- [ ] 6.27 Test complete booking flow (explore → detail → booking → confirmation)
- [ ] 6.28 Test profile flow (view → edit → save)
- [ ] 6.29 Test shop flow (browse → cart → checkout)
- [ ] 6.30 Test auth flow (login → register → password reset)
- [ ] 6.31 Test events flow (browse → detail → book)

---

## 📋 PHASE 7: DOCUMENTATION & CLEANUP
**Status:** Pending ⏳  
**Time Estimate:** 30 minutes  
**Impact:** Maintainability and team knowledge

### Update Documentation:
- [ ] 7.1 Update app_theme.dart with comments explaining 3-level system
- [ ] 7.2 Add JSDoc comments to text_theme_extensions.dart
- [ ] 7.3 Update README.md with dark mode implementation notes
- [ ] 7.4 Document color system for future developers

### Code Cleanup:
- [ ] 7.5 Remove deprecated AppTheme text style getters (or mark @Deprecated)
- [ ] 7.6 Clean up any commented-out old code
- [ ] 7.7 Ensure consistent code formatting
- [ ] 7.8 Remove any temporary debug code

### Git Commit:
- [ ] 7.9 Review all changes
- [ ] 7.10 Commit with descriptive message
- [ ] 7.11 Push to repository

---

## 📊 PROGRESS TRACKING

```
┌─────────────────────────────────────────────────────┐
│                  OVERALL PROGRESS                   │
├─────────────────────────────────────────────────────┤
│ Phase 1: Text Readability (29 files)    [█░░░] 10% │
│ Phase 2: Text Readability (21 files)    [░░░░]  0% │
│ Phase 3: Text Readability (19 files)    [░░░░]  0% │
│ Phase 4: Backgrounds (20 files)         [░░░░]  0% │
│ Phase 5: Hardcoded Colors (49 files)    [░░░░]  0% │
│ Phase 6: Testing & Validation           [░░░░]  0% │
│ Phase 7: Documentation & Cleanup        [░░░░]  0% │
├─────────────────────────────────────────────────────┤
│ TOTAL PROGRESS:                          [█░░░]  5% │
└─────────────────────────────────────────────────────┘
```

---

## 📈 SUCCESS METRICS

After completing all phases, you should have:

- ✅ **0 instances** of `AppTheme.titleLarge` etc. (all using `context.XXX`)
- ✅ **0 instances** of hardcoded `Colors.grey[XX]` (all using `context.greyXX`)
- ✅ **0 instances** of direct `AppTheme.backgroundColor` (all using `context.backgroundColor`)
- ✅ **Exactly 3 background colors** per theme (Level 1, 2, 3)
- ✅ **All text readable** in both light and dark modes
- ✅ **Consistent shadows** that adapt to theme
- ✅ **0 linter warnings** related to colors
- ✅ **Perfect theme transitions** when toggling
- ✅ **Professional appearance** in both modes

---

## 🎯 PRIORITY ORDER (If Time Limited)

If you can't do everything at once, prioritize:

1. **MUST DO (Critical):** Phase 1 - Text readability in critical screens (29 files)
2. **SHOULD DO (Important):** Phase 2 - Text readability in remaining screens (21 files)
3. **GOOD TO DO:** Phase 4 - Background consolidation
4. **NICE TO HAVE:** Phase 5 - All hardcoded color fixes
5. **ALWAYS DO:** Phase 6 - Testing

---

## 📝 NOTES

- **Files Fixed:** 3/65 ✅
- **Files Remaining:** 62/65 ⏳
- **Total Text Instances:** 1,097
- **Total Background Issues:** 36
- **Total Hardcoded Colors:** 343
- **Estimated Total Time:** 4-6 hours (can be spread over multiple sessions)

---

## 🚀 READY TO START?

**Once you approve this TODO list, I will:**

1. Systematically work through each phase
2. Update progress after completing each file
3. Test as I go
4. Provide status updates
5. Mark items complete ✅

**Say "APPROVED - START FIXING" and I'll begin with Phase 1!** 🎯

Or let me know if you want to adjust priorities or approach!

