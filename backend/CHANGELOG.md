# Backend API Changelog

All notable changes to the Zoea Backend API will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned
- Payment gateway integration
- Advanced analytics endpoints
- Real-time notifications via WebSockets

## [2.0.0] - 2024-12-30

### Added
- **Enhanced Swagger Documentation**: Comprehensive API documentation with examples
- **HTML Entity Fixes**: Cleaned up HTML entities in database listings
- **Performance Optimizations**: Query optimization and caching improvements

### Changed
- Improved error handling and validation messages
- Enhanced response formats for consistency

### Fixed
- HTML entity encoding in listing titles and descriptions
- Special character handling in search queries

## [1.9.0] - 2024-12-20

### Added
- **Filtering Endpoints**: Advanced filtering for listings
  - Category filtering
  - Type filtering
  - Location filtering
  - Price range filtering
  - Rating filtering
  - Featured status filtering
- **Sorting Endpoints**: Multiple sort options
  - Sort by popularity
  - Sort by rating (high to low, low to high)
  - Sort by name (A-Z, Z-A)
  - Sort by price (low to high, high to low)
  - Sort by date (newest, oldest)

### Changed
- Optimized database queries for filtering and sorting
- Improved pagination performance

## [1.8.0] - 2024-12-15

### Added
- **User Data Collection Endpoints**:
  - `POST /api/user-data-collection` - Create/update user preferences
  - `GET /api/user-data-collection` - Get user preferences
  - Country, age range, length of stay, preferences, interests
- **Data Inference Service**: Automatic preference learning from user interactions

### Changed
- Enhanced user profile endpoints with additional fields
- Improved data validation

## [1.7.0] - 2024-12-01

### Added
- **Reviews & Ratings Endpoints**:
  - `POST /api/reviews` - Create review
  - `GET /api/reviews` - Get reviews with filtering
  - `GET /api/reviews/:id` - Get review details
  - `PATCH /api/reviews/:id` - Update review
  - `DELETE /api/reviews/:id` - Delete review
  - `POST /api/reviews/:id/helpful` - Mark review as helpful
- **Favorites Endpoints**:
  - `POST /api/favorites` - Add to favorites
  - `DELETE /api/favorites/:id` - Remove from favorites
  - `GET /api/favorites` - Get user favorites

### Changed
- Enhanced listing endpoints to include review statistics
- Added average rating calculations

## [1.6.0] - 2024-11-20

### Added
- **Tours & Packages Endpoints**:
  - `GET /api/tours` - Get all tours
  - `GET /api/tours/:id` - Get tour details
  - `POST /api/tours/book` - Book a tour
  - `GET /api/tours/bookings` - Get tour bookings
- Tour itinerary management
- Multi-day tour support

### Changed
- Enhanced booking system to support tours

## [1.5.0] - 2024-11-10

### Added
- **Restaurant Booking Endpoints**:
  - `POST /api/bookings/restaurant` - Create restaurant booking
  - `GET /api/bookings/restaurant` - Get restaurant bookings
  - `GET /api/bookings/restaurant/:id` - Get booking details
  - `PATCH /api/bookings/restaurant/:id/cancel` - Cancel booking
- Party size and time slot management
- Special requests handling

### Changed
- Unified booking response formats
- Enhanced booking validation

## [1.4.0] - 2024-11-01

### Added
- **Accommodation Booking Endpoints**:
  - `POST /api/bookings/accommodation` - Create accommodation booking
  - `GET /api/bookings/accommodation` - Get accommodation bookings
  - `GET /api/bookings/accommodation/:id` - Get booking details
  - Room availability checking
  - Date range validation
- **Events Integration**: SINC API integration for events
- **Notifications Service**:
  - Push notification support
  - In-app notifications
  - Notification preferences

### Changed
- Enhanced listing endpoints with booking availability
- Improved date handling

## [1.3.0] - 2024-10-15

### Added
- **Global Search Endpoint**: `GET /api/search`
  - Multi-category search
  - Search across listings, events, tours
  - Fuzzy search support
- **Category Endpoints**:
  - `GET /api/categories` - Get all categories
  - `GET /api/categories/:id` - Get category details
  - Dynamic subcategory support

### Changed
- Optimized search queries with full-text search
- Added search result ranking

## [1.2.0] - 2024-10-01

### Added
- **Enhanced Listing Endpoints**:
  - `GET /api/listings/:id` - Get detailed listing information
  - Image gallery support
  - Amenities array
  - Operating hours
  - Contact information
- **Image Optimization**: Automatic image resizing and optimization

### Changed
- Enhanced listing model with additional fields
- Improved response times with caching

## [1.1.0] - 2024-09-20

### Added
- **Listings Endpoints**:
  - `GET /api/listings` - Get all listings with pagination
  - Basic filtering by category and type
  - Basic sorting options
- **Location Endpoints**: PostGIS integration for geolocation

### Changed
- Database schema updates for listings
- Added indexes for performance

## [1.0.0] - 2024-09-01

### Added
- **Authentication Endpoints**:
  - `POST /api/auth/register` - User registration
  - `POST /api/auth/login` - User login
  - `POST /api/auth/refresh` - Token refresh
  - `POST /api/auth/logout` - User logout
- **User Endpoints**:
  - `GET /api/users/profile` - Get user profile
  - `PATCH /api/users/profile` - Update profile
  - `POST /api/users/profile/picture` - Upload profile picture
- **Referral Endpoints**:
  - `GET /api/referrals` - Get referral information
  - `POST /api/referrals/redeem` - Redeem referral code

### Technical
- NestJS framework setup
- PostgreSQL 16 + PostGIS database
- Prisma ORM integration
- JWT authentication
- Swagger documentation setup
- Docker containerization
- Initial database schema

---

## API Information

- **Base URL**: `https://zoea-africa.qtsoftwareltd.com/api`
- **Documentation**: `https://zoea-africa.qtsoftwareltd.com/api/docs`
- **Authentication**: JWT (Access Token + Refresh Token)

---

## Database

- **Engine**: PostgreSQL 16 with PostGIS extension
- **ORM**: Prisma
- **Migrations**: Managed via Prisma Migrate

---

## Deployment

The API is deployed on:
- **Production**: `https://zoea-africa.qtsoftwareltd.com/api`
- **Staging**: TBD

---

## Links

- [Project Repository](https://github.com/zoea-africa/zoea2-apis.git)
- [Swagger Documentation](https://zoea-africa.qtsoftwareltd.com/api/docs)
- [Issue Tracker](https://github.com/zoea-africa/zoea2-apis/issues)

