# 🎨 Quick Reference: Dark Mode Color Fixes

## 🚀 Quick Find & Replace

Use these replacements across your entire codebase:

### 1️⃣ AppTheme Direct Access
```dart
❌ AppTheme.backgroundColor       → ✅ context.backgroundColor
❌ AppTheme.primaryTextColor      → ✅ context.primaryTextColor
❌ AppTheme.secondaryTextColor    → ✅ context.secondaryTextColor
❌ AppTheme.dividerColor          → ✅ context.dividerColor
❌ AppTheme.primaryColor          → ✅ context.primaryColorTheme
```

### 2️⃣ Hardcoded Colors
```dart
❌ Colors.grey[50]                → ✅ context.grey50
❌ Colors.grey[100]               → ✅ context.grey100
❌ Colors.grey[200]               → ✅ context.grey200
❌ Colors.grey[300]               → ✅ context.grey300
❌ Colors.grey[400]               → ✅ context.grey400
❌ Colors.red                     → ✅ context.errorColor
```

### 3️⃣ Common Patterns

#### Scaffold
```dart
❌ Scaffold(backgroundColor: Colors.white)
❌ Scaffold(backgroundColor: AppTheme.backgroundColor)
✅ Scaffold(backgroundColor: context.backgroundColor)
```

#### AppBar
```dart
❌ AppBar(backgroundColor: AppTheme.backgroundColor)
✅ AppBar(backgroundColor: context.backgroundColor)
```

#### Card/Container
```dart
❌ Container(color: Colors.white)
❌ Container(color: AppTheme.backgroundColor)
✅ Container(color: context.cardColor)
```

#### Text
```dart
❌ Text('Hello', style: TextStyle(color: AppTheme.primaryTextColor))
✅ Text('Hello', style: TextStyle(color: context.primaryTextColor))
```

#### Shadows
```dart
❌ BoxShadow(color: Colors.black.withOpacity(0.05))
✅ BoxShadow(
    color: context.isDarkMode 
        ? Colors.black.withOpacity(0.3)
        : Colors.black.withOpacity(0.05),
  )
```

---

## 📊 3-Level Background System

### Light Mode
```dart
Level 1 (Main):       context.backgroundColor  // #FFFFFF
Level 2 (Cards):      context.cardColor        // #F9FAFB
Level 3 (Inputs):     context.grey100          // #F3F4F6
```

### Dark Mode
```dart
Level 1 (Main):       context.backgroundColor  // #0A0D12
Level 2 (Cards):      context.cardColor        // #181C21
Level 3 (Inputs):     context.grey100          // #252A30
```

---

## 🎯 Text Readability

### On ANY Background
```dart
Primary Text:    context.primaryTextColor
Secondary Text:  context.secondaryTextColor
Disabled Text:   context.grey500
```

### On Image Overlays (Always White)
```dart
Text(
  'Title',
  style: TextStyle(color: Colors.white),  // ✅ OK on images
)
```

---

## 📝 Usage by Widget Type

| Widget Type | Background Color | Text Color |
|-------------|-----------------|------------|
| Scaffold | `context.backgroundColor` | `context.primaryTextColor` |
| AppBar | `context.backgroundColor` | `context.primaryTextColor` |
| Card | `context.cardColor` | `context.primaryTextColor` |
| Container (elevated) | `context.cardColor` | `context.primaryTextColor` |
| TextField | `context.grey50` | `context.primaryTextColor` |
| Dialog | `context.cardColor` | `context.primaryTextColor` |
| BottomSheet | `context.cardColor` | `context.primaryTextColor` |
| ListTile | `context.backgroundColor` | `context.primaryTextColor` |
| Divider | — | `context.dividerColor` |
| Border | — | `context.borderColor` |
| Icon | — | `context.primaryTextColor` |
| Button Text | — | `context.primaryColorTheme` |

---

## ✅ Screen Update Checklist

For EACH screen you update:

- [ ] Find all `AppTheme.backgroundColor` → Replace with `context.backgroundColor`
- [ ] Find all `AppTheme.primaryTextColor` → Replace with `context.primaryTextColor`
- [ ] Find all `AppTheme.secondaryTextColor` → Replace with `context.secondaryTextColor`
- [ ] Find all `AppTheme.primaryColor` → Replace with `context.primaryColorTheme`
- [ ] Find all `Colors.grey[XX]` → Replace with `context.greyXX`
- [ ] Find all `Colors.white` → Check context, replace if not on image
- [ ] Find all `Colors.black.withOpacity()` → Make theme-aware
- [ ] Find all `Colors.red` → Replace with `context.errorColor`
- [ ] Test in light mode ☀️
- [ ] Test in dark mode 🌙
- [ ] Verify text readability
- [ ] Commit changes

---

## 🔧 Helper Extension Available

Already available in `theme_extensions.dart`:

```dart
context.backgroundColor      // Main background
context.cardColor           // Card background
context.surfaceColor        // Surface color
context.primaryTextColor    // Primary text
context.secondaryTextColor  // Secondary text
context.dividerColor        // Dividers
context.borderColor         // Borders
context.grey50              // Grey shades
context.grey100
context.grey200
context.grey300
context.grey400
context.grey500
context.grey600
context.successColor        // Success green
context.errorColor          // Error red
context.primaryColorTheme   // Primary color (theme-aware)
context.isDarkMode          // Check if dark mode
context.isLightMode         // Check if light mode
```

---

## 📂 Files by Priority

### 🔴 CRITICAL (Fix First)
1. explore_screen.dart (39 colors)
2. place_detail_screen.dart (31 colors)
3. accommodation_detail_screen.dart (23 colors)
4. accommodation_screen.dart (22 colors)
5. my_bookings_screen.dart (19 colors)

### 🟡 MEDIUM
- All profile screens
- All auth screens
- All event screens
- All shop screens

### 🟢 LOW
- Listings screens
- User data collection
- Other screens

---

## 🚫 Keep These (Semantic Colors)

These are OK to keep as hardcoded:

```dart
✅ Colors.amber            // Star ratings
✅ Colors.transparent      // Transparent overlays
✅ Colors.white            // On image overlays ONLY
```

---

## 💡 Pro Tips

1. **Work systematically** - One screen at a time
2. **Test frequently** - Toggle dark mode after each file
3. **Use find & replace** - Speed up the process
4. **Commit often** - Small focused commits
5. **Check readability** - Primary concern is text visibility
6. **Three backgrounds max** - Stick to the 3-level system

---

## 🎯 Success = Zero Hardcoded Colors

After you're done:
- ✅ Search `AppTheme.backgroundColor` → 0 results (except in app_theme.dart)
- ✅ Search `Colors.white` → Only in image overlays
- ✅ Search `Colors.grey[` → 0 results
- ✅ Search `Colors.black.withOpacity` → Only theme-aware
- ✅ All screens work perfectly in both light 🌞 and dark 🌙 modes

---

**Ready to start? Open the first file and let's fix it!** 🚀

