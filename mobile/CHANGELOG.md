# Changelog

All notable changes to the Zoea Mobile App will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Theme-aware logo switching for dark mode
- White logo displayed in AppBar when dark mode is enabled
- Visit Rwanda logo color filtering in quick actions to match theme
- Color-adapted splash screen logo

## [2.0.0] - 2025-01-02

### Added
- **Dark Mode Support**: Complete dark mode implementation with theme switching (Light/Dark/System)
  - Theme persistence across app restarts
  - Consistent color system using theme extensions
  - Proper contrast and readability in dark mode
- **Theme-Aware UI Components**: All components adapt to light/dark themes
- **Logo Switching**: Dynamic logo colors based on active theme
- **Quick Actions Widget**: Visit Rwanda and Irembo integration with theme-aware icons

### Changed
- Updated color system to use theme-aware extensions
- Improved text contrast across all screens
- Enhanced dark mode color palette for better readability

## [1.9.0] - 2024-12-30

### Added
- **Share Functionality**: Native share for listings, events, accommodations, and referral codes
- **Booking Search**: Search functionality in bookings screen
- **Enhanced Sorting**: 9 sort options for listings (Popular, Rating High-Low, Rating Low-High, Name A-Z, Name Z-A, Price Low-High, Price High-Low, Newest, Oldest)
- **Advanced Filters**: Enhanced filtering with rating ranges, price ranges, and featured status
- **Skeleton Loaders**: Improved loading states with shimmer effects
- **HTML Entity Fix**: Fixed broken special characters in database listings

### Changed
- Reduced font sizes in stays tab search bar for better UX
- Improved listing cards with better spacing and typography

### Fixed
- All Flutter analyze errors and warnings (0 errors, 0 warnings)
- HTML entity encoding issues in listing titles and descriptions

## [1.8.0] - 2024-12-15

### Added
- **User Data Collection Module**: UX-first onboarding data collection
  - Country of residence with flag selection
  - Age range selection
  - Length of stay (conditional based on country)
  - Travel preferences
  - Interests selection
- **Smart Data Inference**: Automatic data collection from user interactions
- **Session Management**: Improved session persistence and tracking

### Changed
- Enhanced profile screen with better data display
- Improved edit profile functionality

### Fixed
- Session persistence issues
- Profile update synchronization

## [1.7.0] - 2024-12-01

### Added
- **Reviews & Ratings System**:
  - View reviews with ratings
  - Create reviews for listings, events, and tours
  - Mark reviews as helpful
  - Review filtering and sorting
- **Favorites Management**:
  - Add/remove favorites
  - Favorites screen with grid view
  - Favorite status indicators on listings

### Changed
- Enhanced listing detail screens with reviews section
- Improved booking history with review options

## [1.6.0] - 2024-11-20

### Added
- **Tours & Packages**: Browse and view tour packages
- **Tour Booking**: Multi-day tour booking with participant selection
- **Tour Detail Screen**: Comprehensive tour information with itinerary

### Changed
- Updated explore screen with tours category
- Enhanced navigation structure

## [1.5.0] - 2024-11-10

### Added
- **Restaurant Bookings**:
  - Date and time selection
  - Party size specification
  - Special requests field
  - Booking confirmation
- **Booking History**: View all accommodation and restaurant bookings
- **Booking Cancellation**: Cancel bookings with confirmation dialog

### Changed
- Unified booking flow for accommodations and restaurants
- Improved booking detail screens

## [1.4.0] - 2024-11-01

### Added
- **Accommodation Booking System**:
  - Check-in/check-out date selection
  - Number of guests specification
  - Room type selection
  - Booking confirmation screens
- **Events Integration** (SINC API):
  - Browse events
  - Event detail screens
  - Event filtering by category
- **Notifications System**:
  - View notifications
  - Mark as read/unread
  - Unread count badge

### Changed
- Enhanced accommodation detail screens with booking CTA
- Improved date picker UI

## [1.3.0] - 2024-10-15

### Added
- **Global Search**: Search across all content types (listings, events, accommodations)
- **Search History**: Recent searches with clear history option
- **Search Filters**: Filter search results by category and type
- **Category System**: Dynamic category browsing with subcategories

### Changed
- Improved explore screen layout
- Enhanced navigation with bottom navigation bar

## [1.2.0] - 2024-10-01

### Added
- **Listing Details**: Comprehensive listing detail screens
  - Image gallery with zoom
  - Amenities display
  - Location information
  - Operating hours
  - Contact information
- **Image Caching**: Improved image loading with CachedNetworkImage
- **Pull to Refresh**: Refresh functionality on main screens

### Changed
- Enhanced listing cards with better imagery
- Improved data loading states

## [1.1.0] - 2024-09-20

### Added
- **Explore & Discovery Screen**:
  - Featured listings
  - Category browsing
  - Recent listings
  - Recommendations based on preferences
- **Filtering System**: Filter by category, type, location, price, and rating
- **Sorting System**: Sort by popularity, rating, name, price, and date

### Changed
- Redesigned home screen with better content organization
- Improved navigation flow

## [1.0.0] - 2024-09-01

### Added
- **Authentication System**:
  - User registration with email/phone
  - Login with email or phone
  - JWT token management
  - Automatic token refresh
  - Logout functionality
- **Profile Management**:
  - View profile
  - Edit profile information
  - Profile picture upload
- **Referral System**:
  - Generate referral codes
  - Share referral codes
  - Track referrals
- **Zoea Card**: Digital card management (placeholder)
- **Settings**: App settings and preferences

### Technical
- Flutter 3.4.3+ setup
- Riverpod 2.4.9 for state management
- GoRouter 12.1.3 for navigation
- Dio 5.4.0 for API integration
- SharedPreferences for local storage
- Initial project structure and architecture

---

## Version Guidelines

- **Major Version (X.0.0)**: Breaking changes, major feature additions
- **Minor Version (0.X.0)**: New features, non-breaking changes
- **Patch Version (0.0.X)**: Bug fixes, minor improvements

---

## Links

- [API Documentation](https://zoea-africa.qtsoftwareltd.com/api/docs)
- [Project Repository](https://github.com/hubertit/zoea.mobile.2.git)
- [Issue Tracker](https://github.com/hubertit/zoea.mobile.2/issues)

