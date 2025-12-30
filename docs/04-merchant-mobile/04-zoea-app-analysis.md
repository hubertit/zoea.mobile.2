# Zoea App - Comprehensive Analysis

## Overview
**Zoea Africa** is a Flutter-based travel and discovery app focused on Rwanda, allowing users to explore events, accommodations, dining, experiences, and more. The app follows a feature-based architecture with Riverpod for state management.

---

## Architecture & Design Patterns

### 1. **State Management**
- **Riverpod 2.4.9** with code generation (`riverpod_annotation`, `riverpod_generator`)
- Provider-based architecture with reactive state management
- Stream-based authentication state

### 2. **Routing**
- **go_router 12.1.3** for declarative routing
- ShellRoute pattern for bottom navigation bar
- Deep linking support with path parameters and query parameters

### 3. **Project Structure**
```
lib/
├── core/           # Shared utilities, configs, models, providers
│   ├── config/     # App configuration (API endpoints, constants)
│   ├── constants/  # Asset paths, constants
│   ├── models/     # Data models (User, Listing, Booking, Event, etc.)
│   ├── providers/  # Riverpod providers (auth, events, theme)
│   ├── router/     # Navigation configuration
│   ├── services/   # Business logic services (auth, events)
│   ├── theme/      # App theming (light/dark mode)
│   ├── utils/      # Helper utilities (phone validation, formatters)
│   └── widgets/    # Reusable widgets (shell, place cards)
│
└── features/       # Feature modules (each feature is self-contained)
    ├── auth/
    ├── booking/
    ├── events/
    ├── explore/
    ├── listings/
    ├── notifications/
    ├── profile/
    ├── referrals/
    ├── search/
    └── zoea_card/
```

### 4. **Storage**
- **Hive 2.2.3** for local database
- **shared_preferences 2.2.2** for simple key-value storage
- Cache keys defined in `AppConfig` for consistency

---

## Tech Stack

### Core Dependencies
- **Flutter SDK**: >=3.4.3 <4.0.0
- **State Management**: flutter_riverpod, riverpod_annotation
- **Routing**: go_router
- **Networking**: dio 5.4.0
- **Storage**: hive, hive_flutter, shared_preferences
- **UI**: google_fonts, flutter_animate, lottie
- **Image Handling**: cached_network_image, image_picker, cloudinary_flutter
- **Utilities**: intl, uuid, url_launcher, table_calendar, country_picker

### Code Generation
- `build_runner` for code generation
- `json_serializable` for JSON serialization
- `hive_generator` for Hive adapters

---

## Key Features

### 1. **Authentication** (Dual Login System)
- **Login Methods**:
  - Phone login (default) with country code picker
  - Email login (toggleable)
  - Password authentication
- **Phone Login Features**:
  - Country picker (country_picker package)
  - Phone number formatting (07X XXX XXX for Rwanda)
  - International phone validation
  - Country code display with flag emoji
- **Email Login Features**:
  - Email validation
  - Standard email/password form
- **User Roles**: Explorer, Merchant, Event Organizer, Admin
- **Mock Authentication**: 
  - Test accounts: explorer@zoea.africa, merchant@zoea.africa, eventorg@zoea.africa
  - Default password: Pass123
  - Stream-based auth state management
- **Registration**: Sign up with email/password, full name, and user role selection
- **Onboarding**: Welcome screens for new users

### 2. **Explore Section** (Main Discovery Hub)
- **Categories**: Events, Dining, Experiences, Nightlife, Accommodation, Shopping
- **Weather Widget**: Shows Kigali weather with temperature and rain probability
- **Currency Widget**: USD/RWF exchange rate with trend indicators
- **Quick Actions**: Emergency SOS, Call Taxi, Find ATM, Book Tour, Find Hospital, Police, Pharmacy, Roadside Assistance, Flight Info
- **Happening Section**: Today's events with horizontal scrolling
- **Recommend Section**: Personalized recommendations (5 items)
- **Near Me Section**: Location-based places with distance
- **Special Offers**: Discounted experiences and deals
- **Animated Greeting**: Time-based greeting that fades to search bar after 60 seconds

### 3. **Events** (Comprehensive Feature)
- **Event Tabs**: 
  - Trending (default)
  - Near Me (location-based)
  - This Week (current week events)
  - MICE (Meetings, Incentives, Conferences, Exhibitions) - 20+ preloaded events
- **Event Filtering**:
  - Category filter (Music, Sports, Food, Arts, Conferences, Performance)
  - Location filter
  - Date range picker (calendar sheet)
  - Price range filter
  - Free events filter
  - Verified events filter
  - Search query
- **Event Display**:
  - Event cards with flyer images
  - Event details: name, date/time, location, organizer
  - Attendance count (attending/maxAttendance)
  - Ticket pricing (from price with currency)
  - Organizer verification badge
  - Skeleton loading states with shimmer animation
- **Event Actions**:
  - Calendar view (table_calendar integration)
  - Filter bottom sheet
  - Search dialog
  - Event detail navigation
- **MICE Events**: Pre-loaded list of major conferences, summits, and exhibitions in Rwanda

### 4. **Bookings**
- Booking system for hotels, restaurants, tours, events
- Booking status: pending, confirmed, cancelled, completed, refunded
- Payment methods: Zoea Card, Mobile Money, Bank Transfer, Cash
- Booking confirmation screens

### 5. **Accommodation**
- Hotel/accommodation listings
- Room selection and booking
- Check-in/check-out date selection
- Guest count management

### 6. **Dining**
- Restaurant listings
- Table booking system
- Dining booking confirmation

### 7. **Profile Management**
- User profile with stats (Events Attended, Places Visited, Reviews Written)
- Edit profile functionality
- Preferences: Currency, Country, Location, Language
- Account settings: Email & Phone, Privacy & Security
- Travel & Activities: My Bookings, Favorites, Reviews & Ratings
- Support: Help Center, About

### 8. **Zoea Card**
- Digital wallet/card functionality
- Transaction history
- Payment integration

### 9. **Search**
- Global search with query and category filters
- Search history (cached)

### 10. **Notifications**
- Push notification support (Firebase Messaging - commented out)
- Notification badge in app bar

### 11. **Referrals**
- Referral system with rewards
- Animated gift card icon in app bar

### 12. **Listings**
- Business/place listings
- Listing detail screens
- Category-based browsing

---

## Data Models

### User Model
```dart
- id, email, fullName, phoneNumber, profileImage
- createdAt, updatedAt, isVerified
- role: explorer | merchant | eventOrganizer | admin
- preferences: language, currency, notifications, location, interests
```

### Listing Model
```dart
- id, name, description, category
- type: hotel | restaurant | tour | event | attraction
- location: latitude, longitude, address, city, country, district, sector
- images, rating, reviewCount
- priceRange: minPrice, maxPrice, currency, unit
- amenities, tags, isVerified, isFeatured
- contactPhone, contactEmail, website
```

### Booking Model
```dart
- id, userId, listingId
- type: hotel | restaurant | tour | event
- status: pending | confirmed | cancelled | completed | refunded
- checkInDate, checkOutDate, guestCount
- totalAmount, currency
- paymentMethod: zoeaCard | momo | bankTransfer | cash
- specialRequests, guests[]
```

### Event Model (Complete Structure)
```dart
Event:
  - id, eventId, userId, creatorId, isBlocked, slug
  - organizerProfileId, type
  - createdAt, updatedAt
  - commentCount, likeCount, sincCount, hasLiked
  - event: EventDetails
  - owner: EventOwner

EventDetails:
  - id, userId, name, description
  - organizerProfileId, flyer, imageId, fileId
  - location: EventLocation (GeoJSON format)
  - locationName, isAcceptable, eventContextId
  - maxAttendance, attending
  - startDate, endDate, createdAt, updatedAt
  - setup, privacy, postId, ongoing
  - tickets: EventTicket[]
  - attachments: EventAttachment[]
  - eventContext: EventContext?

EventLocation:
  - type: "Point" (GeoJSON)
  - coordinates: [longitude, latitude]

EventTicket:
  - id, price, name, disabled
  - type, orderType, currency
  - createdAt, updatedAt, description?

EventAttachment:
  - id, blurhash, url, fileType
  - imageId, width, height, videoId?, fileId
  - createdAt, updatedAt, contentId?
  - eventId, color, medium?, small?
  - isDark, isMainFlyer

EventOwner:
  - id, username, name, email, imageUrl, bgUrl?
  - isPrivate, accountType, isActive
  - createdAt, maxDistance, bio?
  - isVerified, organizerProfileVerified
  - isCallerSubscribedToUser, isUserSubscribedToCaller

EventContext:
  - id, name, description
  - createdAt, updatedAt
```

### Event Filter Model
```dart
EventFilter:
  - category, location, startDate, endDate
  - minPrice, maxPrice, searchQuery
  - isFree, isVerified
  - Methods: copyWith(), hasActiveFilters, toQueryParams()

EventCategory (Predefined):
  - Music, Sports & Wellness, Food & Drinks
  - Arts & Culture, Conferences, Performance

PriceRange (Predefined):
  - Free, Under 5K RWF, 5K-15K RWF
  - 15K-50K RWF, 50K-100K RWF, 100K+ RWF
```

### Zoea Card Model
```dart
ZoeaCard:
  - id, userId, balance, currency
  - status: active | inactive | suspended | blocked
  - createdAt, updatedAt, linkedAccountId?
  - transactions: Transaction[]

Transaction:
  - id, cardId, type, amount, currency
  - description, timestamp, status
  - reference?, merchantId?
  
TransactionType:
  - deposit, withdrawal, payment
  - refund, commission, bonus

TransactionStatus:
  - pending, completed, failed, cancelled
```

---

## API Configuration

### Base URL
- `https://api.zoea.africa/v1`

### Endpoints
- `/auth` - Authentication
- `/users` - User management
- `/listings` - Business listings
- `/hotels` - Hotel-specific
- `/restaurants` - Restaurant-specific
- `/tours` - Tour packages
- `/events` - Events
- `/bookings` - Booking management
- `/zoea-card` - Digital wallet
- `/transactions` - Transaction history
- `/notifications` - Push notifications
- `/search` - Search functionality
- `/recommendations` - Personalized recommendations
- `/reviews` - Reviews and ratings
- `/upload` - File uploads

### Payment Configuration
- Gateway: ZoeaPay
- Currency: RWF (Rwandan Franc)
- Symbol: Frw
- Min: 100 RWF, Max: 1,000,000 RWF

---

## UI/UX Design

### Theme
- **Primary Color**: `#181E29` (Dark blue-gray)
- **Background**: White (light) / `#121212` (dark)
- **Typography**: Google Fonts (Inter)
- **Border Radius**: 12-16px for cards, 20px for search bars
- **Spacing**: Consistent spacing system (2, 4, 8, 12, 16, 20, 24, 32)

### Design Patterns
- **Material Design 3** with custom theming
- **Card-based layouts** with subtle shadows
- **Bottom sheets** for filters and selections
- **Horizontal scrolling** for categories and events
- **Skeleton loaders** for loading states
- **Animated transitions** using flutter_animate

### Navigation
- **Bottom Navigation Bar** with 5 tabs:
  1. Explore (home)
  2. Events
  3. Stay (Accommodation)
  4. Bookings
  5. Profile

---

## Key Services

### AuthService
- `signInWithEmail()` - Email/password login
- `signUpWithEmail()` - User registration
- `signOut()` - Logout
- `authStateChanges` - Stream of auth state

### EventsService
- **Base URL**: `https://api-prod.sinc.today/events/v1/public`
- `getEvents()` - Get events with pagination and filters
- `getTrendingEvents()` - Get trending events
- `getNearbyEvents()` - Get events by location (latitude, longitude, radius)
- `getThisWeekEvents()` - Get events for current week
- `searchEvents()` - Search events by query string
- All methods return `EventsResponse` with pagination support

### EventsProvider (StateNotifier)
- `EventsState`: events list, loading state, error, current tab, filters
- `EventsTab`: trending, nearMe, thisWeek
- Methods: loadTrendingEvents(), loadNearbyEvents(), loadThisWeekEvents(), searchEvents()
- Filter management: setFilters(), clearFilters()

---

## Widget Architecture

### Shell Widget
- Wraps main app screens
- Provides bottom navigation bar
- Handles route-based tab highlighting
- **Navigation Tabs**:
  1. Explore (home icon)
  2. Events (event icon)
  3. Stay/Accommodation (hotel icon)
  4. Bookings (book_online icon)
  5. Profile (person icon)

### Event Widgets
- **EventCalendarSheet**: Calendar view for event date selection
- **EventFilterSheet**: Comprehensive filter interface with all filter options

### Utility Widgets
- **PlaceCard**: Reusable listing/place display card
- **Skeleton Loaders**: Shimmer animation for loading states

### Place Card Widget
- Reusable card for displaying places/listings
- **Features**:
  - Cached network image with placeholder and error handling
  - Favorite button (top-right overlay)
  - Category badge
  - Rating display with star icon and review count
  - Location with icon
  - Price range display
  - Tap navigation to detail screen
- **Styling**: Rounded corners (16px), shadow, proper spacing

---

## Feature Flags
- Push Notifications: Enabled
- Location Services: Enabled
- Offline Mode: Enabled
- Analytics: Enabled
- Social Login: Enabled
- Biometric Auth: Enabled
- Dark Mode: Enabled
- AR Features: Disabled (future)

---

## Integration Points

### Visit Rwanda Integration
- API URL: `https://api.visitrwanda.gov.rw/v1`
- RDB API: `https://api.rdb.rw/v1`
- Integration enabled

### Cloudinary
- Image upload and management
- Cloud storage for user-generated content

---

## User Roles

1. **Explorer** (Default)
   - Discover and book experiences
   - Browse listings and events
   - Make bookings

2. **Merchant**
   - Manage business listings
   - Handle bookings
   - View analytics

3. **Event Organizer**
   - Create and manage events
   - Manage event bookings

4. **Admin**
   - Platform administration
   - Full system access

---

## Key Observations for Merchant App

### What to Reuse
1. **Architecture Pattern**: Feature-based structure
2. **State Management**: Riverpod with code generation
3. **Routing**: go_router with ShellRoute
4. **Theme System**: AppTheme with light/dark mode
5. **Models**: User, Listing, Booking models (with merchant-specific extensions)
6. **Services Pattern**: Service layer for business logic

### What to Adapt
1. **Navigation**: Different bottom nav for merchant (Dashboard, Listings, Bookings, Analytics, Profile)
2. **Features**: Focus on business management rather than discovery
3. **UI**: Merchant-focused dashboard with stats, charts, and management tools
4. **Permissions**: Role-based access control for merchant features

### Merchant-Specific Features Needed
1. **Dashboard**: Overview of business metrics
2. **Listing Management**: Create, edit, delete listings
3. **Booking Management**: View, confirm, cancel bookings
4. **Analytics**: Revenue, bookings, views, reviews
5. **Inventory Management**: Room availability, table management
6. **Pricing Management**: Set prices, discounts, special offers
7. **Review Management**: View and respond to reviews
8. **Notification Management**: Business notifications
9. **Payment Management**: View transactions, payouts
10. **Settings**: Business profile, operating hours, contact info

---

## Next Steps for Merchant App Development

1. **Setup Project Structure** following the same pattern
2. **Create Merchant-Specific Models** extending base models
3. **Build Merchant Dashboard** with key metrics
4. **Implement Listing Management** (CRUD operations)
5. **Build Booking Management** interface
6. **Add Analytics/Reporting** screens
7. **Create Merchant Profile** management
8. **Implement Role-Based Routing** (merchant vs explorer)

---

## Complete Screen Inventory

### Auth Screens (3)
1. **OnboardingScreen** - Welcome/onboarding flow
2. **LoginScreen** - Phone/Email login with country picker
3. **RegisterScreen** - User registration

### Explore Screens (15)
1. **ExploreScreen** - Main discovery hub with all widgets
2. **DiningScreen** - Restaurant listings
3. **ExperiencesScreen** - Experience/tour listings
4. **NightlifeScreen** - Nightlife venues
5. **ShoppingScreen** - Shopping locations
6. **AccommodationScreen** - Hotel listings
7. **AccommodationDetailScreen** - Hotel details with room selection
8. **AccommodationBookingScreen** - Hotel booking flow
9. **PlaceDetailScreen** - Generic place details
10. **DiningBookingScreen** - Restaurant table booking
11. **DiningBookingConfirmationScreen** - Booking confirmation
12. **MapScreen** - Map view of places
13. **RecommendationsScreen** - Personalized recommendations
14. **CategoryPlacesScreen** - Places by category
15. **CategorySearchScreen** - Category-based search
16. **SpecialsScreen** - Special offers and deals

### Events Screens (2)
1. **EventsScreen** - Main events listing with tabs (Trending, Near Me, This Week, MICE)
2. **EventDetailScreen** - Individual event details

### Booking Screens (2)
1. **BookingScreen** - Generic booking interface
2. **BookingConfirmationScreen** - Booking confirmation

### Profile Screens (13)
1. **ProfileScreen** - Main profile with stats and menu
2. **EditProfileScreen** - Edit user profile
3. **MyBookingsScreen** - User's booking history
4. **FavoritesScreen** - Saved favorites
5. **ReviewsRatingsScreen** - Reviews received
6. **ReviewsWrittenScreen** - Reviews written by user
7. **EventsAttendedScreen** - Events user attended
8. **VisitedPlacesScreen** - Places user visited
9. **PrivacySecurityScreen** - Privacy and security settings
10. **HelpCenterScreen** - Help and support
11. **AboutScreen** - App information
12. **SettingsScreen** - App settings

### Other Feature Screens (6)
1. **ListingsScreen** - Business listings
2. **ListingDetailScreen** - Listing details
3. **SearchScreen** - Global search
4. **NotificationsScreen** - Notifications list
5. **ReferralScreen** - Referral program
6. **ZoeaCardScreen** - Digital wallet
7. **TransactionHistoryScreen** - Transaction list

---

## Animation & Loading States

### Animations
- **Greeting Animation**: Fade-in animation on explore screen (1.5s duration)
- **Search Bar Animation**: Fade-in after greeting (800ms duration)
- **Shimmer Animation**: Continuous loading shimmer (1.5s loop)
- **Rewards Icon Animation**: Color pulse animation (orange theme, 2s loop)
- **Page Transitions**: 300ms duration (defined in AppConfig)

### Loading States
- **Skeleton Cards**: Shimmer effect on event cards, place cards
- **Loading Indicators**: CircularProgressIndicator with primary color
- **Error States**: Error icon with retry button
- **Empty States**: Icon with descriptive message

---

## Phone Validation & Formatting

### PhoneValidator
- `validateInternationalPhone()`: Validates 7-15 digit phone numbers
- `validateRwandanPhone()`: Validates Rwandan format (07xxxxxxxx or 08xxxxxxxx, 9 digits)

### PhoneInputFormatter
- Formats phone numbers as user types
- Format: `07X XXX XXX` for Rwandan numbers
- Limits to 9 digits
- Removes non-digit characters

---

## Theme Provider

### ThemeNotifier (StateNotifier)
- Manages theme mode: light, dark, system
- Persists theme preference in SharedPreferences
- Methods: `setTheme()`, `toggleTheme()`
- Getters: `isDarkMode`, `isLightMode`, `isSystemMode`

### Current Theme Provider
- Provides current ThemeData based on theme mode and system brightness
- Automatically switches between light/dark themes

---

## Complete Routing Structure

### Auth Routes
- `/onboarding` - Onboarding flow
- `/login` - Login screen
- `/register` - Registration screen

### Main Shell Routes (Bottom Nav)
- `/explore` - Explore/home screen
- `/events` - Events listing
- `/accommodation` - Accommodation listings
- `/my-bookings` - User bookings
- `/profile` - User profile

### Detail Routes
- `/event/:id` - Event details (with Event object as extra)
- `/listing/:id` - Listing details
- `/place/:placeId` - Place details
- `/accommodation/:accommodationId` - Accommodation details (with date/guest data)
- `/accommodation/:accommodationId/book` - Accommodation booking (with booking data)

### Booking Routes
- `/booking/:listingId` - Generic booking
- `/booking-confirmation/:bookingId` - Booking confirmation
- `/dining-booking` - Dining booking (with booking data as extra)
- `/dining-booking-confirmation` - Dining confirmation (with confirmation data)

### Profile Routes
- `/profile/edit` - Edit profile
- `/profile/privacy-security` - Privacy settings
- `/profile/my-bookings` - Bookings
- `/profile/favorites` - Favorites
- `/profile/reviews-ratings` - Reviews received
- `/profile/reviews-written` - Reviews written
- `/profile/events-attended` - Events attended
- `/profile/visited-places` - Visited places

### Other Routes
- `/zoea-card` - Digital wallet
- `/transactions` - Transaction history
- `/settings` - App settings
- `/referrals` - Referral program
- `/notifications` - Notifications
- `/search` - Search (with query and category params)
- `/map` - Map view
- `/dining` - Dining listings
- `/experiences` - Experiences
- `/nightlife` - Nightlife
- `/shopping` - Shopping
- `/specials` - Special offers
- `/recommendations` - Recommendations
- `/category/:category` - Category places

---

## API Integration Details

### Events API (sinc.today)
- **Base URL**: `https://api-prod.sinc.today/events/v1/public`
- **Endpoint**: `/explore-events`
- **Query Parameters**:
  - `page`, `limit` - Pagination
  - `category`, `location` - Filters
  - `startDate`, `endDate` - Date range
  - `latitude`, `longitude`, `radius` - Location-based
  - `search` - Search query
  - `sort` - Sorting (e.g., 'trending')
- **Response Format**: EventsResponse with EventsData and Pagination

### Zoea API (zoea.africa)
- **Base URL**: `https://api.zoea.africa/v1`
- All endpoints defined in AppConfig
- Dio instance with logging interceptor (debug mode)
- Timeout: 30 seconds (connection and receive)

---

## Notes
- The app uses mock data for development
- Backend integration points are defined but not fully implemented
- Firebase is configured but push notifications are commented out
- Maps integration is commented out (google_maps_flutter)
- The app is designed for Rwanda market (RWF currency, Kigali default location)
- Events API uses sinc.today (external service)
- MICE events are hardcoded (20+ major conferences/summits)
- Phone validation supports both international and Rwandan formats
- Theme system supports system preference detection
- All screens use consistent error and loading states
- Skeleton loaders provide smooth loading experience
- Bottom sheets are used extensively for filters and selections

