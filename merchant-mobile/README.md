# Zoea Merchant Mobile App

Flutter mobile application for merchants to manage their business on iOS and Android.

## Technology Stack

- **Framework**: Flutter
- **Language**: Dart
- **State Management**: Riverpod (or your current state management)
- **Navigation**: GoRouter (or your current navigation)
- **HTTP Client**: Dio
- **Storage**: SharedPreferences, Hive

## Project Structure

```
merchant-mobile/
├── lib/
│   ├── core/           # Core functionality
│   │   ├── config/     # App configuration
│   │   ├── services/    # API services
│   │   ├── providers/  # State management
│   │   └── router/     # Navigation
│   └── features/       # Merchant features
│       ├── dashboard/  # Business dashboard
│       ├── listings/   # Manage listings
│       ├── bookings/   # Manage bookings
│       ├── analytics/  # Business analytics
│       └── revenue/    # Revenue tracking
├── android/            # Android platform files
├── ios/                # iOS platform files
└── pubspec.yaml       # Dependencies
```

## Getting Started

### Prerequisites

- Flutter SDK (latest stable)
- Dart SDK
- Android Studio / Xcode
- iOS Simulator / Android Emulator

### Installation

```bash
cd merchant-mobile
flutter pub get
flutter doctor  # Check for issues
```

### Running the App

```bash
# Run on connected device/emulator
flutter run

# Run on specific device
flutter devices  # List devices
flutter run -d <device-id>

# Run in release mode
flutter run --release
```

### Building

```bash
# Android APK
flutter build apk --release

# Android App Bundle (for Play Store)
flutter build appbundle --release

# iOS (requires macOS and Xcode)
flutter build ios --release
```

## API Integration

### Base URL

Configured in `lib/core/config/app_config.dart`:
```dart
static const String apiBaseUrl = 'https://zoea-africa.qtsoftwareltd.com/api';
```

### Merchant-Specific Endpoints

- `/merchant/profile` - Merchant profile
- `/merchant/listings` - Manage listings
- `/merchant/bookings` - Manage bookings
- `/merchant/analytics` - Business analytics
- `/merchant/revenue` - Revenue tracking

## Authentication

The app uses JWT tokens for authentication:
- Access tokens (short-lived)
- Refresh tokens (long-lived)
- Automatic token refresh on 401 errors
- Secure token storage
- Merchant role verification

## Features

- ✅ Business dashboard
- ✅ Listing management
- ✅ Booking management
- ✅ Analytics and insights
- ✅ Revenue tracking
- ✅ Availability calendar
- ✅ Customer reviews management

## Git Repository

**Remote**: (preserved from original location)

## Documentation

See `/docs/` directory for comprehensive documentation:
- `PROJECT_STRUCTURE_RECOMMENDATION.md` - Project structure
- `FEATURES.md` - Feature breakdown
- `DEVELOPMENT_GUIDE.md` - Development guide
