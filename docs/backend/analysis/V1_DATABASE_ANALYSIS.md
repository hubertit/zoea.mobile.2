# V1 Database Analysis & Migration Mapping

## Database Overview

**File:** `/Applications/AMPPS/www/zoea-2/ui/db/zoea-1.sql`  
**Type:** MariaDB 11.4.8  
**Database Name:** `devsvknl_tarama`  
**Total Tables:** 38  
**Total INSERT Statements:** 82  
**File Size:** ~13,669 lines

---

## Table Inventory

### Core Tables

1. **`users`** - User accounts
2. **`admins`** - Admin accounts
3. **`merchants`** - Merchant accounts
4. **`venues`** - Venue/restaurant listings (1000+ records)
5. **`properties`** - Property listings (150+ records)
6. **`rooms`** - Room listings
7. **`bookings`** - Table/reservation bookings
8. **`events`** - Event listings
9. **`application`** - Event applications (500+ records)
10. **`reviews`** - User reviews
11. **`favorites`** - User favorites
12. **`orders`** - E-commerce orders
13. **`order_items`** - Order line items
14. **`payments`** - Payment records
15. **`disbursements`** - Payment disbursements

### Supporting Tables

16. **`categories`** - General categories
17. **`event_categories`** - Event categories
18. **`amenities`** - 50 predefined amenities
19. **`facilities`** - Venue facilities
20. **`cuisines`** - Cuisine types
21. **`locations`** - Location data
22. **`countries`** - Country data
23. **`menus`** - Restaurant menus
24. **`packages`** - Package deals
25. **`photos`** - Photo gallery
26. **`property_photos`** - Property photos
27. **`room_amenities`** - Room amenities junction
28. **`room_facilities`** - Room facilities junction
29. **`room_gallery`** - Room gallery
30. **`venue_facilities`** - Venue facilities junction
31. **`venue_specialities`** - Venue specialities junction
32. **`invites`** - Event invitations
33. **`notifications`** - Notifications
34. **`contact_us`** - Contact form submissions
35. **`blog`** - Blog posts
36. **`qr`** - QR codes
37. **`pwd_reset_codes`** - Password reset codes
38. **`vendors`** - Vendor accounts

---

## Detailed Table Analysis

### 1. Users Table

**V1 Structure:**
```sql
CREATE TABLE `users` (
  `user_id` int(11) NOT NULL,
  `venue_id` int(11) DEFAULT NULL,
  `account_type` varchar(20) NOT NULL DEFAULT 'Customer',
  `user_fname` varchar(255) DEFAULT NULL,
  `user_lname` varchar(255) DEFAULT NULL,
  `user_gender` varchar(20) DEFAULT NULL,
  `country_code` varchar(20) NOT NULL DEFAULT '250',
  `user_phone` varchar(255) DEFAULT NULL,
  `user_email` text DEFAULT NULL,
  `user_reg_date` date NOT NULL,
  `user_profile_picture` text DEFAULT NULL,
  `user_profile_cover` text DEFAULT NULL,
  `user_location` text DEFAULT NULL,
  `user_password` text DEFAULT NULL,  -- SHA1 HASHED
  `user_token` text DEFAULT NULL,
  `user_status` varchar(20) NOT NULL DEFAULT 'active'
)
```

**Key Issues:**
- ❌ **Password hashing:** SHA1 (weak, needs migration to bcrypt)
- ❌ **No UUID:** Uses integer IDs
- ❌ **No soft deletes:** Missing `deleted_at`
- ❌ **Mixed data:** `venue_id` in users table (should be separate merchant profile)
- ⚠️ **Token storage:** Plain text tokens in database

**V2 Mapping:**
```sql
-- V1 users → V2 users
user_id (int)              → id (uuid) [GENERATE NEW]
user_email                 → email
user_phone                 → phone_number
user_fname                 → first_name
user_lname                 → last_name
CONCAT(user_fname, ' ', user_lname) → full_name
user_gender                → gender
user_profile_picture       → profile_image_id (via media table)
user_profile_cover         → background_image_id (via media table)
user_location              → address
user_password (SHA1)       → password_hash (bcrypt) [REQUIRES RE-HASH]
user_reg_date              → created_at
user_status                → is_active (map 'active' → true)
account_type               → roles (map to user_role enum)
venue_id                   → merchant_id (if not null, create merchant_profile)
```

**Migration Strategy:**
1. Generate new UUID for each user
2. Create mapping table: `v1_user_id → v2_user_id`
3. **Password Migration:** Store SHA1 in `legacy_password_hash`, support dual auth
4. **Note:** Merchant profiles created during venue migration (not user migration)
   - Users can have multiple businesses (merchant profiles)
   - Each business can have multiple listings (venues)
5. **Verify and create media records for profile images** (pointing to V1 URLs at https://zoea.africa/)
   - Images remain on V1 server
   - Create media records with `storageProvider: 'v1_legacy'`
   - Verify images are accessible before creating records

---

### 2. Venues Table

**V1 Structure:**
```sql
CREATE TABLE `venues` (
  `venue_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `category_id` int(11) NOT NULL,
  `country_id` int(11) NOT NULL DEFAULT 5,
  `location_id` int(11) NOT NULL DEFAULT 1,
  `venue_code` varchar(20) DEFAULT NULL,
  `venue_name` text NOT NULL,
  `venue_about` text NOT NULL,
  `facilities` text NOT NULL,
  `venue_policy` text NOT NULL,
  `cancellation_policy` text NOT NULL,
  `checkin_policy` date NOT NULL,      -- WRONG TYPE (should be time)
  `checkout_policy` date NOT NULL,    -- WRONG TYPE (should be time)
  `venue_price` int(11) NOT NULL DEFAULT 2,
  `breakfast_included` tinyint(1) DEFAULT 1,
  `venue_phone` text NOT NULL,
  `venue_email` varchar(255) DEFAULT NULL,
  `venue_website` text NOT NULL,
  `venue_image` text NOT NULL,
  `banner_url` text DEFAULT NULL,
  `venue_rating` int(11) NOT NULL DEFAULT 2,
  `venue_reviews` int(11) NOT NULL DEFAULT 0,
  `venue_address` varchar(255) DEFAULT 'Kigali, Rwanda',
  `venue_coordinates` varchar(255) NOT NULL DEFAULT '-1.9876996,30.0721515',
  `services` text NOT NULL,
  `wallet` int(11) NOT NULL DEFAULT 0,
  `working_hours` text NOT NULL,
  `time_added` timestamp NOT NULL,
  `venue_status` varchar(20) NOT NULL DEFAULT 'pending',
  `sponsored` int(11) NOT NULL DEFAULT 0
)
```

**Key Issues:**
- ❌ **Coordinates:** Stored as string, need PostGIS conversion
- ❌ **Check-in/out:** Wrong data type (date instead of time)
- ❌ **No UUID:** Uses integer IDs
- ❌ **No soft deletes:** Missing `deleted_at`
- ⚠️ **Facilities:** Stored as text, need to parse and map to junction table

**V2 Mapping:**
```sql
-- V1 venues → V2 listings
venue_id (int)             → id (uuid) [GENERATE NEW]
venue_code                 → slug (generate if null)
venue_name                 → name
venue_about                → description
venue_about (truncated)    → short_description (first 500 chars)
category_id                → category_id (map to V2 categories)
country_id (int)           → country_id (uuid) [MAP V1→V2]
location_id (int)          → city_id (uuid) [MAP V1 location→V2 city]
venue_address              → address
venue_coordinates           → location (PostGIS geography) [CONVERT]
venue_price                 → min_price, max_price (duplicate or split)
venue_phone                → contact_phone
venue_email                → contact_email
venue_website              → website
venue_image                → listing_images (via media table) [V1 URL]
banner_url                 → listing_images (via media table) [V1 URL]
venue_rating               → rating
venue_reviews               → review_count
venue_status               → status (map to listing_status enum)
working_hours               → operating_hours (JSONB)
time_added                  → created_at
user_id                     → merchant_id (map via user_id → merchant_profile)
```

**Location Mapping Details:**
- **V1 Countries:** Rwanda (1), Uganda (3), Tanzania (4), Kenya (5), Ghana (6)
- **V1 Locations (Cities):** Kigali (1), Musanze (2), Rubavu (3), Karongi (4), Rusizi (6)
- **V2 Structure:** Countries → Regions → Cities → Districts
- **Mapping Strategy:**
  - V1 `country_id` → V2 `country_id` (UUID, get or create)
  - V1 `location_id` → V2 `city_id` (UUID, get or create city within country)
  - Listings can be in different cities and countries - fully supported

**Additional Steps:**
1. **Group venues by user_id** (users can have multiple venues)
2. **Create merchant profiles** for users with venues:
   - Strategy: One merchant profile per venue (recommended)
   - OR: Group by category
   - OR: Single merchant profile per user
3. Parse `facilities` text and create `listing_amenities` records
4. Convert coordinates from string to PostGIS geography
5. **Verify and create media records for images** (pointing to V1 URLs at https://zoea.africa/)
   - Images remain on V1 server
   - Create media records with `storageProvider: 'v1_legacy'`
   - Verify images are accessible before creating records
6. Parse `working_hours` text to JSONB format
7. Link each listing to the correct merchant profile

**Relationship Mapping:**
- V1: `venues.user_id` → User (one user can have many venues)
- V2: `listings.merchant_id` → MerchantProfile (one merchant can have many listings)
- V2: `merchant_profiles.user_id` → User (one user can have many merchant profiles)
- **Result:** User → (many) MerchantProfiles → (many) Listings

---

### 3. Bookings Table

**V1 Structure:**
```sql
CREATE TABLE `bookings` (
  `booking_id` int(11) NOT NULL,
  `booking_no` varchar(20) DEFAULT NULL,
  `venue_id` int(11) NOT NULL,
  `room_id` int(11) DEFAULT NULL,
  `user_id` int(11) NOT NULL,
  `booking_time` timestamp NOT NULL,
  `checkin_date` date DEFAULT '0000-00-00',
  `checkin_time` time DEFAULT NULL,
  `checkout_date` date DEFAULT NULL,
  `checkout_time` time DEFAULT NULL,
  `adults` int(20) NOT NULL DEFAULT 1,
  `children` int(11) NOT NULL DEFAULT 0,
  `additional_request` text NOT NULL,
  `booking_status` varchar(11) NOT NULL DEFAULT 'Pending',
  `payment_status` varchar(255) DEFAULT 'Pending'
)
```

**Key Issues:**
- ❌ **No UUID:** Uses integer IDs
- ❌ **No amounts:** Missing price/total fields
- ❌ **No soft deletes:** Missing `deleted_at`
- ⚠️ **Status values:** String-based, need enum mapping

**V2 Mapping:**
```sql
-- V1 bookings → V2 bookings
booking_id (int)           → id (uuid) [GENERATE NEW]
booking_no                 → booking_number (use if exists, else auto-generate)
venue_id                   → listing_id (map via venue_id → listing UUID)
room_id                    → room_id (map via room_id → room UUID)
user_id                    → user_id (map via user_id → user UUID)
checkin_date               → check_in_date
checkin_time               → booking_time
checkout_date              → check_out_date
adults                     → adults
children                   → children
adults + children           → guest_count
additional_request         → special_requests
booking_status             → status (map to booking_status enum)
payment_status             → payment_status (map to payment_status enum)
booking_time               → created_at
```

**Missing Data:**
- `total_amount` - Not in V1, set to NULL or calculate from listing price
- `currency` - Default to 'RWF'
- `booking_type` - Determine from listing type
- `payment_method` - Set to NULL

---

### 4. Events Table

**V1 Structure:**
```sql
CREATE TABLE `events` (
  `event_id` int(11) NOT NULL,
  `external_event_id` varchar(255) DEFAULT NULL,
  `user_id` int(11) NOT NULL,
  `category_id` int(11) NOT NULL,
  `timestamp` timestamp NOT NULL,
  `third_party` varchar(255) DEFAULT NULL,
  `event_name` varchar(255) NOT NULL,
  `event_poster` text DEFAULT NULL,
  `event_details` text DEFAULT NULL,
  `event_address` varchar(255) DEFAULT NULL,
  `coordinates` varchar(255) DEFAULT NULL,
  `event_start_date` date DEFAULT NULL,
  `event_start_time` time DEFAULT NULL,
  `event_end_date` date DEFAULT NULL,
  `event_end_time` time DEFAULT NULL,
  `tickets_url` text DEFAULT NULL,
  `going` int(11) DEFAULT 0,
  `likes` int(11) DEFAULT 0,
  `shares` int(11) DEFAULT 0,
  `event_status` varchar(20) DEFAULT 'pending'
)
```

**V2 Mapping:**
```sql
-- V1 events → V2 events
event_id (int)             → id (uuid) [GENERATE NEW]
external_event_id         → external_id
event_name                 → title
event_details              → description
event_poster               → event_attachments (via media table)
event_address              → location_name
coordinates                → location (PostGIS geography) [CONVERT]
event_start_date           → start_date
event_start_time           → start_time
event_end_date             → end_date
event_end_time             → end_time
tickets_url                → tickets_url
going                      → attendee_count
likes                      → like_count
event_status               → status (map to event_status enum)
user_id                    → organizer_id (map via user_id → organizer_profile)
category_id                → context_id (map to event_contexts)
```

**Note:** V2 uses SINC API for events, so this migration may not be needed if using external events.

---

### 5. Application Table (Event Applications)

**V1 Structure:**
```sql
CREATE TABLE `application` (
  `id` int(11) NOT NULL,
  `event` varchar(20) NOT NULL DEFAULT 'France',
  `title` text NOT NULL,
  `first_name` text NOT NULL,
  `last_name` text NOT NULL,
  `age` varchar(222) NOT NULL,        -- ISSUE: Contains 'yes' instead of numbers
  `organization` varchar(222) NOT NULL,
  `work_title` text NOT NULL,
  `phone` varchar(22) NOT NULL,
  `email` varchar(222) NOT NULL,
  `qr_code` text NOT NULL,
  `updated_date` timestamp NOT NULL,
  `status` varchar(22) DEFAULT '''pending'''
)
```

**Data Quality Issues:**
- ❌ `age` field contains 'yes' instead of numeric values
- ❌ `status` has inconsistent quoting ('''pending''')
- ❌ Many duplicate records

**V2 Mapping:**
```sql
-- V1 application → V2 event_attendees
id (int)                   → id (uuid) [GENERATE NEW]
event                      → event_id (map to V2 event or external event)
first_name                 → first_name
last_name                  → last_name
CONCAT(first_name, ' ', last_name) → full_name
age                        → age (clean data, convert 'yes' to NULL)
organization               → organization
work_title                 → job_title
phone                      → phone_number
email                      → email
qr_code                    → qr_code_url (via media table)
status                     → status (map to attendee_status enum)
updated_date               → created_at
```

---

### 6. Reviews Table

**V1 Structure:**
```sql
CREATE TABLE `reviews` (
  `review_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `venue_id` int(11) NOT NULL,
  `review_text` text NOT NULL,
  `review_rating` int(11) NOT NULL,
  `review_date` timestamp NOT NULL,
  `review_status` varchar(20) DEFAULT 'pending'
)
```

**V2 Mapping:**
```sql
-- V1 reviews → V2 reviews
review_id (int)            → id (uuid) [GENERATE NEW]
user_id                    → user_id (map via user_id → user UUID)
venue_id                   → listing_id (map via venue_id → listing UUID)
review_text                → content
review_rating              → rating
review_date                → created_at
review_status              → status (map to review_status enum)
```

---

### 7. Favorites Table

**V1 Structure:**
```sql
CREATE TABLE `favorites` (
  `favorite_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `venue_id` int(11) NOT NULL
)
```

**V2 Mapping:**
```sql
-- V1 favorites → V2 favorites
favorite_id (int)          → id (uuid) [GENERATE NEW]
user_id                    → user_id (map via user_id → user UUID)
venue_id                   → listing_id (map via venue_id → listing UUID)
-- type: 'listing' (default)
-- created_at: NOW()
```

---

### 8. Properties Table

**V1 Structure:**
```sql
CREATE TABLE `properties` (
  `property_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `category_id` int(11) NOT NULL,
  `property_name` text NOT NULL,
  `property_description` text NOT NULL,
  `property_price` int(11) NOT NULL,
  `property_address` text NOT NULL,
  `property_coordinates` varchar(255) NOT NULL,
  `property_image` text NOT NULL,
  `property_status` varchar(20) DEFAULT 'pending',
  ...
)
```

**V2 Mapping:**
```sql
-- V1 properties → V2 listings (type: 'hotel')
property_id (int)          → id (uuid) [GENERATE NEW]
property_name              → name
property_description       → description
property_price             → min_price, max_price
property_address           → address
property_coordinates       → location (PostGIS geography)
property_image             → listing_images (via media table)
property_status            → status (map to listing_status enum)
user_id                    → merchant_id (map via user_id → merchant_profile)
category_id                → category_id
```

---

## Data Quality Issues

### Critical Issues

1. **Password Security**
   - ❌ V1 uses SHA1 hashing (weak)
   - ✅ V2 uses bcrypt (secure)
   - **Action Required:** Force password reset for all users

2. **Data Type Inconsistencies**
   - ❌ `application.age` contains 'yes' instead of numbers
   - ❌ `venues.checkin_policy`/`checkout_policy` are dates (should be times)
   - ❌ Coordinates stored as strings (need PostGIS conversion)

3. **Missing Foreign Keys**
   - Many relationships not enforced at database level
   - Need to validate relationships during migration

4. **Duplicate Records**
   - `application` table has many duplicates
   - Need deduplication strategy

### Medium Issues

1. **Missing Data**
   - Bookings missing price/total fields
   - Some records have NULL critical fields

2. **Inconsistent Status Values**
   - String-based status fields
   - Need enum mapping

3. **Token Storage**
   - Plain text tokens in database (security risk)

---

## Migration Scripts Required

### 1. User Migration Script

```sql
-- Step 1: Create mapping table
CREATE TABLE migration_user_mapping (
  v1_user_id INT PRIMARY KEY,
  v2_user_id UUID NOT NULL,
  migrated_at TIMESTAMP DEFAULT NOW()
);

-- Step 2: Migrate users (without passwords)
INSERT INTO users (
  id, email, phone_number, first_name, last_name, full_name,
  gender, profile_image_id, background_image_id, address,
  created_at, is_active, roles, account_type
)
SELECT 
  uuid_generate_v4(),
  user_email,
  user_phone,
  user_fname,
  user_lname,
  CONCAT(user_fname, ' ', user_lname),
  user_gender,
  NULL, -- profile_image_id (migrate separately)
  NULL, -- background_image_id (migrate separately)
  user_location,
  user_reg_date,
  user_status = 'active',
  CASE account_type
    WHEN 'Customer' THEN ARRAY['explorer']::user_role[]
    WHEN 'Merchant' THEN ARRAY['merchant']::user_role[]
    ELSE ARRAY['explorer']::user_role[]
  END,
  'personal'::account_type
FROM v1_users
WHERE user_email IS NOT NULL OR user_phone IS NOT NULL;

-- Step 3: Create mapping records
INSERT INTO migration_user_mapping (v1_user_id, v2_user_id)
SELECT v1.user_id, v2.id
FROM v1_users v1
JOIN users v2 ON v2.email = v1.user_email;
```

### 2. Venue → Listing Migration Script

```sql
-- Step 1: Create mapping table
CREATE TABLE migration_venue_mapping (
  v1_venue_id INT PRIMARY KEY,
  v2_listing_id UUID NOT NULL,
  migrated_at TIMESTAMP DEFAULT NOW()
);

-- Step 2: Migrate venues to listings
INSERT INTO listings (
  id, slug, name, description, short_description,
  category_id, country_id, city_id, address, location,
  min_price, max_price, contact_phone, contact_email, website,
  rating, review_count, status, operating_hours, created_at, merchant_id
)
SELECT 
  uuid_generate_v4(),
  COALESCE(venue_code, LOWER(REPLACE(venue_name, ' ', '-'))),
  venue_name,
  venue_about,
  LEFT(venue_about, 500),
  -- Map category_id, country_id, city_id
  -- Convert coordinates to PostGIS
  ST_GeogFromText('POINT(' || SPLIT_PART(venue_coordinates, ',', 2) || ' ' || SPLIT_PART(venue_coordinates, ',', 1) || ')'),
  venue_price,
  venue_price,
  venue_phone,
  venue_email,
  venue_website,
  venue_rating,
  venue_reviews,
  CASE venue_status
    WHEN 'active' THEN 'active'::listing_status
    WHEN 'pending' THEN 'pending_review'::listing_status
    ELSE 'draft'::listing_status
  END,
  -- Parse working_hours to JSONB
  working_hours::jsonb,
  time_added,
  -- Map user_id to merchant_id
  (SELECT v2_user_id FROM migration_user_mapping WHERE v1_user_id = v1_venues.user_id)
FROM v1_venues;
```

### 3. Booking Migration Script

```sql
-- Migrate bookings
INSERT INTO bookings (
  id, booking_number, listing_id, room_id, user_id,
  check_in_date, booking_time, check_out_date,
  adults, children, guest_count,
  special_requests, status, payment_status, created_at
)
SELECT 
  uuid_generate_v4(),
  COALESCE(booking_no, 'BK' || TO_CHAR(NOW(), 'YYYYMMDD') || '-' || LPAD(booking_id::text, 8, '0')),
  (SELECT v2_listing_id FROM migration_venue_mapping WHERE v1_venue_id = v1_bookings.venue_id),
  -- Map room_id if exists
  (SELECT v2_user_id FROM migration_user_mapping WHERE v1_user_id = v1_bookings.user_id),
  checkin_date,
  checkin_time,
  checkout_date,
  adults,
  children,
  adults + children,
  additional_request,
  CASE booking_status
    WHEN 'Booked' THEN 'confirmed'::booking_status
    WHEN 'Pending' THEN 'pending'::booking_status
    ELSE 'pending'::booking_status
  END,
  CASE payment_status
    WHEN 'Pending' THEN 'pending'::payment_status
    WHEN 'Paid' THEN 'completed'::payment_status
    ELSE 'pending'::payment_status
  END,
  booking_time
FROM v1_bookings
WHERE checkin_date != '0000-00-00';
```

---

## Migration Checklist

### Pre-Migration
- [ ] Backup V1 database
- [ ] Backup V2 database
- [ ] Create mapping tables
- [ ] Test migration scripts on sample data
- [ ] Validate data quality

### Phase 1: Users
- [ ] Create user mapping table
- [ ] Migrate users (without passwords)
- [ ] Migrate profile images to media table
- [ ] Create merchant profiles for venue owners
- [ ] **Require password reset for all users**

### Phase 2: Content
- [ ] Migrate categories
- [ ] Migrate amenities
- [ ] Migrate countries/locations
- [ ] Migrate venues → listings
- [ ] Migrate properties → listings
- [ ] Migrate events (if not using SINC)
- [ ] Migrate rooms

### Phase 3: Relationships
- [ ] Migrate venue_facilities → listing_amenities
- [ ] Migrate reviews
- [ ] Migrate favorites
- [ ] Migrate bookings

### Phase 4: Validation
- [ ] Run data integrity checks
- [ ] Validate foreign key relationships
- [ ] Check for orphaned records
- [ ] Verify data counts match

### Post-Migration
- [ ] Update Flutter app base URL
- [ ] Test API endpoints
- [ ] Monitor for errors
- [ ] User communication (password reset)

---

## Estimated Data Volumes

Based on SQL file analysis:

| Table | Estimated Records |
|-------|------------------|
| Users | 1000+ |
| Venues | 1000+ |
| Properties | 150+ |
| Bookings | 100+ |
| Events | 50+ |
| Applications | 500+ |
| Reviews | 1000+ |
| Favorites | 500+ |

---

## Migration Timeline Estimate

- **Phase 1 (Users):** 1 week
- **Phase 2 (Content):** 2 weeks
- **Phase 3 (Relationships):** 1 week
- **Phase 4 (Validation):** 1 week
- **Total:** 5 weeks

---

**Analysis Date:** December 27, 2024  
**V1 Database:** MariaDB 11.4.8 (`devsvknl_tarama`)  
**V2 Database:** PostgreSQL 16 + PostGIS (`main`)

