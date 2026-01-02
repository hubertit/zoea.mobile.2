# 🚨 CRITICAL BUG: Text Styles Don't Adapt to Dark Mode

## Problem Discovery

**Issue:** Text in AppBars and throughout the app remains **dark even in dark mode**, making it **unreadable** on dark backgrounds.

**Example:** "Profile" title in profile_screen.dart AppBar is dark text on dark background.

**Root Cause:** In `app_theme.dart` (lines 381-484), all static text style getters use **hardcoded static colors** that don't adapt to theme:

```dart
// ❌ BROKEN - Lines 423-428
static TextStyle get titleLarge => GoogleFonts.inter(
  fontSize: 16,
  fontWeight: FontWeight.w500,
  color: primaryTextColor,  // ← ALWAYS #181E29 (dark) - doesn't adapt!
  letterSpacing: 0,
);
```

## Impact

**ALL text styles are broken:**
- `displayLarge`, `displayMedium`, `displaySmall`
- `headlineLarge`, `headlineMedium`, `headlineSmall`
- `titleLarge`, `titleMedium`, `titleSmall`
- `bodyLarge`, `bodyMedium`, `bodySmall`
- `labelLarge`, `labelMedium`, `labelSmall`

**Affected Locations:**
- ✅ AppBar titles (like "Profile")
- ✅ Anywhere using `AppTheme.titleLarge` without `.copyWith(color: context.primaryTextColor)`
- ✅ Any text using these styles directly

## The Fix

### Option 1: Always Use .copyWith() (Current Workaround)

Some screens already do this correctly:

```dart
// ✅ WORKS - my_bookings_screen.dart line 50-52
title: Text(
  'My Bookings',
  style: AppTheme.titleLarge.copyWith(
    color: context.primaryTextColor,  // ← Overrides with theme-aware color
  ),
),
```

**Problem:** Every developer must remember to add `.copyWith(color: ...)` - easy to forget!

### Option 2: Remove Color from Static Getters (Better)

Remove color from static getters and always require explicit color:

```dart
// ✅ BETTER - Remove hardcoded color
static TextStyle get titleLarge => GoogleFonts.inter(
  fontSize: 16,
  fontWeight: FontWeight.w500,
  // NO color specified here
  letterSpacing: 0,
);

// Usage - must always specify color
Text(
  'Profile',
  style: AppTheme.titleLarge.copyWith(
    color: context.primaryTextColor,
  ),
)
```

**Pros:**
- Forces developers to think about color
- Theme-aware by default

**Cons:**
- Verbose - always need `.copyWith(color: ...)`
- More typing

### Option 3: Create Context-Aware Extension Methods (BEST!)

Create extension methods that return theme-aware text styles:

```dart
// NEW FILE: lib/core/theme/text_theme_extensions.dart
extension TextThemeExtensions on BuildContext {
  TextStyle get displayLarge => GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: primaryTextColor,  // ← Uses context.primaryTextColor
    letterSpacing: -0.5,
  );
  
  TextStyle get titleLarge => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: primaryTextColor,  // ← Theme-aware!
    letterSpacing: 0,
  );
  
  // ... all other styles
}

// Usage - Clean and theme-aware!
Text(
  'Profile',
  style: context.titleLarge,  // ← Automatically theme-aware!
)
```

**Pros:**
- ✅ Clean syntax
- ✅ Automatically theme-aware
- ✅ Can't forget to add color
- ✅ Easy to use

**Cons:**
- ❌ Breaking change - need to update all existing code
- ❌ Have to change `AppTheme.titleLarge` → `context.titleLarge`

## Recommended Solution

**Use Option 3** (Context-Aware Extensions) because:

1. **Best long-term solution** - prevents future bugs
2. **Clean syntax** - `context.titleLarge` is cleaner than `AppTheme.titleLarge.copyWith(...)`
3. **Type-safe** - compiler ensures you use context
4. **Consistent** - matches existing `context.backgroundColor` pattern

## Implementation Plan

### Step 1: Create New Extension File

Create `lib/core/theme/text_theme_extensions.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme_extensions.dart';

extension TextThemeExtensions on BuildContext {
  // Display Styles
  TextStyle get displayLarge => GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: primaryTextColor,
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
```

### Step 2: Update All Usages

Find and replace across entire codebase:

```dart
// FIND:
AppTheme.displayLarge
AppTheme.displayMedium
AppTheme.displaySmall
AppTheme.headlineLarge
AppTheme.headlineMedium
AppTheme.headlineSmall
AppTheme.titleLarge
AppTheme.titleMedium
AppTheme.titleSmall
AppTheme.bodyLarge
AppTheme.bodyMedium
AppTheme.bodySmall
AppTheme.labelLarge
AppTheme.labelMedium
AppTheme.labelSmall

// REPLACE WITH:
context.displayLarge
context.displayMedium
context.displaySmall
context.headlineLarge
context.headlineMedium
context.headlineSmall
context.titleLarge
context.titleMedium
context.titleSmall
context.bodyLarge
context.bodyMedium
context.bodySmall
context.labelLarge
context.labelMedium
context.labelSmall
```

### Step 3: Fix Specific Problem Areas

**Profile Screen AppBar (Line 105-108):**

```dart
// ❌ BEFORE
title: Text(
  'Profile',
  style: AppTheme.titleLarge,  // Dark text in dark mode!
),

// ✅ AFTER
title: Text(
  'Profile',
  style: context.titleLarge,  // Automatically theme-aware!
),
```

### Step 4: Keep Static Getters for Non-Context Usage (Optional)

Keep `AppTheme` static getters but mark them deprecated:

```dart
// In app_theme.dart
@Deprecated('Use context.titleLarge instead for theme-aware colors')
static TextStyle get titleLarge => GoogleFonts.inter(
  fontSize: 16,
  fontWeight: FontWeight.w500,
  color: primaryTextColor,  // Static - not theme-aware
  letterSpacing: 0,
);
```

## Quick Fix for Profile Screen Only

If you want a quick fix just for profile_screen.dart:

```dart
// Change line 105-108 from:
title: Text(
  'Profile',
  style: AppTheme.titleLarge,
),

// To:
title: Text(
  'Profile',
  style: AppTheme.titleLarge.copyWith(
    color: context.primaryTextColor,
  ),
),
```

## Testing Checklist

After implementing the fix:

- [ ] Test profile screen in light mode - text should be dark
- [ ] Test profile screen in dark mode - text should be light
- [ ] Test all AppBar titles in both modes
- [ ] Test all body text in both modes
- [ ] Test all buttons in both modes
- [ ] Toggle between light/dark - text should always be readable

## Files to Check/Fix

Based on grep results, these files likely have the issue:

1. ✅ **profile_screen.dart** - Line 107 (confirmed issue)
2. ✅ **favorites_screen.dart** - 9 instances of AppTheme text styles
3. ✅ **my_bookings_screen.dart** - 6 instances (some already fixed with .copyWith)
4. 🔍 **All other screens** - anywhere using `AppTheme.titleLarge`, etc.

## Summary

**Problem:** Static text styles use hardcoded colors that don't adapt to dark mode  
**Impact:** Text becomes unreadable (dark on dark)  
**Solution:** Create context-aware text style extensions  
**Effort:** 1-2 hours to implement + test  
**Benefit:** Future-proof, clean, automatically theme-aware text

This is a **HIGH PRIORITY FIX** because it directly impacts user experience and readability!

