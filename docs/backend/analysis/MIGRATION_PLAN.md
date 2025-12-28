# V1 → V2 Migration Plan

## Overview

**Goal:** Perfect migration from V1 (MariaDB) to V2 (PostgreSQL) with full traceability via legacy IDs.

**Key Principles:**
- ✅ Clean data during migration
- ✅ Use default values when data is missing
- ✅ Add `legacy_id` fields to track V1 records
- ✅ Reset all passwords to "Pass123" (users change on first login)
- ✅ Maintain data integrity throughout

---

## Phase 1: Schema Updates

### 1.1 Add Legacy ID Fields to V2 Schema

Add `legacy_id` (INT) field to key tables:
- `users` → `legacy_id` (INT, nullable, indexed)
- `listings` → `legacy_id` (INT, nullable, indexed)
- `bookings` → `legacy_id` (INT, nullable, indexed)
- `reviews` → `legacy_id` (INT, nullable, indexed)
- `favorites` → `legacy_id` (INT, nullable, indexed)
- `events` → `legacy_id` (INT, nullable, indexed)
- `event_attendees` → `legacy_id` (INT, nullable, indexed)

### 1.2 Password Migration Strategy

**Strategy: RESET ALL PASSWORDS TO DEFAULT**

Add to `users` table:
- `legacy_password_hash` (VARCHAR(255), nullable) - Store original V1 SHA1 hash (for reference only)
- `password_migrated` (BOOLEAN, default true) - Set to true (using new password system)

**Implementation:**
- All migrated users get password: **`Pass123`** (bcrypt hashed, salt rounds: 10)
- Original V1 password hash stored in `legacyPasswordHash` for reference
- Users must change password on first login
- Use existing `PUT /api/users/me/password` endpoint

### 1.3 Create Migration Tracking Table

```sql
CREATE TABLE migration_log (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  table_name VARCHAR(100) NOT NULL,
  v1_record_id INT NOT NULL,
  v2_record_id UUID NOT NULL,
  migration_date TIMESTAMP DEFAULT NOW(),
  status VARCHAR(50) DEFAULT 'success',
  error_message TEXT,
  metadata JSONB
);

CREATE INDEX idx_migration_log_v1 ON migration_log(table_name, v1_record_id);
CREATE INDEX idx_migration_log_v2 ON migration_log(table_name, v2_record_id);
```

---

## Phase 2: Data Cleaning Utilities

### 2.1 Age Field Cleaner

```typescript
function cleanAge(age: string): number | null {
  // Remove 'yes' and other invalid values
  if (!age || age.toLowerCase() === 'yes' || age.trim() === '') {
    return null;
  }
  
  // Extract numeric value
  const numeric = parseInt(age, 10);
  if (isNaN(numeric) || numeric < 0 || numeric > 150) {
    return null;
  }
  
  return numeric;
}
```

### 2.2 Duplicate Remover

```typescript
function removeDuplicates<T>(
  records: T[],
  keyFn: (record: T) => string
): T[] {
  const seen = new Set<string>();
  const unique: T[] = [];
  
  for (const record of records) {
    const key = keyFn(record);
    if (!seen.has(key)) {
      seen.add(key);
      unique.push(record);
    }
  }
  
  return unique;
}
```

### 2.3 Coordinate Converter

```typescript
function convertCoordinates(coords: string): {
  lat: number;
  lng: number;
} | null {
  if (!coords || coords.trim() === '') {
    return null;
  }
  
  // Handle format: "lat,lng" or "-1.9876996,30.0721515"
  const parts = coords.split(',').map(s => s.trim());
  if (parts.length !== 2) {
    return null;
  }
  
  const lat = parseFloat(parts[0]);
  const lng = parseFloat(parts[1]);
  
  if (isNaN(lat) || isNaN(lng)) {
    return null;
  }
  
  // Validate ranges
  if (lat < -90 || lat > 90 || lng < -180 || lng > 180) {
    return null;
  }
  
  return { lat, lng };
}

function toPostGIS(lat: number, lng: number): string {
  return `POINT(${lng} ${lat})`;
}
```

### 2.4 Check-in/Check-out Time Converter

```typescript
function convertCheckPolicy(dateValue: any): string | null {
  // V1 has dates in checkin_policy/checkout_policy
  // V2 needs times (e.g., "14:00:00")
  
  if (!dateValue || dateValue === '0000-00-00') {
    return null;
  }
  
  // If it's a date, extract time or use default
  if (dateValue instanceof Date) {
    const hours = dateValue.getHours();
    const minutes = dateValue.getMinutes();
    return `${String(hours).padStart(2, '0')}:${String(minutes).padStart(2, '0')}:00`;
  }
  
  // Default check-in: 14:00, check-out: 11:00
  return null; // Will use defaults in V2
}
```

### 2.5 Image URL Handler (V1 Server)

**Important:** Images remain on V1 server at `https://zoea.africa/`. We only verify availability and create media records pointing to V1 URLs.

```typescript
const V1_BASE_URL = 'https://zoea.africa/';

async function verifyImageUrl(imagePath: string): Promise<boolean> {
  try {
    // Handle relative paths (e.g., '../catalog/venues/anda.jpeg')
    let fullUrl: string;
    
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      fullUrl = imagePath;
    } else if (imagePath.startsWith('../')) {
      // Remove '../' prefix and construct full URL
      const cleanPath = imagePath.replace(/^\.\.\//, '');
      fullUrl = `${V1_BASE_URL}${cleanPath}`;
    } else if (imagePath.startsWith('/')) {
      fullUrl = `${V1_BASE_URL}${imagePath.substring(1)}`;
    } else {
      fullUrl = `${V1_BASE_URL}${imagePath}`;
    }
    
    // Verify image is accessible
    const response = await fetch(fullUrl, { method: 'HEAD' });
    return response.ok;
  } catch (error) {
    console.warn(`Image verification failed for ${imagePath}:`, error);
    return false;
  }
}

async function createMediaRecordFromV1Url(
  imagePath: string,
  altText?: string
): Promise<string | null> {
  // Verify image exists
  const isValid = await verifyImageUrl(imagePath);
  if (!isValid) {
    return null;
  }
  
  // Construct full URL
  let fullUrl: string;
  if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
    fullUrl = imagePath;
  } else if (imagePath.startsWith('../')) {
    const cleanPath = imagePath.replace(/^\.\.\//, '');
    fullUrl = `${V1_BASE_URL}${cleanPath}`;
  } else if (imagePath.startsWith('/')) {
    fullUrl = `${V1_BASE_URL}${imagePath.substring(1)}`;
  } else {
    fullUrl = `${V1_BASE_URL}${imagePath}`;
  }
  
  // Extract filename from path
  const fileName = imagePath.split('/').pop() || 'image.jpg';
  
  // Create media record pointing to V1 URL
  const media = await prisma.media.create({
    data: {
      url: fullUrl,
      mediaType: 'image',
      fileName: fileName,
      storageProvider: 'v1_legacy', // Mark as legacy V1 image
      altText: altText || fileName,
      // Other fields can be null or set defaults
    },
  });
  
  return media.id;
}
```

---

## Phase 3: Migration Scripts

### 3.1 User Migration

**Steps:**
1. Connect to V1 database
2. Fetch all users
3. Clean data (phone numbers, emails)
4. Generate UUIDs
5. Map account types to roles
6. Store SHA1 password in `legacy_password_hash`
7. **Note:** Merchant profiles will be created during venue migration (not here)
8. Migrate profile images to media table
9. Insert into V2 with `legacy_id`
10. Log migration

**Important:** Users can have multiple businesses (merchant profiles) and multiple listings per business. Merchant profiles are created during venue migration, not user migration.

**Key Mappings:**
- `user_id` (INT) → `legacy_id` (INT) + `id` (UUID)
- `account_type` → `roles` enum
- `user_password` (SHA1) → `legacy_password_hash` (for reference only)
- Set `passwordHash` to bcrypt hash of "Pass123"
- `venue_id` → Create `merchant_profile`
- `user_profile_picture` → Verify and create media record (V1 URL)
- `user_profile_cover` → Verify and create media record (V1 URL)

### 3.2 Venue → Listing Migration

**Steps:**
1. **Group venues by user_id** (users can have multiple venues)
2. **For each user with venues:**
   a. Get or create merchant profiles (strategy: one per venue, or group by category)
   b. Map venue to merchant profile
3. **For each venue:**
   a. **Map locations and countries:**
      - Map V1 `country_id` → V2 `country_id` (UUID)
      - Map V1 `location_id` → V2 `city_id` (UUID)
      - Use location mapper utility to get or create cities/countries
   b. Clean coordinates (convert to PostGIS)
   c. Parse facilities text → create `listing_amenities`
   d. Convert working_hours text → JSONB
   e. **Verify and create media records for images** (pointing to V1 URLs at https://zoea.africa/)
      - Verify `venue_image` is accessible
      - Verify `banner_url` is accessible (if exists)
      - Create media records with `storageProvider: 'v1_legacy'`
   f. Map category_id
   g. **Link to merchant profile** (from step 2)
   h. Insert into V2 with `legacy_id`, `country_id`, `city_id`, `merchant_id`
   i. Create listing_amenities relationships
   j. Create listing_images relationships
4. Log migration

**Merchant Profile Strategy: RECOMMENDED - `one_per_venue`**

**Decision:** Use `one_per_venue` strategy (each venue = one merchant profile)

**Reasoning:**
1. ✅ **Matches V1 Structure:** Each venue has independent business details (name, email, phone, website)
2. ✅ **Maximum Flexibility:** Users can manage each business independently
3. ✅ **Future-Proof:** Can merge later if needed, but splitting is harder
4. ✅ **Data Integrity:** Preserves all business details, no assumptions
5. ✅ **Mobile App Compatible:** Each business appears separately in user's business list

**Migration Result:**
- V1: User → Venues [6, 8, 9, 10, ...]
- V2: User → MerchantProfiles [MP1, MP2, MP3, ...] → Listings [L1, L2, L3, ...]
- Each venue becomes: 1 MerchantProfile + 1 Listing

**Alternative Options (Not Recommended):**
- `group_by_category` - Assumes venues in same category are same business (risky)
- `single_per_user` - Loses individual business details (not suitable)

**Location Mapping:**
- V1 `location_id` represents cities (Kigali, Musanze, Rubavu, etc.)
- V1 `country_id` represents countries (Rwanda, Uganda, Tanzania, Kenya, Ghana)
- V2 uses UUIDs for both countries and cities
- Need to create/get V2 countries and cities before migrating listings
- Listings can be in different cities and countries - this is fully supported

**Image Handling:**
- Images remain on V1 server (https://zoea.africa/)
- Create media records that point to V1 URLs
- Set `storageProvider: 'v1_legacy'` to identify legacy images
- Verify images are accessible before creating media records
- If image verification fails, skip that image (don't create media record)

**Key Mappings:**
- `venue_id` (INT) → `legacy_id` (INT) + `id` (UUID)
- `venue_coordinates` (string) → `location` (PostGIS geography)
- `facilities` (text) → `listing_amenities` (junction table)
- `working_hours` (text) → `operating_hours` (JSONB)

### 3.3 Booking Migration

**Steps:**
1. Fetch all bookings from V1
2. Map user_id → V2 user UUID (via legacy_id)
3. Map venue_id → V2 listing UUID (via legacy_id)
4. Map room_id → V2 room UUID (if exists)
5. Clean dates (skip '0000-00-00')
6. Generate booking_number if missing
7. Calculate total_amount (use listing price if missing)
8. Insert into V2 with `legacy_id`
9. Log migration

**Key Mappings:**
- `booking_id` (INT) → `legacy_id` (INT) + `id` (UUID)
- `booking_status` (string) → `status` (enum)
- `payment_status` (string) → `payment_status` (enum)

### 3.4 Review Migration

**Steps:**
1. Fetch all reviews from V1
2. Map user_id → V2 user UUID
3. Map venue_id → V2 listing UUID
4. Clean review text
5. Insert into V2 with `legacy_id`
6. Log migration

### 3.5 Favorite Migration

**Steps:**
1. Fetch all favorites from V1
2. Map user_id → V2 user UUID
3. Map venue_id → V2 listing UUID
4. Insert into V2 with `legacy_id`
5. Log migration

### 3.6 Event Application → Event Attendee Migration

**Steps:**
1. Fetch all applications from V1
2. Clean age field (remove 'yes', convert to number)
3. Remove duplicates
4. Map event → V2 event UUID (or external event)
5. Insert into V2 `event_attendees` with `legacy_id`
6. Log migration

---

## Phase 4: Password Reset Strategy

### 4.1 Password Migration

**Strategy: RESET ALL PASSWORDS TO DEFAULT**

- All migrated users get password: **`Pass123`** (bcrypt hashed)
- Original V1 password hash stored in `legacyPasswordHash` (for reference only)
- `passwordMigrated` set to `true`
- No dual authentication needed

### 4.2 User Password Change

Users change password on first login using existing endpoint:
- `PUT /api/users/me/password` (requires current password "Pass123")

**Implementation in Migration:**
```typescript
// In migration.service.ts - migrateUsers()
const defaultPassword = 'Pass123';
const passwordHash = await bcrypt.hash(defaultPassword, 10);

await this.prisma.user.create({
  data: {
    // ... other fields
    passwordHash: passwordHash, // Set default password
    legacyPasswordHash: v1User.user_password || null, // Keep for reference
    passwordMigrated: true, // Mark as migrated
  },
});
```

---

## Phase 5: Validation & Testing

### 5.1 Data Count Validation

```sql
-- Compare record counts
SELECT 
  'users' as table_name,
  (SELECT COUNT(*) FROM v1_users) as v1_count,
  (SELECT COUNT(*) FROM users WHERE legacy_id IS NOT NULL) as v2_count;

-- Repeat for all tables
```

### 5.2 Relationship Validation

```sql
-- Check for orphaned bookings
SELECT COUNT(*) 
FROM bookings b
LEFT JOIN users u ON b.user_id = u.id
WHERE b.legacy_id IS NOT NULL AND u.id IS NULL;

-- Check for orphaned listings
SELECT COUNT(*)
FROM listings l
LEFT JOIN users u ON l.merchant_id = u.id
WHERE l.legacy_id IS NOT NULL AND l.merchant_id IS NOT NULL AND u.id IS NULL;
```

### 5.3 Data Integrity Checks

- All foreign keys valid
- No NULL values in required fields (after defaults applied)
- All legacy_ids unique
- All UUIDs unique
- Coordinate conversions valid
- Date conversions valid

---

## Phase 6: Migration Execution

### 6.1 Pre-Migration Checklist

- [ ] Backup V1 database
- [ ] Backup V2 database
- [ ] Run Prisma migrations (add legacy_id fields)
- [ ] Test migration scripts on sample data
- [ ] Set up monitoring/logging
- [ ] Prepare rollback plan

### 6.2 Migration Order

1. **Countries** (map V1 countries → V2 countries, get or create)
2. **Cities** (map V1 locations → V2 cities, get or create within countries)
3. **Users** (foundation for all relationships)
4. **Categories, Amenities** (reference data)
5. **Merchant Profiles** (for venue owners)
6. **Listings** (venues + properties) - requires countries and cities
7. **Rooms** (if applicable)
8. **Events** (if not using SINC)
9. **Reviews**
10. **Favorites**
11. **Bookings** (depends on users + listings)
12. **Event Attendees** (depends on events + users)

**Important:** Countries and Cities must be migrated first since listings reference them!

### 6.3 Migration Script Structure

```typescript
class MigrationService {
  async migrateUsers(): Promise<MigrationResult> {
    // Implementation
  }
  
  async migrateListings(): Promise<MigrationResult> {
    // Implementation
  }
  
  // ... other migration methods
}

interface MigrationResult {
  success: boolean;
  recordsProcessed: number;
  recordsSucceeded: number;
  recordsFailed: number;
  errors: Error[];
  duration: number;
}
```

---

## Phase 7: Post-Migration

### 7.1 Validation Queries

Run all validation queries and fix any issues.

### 7.2 User Communication

- Send email to all users about password upgrade
- In-app notification about new features
- Support documentation

### 7.3 Monitoring

- Monitor authentication failures
- Track password upgrades
- Monitor API errors
- Check for data inconsistencies

---

## Timeline Estimate

- **Phase 1 (Schema Updates):** 1 day
- **Phase 2 (Data Cleaning):** 2 days
- **Phase 3 (Migration Scripts):** 1 week
- **Phase 4 (Dual Auth):** 2 days
- **Phase 5 (Testing):** 3 days
- **Phase 6 (Execution):** 1 week (with testing)
- **Phase 7 (Post-Migration):** 3 days

**Total: 3-4 weeks**

---

## Risk Mitigation

1. **Data Loss:** Full backups before migration
2. **Authentication Issues:** Dual auth support
3. **Performance:** Batch processing, indexes on legacy_id
4. **Rollback:** Keep V1 active, can revert if needed
5. **User Friction:** Seamless password upgrade

---

## Success Criteria

- ✅ All V1 records migrated with legacy_id
- ✅ All relationships intact
- ✅ No data loss
- ✅ All users can authenticate with default password "Pass123"
- ✅ Users can change password on first login
- ✅ All validation queries pass
- ✅ Mobile app works with migrated data
- ✅ Performance acceptable

---

**Created:** December 27, 2024  
**Status:** Planning Phase

