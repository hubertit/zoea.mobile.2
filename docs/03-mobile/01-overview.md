# Mobile App (Consumer) - Overview

**Last Updated**: December 30, 2024  
**Version**: 2.0.15+1  
**Technology**: Flutter (Dart)  
**Platform**: iOS, Android

---

## Description

The Zoea Consumer Mobile App is a Flutter-based application that enables users to discover and book accommodations, dining, experiences, events, and tours throughout Rwanda. The app provides a seamless user experience with modern UI/UX design patterns.

---

## Technology Stack

- **Framework**: Flutter (>=3.4.3 <4.0.0)
- **Language**: Dart
- **State Management**: Riverpod
- **Navigation**: GoRouter
- **HTTP Client**: Dio
- **Local Storage**: SharedPreferences, Hive
- **Platform Support**: iOS, Android, Web, macOS, Linux, Windows

---

## Project Structure

```
mobile/
├── lib/
│   ├── core/                    # Shared utilities and configs
│   │   ├── config/             # App configuration
│   │   ├── constants/          # Constants and assets
│   │   ├── models/             # Data models
│   │   ├── providers/          # Riverpod providers
│   │   ├── router/             # GoRouter configuration
│   │   ├── services/           # API services
│   │   ├── theme/              # App theming
│   │   ├── utils/              # Utility functions
│   │   └── widgets/            # Shared widgets
│   └── features/                # Feature modules
│       ├── auth/               # Authentication
│       ├── explore/            # Explore & discovery
│       ├── listings/           # Listings management
│       ├── events/             # Events (SINC API)
│       ├── bookings/           # Booking system
│       ├── profile/            # User profile
│       ├── search/             # Search functionality
│       ├── favorites/          # Favorites
│       ├── reviews/            # Reviews & ratings
│       ├── notifications/      # Notifications
│       ├── referrals/          # Referral program
│       ├── zoea_card/          # Zoea Card
│       └── user_data_collection/ # UX-first data collection
├── android/                     # Android platform files
├── ios/                         # iOS platform files
├── pubspec.yaml                 # Flutter dependencies
└── README.md                    # Mobile app README
```

---

## Key Features

### ✅ Fully Implemented

1. **Authentication** (100%)
   - User registration
   - Login (email/phone)
   - Password reset
   - Profile management
   - Token management with auto-refresh

2. **Explore & Discovery** (95%)
   - Category browsing
   - Featured listings
   - Recommendations
   - Search functionality
   - Advanced filtering and sorting
   - Skeleton loaders

3. **Listings** (90%)
   - View listing details
   - Filter and sort listings
   - View images, amenities, reviews
   - Accommodation-specific details
   - Restaurant details

4. **Bookings** (85%)
   - Hotel bookings
   - Restaurant bookings
   - View booking history
   - Cancel bookings
   - Booking confirmation

5. **Reviews & Ratings** (100%)
   - View reviews
   - Create reviews
   - Rate listings, events, tours
   - Mark reviews as helpful

6. **Favorites** (100%)
   - Add/remove favorites
   - View favorite listings
   - Favorite status indicators

7. **Events** (100%)
   - Events listing (SINC API)
   - Event details
   - Event filtering
   - Calendar integration

8. **User Data Collection** (100%)
   - Mandatory onboarding
   - Progressive prompts
   - Complete profile menu
   - Passive analytics tracking
   - Privacy controls

### ⏳ Pending Features

- Tour bookings
- Payment integration
- Push notifications
- Offline mode
- Maps integration
- Camera/Gallery integration
- Phone/Email verification

---

## API Integration

- **Base URL**: `https://zoea-africa.qtsoftwareltd.com/api`
- **Authentication**: JWT (Access Token + Refresh Token)
- **External APIs**: SINC API for events

---

## Git Repository

**Repository**: `https://github.com/hubertit/zoea.mobile.2.git`

---

## Related Documentation

- [Codebase Analysis](./02-codebase-analysis.md)
- [Features](./03-features.md)
- [User Data Collection](./04-user-data-collection.md)
- [API Integration](./05-api-integration.md)
- [Authentication](./06-authentication.md)
- [Bookings](./07-bookings.md)
- [Search](./08-search.md)

---

## Quick Start

```bash
cd mobile
flutter pub get
flutter run
```

---

**See [Project Status](../01-project-overview/02-project-status.md) for current implementation status**

