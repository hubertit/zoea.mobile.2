# Zoea Features Breakdown

## Feature Ownership by Application

### Consumer Mobile App Features (`mobile/`)

**Primary User**: End users (travelers, tourists, locals)

#### Core Features
- ✅ **Authentication**
  - User registration
  - Login (email/phone)
  - Password reset
  - Profile management
  - Token management

- ✅ **Explore & Discovery**
  - Category browsing (Accommodation, Dining, Experiences, etc.)
  - Featured listings
  - Recommendations
  - Search functionality
  - Location-based discovery

- ✅ **Listings**
  - View listing details
  - Filter by category, type, location, price
  - Sort listings
  - View images, amenities, reviews
  - Accommodation-specific details (rooms, room types)

- ✅ **Favorites**
  - Add/remove favorites
  - View favorite listings
  - Favorite status indicators

- ✅ **Reviews & Ratings**
  - View reviews
  - Create reviews
  - Rate listings
  - Mark reviews as helpful

- ✅ **Bookings** (In Progress)
  - Hotel bookings (check-in/check-out, room selection)
  - Restaurant bookings (date, time, party size)
  - View booking history
  - Cancel bookings

- ✅ **Sharing**
  - Share listings via native share
  - Share accommodations
  - Share with social media

- ✅ **Contact**
  - Call listings (tel: links)
  - Open website URLs
  - Email contact

#### Future Features
- ⏳ Payment integration
- ⏳ Push notifications
- ⏳ Offline mode
- ⏳ Maps integration
- ⏳ Tour bookings
- ⏳ Event bookings

---

### Merchant Mobile App Features (`merchant-mobile/`)

**Primary User**: Merchants (hotel owners, restaurant owners, tour operators)

#### Core Features
- ✅ **Business Dashboard**
  - Overview of business performance
  - Key metrics and statistics
  - Recent activity

- ✅ **Listing Management**
  - View own listings
  - Create new listings
  - Edit listing details
  - Manage listing images
  - Update availability

- ✅ **Booking Management**
  - View incoming bookings
  - Manage booking status
  - Booking calendar
  - Guest information

- ✅ **Analytics**
  - Business performance metrics
  - Revenue tracking
  - Booking trends
  - Customer insights

- ✅ **Revenue Management**
  - View earnings
  - Payment history
  - Payout information

#### Future Features
- ⏳ Push notifications for new bookings
- ⏳ Offline mode
- ⏳ Advanced analytics
- ⏳ Customer communication
- ⏳ Review management

---

### Backend API Features (`backend/`)

**Primary User**: All applications (mobile, admin, web)

#### Core Modules
- ✅ **Authentication Module** (`/auth`)
  - User registration
  - Login with email/phone
  - Token refresh
  - Password reset
  - Profile management

- ✅ **Users Module** (`/users`)
  - Get user profile
  - Update profile
  - Change password/email/phone
  - Upload profile image
  - User preferences
  - User statistics

- ✅ **Listings Module** (`/listings`)
  - CRUD operations for listings
  - Filtering (category, type, location, price)
  - Search functionality
  - Featured listings
  - Listing details with relations

- ✅ **Categories Module** (`/categories`)
  - Get all categories
  - Get subcategories
  - Create categories
  - Category hierarchy (parent-child)

- ✅ **Bookings Module** (`/bookings`)
  - Create bookings (hotel, restaurant, tour, event)
  - Get user bookings
  - Update bookings
  - Cancel bookings
  - Confirm payment
  - Get upcoming bookings
  - Booking invoices

- ✅ **Reviews Module** (`/reviews`)
  - Create reviews
  - Get reviews (filtered by listing/event/tour)
  - Update reviews
  - Delete reviews
  - Mark reviews as helpful
  - Review moderation

- ✅ **Favorites Module** (`/favorites`)
  - Add to favorites
  - Remove from favorites
  - Toggle favorites
  - Get user favorites
  - Check favorite status

- ✅ **Search Module** (`/search`)
  - Global search (listings, events, tours)
  - Search by category
  - Location-based search
  - Advanced filters

- ✅ **Events Module** (`/events`)
  - Get events (via SINC API integration)
  - Event filtering
  - Event details

- ✅ **Tours Module** (`/tours`)
  - Get tours
  - Tour schedules
  - Featured tours
  - Tour details

- ✅ **Notifications Module** (`/notifications`)
  - Push notifications
  - In-app notifications
  - Notification preferences

- ✅ **Media/Upload Module** (`/upload`)
  - Image uploads
  - File uploads
  - Media management

- ✅ **Zoea Card Module** (`/zoea-card`)
  - Card management
  - Balance checking
  - Top-up functionality
  - Transaction history

- ✅ **Transactions Module** (`/transactions`)
  - Transaction history
  - Payment processing
  - Refund management

#### Admin-Only Modules
- ✅ **Admin Module** (`/admin/*`)
  - User management
  - Listing management
  - Booking management
  - Merchant management
  - Analytics and reports
  - Content moderation

---

### Admin Dashboard Features (`admin/`)

**Primary User**: Platform administrators, merchants, operators

#### Core Features
- ✅ **Dashboard**
  - Analytics overview
  - Key metrics
  - Charts and graphs
  - Recent activity

- ✅ **User Management**
  - View all users
  - User details
  - User statistics
  - User moderation

- ✅ **Listing Management**
  - View all listings
  - Create/edit listings
  - Approve/reject listings
  - Listing analytics

- ✅ **Booking Management**
  - View all bookings
  - Booking details
  - Booking status management
  - Booking analytics

- ✅ **Merchant Management**
  - Merchant profiles
  - Merchant verification
  - Merchant statistics
  - Merchant onboarding

- ✅ **Content Moderation**
  - Review moderation
  - Listing approval
  - User reports

- ✅ **Analytics & Reports**
  - Revenue reports
  - Booking statistics
  - User growth
  - Performance metrics

#### Future Features
- ⏳ Advanced analytics
- ⏳ Export functionality
- ⏳ Bulk operations
- ⏳ Automated workflows

---

### Public Web App Features (`web/`)

**Primary User**: General public, potential customers

#### Planned Features
- ⏳ **Public Website**
  - Homepage
  - About page
  - Listings showcase
  - Blog/News
  - Contact information
  - SEO optimization

- ⏳ **Public Listings**
  - Browse listings without login
  - View listing details
  - Search functionality
  - Category browsing

- ⏳ **Marketing**
  - Promotional content
  - Special offers
  - Newsletter signup
  - Social media integration

---

## Feature Matrix

| Feature | Mobile | Backend | Admin | Web |
|---------|--------|---------|-------|-----|
| User Authentication | ✅ | ✅ | ✅ | ⏳ |
| Browse Listings | ✅ | ✅ | ✅ | ⏳ |
| Create Bookings | 🚧 | ✅ | ✅ | ⏳ |
| Manage Favorites | ✅ | ✅ | ❌ | ❌ |
| Write Reviews | ✅ | ✅ | ✅ | ⏳ |
| Search | ✅ | ✅ | ✅ | ⏳ |
| Admin Dashboard | ❌ | ✅ | ✅ | ❌ |
| Analytics | ❌ | ✅ | ✅ | ❌ |
| Content Moderation | ❌ | ✅ | ✅ | ❌ |
| Payment Processing | ⏳ | ✅ | ✅ | ⏳ |

**Legend:**
- ✅ Implemented
- 🚧 In Progress
- ⏳ Planned
- ❌ Not Applicable

