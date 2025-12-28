# Zoea Mobile App

Flutter mobile application for iOS and Android.

## Technology Stack

- **Framework**: Flutter
- **Language**: Dart
- **State Management**: Riverpod
- **Navigation**: GoRouter
- **HTTP Client**: Dio
- **Storage**: SharedPreferences, Hive

## Project Structure

```
mobile/
├── lib/
│   ├── core/
│   │   ├── config/          # App configuration
│   │   ├── services/        # API services
│   │   ├── providers/       # State management (Riverpod)
│   │   ├── models/          # Data models
│   │   ├── router/          # Navigation (GoRouter)
│   │   └── theme/           # App theming
│   └── features/
│       ├── auth/            # Authentication screens
│       ├── explore/         # Explore & discovery
│       ├── listings/        # Listings screens
│       ├── booking/         # Booking screens
│       └── profile/         # User profile
├── android/                 # Android platform files
├── ios/                     # iOS platform files
└── pubspec.yaml            # Dependencies
```

## Getting Started

### Prerequisites

- Flutter SDK (latest stable)
- Dart SDK
- Android Studio / Xcode
- iOS Simulator / Android Emulator

### Installation

```bash
cd mobile
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

### Services

All API services are in `lib/core/services/`:
- `auth_service.dart` - Authentication
- `listings_service.dart` - Listings
- `bookings_service.dart` - Bookings (in progress)
- `reviews_service.dart` - Reviews
- `favorites_service.dart` - Favorites
- `categories_service.dart` - Categories
- `user_service.dart` - User profile
- `search_service.dart` - Search

### Authentication

The app uses JWT tokens for authentication:
- Access tokens (short-lived)
- Refresh tokens (long-lived)
- Automatic token refresh on 401 errors
- Secure token storage

## State Management

Using Riverpod for state management:
- Providers in `lib/core/providers/`
- Feature-specific providers in feature folders
- Async providers for API calls

## Navigation

Using GoRouter for navigation:
- Routes defined in `lib/core/router/app_router.dart`
- Deep linking support
- Route guards for authentication

## Testing

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/unit/auth_service_test.dart

# Run with coverage
flutter test --coverage
```

## Code Analysis

```bash
# Analyze code
flutter analyze

# Fix auto-fixable issues
dart fix --apply
```

## Git Repository

**Remote**: `https://github.com/hubertit/zoea.mobile.2.git`

## Documentation

See `/docs/` directory for comprehensive documentation:
- `USER_FLOWS.md` - User flow documentation
- `FEATURES.md` - Feature breakdown
- `DEVELOPMENT_GUIDE.md` - Development guide

