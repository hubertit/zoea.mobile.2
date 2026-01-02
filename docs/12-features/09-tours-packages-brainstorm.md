# Tours & Packages Features - Brainstorming Document

## Current State Analysis

### ✅ What Already Exists

#### Backend Infrastructure
- **Tours API**: Full CRUD operations (`/api/tours`)
- **Tour Model**: Comprehensive schema with:
  - Basic info (name, description, slug)
  - Classification (category, type: wildlife/cultural/adventure/hiking/city/beach/safari)
  - Duration (hours/days)
  - Location (country, city, start/end locations, operating regions)
  - Pricing (per person, group discounts, min/max group size)
  - Details (includes/excludes, itinerary JSON, requirements, difficulty level)
  - Languages offered
  - Status management (draft/active/inactive/cancelled)
  - Stats (rating, review count, booking count)
- **Tour Schedules**: Date/time-based availability with spot management
- **Tour Images**: Media management with primary image support
- **Tour Operators**: Operator profiles linked to tours
- **Bookings Integration**: Tours can be booked (Booking model has `tourId` field)

#### Mobile App Foundation
- **Booking Model**: Already supports tours (`BookingType.tour`, `tourId` field)
- **Booking Service**: Infrastructure exists for tour bookings
- **Router**: Can add tour routes easily
- **State Management**: Riverpod providers pattern established
- **UI Components**: Reusable components for listings, bookings, etc.

### ❌ What's Missing

#### Mobile App Features
- No tour browsing/discovery screens
- No tour detail screens
- No tour booking flow
- No tour schedule selection UI
- No tour package comparison
- No tour favorites
- No tour reviews display/creation
- No tour search/filtering
- No tour recommendations

---

## Feature Brainstorming

### 1. Tour Discovery & Browsing

#### 1.1 Tours Screen
**Purpose**: Main entry point for discovering tours

**Features**:
- **Hero Section**: Featured tours carousel
- **Categories**: Quick filter by tour type (Wildlife, Cultural, Adventure, Hiking, City, Beach, Safari)
- **Popular Tours**: Most booked tours
- **New Tours**: Recently added tours
- **Nearby Tours**: Location-based recommendations
- **Price Range Filters**: Budget-friendly to premium
- **Duration Filters**: Day trips vs multi-day tours

**UI Components**:
- Tour card with:
  - Hero image
  - Tour name
  - Tour type badge
  - Duration (e.g., "3 Days", "8 Hours")
  - Price per person
  - Rating & review count
  - Difficulty level indicator
  - "From" pricing for variable pricing
  - Quick action: "View Details" or "Book Now"

**Layout Options**:
- Grid view (2 columns)
- List view (detailed cards)
- Map view (tours on map)

#### 1.2 Tour Categories Screen
**Purpose**: Browse tours by category/type

**Categories**:
- 🦁 **Wildlife Tours**: Gorilla trekking, safari, bird watching
- 🏛️ **Cultural Tours**: Heritage sites, traditional experiences
- ⛰️ **Adventure Tours**: Hiking, biking, water sports
- 🥾 **Hiking Tours**: Mountain trails, nature walks
- 🏙️ **City Tours**: Urban exploration, city highlights
- 🏖️ **Beach Tours**: Lake excursions, beach activities
- 🦏 **Safari Tours**: Game drives, wildlife viewing

**Features**:
- Category-specific filters
- Sub-categories where applicable
- Category descriptions
- Popular tours in category

#### 1.3 Tour Search & Filters
**Purpose**: Advanced search and filtering

**Search**:
- Text search (tour name, description, location)
- Voice search
- Search history
- Search suggestions

**Filters**:
- **Location**: Country, City, Region
- **Tour Type**: Wildlife, Cultural, Adventure, etc.
- **Duration**: 
  - Day trips (1 day)
  - Short tours (2-3 days)
  - Extended tours (4+ days)
- **Price Range**: Slider or preset ranges
- **Difficulty Level**: Easy, Moderate, Challenging
- **Group Size**: Solo-friendly, Small groups, Large groups
- **Languages**: English, French, Kinyarwanda, etc.
- **Availability**: Tours available in next 7/30/90 days
- **Rating**: Minimum rating filter
- **Features**: 
  - Includes meals
  - Includes accommodation
  - Transportation included
  - Guide included
  - Photography allowed
  - Family-friendly
  - Wheelchair accessible

**Sort Options**:
- Popularity (most booked)
- Rating (highest rated)
- Price (low to high, high to low)
- Duration (shortest to longest)
- Newest first
- Distance (nearest first)

---

### 2. Tour Details & Information

#### 2.1 Tour Detail Screen
**Purpose**: Comprehensive tour information

**Sections**:

1. **Hero Section**
   - Image gallery (swipeable, full-screen view)
   - Tour name
   - Tour type badge
   - Quick stats (rating, reviews, bookings)
   - Share button
   - Favorite button

2. **Overview**
   - Short description
   - Duration (days/hours)
   - Difficulty level with icon
   - Languages offered
   - Group size (min/max)
   - Price per person (with currency)
   - Group discount info

3. **Highlights**
   - Key features/attractions
   - What makes it special
   - Icon-based highlights

4. **Itinerary**
   - Day-by-day breakdown (for multi-day tours)
   - Time-based schedule (for day tours)
   - Activities per day
   - Meal times
   - Accommodation details (if included)
   - Interactive timeline view

5. **What's Included/Excluded**
   - Clear lists with checkmarks/X marks
   - Transportation details
   - Meals included
   - Accommodation details
   - Guide information
   - Equipment provided

6. **Requirements**
   - Physical fitness level
   - Age restrictions
   - Health requirements
   - Visa/passport requirements
   - What to bring
   - Weather considerations

7. **Location Information**
   - Start location (with map)
   - End location (with map)
   - Pickup points
   - Operating regions
   - Directions/transportation info

8. **Pricing Details**
   - Base price per person
   - Group discounts (if applicable)
   - Child pricing (if applicable)
   - Additional fees
   - Cancellation policy
   - Refund policy

9. **Tour Operator**
   - Operator name & logo
   - Verification badge
   - Operator rating
   - Other tours by operator
   - Contact information

10. **Reviews & Ratings**
    - Overall rating breakdown
    - Review count
    - Recent reviews
    - Filter reviews (most helpful, newest, highest rated)
    - Write review button

11. **Availability Calendar**
    - Calendar view of available dates
    - Available spots per date
    - Price variations (if any)
    - Book now CTA

12. **Similar Tours**
    - Recommendations based on:
      - Same category
      - Same location
      - Similar price range
      - Similar duration

**Actions**:
- Book Now (primary CTA)
- Add to Favorites
- Share Tour
- Contact Operator
- View on Map
- Read Reviews
- Report Issue

#### 2.2 Tour Image Gallery
**Purpose**: Full-screen image viewing

**Features**:
- Swipeable gallery
- Zoom functionality
- Image captions
- Share individual images
- Download images (if allowed)

#### 2.3 Tour Map View
**Purpose**: Visualize tour locations and route

**Features**:
- Start location marker
- End location marker
- Route visualization (if applicable)
- Waypoints/stops
- Nearby attractions
- Distance indicators
- Directions integration

---

### 3. Tour Booking Flow

#### 3.1 Tour Booking Screen
**Purpose**: Select dates, participants, and book tour

**Flow**:

1. **Select Date & Time**
   - Calendar picker
   - Available dates highlighted
   - Unavailable dates grayed out
   - Time slots (if applicable)
   - Available spots indicator
   - Price per date (if varies)

2. **Select Participants**
   - Number of adults
   - Number of children (if applicable)
   - Age groups (if pricing differs)
   - Guest details form:
     - Full name
     - Email
     - Phone
     - Nationality
     - ID type & number (if required)
   - Add multiple guests

3. **Special Requirements**
   - Dietary restrictions
   - Accessibility needs
   - Medical conditions
   - Special requests
   - Equipment needs

4. **Pricing Breakdown**
   - Base price × participants
   - Group discount (if applicable)
   - Additional fees
   - Taxes
   - Total amount
   - Currency conversion (if needed)

5. **Contact Information**
   - Primary contact details
   - Emergency contact
   - Communication preferences

6. **Terms & Conditions**
   - Cancellation policy
   - Refund policy
   - Terms acceptance checkbox

7. **Payment**
   - Payment method selection
   - Payment processing
   - Booking confirmation

**Validation**:
- Date availability check
- Group size limits
- Minimum age requirements
- Required fields validation
- Real-time price calculation

#### 3.2 Tour Booking Confirmation
**Purpose**: Confirm successful booking

**Information Displayed**:
- Booking number
- Tour name
- Date & time
- Participants
- Total amount
- Payment status
- Booking status
- Operator contact
- What to expect next
- Cancellation instructions
- Add to calendar
- Download booking PDF

**Actions**:
- View booking details
- Modify booking (if allowed)
- Cancel booking
- Contact operator
- Share booking
- Add to favorites

#### 3.3 Tour Schedule Selection
**Purpose**: Advanced schedule selection for tours with multiple time slots

**Features**:
- Calendar view with availability
- Time slot selection
- Available spots per slot
- Price variations
- Group size requirements
- Real-time availability updates

---

### 4. Tour Packages & Bundles

#### 4.1 Tour Packages
**Purpose**: Combine multiple tours or services

**Package Types**:

1. **Multi-Tour Packages**
   - Combine 2+ tours
   - Discounted pricing
   - Recommended combinations
   - Customizable packages

2. **Tour + Accommodation**
   - Tour + hotel stay
   - Tour + resort package
   - Extended stay options

3. **Tour + Dining**
   - Tour + restaurant bookings
   - Meal packages
   - Culinary tour experiences

4. **Complete Experience Packages**
   - Tour + accommodation + dining
   - All-inclusive packages
   - Luxury packages

**Features**:
- Package builder
- Save custom packages
- Share packages
- Package comparison
- Package recommendations

#### 4.2 Tour Comparison
**Purpose**: Compare multiple tours side-by-side

**Comparison Criteria**:
- Price
- Duration
- Difficulty
- Rating
- What's included
- Location
- Group size
- Languages

**UI**:
- Side-by-side cards
- Highlight differences
- Quick book from comparison

---

### 5. Tour Management (User Side)

#### 5.1 My Tours (Bookings)
**Purpose**: Manage tour bookings

**Sections**:
- **Upcoming Tours**: Future bookings
- **Past Tours**: Completed tours
- **Cancelled Tours**: Cancelled bookings

**Tour Card Information**:
- Tour name & image
- Date & time
- Booking number
- Status
- Participants
- Total amount
- Quick actions

**Actions**:
- View details
- Modify booking
- Cancel booking
- Contact operator
- Write review
- Rebook tour

**Filters**:
- Status (upcoming, past, cancelled)
- Date range
- Tour type
- Sort by date

#### 5.2 Tour Favorites
**Purpose**: Save tours for later

**Features**:
- Favorite tours list
- Organize by category
- Share favorite lists
- Get notified of price changes
- Get notified of availability

#### 5.3 Tour Reviews
**Purpose**: Review and rate tours

**Review Form**:
- Overall rating (1-5 stars)
- Rating breakdown:
  - Tour guide
  - Value for money
  - Experience quality
  - Organization
- Written review
- Photos/videos
- Would recommend toggle
- Helpful votes

**Review Display**:
- Review cards
- Filter by rating
- Sort by helpful/newest
- Report inappropriate reviews

---

### 6. Tour Recommendations & Personalization

#### 6.1 Personalized Recommendations
**Purpose**: Suggest tours based on user preferences

**Recommendation Factors**:
- User interests (from profile)
- Past bookings
- Location preferences
- Budget range
- Travel style
- Reviews written
- Favorites
- Search history

**Recommendation Types**:
- "For You" section
- "Based on your interests"
- "Similar to [Tour Name]"
- "Popular in [Location]"
- "Trending now"
- "Limited availability"

#### 6.2 Tour Discovery Features
**Purpose**: Help users discover new tours

**Features**:
- "Tour of the Day"
- "Hidden Gems"
- "Budget-Friendly Tours"
- "Luxury Experiences"
- "Last-Minute Deals"
- "Seasonal Tours"
- "New This Week"

---

### 7. Tour Social Features

#### 7.1 Tour Sharing
**Purpose**: Share tours with friends/family

**Sharing Options**:
- Share via social media
- Share via messaging apps
- Share via email
- Generate shareable link
- Share booking details
- Share wishlist

#### 7.2 Tour Groups
**Purpose**: Book tours as a group

**Features**:
- Create tour group
- Invite friends
- Group chat
- Split payment
- Group discounts
- Group itinerary coordination

#### 7.3 Tour Experiences
**Purpose**: Share tour experiences

**Features**:
- Post tour photos
- Share tour stories
- Tag tours in posts
- Follow tour operators
- Tour experience feed

---

### 8. Tour Information & Support

#### 8.1 Tour FAQs
**Purpose**: Common questions about tours

**Categories**:
- Booking questions
- Cancellation/refund
- What to bring
- Health & safety
- Group size
- Pricing
- Operator contact

#### 8.2 Tour Support
**Purpose**: Get help with tours

**Features**:
- Contact tour operator
- Contact support
- Live chat
- Help center
- Report issues
- Request refund

#### 8.3 Tour Preparation
**Purpose**: Help users prepare for tours

**Features**:
- Pre-tour checklist
- What to pack
- Weather forecast
- Health recommendations
- Visa requirements
- Meeting point details
- Emergency contacts

---

### 9. Advanced Features

#### 9.1 Tour Waitlist
**Purpose**: Join waitlist for fully booked tours

**Features**:
- Join waitlist
- Notifications when spots available
- Automatic booking option
- Waitlist position

#### 9.2 Tour Gift Cards
**Purpose**: Gift tours to others

**Features**:
- Purchase tour gift card
- Custom amount
- Personal message
- Delivery options
- Gift card redemption

#### 9.3 Tour Subscriptions
**Purpose**: Subscribe to tour updates

**Features**:
- Subscribe to tour operator
- Get new tour notifications
- Price drop alerts
- Availability alerts
- Newsletter subscription

#### 9.4 Tour Loyalty Program
**Purpose**: Reward frequent tour bookers

**Features**:
- Points for bookings
- Points for reviews
- Tiered benefits
- Exclusive tours
- Discounts
- Early access

#### 9.5 Tour Analytics (for users)
**Purpose**: Track tour history and preferences

**Features**:
- Tours booked count
- Total spent
- Favorite tour types
- Most visited locations
- Tour completion rate
- Review contribution

---

### 10. Integration Features

#### 10.1 Calendar Integration
**Purpose**: Add tours to calendar

**Features**:
- Add to device calendar
- Reminders
- Sync across devices
- Share calendar events

#### 10.2 Maps Integration
**Purpose**: Navigation and location services

**Features**:
- Directions to start location
- Tour route on map
- Nearby tours
- Location-based recommendations
- Offline maps

#### 10.3 Payment Integration
**Purpose**: Seamless payment processing

**Features**:
- Multiple payment methods
- Saved payment methods
- Split payment
- Installment options
- Refund processing

#### 10.4 Notification Integration
**Purpose**: Keep users informed

**Notifications**:
- Booking confirmations
- Reminders (24h, 1h before)
- Cancellation notices
- Price drop alerts
- Availability alerts
- Review reminders
- Operator messages

---

## Technical Implementation Considerations

### Mobile App Architecture

#### New Features/Screens Needed

1. **Tours Feature Module**
   ```
   mobile/lib/features/tours/
   ├── screens/
   │   ├── tours_screen.dart              # Main tours browsing
   │   ├── tour_detail_screen.dart        # Tour details
   │   ├── tour_booking_screen.dart       # Booking flow
   │   ├── tour_booking_confirmation_screen.dart
   │   ├── tour_categories_screen.dart    # Browse by category
   │   ├── tour_search_screen.dart        # Search & filters
   │   ├── tour_schedule_screen.dart      # Schedule selection
   │   ├── tour_reviews_screen.dart       # Reviews list
   │   ├── tour_map_screen.dart           # Map view
   │   └── my_tours_screen.dart           # User's bookings
   ├── widgets/
   │   ├── tour_card.dart                 # Tour list item
   │   ├── tour_image_gallery.dart        # Image gallery
   │   ├── tour_itinerary_widget.dart     # Itinerary display
   │   ├── tour_schedule_calendar.dart    # Calendar picker
   │   ├── tour_pricing_breakdown.dart    # Price details
   │   ├── tour_operator_card.dart        # Operator info
   │   └── tour_review_card.dart          # Review display
   └── models/
       └── tour.dart                      # Tour model
   ```

2. **Models**
   - `Tour` model (mirror backend schema)
   - `TourSchedule` model
   - `TourImage` model
   - `TourOperator` model (if needed)

3. **Providers**
   - `tours_provider.dart` - Tours list, search, filters
   - `tour_detail_provider.dart` - Single tour details
   - `tour_booking_provider.dart` - Booking creation
   - `tour_schedules_provider.dart` - Schedule availability
   - `tour_favorites_provider.dart` - Favorites management
   - `tour_reviews_provider.dart` - Reviews

4. **Services**
   - `tours_service.dart` - API calls for tours
   - Extend `bookings_service.dart` for tour bookings

5. **Router Updates**
   - Add tour routes to `app_router.dart`
   - `/tours` - Tours list
   - `/tours/:id` - Tour detail
   - `/tours/:id/book` - Tour booking
   - `/tours/:id/reviews` - Tour reviews
   - `/my-tours` - User's tour bookings

### Data Models

#### Tour Model (Dart)
```dart
class Tour {
  final String id;
  final String? operatorId;
  final String name;
  final String? slug;
  final String? description;
  final String? shortDescription;
  final String? categoryId;
  final TourType? type;
  final double? durationHours;
  final int? durationDays;
  final String? countryId;
  final String? cityId;
  final String? startLocationName;
  final String? endLocationName;
  final double? pricePerPerson;
  final String currency;
  final double? groupDiscountPercentage;
  final int minGroupSize;
  final int maxGroupSize;
  final List<String> includes;
  final List<String> excludes;
  final Map<String, dynamic>? itinerary;
  final List<String> requirements;
  final DifficultyLevel? difficultyLevel;
  final List<String> languages;
  final TourStatus status;
  final bool isFeatured;
  final double rating;
  final int reviewCount;
  final int bookingCount;
  final List<TourImage> images;
  final List<TourSchedule> schedules;
  final Category? category;
  final City? city;
  final Country? country;
  final TourOperator? operator;
  // ... fromJson, toJson methods
}

enum TourType {
  wildlife,
  cultural,
  adventure,
  hiking,
  city,
  beach,
  safari,
}

enum DifficultyLevel {
  easy,
  moderate,
  challenging,
}

enum TourStatus {
  draft,
  active,
  inactive,
  cancelled,
}
```

### API Integration

#### Endpoints to Use
- `GET /api/tours` - List tours with filters
- `GET /api/tours/:id` - Get tour details
- `GET /api/tours/:id/schedules` - Get tour schedules
- `POST /api/bookings` - Create tour booking (use existing endpoint)
- `GET /api/tours/:id/reviews` - Get tour reviews
- `POST /api/tours/:id/favorites` - Add to favorites
- `DELETE /api/tours/:id/favorites` - Remove from favorites

### State Management

#### Riverpod Providers Pattern
- Use `FutureProvider` for async data fetching
- Use `StateNotifier` for complex state (booking flow)
- Use `Provider` for derived state
- Cache tour data appropriately

### UI/UX Considerations

#### Design Principles
1. **Visual Hierarchy**: Tour images should be prominent
2. **Information Density**: Balance detail with readability
3. **Progressive Disclosure**: Show key info first, details on demand
4. **Mobile-First**: Optimize for mobile screens
5. **Accessibility**: Support screen readers, high contrast
6. **Performance**: Lazy load images, paginate lists

#### Key UI Patterns
- **Card-based Design**: Tour cards for browsing
- **Bottom Sheets**: For filters, booking flow
- **Full-screen Modals**: For image gallery, booking
- **Sticky Headers**: Keep important actions visible
- **Pull-to-Refresh**: Update tour lists
- **Infinite Scroll**: Load more tours as user scrolls

#### Loading States
- Skeleton loaders for tour cards
- Shimmer effects
- Progress indicators for booking flow
- Empty states with helpful messages

#### Error Handling
- Network error messages
- No tours found states
- Booking failure handling
- Retry mechanisms

---

## Implementation Priority

### Phase 1: Core Features (MVP)
1. ✅ Tour browsing screen
2. ✅ Tour detail screen
3. ✅ Tour booking flow
4. ✅ Tour booking confirmation
5. ✅ My tours (bookings list)

### Phase 2: Enhanced Discovery
6. Tour search & filters
7. Tour categories
8. Tour reviews display
9. Tour favorites

### Phase 3: Advanced Features
10. Tour packages/bundles
11. Tour comparison
12. Tour recommendations
13. Tour map view
14. Tour image gallery

### Phase 4: Social & Engagement
15. Tour sharing
16. Tour groups
17. Tour reviews creation
18. Tour social features

### Phase 5: Premium Features
19. Tour waitlist
20. Tour gift cards
21. Tour subscriptions
22. Tour loyalty program

---

## Open Questions & Decisions Needed

1. **Tour Packages**: Should packages be a separate entity or just UI grouping?
2. **Pricing**: How to handle dynamic pricing (seasonal, group discounts)?
3. **Availability**: Real-time vs cached availability?
4. **Booking Modifications**: Allow modifications after booking?
5. **Cancellation**: Automatic vs manual cancellation?
6. **Reviews**: When can users review (after tour, after completion)?
7. **Offline Support**: Cache tour data for offline viewing?
8. **Push Notifications**: What events trigger notifications?
9. **Analytics**: What tour metrics to track?
10. **Internationalization**: Support multiple languages in UI?

---

## Next Steps

1. **Review & Prioritize**: Review this document and prioritize features
2. **Design Mockups**: Create UI/UX mockups for key screens
3. **Technical Design**: Detailed technical design for Phase 1
4. **API Review**: Verify backend APIs support all needed features
5. **Prototype**: Build prototype for core booking flow
6. **User Testing**: Test with target users
7. **Iterate**: Refine based on feedback

---

## References

- Backend Tours API: `backend/src/modules/tours/`
- Database Schema: `backend/prisma/schema.prisma` (Tour model)
- Booking Model: `mobile/lib/core/models/booking.dart`
- Category Analysis: `CATEGORY_ANALYSIS.md`
- Existing Booking Flow: `mobile/lib/features/explore/screens/accommodation_booking_screen.dart`




