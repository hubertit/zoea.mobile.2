# 🎨 Recommended Color System - Zoea2 Mobile

## Overview
This document defines the **simplified 3-level background system** for a clean, modern, and consistent app experience.

---

## 🌞 Light Mode Color Palette

### Background Colors (3 Levels)

```
┌─────────────────────────────────────────────────────┐
│                                                     │
│  LEVEL 1: Main Background                          │
│  #FFFFFF (White)                                    │
│  Usage: Scaffold, main screen background           │
│  Code: context.backgroundColor                      │
│                                                     │
│  ┌──────────────────────────────────────────────┐  │
│  │                                              │  │
│  │  LEVEL 2: Elevated Surface                  │  │
│  │  #F9FAFB (lightGrey50)                      │  │
│  │  Usage: Cards, containers, elevated items   │  │
│  │  Code: context.cardColor                     │  │
│  │                                              │  │
│  │  ┌────────────────────────────────────────┐ │  │
│  │  │                                        │ │  │
│  │  │  LEVEL 3: Input/Subtle Background     │ │  │
│  │  │  #F3F4F6 (lightGrey100)               │ │  │
│  │  │  Usage: Input fields, disabled states │ │  │
│  │  │  Code: context.grey100                 │ │  │
│  │  │                                        │ │  │
│  │  └────────────────────────────────────────┘ │  │
│  │                                              │  │
│  └──────────────────────────────────────────────┘  │
│                                                     │
└─────────────────────────────────────────────────────┘
```

### Text Colors

| Purpose | Color | Hex | Code |
|---------|-------|-----|------|
| **Primary Text** | Very Dark Blue-Grey | `#181E29` | `context.primaryTextColor` |
| **Secondary Text** | Medium Grey | `#6C727F` | `context.secondaryTextColor` |
| **Disabled Text** | Light Grey | `#9CA3AF` | `context.grey400` |
| **Link/Accent Text** | Primary Blue-Grey | `#181E29` | `context.primaryColorTheme` |

### Supporting Colors

| Purpose | Color | Hex | Code |
|---------|-------|-----|------|
| **Success** | Green | `#009E60` | `context.successColor` |
| **Error** | Red | `#D9534F` | `context.errorColor` |
| **Warning** | Orange | `#FFA500` | `AppTheme.warningColor` |
| **Info** | Blue | `#2196F3` | `AppTheme.infoColor` |
| **Divider** | Very Light Grey | `#E9E9EC` | `context.dividerColor` |
| **Border** | Same as Divider | `#E9E9EC` | `context.borderColor` |

---

## 🌙 Dark Mode Color Palette

### Background Colors (3 Levels)

```
┌─────────────────────────────────────────────────────┐
│                                                     │
│  LEVEL 1: Main Background                          │
│  #0A0D12 (Very Dark Blue-Grey)                     │
│  Usage: Scaffold, main screen background           │
│  Code: context.backgroundColor                      │
│                                                     │
│  ┌──────────────────────────────────────────────┐  │
│  │                                              │  │
│  │  LEVEL 2: Elevated Surface                  │  │
│  │  #181C21 (Dark Blue-Grey)                   │  │
│  │  Usage: Cards, containers, elevated items   │  │
│  │  Code: context.cardColor                     │  │
│  │                                              │  │
│  │  ┌────────────────────────────────────────┐ │  │
│  │  │                                        │ │  │
│  │  │  LEVEL 3: Input/Subtle Background     │ │  │
│  │  │  #252A30 (Medium Dark Grey)           │ │  │
│  │  │  Usage: AppBars, inputs, hover states │ │  │
│  │  │  Code: context.grey100                 │ │  │
│  │  │                                        │ │  │
│  │  └────────────────────────────────────────┘ │  │
│  │                                              │  │
│  └──────────────────────────────────────────────┘  │
│                                                     │
└─────────────────────────────────────────────────────┘
```

### Text Colors

| Purpose | Color | Hex | Code |
|---------|-------|-----|------|
| **Primary Text** | Off-White | `#F5F7FA` | `context.primaryTextColor` |
| **Secondary Text** | Medium Grey | `#9CA3AF` | `context.secondaryTextColor` |
| **Disabled Text** | Dark Grey | `#6A6F77` | `context.grey500` |
| **Link/Accent Text** | Light Grey | `#C5CBD3` | `context.primaryColorTheme` |

### Supporting Colors

| Purpose | Color | Hex | Code |
|---------|-------|-----|------|
| **Success** | Bright Green | `#00C973` | `context.successColor` |
| **Error** | Light Red | `#E57373` | `context.errorColor` |
| **Warning** | Light Orange | `#FFB74D` | `AppTheme.darkWarningColor` |
| **Info** | Light Blue | `#64B5F6` | `AppTheme.darkInfoColor` |
| **Divider** | Dark Grey | `#252A30` | `context.dividerColor` |
| **Border** | Same as Divider | `#252A30` | `context.borderColor` |

---

## 🎯 Usage Guidelines

### When to Use Each Background Level

#### Level 1: Main Background (`context.backgroundColor`)
- ✅ Scaffold background
- ✅ Main screen container
- ✅ Full-screen layouts
- ✅ Bottom sheets background

#### Level 2: Elevated Surface (`context.cardColor`)
- ✅ Card widgets
- ✅ List items
- ✅ Dialog backgrounds
- ✅ Modal backgrounds
- ✅ Any elevated container above main background

#### Level 3: Subtle Background (`context.grey100` / `context.grey50`)
- ✅ Text input fields
- ✅ Search bars
- ✅ Disabled button states
- ✅ AppBar (dark mode)
- ✅ Hover states
- ✅ Section dividers with background

### Text Readability Rules

#### On Level 1 Background (Main):
- ✅ Use `context.primaryTextColor` for main text
- ✅ Use `context.secondaryTextColor` for supporting text
- ✅ Ensure minimum contrast ratio: 4.5:1 for normal text, 3:1 for large text

#### On Level 2 Background (Cards):
- ✅ Same text colors as Level 1
- ✅ Cards provide subtle elevation but maintain readability

#### On Level 3 Background (Inputs):
- ✅ Use `context.primaryTextColor` for input text
- ✅ Use `context.secondaryTextColor` for placeholder text
- ✅ Use `context.grey600` for label text

#### On Image Overlays:
- ✅ Use `Colors.white` with shadow or dark overlay
- ✅ Add semi-transparent black background: `Colors.black.withOpacity(0.5)`
- ✅ For dark mode, adjust opacity: `Colors.black.withOpacity(0.7)`

### Shadow Guidelines

```dart
// Light Mode - Subtle shadows
BoxShadow(
  color: Colors.black.withOpacity(0.05),
  blurRadius: 8,
  offset: const Offset(0, 2),
)

// Dark Mode - Stronger shadows for depth
BoxShadow(
  color: Colors.black.withOpacity(0.3),
  blurRadius: 8,
  offset: const Offset(0, 2),
)

// Theme-aware (recommended)
BoxShadow(
  color: context.isDarkMode 
      ? Colors.black.withOpacity(0.3)
      : Colors.black.withOpacity(0.05),
  blurRadius: 8,
  offset: const Offset(0, 2),
)
```

---

## 📝 Code Examples

### Example 1: Basic Screen Layout

```dart
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // LEVEL 1: Main background
      backgroundColor: context.backgroundColor,
      
      appBar: AppBar(
        // LEVEL 3 in dark mode, LEVEL 1 in light mode
        backgroundColor: context.isDarkMode 
            ? context.grey100 
            : context.backgroundColor,
        foregroundColor: context.primaryTextColor,
      ),
      
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // LEVEL 2: Card
          Container(
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: context.isDarkMode
                      ? Colors.black.withOpacity(0.3)
                      : Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                ),
              ],
            ),
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Primary text
                Text(
                  'Card Title',
                  style: AppTheme.headlineSmall.copyWith(
                    color: context.primaryTextColor,
                  ),
                ),
                SizedBox(height: 8),
                // Secondary text
                Text(
                  'Card description',
                  style: AppTheme.bodyMedium.copyWith(
                    color: context.secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 16),
          
          // LEVEL 3: Input field
          TextField(
            style: TextStyle(color: context.primaryTextColor),
            decoration: InputDecoration(
              fillColor: context.grey50,
              filled: true,
              hintText: 'Enter text',
              hintStyle: TextStyle(color: context.secondaryTextColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: context.borderColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

### Example 2: Image Card with Overlay

```dart
class ImageCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      // LEVEL 2: Card background
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              'https://example.com/image.jpg',
              fit: BoxFit.cover,
            ),
          ),
          
          // Dark overlay for text readability
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(
                    context.isDarkMode ? 0.7 : 0.5,
                  ),
                ],
              ),
            ),
          ),
          
          // Text overlay (always white for contrast)
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Image Title',
                  style: AppTheme.headlineMedium.copyWith(
                    color: Colors.white, // Always white on image
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Image description',
                  style: AppTheme.bodyMedium.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

### Example 3: List with Different Backgrounds

```dart
class SettingsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // LEVEL 1: Main background
      backgroundColor: context.backgroundColor,
      
      body: ListView(
        children: [
          // Section Header (LEVEL 1)
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Account Settings',
              style: AppTheme.titleMedium.copyWith(
                color: context.primaryTextColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          // List Item (LEVEL 2 on tap/hover, LEVEL 1 default)
          ListTile(
            tileColor: context.backgroundColor,
            title: Text(
              'Profile',
              style: AppTheme.bodyLarge.copyWith(
                color: context.primaryTextColor,
              ),
            ),
            subtitle: Text(
              'Edit your profile information',
              style: AppTheme.bodySmall.copyWith(
                color: context.secondaryTextColor,
              ),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: context.secondaryTextColor,
            ),
            onTap: () {},
          ),
          
          Divider(color: context.dividerColor, height: 1),
          
          // Another list item
          ListTile(
            tileColor: context.backgroundColor,
            title: Text(
              'Privacy',
              style: AppTheme.bodyLarge.copyWith(
                color: context.primaryTextColor,
              ),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: context.secondaryTextColor,
            ),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
```

---

## ✅ Checklist for Each Screen

When updating a screen, verify:

- [ ] Scaffold uses `context.backgroundColor`
- [ ] Cards/containers use `context.cardColor`
- [ ] Input fields use `context.grey50` or `context.grey100`
- [ ] All text uses `context.primaryTextColor` or `context.secondaryTextColor`
- [ ] No direct `AppTheme.backgroundColor` references
- [ ] No hardcoded `Colors.white`, `Colors.black`, `Colors.grey[XX]`
- [ ] Shadows are theme-aware (different opacity for dark mode)
- [ ] Icons use `context.primaryTextColor` or `context.secondaryTextColor`
- [ ] Borders use `context.borderColor` or `context.dividerColor`
- [ ] Success/Error colors use `context.successColor` / `context.errorColor`
- [ ] Tested in both light and dark modes
- [ ] Text is readable on all backgrounds

---

## 🚫 Anti-Patterns to Avoid

### ❌ Don't Do This:

```dart
// TOO MANY background colors
Container(color: Colors.grey[50])
Container(color: Colors.grey[100])
Container(color: Colors.grey[200])
Container(color: Color(0xFFF5F5F5))
Container(color: Colors.white.withOpacity(0.9))

// Direct AppTheme usage
backgroundColor: AppTheme.backgroundColor
color: AppTheme.primaryTextColor

// Non-theme-aware shadows
BoxShadow(color: Colors.black.withOpacity(0.05))

// Hardcoded colors
Text('Hello', style: TextStyle(color: Colors.black))
Icon(Icons.star, color: Colors.grey)
```

### ✅ Do This Instead:

```dart
// 3 background levels only
Container(color: context.backgroundColor)  // Level 1
Container(color: context.cardColor)        // Level 2
Container(color: context.grey100)          // Level 3

// Use context helpers
backgroundColor: context.backgroundColor
color: context.primaryTextColor

// Theme-aware shadows
BoxShadow(
  color: context.isDarkMode
      ? Colors.black.withOpacity(0.3)
      : Colors.black.withOpacity(0.05),
)

// Theme-aware text and icons
Text('Hello', style: TextStyle(color: context.primaryTextColor))
Icon(Icons.star, color: context.secondaryTextColor)
```

---

## 📊 Before & After Comparison

### Before (Inconsistent):
- 10+ different background colors
- Mix of `AppTheme.backgroundColor`, `Colors.white`, `Colors.grey[50]`, etc.
- Poor dark mode support
- Inconsistent text colors
- Hardcoded values everywhere

### After (Clean & Consistent):
- Exactly 3 background levels per theme
- All screens use `context.backgroundColor`, `context.cardColor`, `context.grey100`
- Perfect dark mode support
- Consistent readable text on all backgrounds
- Zero hardcoded color values (except semantic colors like amber for ratings)

---

## 🎯 Goal

Create a **clean, modern, and professional** app with:
- 🎨 Consistent color usage across all screens
- 🌓 Perfect light and dark mode support
- 📖 Excellent text readability everywhere
- 🎭 Smooth theme transitions
- 🧹 Clean, maintainable code

---

**Next Step:** Start implementing using the COMPREHENSIVE_DARK_MODE_CONSISTENCY_ANALYSIS.md guide!

