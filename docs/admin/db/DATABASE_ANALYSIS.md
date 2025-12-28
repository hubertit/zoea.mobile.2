# Database Analysis: Zoea Platform

## Overview
**Database Name:** `devsvknl_tarama`  
**Server:** MariaDB 11.4.8  
**Generated:** November 9, 2025  
**Total Tables:** 38

This is a comprehensive multi-purpose platform database supporting:
- Event management and applications
- Venue/restaurant listings and bookings
- Real estate property management
- E-commerce functionality
- User management and authentication
- Content management

---

## Table Structure Analysis

### 1. **User Management Tables**

#### `users` (Primary User Table)
- **Purpose:** Stores all platform users (customers, venue owners, etc.)
- **Key Fields:**
  - `user_id` (PK)
  - `venue_id` (FK to venues)
  - `account_type` (Customer, Venue Owner, etc.)
  - `user_fname`, `user_lname`, `user_email`, `user_phone`
  - `user_password` (SHA1 hashed)
  - `user_token` (authentication)
  - `user_status` (active/inactive)
- **Relationships:** Links to venues, bookings, orders, favorites

#### `admins`
- **Purpose:** Administrative users
- **Key Fields:**
  - `admin_id` (PK)
  - `admin_email`, `admin_phone`, `admin_name`
  - `admin_password`, `admin_token`
  - `admin_status` (active/inactive)
- **Note:** Contains 7 admin accounts

#### `merchants`
- **Purpose:** Merchant/vendor accounts
- **Key Fields:**
  - `merchant_id` (PK)
  - `category`, `name`, `phone`, `email`
  - `token`, `password`
  - `status` (Active/Inactive)

---

### 2. **Event Management Tables**

#### `application`
- **Purpose:** Event application/registration system
- **Key Fields:**
  - `id` (PK)
  - `event` (default: 'France', but data shows 'Kigali')
  - `title`, `first_name`, `last_name`, `age`
  - `organization`, `work_title`
  - `phone`, `email`
  - `qr_code` (path to QR code image)
  - `status` (pending/approved/rejected)
  - `updated_date` (timestamp)
- **Data Volume:** 500+ application records
- **Issues:**
  - Age field contains 'yes' instead of numeric values in many records
  - Status field has inconsistent quoting (`'pending'` vs `pending`)
  - Many duplicate entries

#### `events`
- **Purpose:** Event listings
- **Key Fields:**
  - `event_id` (PK)
  - Event details, dates, location
  - Status management

#### `event_categories`
- **Purpose:** Categorization of events
- **Key Fields:**
  - `category_id` (PK)

#### `invites`
- **Purpose:** Event invitation system
- **Key Fields:**
  - `id` (PK)
  - Invitation details

---

### 3. **Venue/Restaurant Management**

#### `venues` (Core Venue Table)
- **Purpose:** Restaurant, bar, cafe, and venue listings
- **Key Fields:**
  - `venue_id` (PK)
  - `user_id` (FK to users)
  - `category_id` (FK to categories)
  - `country_id`, `location_id`
  - `venue_code` (unique identifier)
  - `venue_name`, `venue_about`
  - `facilities`, `venue_policy`, `cancellation_policy`
  - `checkin_policy`, `checkout_policy` (date fields - unusual for venues)
  - `venue_price`, `breakfast_included`
  - `venue_phone`, `venue_email`, `venue_website`
  - `venue_image`, `banner_url`
  - `venue_rating`, `venue_reviews`
  - `venue_address`, `venue_coordinates`
  - `services`, `working_hours`
  - `wallet` (balance system)
  - `venue_status` (pending/active)
  - `sponsored`, `sort_order`
- **Data Volume:** 1000+ venue records
- **Categories:** Restaurants, Cafes, Bars, Lounges, Safari Tours
- **Issues:**
  - `checkin_policy` and `checkout_policy` are date fields but should likely be time-based
  - Many venues have default coordinates `-1.9876996,30.0721515`

#### `bookings`
- **Purpose:** Table/reservation bookings for venues
- **Key Fields:**
  - `booking_id` (PK)
  - Booking details, dates, times
  - Status management

#### `reviews`
- **Purpose:** User reviews for venues
- **Key Fields:**
  - Review content, ratings
  - Links to venues and users

#### `venue_facilities`
- **Purpose:** Junction table linking venues to facilities
- **Key Fields:**
  - `id` (PK)
  - `venue_id` (FK)
  - `facility_id` (FK)

#### `venue_specialities`
- **Purpose:** Junction table for venue specialities
- **Key Fields:**
  - `vs_id` (PK)
  - `venue_id` (FK)
  - `speciality_id` (FK)

#### `facilities`
- **Purpose:** Available facility types
- **Key Fields:**
  - `facility_id` (PK)

---

### 4. **Real Estate Management**

#### `properties`
- **Purpose:** Real estate listings (apartments, houses, commercial, land)
- **Key Fields:**
  - `property_id` (PK)
  - `location_id`, `agent_id`
  - `uid` (unique identifier)
  - `slug` (URL-friendly identifier)
  - `category` (enum: Apartment, House, Commercial, Land, Development)
  - `bedrooms`, `bathrooms`, `size`, `parking_spaces`
  - `year_built`, `listing_date`
  - `status` (enum: available, sold, rented)
  - `title`, `description`, `address`, `features`
  - `photo_url`
  - `property_type` (enum: sale, rent, booking)
  - `price` (decimal)
  - `breakfast_included` (unusual for real estate)
  - `created_at`, `updated_at`
- **Data Volume:** 150+ property records
- **Geographic Coverage:** Kigali (Rwanda), Accra (Ghana), Nairobi (Kenya)
- **Issues:**
  - `breakfast_included` field seems misplaced (likely copied from venue schema)
  - Many properties have empty `location_id` values
  - Some properties have inconsistent address formats

#### `rooms`
- **Purpose:** Room listings (likely for hotels/accommodations)
- **Key Fields:**
  - Room details, pricing, availability

#### `room_amenities`
- **Purpose:** Junction table for room amenities
- **Key Fields:**
  - Links rooms to amenities

#### `room_facilities`
- **Purpose:** Junction table for room facilities
- **Key Fields:**
  - Links rooms to facilities

#### `room_gallery`
- **Purpose:** Room photo gallery
- **Key Fields:**
  - Photo URLs linked to rooms

#### `property_photos`
- **Purpose:** Property photo gallery
- **Key Fields:**
  - `photo_id` (PK)
  - `property_id` (FK)
  - `photo_url`

#### `amenities`
- **Purpose:** Available amenities (50 predefined items)
- **Key Fields:**
  - `amenity_id` (PK)
  - `amenity_name` (e.g., "Free Wi-Fi", "Air conditioning")
  - `amenity_icon` (currently empty)

---

### 5. **E-commerce Tables**

#### `orders`
- **Purpose:** E-commerce order management
- **Key Fields:**
  - `id` (PK)
  - `order_no` (unique, indexed)
  - `customer_id` (FK to users, indexed)
  - `seller_id` (FK to merchants, indexed)
  - `total_amount` (decimal)
  - `currency` (default: RWF)
  - `status` (enum: pending, confirmed, processing, shipped, delivered, cancelled)
  - `shipping_address`, `shipping_notes`
  - `order_date`, `updated_at`
  - `cancellation_reason`
- **Indexes:** Well-indexed for performance
- **Data Volume:** Minimal (2 test orders)

#### `order_items`
- **Purpose:** Individual items within orders
- **Key Fields:
  - `id` (PK)
  - `order_id` (FK, indexed)
  - `product_id` (indexed)
  - Quantity, price, etc.

#### `payments`
- **Purpose:** Payment transaction records
- **Key Fields:**
  - `payment_id` (PK)
  - Payment details, status, amounts

#### `disbursements`
- **Purpose:** Payment disbursements to merchants
- **Key Fields:**
  - `disbursement_id` (PK)

---

### 6. **Content Management**

#### `blog`
- **Purpose:** Blog posts/articles
- **Key Fields:**
  - `blog_id` (PK)
  - Blog content, dates, status

#### `photos`
- **Purpose:** General photo storage
- **Key Fields:**
  - `photo_id` (PK)
  - Photo metadata and URLs

#### `categories`
- **Purpose:** General categorization system
- **Key Fields:**
  - `category_id` (PK)
  - Used across venues, properties, etc.

---

### 7. **Supporting Tables**

#### `locations`
- **Purpose:** Geographic locations
- **Key Fields:**
  - `location_id` (PK)
  - Location names and details

#### `countries`
- **Purpose:** Country reference data
- **Key Fields:**
  - `country_id` (PK)
  - Country names

#### `cuisines`
- **Purpose:** Cuisine types for restaurants
- **Key Fields:**
  - `cuisine_Id` (PK)
  - Cuisine names

#### `favorites`
- **Purpose:** User favorites/bookmarks
- **Key Fields:**
  - `favorite_id` (PK)
  - Links users to favorited items

#### `notifications`
- **Purpose:** User notification system
- **Key Fields:**
  - `notification_id` (PK)
  - `user_id` (FK)
  - `notification_title`, `notification_body`
  - `notification_time`, `notification_image`
  - `notification_status` (seen/unseen)
- **Data Volume:** 27 notification records

#### `menus`
- **Purpose:** Restaurant menu items
- **Key Fields:**
  - `menu_id` (PK)
  - Menu details

#### `packages`
- **Purpose:** Package deals/offers
- **Key Fields:**
  - `package_id` (PK

#### `contact_us`
- **Purpose:** Contact form submissions
- **Key Fields:**
  - `id` (PK)
  - Contact details, messages

#### `qr`
- **Purpose:** QR code management
- **Key Fields:**
  - QR code data and links

#### `pwd_reset_codes`
- **Purpose:** Password reset functionality
- **Key Fields:**
  - `code_id` (PK)
  - Reset codes and expiration

#### `vendors`
- **Purpose:** Vendor/supplier management
- **Key Fields:**
  - Vendor details

---

## Data Quality Issues

### Critical Issues:
1. **Inconsistent Data Types:**
   - `application.age` contains 'yes' instead of numeric values
   - `application.status` has inconsistent quoting

2. **Missing Foreign Key Constraints:**
   - Many relationships are logical but not enforced at database level
   - Risk of orphaned records

3. **Data Inconsistencies:**
   - Many properties have empty `location_id`
   - Default coordinates used for many venues
   - Duplicate application records

4. **Schema Issues:**
   - `properties.breakfast_included` seems misplaced
   - `venues.checkin_policy` and `checkout_policy` are date fields (should be time-based)

### Medium Priority Issues:
1. **Empty Fields:**
   - Many `amenity_icon` fields are empty
   - Some email fields are NULL where they shouldn't be

2. **Indexing:**
   - Some frequently queried tables lack proper indexes
   - `orders` table is well-indexed (good example)

3. **Character Encoding:**
   - Some records show encoding issues (e.g., "KonÃ©" instead of "Koné")

---

## Security Concerns

1. **Password Storage:**
   - Passwords stored as SHA1 hashes (weak, should use bcrypt/argon2)
   - Tokens stored in plain text (should be hashed)

2. **SQL Injection Risk:**
   - No visible prepared statement usage in dump
   - Application code should use parameterized queries

3. **Data Exposure:**
   - Admin tokens and passwords visible in dump
   - Should implement proper access controls

---

## Performance Considerations

### Well-Optimized:
- `orders` table has comprehensive indexing
- Primary keys properly defined on all tables

### Needs Optimization:
- `venues` table could benefit from indexes on:
  - `venue_status`
  - `category_id`
  - `location_id`
  - `sponsored`, `sort_order` (for listing queries)

- `properties` table could benefit from indexes on:
  - `status`
  - `property_type`
  - `category`
  - `location_id`

- `application` table could benefit from indexes on:
  - `status`
  - `event`
  - `email` (for lookups)

---

## Recommendations

### Immediate Actions:
1. **Fix Data Quality:**
   - Clean up `application.age` field
   - Standardize `application.status` values
   - Remove duplicate application records

2. **Add Foreign Key Constraints:**
   - Enforce referential integrity
   - Prevent orphaned records

3. **Improve Security:**
   - Migrate to bcrypt/argon2 for password hashing
   - Implement token hashing
   - Add proper access controls

### Short-term Improvements:
1. **Add Missing Indexes:**
   - Index frequently queried fields
   - Add composite indexes for common query patterns

2. **Fix Schema Issues:**
   - Change `venues.checkin_policy`/`checkout_policy` to time fields
   - Remove or repurpose `properties.breakfast_included`

3. **Data Cleanup:**
   - Fix encoding issues
   - Populate missing location data
   - Update default coordinates

### Long-term Enhancements:
1. **Database Normalization:**
   - Review and optimize table structures
   - Consider partitioning for large tables

2. **Audit Trail:**
   - Add created_by, updated_by fields
   - Implement soft deletes where appropriate

3. **Performance Monitoring:**
   - Set up query logging
   - Monitor slow queries
   - Optimize based on usage patterns

---

## Database Statistics

- **Total Tables:** 38
- **Primary User Tables:** 3 (users, admins, merchants)
- **Event Management Tables:** 4
- **Venue Management Tables:** 7
- **Real Estate Tables:** 7
- **E-commerce Tables:** 4
- **Content Management Tables:** 3
- **Supporting Tables:** 10

**Estimated Data Volume:**
- Users: 1000+
- Venues: 1000+
- Properties: 150+
- Applications: 500+
- Orders: 2 (minimal, likely test data)

---

## Conclusion

This is a well-structured multi-purpose platform database with good separation of concerns. The main areas for improvement are:
1. Data quality and consistency
2. Security (password hashing, token management)
3. Performance optimization (indexing)
4. Foreign key constraint enforcement

The database supports a comprehensive platform covering events, venues, real estate, and e-commerce, making it a versatile solution for the Zoea platform.

