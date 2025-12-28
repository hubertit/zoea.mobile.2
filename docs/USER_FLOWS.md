# User Flows Documentation

## Mobile App User Flows

### 1. Authentication Flow

```
User opens app
    ↓
[Not Logged In]
    ↓
Login Screen / Register Screen
    ↓
Enter credentials (email/phone + password)
    ↓
API: POST /auth/login or /auth/register
    ↓
Receive: accessToken + refreshToken
    ↓
Store tokens securely
    ↓
Navigate to Home/Explore Screen
```

**Who Handles What:**
- **Mobile**: UI, form validation, token storage, navigation
- **Backend**: Authentication, token generation, user creation

---

### 2. Explore & Discovery Flow

```
User opens Explore Screen
    ↓
API: GET /categories (parent categories)
    ↓
Display main categories (Accommodation, Dining, etc.)
    ↓
User taps category
    ↓
API: GET /listings?categoryId={id}
    ↓
Display listings in CategoryPlacesScreen
    ↓
User taps listing
    ↓
API: GET /listings/{id}
    ↓
Display ListingDetailScreen or AccommodationDetailScreen
```

**Who Handles What:**
- **Mobile**: Category display, listing cards, navigation, filtering UI
- **Backend**: Category data, listing queries, filtering logic

---

### 3. Accommodation Booking Flow

```
User views AccommodationDetailScreen
    ↓
User taps "Book Now" or selects rooms
    ↓
Navigate to AccommodationBookingScreen
    ↓
User selects:
  - Check-in date
  - Check-out date
  - Guest count
  - Room types (if not pre-selected)
    ↓
User reviews price breakdown
    ↓
User adds special requests (optional)
    ↓
User applies coupon (optional)
    ↓
User taps "Continue to Payment"
    ↓
API: POST /bookings
  {
    bookingType: "hotel",
    listingId: "...",
    checkInDate: "...",
    checkOutDate: "...",
    roomTypeId: "...",
    guestCount: 2,
    specialRequests: "..."
  }
    ↓
Navigate to Payment/Confirmation Screen
```

**Who Handles What:**
- **Mobile**: Date pickers, room selection UI, price calculation, form validation
- **Backend**: Booking creation, availability checking, price calculation, payment processing

---

### 4. Restaurant Booking Flow

```
User views Restaurant Listing
    ↓
User taps "Book Table"
    ↓
Navigate to DiningBookingScreen
    ↓
User selects:
  - Date
  - Time slot
  - Party size (guests)
    ↓
User enters contact information:
  - Full Name
  - Phone Number
  - Email Address
    ↓
User adds special requests (optional)
    ↓
User applies coupon (optional)
    ↓
User taps "Confirm Booking"
    ↓
API: POST /bookings
  {
    bookingType: "restaurant",
    listingId: "...",
    bookingDate: "...",
    bookingTime: "19:00",
    partySize: 4,
    guests: [{ fullName, email, phone }]
  }
    ↓
Show confirmation modal
    ↓
Navigate to BookingConfirmationScreen
```

**Who Handles What:**
- **Mobile**: Time slot selection, contact form, validation
- **Backend**: Booking creation, table availability, time slot validation

---

### 5. Favorites Flow

```
User views listing
    ↓
User taps heart icon
    ↓
API: POST /favorites (toggle)
    ↓
Update UI (heart filled/unfilled)
    ↓
Show success message
```

**Who Handles What:**
- **Mobile**: UI state, user feedback
- **Backend**: Favorite storage, toggle logic

---

### 6. Review Flow

```
User views ListingDetailScreen
    ↓
User scrolls to Reviews tab
    ↓
API: GET /reviews?listingId={id}
    ↓
Display reviews
    ↓
User taps "Write Review"
    ↓
User enters:
  - Rating (1-5 stars)
  - Review text
  - Optional: images
    ↓
API: POST /reviews
  {
    listingId: "...",
    rating: 5,
    comment: "..."
  }
    ↓
Refresh reviews list
    ↓
Show success message
```

**Who Handles What:**
- **Mobile**: Review form, image picker, rating UI
- **Backend**: Review storage, moderation, aggregation

---

### 7. Search Flow

```
User taps search bar
    ↓
User enters search query
    ↓
API: GET /search?q={query}
    ↓
Display results:
  - Listings
  - Events
  - Tours
    ↓
User filters results (optional)
    ↓
User taps result
    ↓
Navigate to detail screen
```

**Who Handles What:**
- **Mobile**: Search UI, result display, filtering UI
- **Backend**: Search indexing, query processing, result ranking

---

## Admin Dashboard User Flows

### 1. Admin Login Flow

```
Admin opens dashboard
    ↓
Login Screen
    ↓
Enter admin credentials
    ↓
API: POST /auth/login
    ↓
Receive tokens
    ↓
Navigate to Dashboard
```

**Who Handles What:**
- **Admin**: Login UI, form handling
- **Backend**: Admin authentication, role verification

---

### 2. Listing Management Flow

```
Admin navigates to Listings
    ↓
API: GET /admin/listings
    ↓
Display all listings with filters
    ↓
Admin can:
  - View listing details
  - Edit listing
  - Approve/reject listing
  - Delete listing
    ↓
API: PUT /admin/listings/{id} or DELETE
    ↓
Refresh listings list
```

**Who Handles What:**
- **Admin**: Listing table, edit forms, action buttons
- **Backend**: Listing CRUD, approval workflow, permissions

---

### 3. Booking Management Flow

```
Admin navigates to Bookings
    ↓
API: GET /admin/bookings
    ↓
Display all bookings with filters
    ↓
Admin can:
  - View booking details
  - Update booking status
  - Cancel booking
  - Generate invoice
    ↓
API: PUT /admin/bookings/{id} or POST /cancel
    ↓
Update booking status
```

**Who Handles What:**
- **Admin**: Booking table, status management UI
- **Backend**: Booking status updates, cancellation logic, invoice generation

---

### 4. Analytics Flow

```
Admin opens Dashboard
    ↓
API: GET /admin/analytics
    ↓
Display:
  - Total bookings
  - Revenue
  - User growth
  - Popular listings
  - Charts and graphs
    ↓
Admin can filter by date range
    ↓
API: GET /admin/analytics?startDate=...&endDate=...
    ↓
Update charts
```

**Who Handles What:**
- **Admin**: Chart rendering, date pickers, data visualization
- **Backend**: Analytics calculation, data aggregation, report generation

---

## System Flows

### 1. Booking Creation Flow (System)

```
User submits booking
    ↓
Mobile: Validate form data
    ↓
Mobile: POST /bookings
    ↓
Backend: Validate request
    ↓
Backend: Check availability
    ↓
Backend: Calculate price
    ↓
Backend: Apply discounts/coupons
    ↓
Backend: Create booking (status: pending)
    ↓
Backend: Generate booking number
    ↓
Backend: Send confirmation email (async)
    ↓
Backend: Return booking data
    ↓
Mobile: Display confirmation
    ↓
Mobile: Navigate to payment (if required)
```

**Who Handles What:**
- **Mobile**: Form validation, API call, UI feedback
- **Backend**: Business logic, database operations, email notifications

---

### 2. Payment Flow (System)

```
User confirms booking
    ↓
Mobile: Navigate to payment screen
    ↓
User selects payment method
    ↓
Mobile: POST /bookings/{id}/confirm-payment
    ↓
Backend: Process payment
    ↓
Backend: Update booking status (confirmed)
    ↓
Backend: Update payment status
    ↓
Backend: Send confirmation notification
    ↓
Backend: Return updated booking
    ↓
Mobile: Display success
    ↓
Mobile: Navigate to booking details
```

**Who Handles What:**
- **Mobile**: Payment UI, method selection
- **Backend**: Payment processing, status updates, notifications

---

### 3. Review Moderation Flow (System)

```
User submits review
    ↓
Backend: Create review (status: pending)
    ↓
Backend: Notify admin (async)
    ↓
Admin: View pending reviews
    ↓
Admin: Approve or reject
    ↓
Backend: Update review status
    ↓
Backend: Update listing rating (if approved)
    ↓
Backend: Notify user (async)
    ↓
Mobile: Review appears in listing (if approved)
```

**Who Handles What:**
- **Mobile**: Review submission, display approved reviews
- **Backend**: Moderation workflow, rating aggregation, notifications
- **Admin**: Review approval UI, moderation actions

---

### 4. Token Refresh Flow (System)

```
Mobile: Makes API request
    ↓
Backend: Validates token
    ↓
Token expired?
    ↓
Yes → Backend: Returns 401 Unauthorized
    ↓
Mobile: Intercepts 401
    ↓
Mobile: POST /auth/refresh (with refreshToken)
    ↓
Backend: Validates refreshToken
    ↓
Backend: Returns new accessToken
    ↓
Mobile: Updates stored token
    ↓
Mobile: Retries original request
```

**Who Handles What:**
- **Mobile**: Token interceptor, automatic refresh, retry logic
- **Backend**: Token validation, refresh token generation

---

## Data Flow Diagrams

### Listing Data Flow

```
Database (PostgreSQL)
    ↓
Backend API (NestJS + Prisma)
    ↓
Mobile App (Flutter + Dio)
    ↓
UI Display (Widgets)
```

### Booking Data Flow

```
Mobile Form Input
    ↓
Validation (Mobile)
    ↓
API Request (Dio)
    ↓
Backend Validation (NestJS)
    ↓
Business Logic (Service)
    ↓
Database (Prisma)
    ↓
Response
    ↓
Mobile UI Update
```

### Search Data Flow

```
User Query (Mobile)
    ↓
API: GET /search?q={query}
    ↓
Backend: Process query
    ↓
Database: Search listings/events/tours
    ↓
Backend: Rank results
    ↓
Response: Ranked results
    ↓
Mobile: Display results
```

