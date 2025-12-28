# V1 → V2 Migration Guide

## Overview

This migration script migrates data from V1 (MariaDB) to V2 (PostgreSQL) with full traceability via `legacy_id` fields.

## Prerequisites

1. **Install Dependencies:**
   ```bash
   cd /Applications/AMPPS/www/zoea-2/backend
   npm install
   ```

2. **Run Prisma Migration:**
   ```bash
   # Apply the legacy_id fields migration
   npx prisma migrate deploy
   # OR manually run the SQL file:
   # psql -h 172.16.40.61 -U admin -d main -f prisma/migrations/20241227000000_add_legacy_id_fields/migration.sql
   ```

3. **Generate Prisma Client:**
   ```bash
   npx prisma generate
   ```

## Configuration

Create a `.env` file or set environment variables:

```env
# V2 Database (PostgreSQL)
DATABASE_URL="postgresql://admin:Zoea2025Secure@172.16.40.61:5432/main"

# V1 Database (MariaDB) - UPDATE THESE WITH ACTUAL CREDENTIALS
V1_DB_HOST=localhost
V1_DB_PORT=3306
V1_DB_USER=root
V1_DB_PASSWORD=your_password
V1_DB_NAME=devsvknl_tarama
```

## Running the Migration

### Option 1: Using npm script
```bash
npm run migrate
```

### Option 2: Direct execution
```bash
npx ts-node src/migration/migrate.ts
```

## Migration Process

The migration runs in this order:

1. **Countries** - Maps V1 countries to V2 (creates if needed)
2. **Cities** - Maps V1 locations to V2 cities (creates if needed)
3. **Users** - Migrates all users with legacy_id tracking
4. **Venues → Listings** - Migrates venues to listings with merchant profiles

## What Gets Migrated

### Users
- ✅ All user data
- ✅ Profile images (verified from V1 server)
- ✅ **Passwords reset to "Pass123"** (users must change on first login)
- ✅ Legacy password hashes stored in `legacyPasswordHash` (for reference only)
- ✅ Legacy IDs for tracking

### Venues → Listings
- ✅ All venue data
- ✅ Images (verified from V1 server at https://zoea.africa/)
- ✅ Location mapping (country_id, location_id → country_id, city_id)
- ✅ Merchant profiles (one per venue)
- ✅ Facilities → Amenities
- ✅ Coordinates → PostGIS geography

### Other Data
- ✅ Countries and Cities (reference data)
- ✅ Reviews (with legacy_id)
- ✅ Favorites (with legacy_id)
- ✅ Bookings (with legacy_id)

## Migration Strategy

- **Merchant Profiles:** `one_per_venue` (each venue = one business)
- **Images:** Verified from V1 server, stored as media records pointing to V1 URLs
- **Passwords:** Dual authentication (SHA1 + bcrypt)
- **Data Cleaning:** Age fields, duplicates, coordinates all cleaned during migration

## Monitoring

The migration script logs:
- Progress for each phase
- Success/failure counts
- Errors with details

## Password Reset Strategy

**All migrated users will have their password reset to: `Pass123`**

- V1 used SHA1 encryption (insecure)
- V2 uses bcrypt (secure)
- All migrated users get the default password "Pass123"
- Users must change password on first login
- Original V1 password hash stored in `legacyPasswordHash` field (for reference only)

**User Communication:**
- Notify users via email/SMS that password has been reset
- Prompt password change on first login in mobile app
- Use existing endpoint: `PUT /api/users/me/password`

## Post-Migration

After migration:
1. Run validation queries (see MIGRATION_PLAN.md)
2. Test API endpoints
3. Update Flutter app base URL
4. **Notify users about password reset** (email/SMS)
5. Monitor for issues

## Rollback

If needed, you can:
- Keep V1 database as backup
- Use legacy_id fields to track back to V1 records
- Re-run migration after fixing issues

## Troubleshooting

### Collation Version Mismatch
If you see collation errors, you can:
- Run migration SQL manually
- Or fix the database collation version

### Connection Issues
- Verify V1 database credentials
- Check network connectivity
- Ensure V1 database is accessible

### Image Verification Failures
- Images that fail verification are skipped (not migrated)
- Check V1 server accessibility
- Verify image URLs are correct

