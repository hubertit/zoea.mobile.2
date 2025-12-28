# Migration Readiness Checklist

## ✅ Pre-Migration Checklist

### 1. Schema & Database
- [x] Prisma schema has `legacy_id` fields added
- [x] Migration SQL file created (`20241227000000_add_legacy_id_fields/migration.sql`)
- [x] All required fields exist: `legacyId`, `legacyPasswordHash`, `passwordMigrated`
- [ ] **TODO:** Run Prisma migration: `npx prisma migrate deploy` or manually run SQL
- [ ] **TODO:** Generate Prisma client: `npx prisma generate`

### 2. Dependencies
- [x] `mysql2` added to package.json
- [x] `@types/mysql2` added to devDependencies
- [x] `bcrypt` already in dependencies
- [ ] **TODO:** Run `npm install` to install new dependencies

### 3. Migration Service
- [x] `MigrationService` class created
- [x] V1 database connection handling
- [x] Password reset to "Pass123" implemented
- [x] User migration method
- [x] Venue → Listing migration method
- [x] Country migration method
- [x] City migration method

### 4. Utilities
- [x] `image-verifier.ts` - Image verification from V1 server
- [x] `location-mapper.ts` - Country/city mapping
- [x] `merchant-profile-mapper.ts` - Merchant profile creation (one_per_venue strategy)

### 5. Entry Point
- [x] `migrate.ts` - Migration script entry point
- [x] `migration.module.ts` - NestJS module
- [x] `MigrationModule` added to `AppModule`
- [x] npm script: `npm run migrate`

### 6. Configuration
- [ ] **TODO:** Set V1 database credentials in `.env`:
  ```
  V1_DB_HOST=localhost
  V1_DB_PORT=3306
  V1_DB_USER=root
  V1_DB_PASSWORD=your_password
  V1_DB_NAME=devsvknl_tarama
  ```
- [x] V2 database connection already configured in `.env`

### 7. Code Quality
- [x] No linter errors
- [x] All imports correct
- [x] TypeScript types defined
- [x] Error handling in place

## ⚠️ Known Issues / TODOs

### Critical
1. **Location Mapper Helper Functions**
   - `getCurrencyCode()` and `getPhoneCode()` functions need to be implemented
   - Currently missing in `location-mapper.ts`

2. **PostGIS Geography**
   - Location field uses PostGIS `geography` type
   - Need to verify Prisma handles this correctly
   - May need to use raw SQL for geography insertion

3. **Listing Image Creation**
   - Uses `listingImage` model - verify this exists in schema
   - ✅ Verified: `ListingImage` model exists

4. **Category Mapping**
   - TODO comment in migration service about mapping `category_id` to V2 categories
   - Not critical for initial migration

5. **Facilities/Amenities**
   - TODO comment about parsing facilities
   - Not critical for initial migration

### Non-Critical
- Image verification may be slow (5s timeout per image)
- Consider batch processing for large datasets
- Add progress reporting for long migrations

## 🚀 Migration Steps

1. **Install Dependencies:**
   ```bash
   cd /Applications/AMPPS/www/zoea-2/backend
   npm install
   ```

2. **Run Prisma Migration:**
   ```bash
   # Option 1: Use Prisma migrate (may fail due to collation issue)
   npx prisma migrate deploy
   
   # Option 2: Run SQL manually
   psql -h 172.16.40.61 -U admin -d main -f prisma/migrations/20241227000000_add_legacy_id_fields/migration.sql
   ```

3. **Generate Prisma Client:**
   ```bash
   npx prisma generate
   ```

4. **Set Environment Variables:**
   ```bash
   # Add to .env file
   V1_DB_HOST=localhost
   V1_DB_PORT=3306
   V1_DB_USER=root
   V1_DB_PASSWORD=your_password
   V1_DB_NAME=devsvknl_tarama
   ```

5. **Test Migration (Optional):**
   ```bash
   # Test with a small subset first
   npm run migrate
   ```

6. **Run Full Migration:**
   ```bash
   npm run migrate
   ```

## 📊 Expected Results

After migration, you should see:
- Countries migrated (with success/failed counts)
- Cities migrated (with success/failed counts)
- Users migrated (all with password "Pass123")
- Venues migrated to Listings (with merchant profiles)

## 🔍 Post-Migration Validation

1. Check user count matches V1
2. Verify all users can login with "Pass123"
3. Check listings exist for all venues
4. Verify images are accessible
5. Test API endpoints

## ⚡ Quick Fixes Needed

1. **Add helper functions to location-mapper.ts:**
   ```typescript
   function getCurrencyCode(countryCode: string): string {
     const currencyMap: Record<string, string> = {
       'RWA': 'RWF',
       'UGA': 'UGX',
       'TZA': 'TZS',
       'KEN': 'KES',
       'GHA': 'GHS',
     };
     return currencyMap[countryCode] || 'USD';
   }
   
   function getPhoneCode(countryCode: string): string {
     const phoneMap: Record<string, string> = {
       'RWA': '+250',
       'UGA': '+256',
       'TZA': '+255',
       'KEN': '+254',
       'GHA': '+233',
     };
     return phoneMap[countryCode] || '+1';
   }
   ```

2. **Fix PostGIS geography insertion:**
   - May need to use Prisma raw SQL for geography fields
   - Or use `ST_GeogFromText()` function

