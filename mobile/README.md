# Zoea Mobile App

**Discover Rwanda Like Never Before**

Flutter mobile application for iOS and Android.

## Technology Stack

- **Framework**: Flutter
- **Language**: Dart
- **State Management**: Riverpod 2.4.9
- **Navigation**: GoRouter 12.1.3
- **HTTP Client**: Dio 5.4.0
- **Storage**: SharedPreferences, Hive
- **Image Caching**: CachedNetworkImage
- **Sharing**: SharePlus 12.0.1

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
│       ├── events/          # Events screens
│       ├── profile/         # User profile
│       ├── notifications/   # Notifications
│       ├── search/          # Search functionality
│       ├── referrals/      # Referral program
│       └── zoea_card/       # Zoea Card management
├── android/                 # Android platform files
├── ios/                     # iOS platform files
└── pubspec.yaml            # Dependencies
```

## Prerequisites

- Flutter SDK (>=3.4.3 <4.0.0)
- Dart SDK
- Android Studio / Xcode
- iOS Simulator / Android Emulator

## Installation

**New to the project?** Check out the [Quick Start Guide](QUICKSTART.md) for a fast 5-minute setup!

```bash
cd mobile
flutter pub get
flutter doctor  # Check for issues
```

## Running the App

```bash
# Run on connected device/emulator
flutter run

# Run on specific device
flutter devices  # List devices
flutter run -d <device-id>

# Run in release mode
flutter run --release
```

## Building

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

| Service | Status | Description |
|---------|--------|-------------|
| `auth_service.dart` | ✅ Complete | Authentication, token management |
| `user_service.dart` | ✅ Complete | User profile management |
| `listings_service.dart` | ✅ Complete | Listings with filters & sorting |
| `bookings_service.dart` | ✅ Complete | Bookings (hotel, restaurant) |
| `reviews_service.dart` | ✅ Complete | Reviews and ratings |
| `favorites_service.dart` | ✅ Complete | Favorites management |
| `categories_service.dart` | ✅ Complete | Categories |
| `events_service.dart` | ✅ Complete | Events (SINC API) |
| `notifications_service.dart` | ✅ Complete | Notifications |
| `search_service.dart` | ✅ Complete | Global search |
| `token_storage_service.dart` | ✅ Complete | Secure token storage |

### Authentication

The app uses JWT tokens for authentication:
- Access tokens (short-lived)
- Refresh tokens (long-lived)
- Automatic token refresh on 401 errors
- Secure token storage with SharedPreferences

## Features

### ✅ Implemented Features

1. **Authentication**
   - User registration
   - Login (email/phone)
   - Token management
   - Profile management

2. **Explore & Discovery**
   - Category browsing
   - Featured listings
   - Recommendations
   - Search functionality
   - Filtering (category, type, location, price, rating, featured)
   - Sorting (popular, rating, name, price, date)

3. **Listings**
   - View listing details
   - Filter and sort listings
   - View images, amenities, reviews
   - Accommodation-specific details (rooms, room types)
   - Skeleton loaders for better UX

4. **Bookings**
   - Hotel bookings (check-in/check-out, room selection)
   - Restaurant bookings (date, time, party size)
   - View booking history
   - Cancel bookings
   - Search bookings

5. **Reviews & Ratings**
   - View reviews
   - Create reviews
   - Rate listings, events, tours
   - Mark reviews as helpful

6. **Favorites**
   - Add/remove favorites
   - View favorite listings
   - Favorite status indicators

7. **Sharing**
   - Share listings via native share
   - Share accommodations
   - Share events
   - Share referral codes

8. **Notifications**
   - View notifications
   - Mark as read
   - Unread count

9. **Search**
   - Global search
   - Search history
   - Clear search history

### ⏳ Planned Features

- Payment integration
- Push notifications
- Offline mode
- Maps integration
- Tour bookings
- Event bookings (from main API)

## State Management

Using Riverpod for state management:
- Providers in `lib/core/providers/`
- Feature-specific providers in feature folders
- Async providers for API calls
- StateNotifier for complex state

## Navigation

Using GoRouter for navigation:
- Routes defined in `lib/core/router/app_router.dart`
- Deep linking support
- Route guards for authentication
- 30+ routes covering all major features

## Code Quality

```bash
# Analyze code
flutter analyze

# Fix auto-fixable issues
dart fix --apply
```

**Current Status**: 0 errors, 0 warnings, 33 info-level suggestions

## Testing

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/unit/auth_service_test.dart

# Run with coverage
flutter test --coverage
```

## Git Repository

**Remote**: `https://github.com/hubertit/zoea.mobile.2.git`

## Documentation

See `/docs/` directory for comprehensive documentation:
- `USER_FLOWS.md` - User flow documentation
- `FEATURES.md` - Feature breakdown
- `DEVELOPMENT_GUIDE.md` - Development guide
- `API_REFERENCE.md` - API endpoint reference

## Recent Updates

### January 2025
- ✅ **Dark Mode Support**: Complete dark mode implementation with Light/Dark/System theme options
- ✅ **Theme-Aware Logos**: Dynamic logo switching based on active theme
- ✅ **Theme Persistence**: User theme preferences saved across app restarts
- ✅ **Consistent Theming**: All UI components properly adapt to light/dark themes

### December 2024
- ✅ Implemented share functionality for all detail screens
- ✅ Added search functionality for bookings
- ✅ Implemented sorting for listings (9 sort options)
- ✅ Enhanced filtering (rating, price range, featured status)
- ✅ Added skeleton loaders for better loading UX
- ✅ Fixed HTML entities in database listings
- ✅ Reduced font sizes in stays tab search bar
- ✅ Fixed all Flutter analyze errors and warnings

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for detailed version history and feature additions.
