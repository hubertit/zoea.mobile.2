# Quick Start Guide - Zoea Mobile App

Get up and running with the Zoea Mobile App in minutes!

## Prerequisites

Before you begin, ensure you have:

- ✅ **Flutter SDK** (>=3.4.3 <4.0.0) - [Install Flutter](https://flutter.dev/docs/get-started/install)
- ✅ **Dart SDK** (included with Flutter)
- ✅ **IDE**: Android Studio, VS Code, or IntelliJ IDEA
- ✅ **Device/Emulator**: iOS Simulator or Android Emulator

### Check Your Setup

```bash
flutter doctor
```

This command checks your environment and displays a report. Ensure all checks pass.

---

## Installation (5 minutes)

### Step 1: Clone the Repository

```bash
git clone https://github.com/hubertit/zoea.mobile.2.git
cd zoea.mobile.2/mobile
```

### Step 2: Install Dependencies

```bash
flutter pub get
```

This downloads all required packages defined in `pubspec.yaml`.

### Step 3: Verify Installation

```bash
flutter analyze
```

Should show: `No issues found!`

---

## Running the App (2 minutes)

### Option 1: Run on Connected Device

```bash
# List available devices
flutter devices

# Run on first available device
flutter run

# Run on specific device
flutter run -d <device-id>
```

### Option 2: Run with Hot Reload (Development)

```bash
flutter run
```

Then press:
- `r` - Hot reload
- `R` - Hot restart
- `q` - Quit

### Option 3: Run in Release Mode (Testing)

```bash
flutter run --release
```

---

## First Launch

When you first launch the app:

1. **Splash Screen** - Shows for 2-3 seconds
2. **Onboarding** (if first time):
   - Country of residence
   - Age range
   - Length of stay (if applicable)
   - Travel preferences
   - Interests selection
3. **Login/Register**:
   - Register with email or phone
   - Login with credentials
4. **Explore Screen** - Main app interface

---

## Test Accounts

For quick testing, use these pre-configured accounts:

### Consumer Account
- **Email**: `test@zoea.com`
- **Password**: `Test123!`

### Alternative Account
- **Email**: `demo@zoea.com`
- **Password**: `Demo123!`

See [TEST_ACCOUNTS.md](../TEST_ACCOUNTS.md) for more test accounts.

---

## Key Features to Try

### 1. Explore & Discovery (Home Screen)
- Browse featured listings
- View categories
- Try the search functionality
- Apply filters (category, price, rating)
- Sort listings (popularity, rating, price)

### 2. Listings & Details
- Tap any listing to view details
- View image gallery (swipe through images)
- Check amenities and reviews
- Share listings (tap share icon)

### 3. Bookings
- Book accommodations (select dates, rooms)
- Book restaurants (select date, time, party size)
- View booking history (Profile → Bookings)
- Search your bookings

### 4. Events
- Browse upcoming events
- View event details
- Filter by category

### 5. Profile & Settings
- View and edit profile
- Change theme (Light/Dark/System)
- View favorites
- Check referral code

---

## Development Tips

### Hot Reload
Make changes to your code and press `r` in the terminal to see instant updates without losing app state.

### Debug Console
```bash
flutter run --verbose
```

### Clear Cache (if issues)
```bash
flutter clean
flutter pub get
flutter run
```

### Check for Updates
```bash
flutter upgrade
flutter pub upgrade
```

---

## Common Issues & Solutions

### Issue: "No devices found"
**Solution**: 
- Start an emulator: `flutter emulators --launch <emulator-id>`
- Or connect a physical device via USB with USB debugging enabled

### Issue: Build fails with dependency errors
**Solution**:
```bash
flutter clean
rm -rf pubspec.lock
flutter pub get
```

### Issue: iOS build fails
**Solution**:
```bash
cd ios
pod install
cd ..
flutter run
```

### Issue: "Waiting for another flutter command to release the startup lock"
**Solution**:
```bash
killall -9 dart
```

---

## Project Structure Overview

```
mobile/
├── lib/
│   ├── core/
│   │   ├── config/          # App configuration (API URLs, constants)
│   │   ├── models/          # Data models
│   │   ├── providers/       # Riverpod providers (state management)
│   │   ├── router/          # Navigation routes (GoRouter)
│   │   ├── services/        # API services
│   │   └── theme/           # App theming (colors, text styles)
│   ├── features/
│   │   ├── auth/            # Login, register, splash
│   │   ├── explore/         # Home, categories, listings
│   │   ├── booking/         # Booking screens
│   │   ├── events/          # Events screens
│   │   ├── profile/         # Profile, settings
│   │   └── ...
│   └── main.dart           # App entry point
├── android/                # Android configuration
├── ios/                    # iOS configuration
├── assets/                 # Images, fonts, etc.
└── pubspec.yaml           # Dependencies
```

---

## Next Steps

1. **Read the Documentation**:
   - [README.md](README.md) - Complete app overview
   - [CHANGELOG.md](CHANGELOG.md) - Version history
   - [/docs/03-mobile/](../docs/03-mobile/) - Detailed documentation

2. **Explore the Code**:
   - Start with `lib/main.dart`
   - Check out `lib/core/router/app_router.dart` for navigation
   - Review `lib/core/providers/` for state management

3. **Make Your First Change**:
   - Try changing a color in `lib/core/theme/app_theme.dart`
   - Add a new screen in `lib/features/`
   - Modify an existing screen layout

4. **Test on Real Device**:
   - Connect your phone
   - Enable developer options
   - Run `flutter run`

---

## Building for Release

### Android (APK)
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Android (App Bundle - for Play Store)
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

### iOS (requires macOS)
```bash
flutter build ios --release
# Then open Xcode to archive and upload
```

---

## Helpful Commands

```bash
# Analyze code for issues
flutter analyze

# Format code
dart format lib/

# Run tests
flutter test

# Check app size
flutter build apk --analyze-size

# Generate app icons
flutter pub run flutter_launcher_icons:main

# List all routes
grep -r "path:" lib/core/router/
```

---

## API Configuration

The app connects to:
- **Base URL**: `https://zoea-africa.qtsoftwareltd.com/api`
- **Docs**: `https://zoea-africa.qtsoftwareltd.com/api/docs`

To change the API endpoint, edit:
```dart
// lib/core/config/app_config.dart
static const String apiBaseUrl = 'YOUR_API_URL';
```

---

## Need Help?

- 📖 **Documentation**: [/docs/03-mobile/](../docs/03-mobile/)
- 🐛 **Issues**: [GitHub Issues](https://github.com/hubertit/zoea.mobile.2/issues)
- 💬 **Flutter Docs**: [flutter.dev/docs](https://flutter.dev/docs)
- 🎯 **Riverpod Docs**: [riverpod.dev](https://riverpod.dev)

---

**Happy Coding! 🚀**

