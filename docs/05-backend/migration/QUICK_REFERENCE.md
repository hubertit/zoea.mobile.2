# Migration Quick Reference Guide

**Date:** December 27, 2025  
**Purpose:** Quick reference for migration commands, results, and troubleshooting

## Migration Commands

### Run Full Migration
```bash
cd /Applications/AMPPS/www/zoea-2/backend
pnpm migrate
```

### Targeted Migrations
```bash
# Migrate user 1's venues specifically
pnpm migrate:user1
```

### Database Queries

#### Check Migration Status
```sql
-- V2: Count migrated users
SELECT COUNT(*) FROM users WHERE legacy_id IS NOT NULL;

-- V2: Count migrated venues
SELECT COUNT(*) FROM listings WHERE legacy_id IS NOT NULL;

-- V2: Count migrated bookings
SELECT COUNT(*) FROM bookings WHERE legacy_id IS NOT NULL;
```

#### Find Failed Users
```sql
-- V1: Get all user IDs
SELECT user_id FROM users ORDER BY user_id;

-- V2: Get migrated user IDs
SELECT legacy_id FROM users WHERE legacy_id IS NOT NULL ORDER BY legacy_id;

-- Compare: Users in V1 but not in V2
-- (Use application logic to compare)
```

## Migration Results Summary

| Data Type | V1 Total | V2 Migrated | Success Rate |
|-----------|----------|-------------|--------------|
| Users | 4,564 | 4,447 | 97.4% |
| Venues | 971 | 970 | 99.9% |
| Countries | 5 | 5 | 100% |
| Cities | 15 | 15 | 100% |
| Bookings | 125 | 104 | 83.2% |
| Reviews | 97 | 36 | 37.1% |
| Favorites | 282 | 188 | 66.7% |

## Environment Variables

```bash
# V1 Database (MariaDB)
V1_DB_HOST=localhost
V1_DB_PORT=3306
V1_DB_USER=root
V1_DB_PASSWORD=mysql
V1_DB_NAME=zoea

# V2 Database (PostgreSQL)
DATABASE_URL=postgresql://admin:Zoea2025Secure@172.16.40.61:5432/main
```

## Common Issues & Solutions

### Issue: User Migration Fails
**Solution:**
- Check for duplicate email/phone
- Verify data quality (no null bytes)
- Check if user already migrated

### Issue: Venue Migration Fails
**Solution:**
- Verify user exists in V2
- Check merchant profile creation
- Verify location mapping

### Issue: UTF-8 Encoding Error
**Solution:**
- Data cleaner should handle this automatically
- Check for null bytes in source data

### Issue: Duplicate Constraint Violation
**Solution:**
- Migration handles duplicates automatically
- Sets duplicate emails to null
- Modifies duplicate phones

## Key Files

### Migration Scripts
- `src/migration/migrate.ts` - Main entry point
- `src/migration/migration.service.ts` - Core service
- `src/migration/migrate-user1-venues.ts` - User 1 specific

### Utilities
- `src/migration/utils/user-data-cleaner.ts` - Data cleaning
- `src/migration/utils/image-verifier.ts` - Image verification
- `src/migration/utils/location-mapper.ts` - Location mapping
- `src/migration/utils/merchant-profile-mapper.ts` - Merchant profiles

## Data Cleaning Features

### Automatic Handling
- ✅ Email in phone field → Move to email field
- ✅ Duplicate email → Set to null
- ✅ Duplicate phone → Append user_id
- ✅ No contact info → Generate placeholder phone
- ✅ Missing name → Generate from email/phone
- ✅ UTF-8 issues → Sanitize strings
- ✅ Invalid phone → Validate and clean

## Password Migration

- **Default Password:** "Pass123" for all migrated users
- **Legacy Hash:** Stored in `legacy_password_hash`
- **Migration Flag:** `password_migrated = true`
- **User Action:** Prompt to change on first login

## Legacy ID Tracking

All migrated records maintain `legacy_id` for reference:
- `users.legacy_id` → V1 `users.user_id`
- `listings.legacy_id` → V1 `venues.venue_id`
- `bookings.legacy_id` → V1 `bookings.booking_id`
- `reviews.legacy_id` → V1 `reviews.review_id`
- `favorites.legacy_id` → V1 `favorites.favorite_id`

## Image Handling

- **V1 Server:** `https://zoea.africa/`
- **Process:** Verify image accessibility, create V2 Media record
- **Status:** Images remain on V1 server, referenced in V2

## Merchant Profile Strategy

- **Strategy:** One merchant profile per venue (`one_per_venue`)
- **Rationale:** Most flexible, supports multiple businesses per user
- **Implementation:** Automatic creation during venue migration

---

**Quick Links:**
- [Full Migration Summary](./MIGRATION_SUMMARY.md)
- [Failed Users Analysis](./FAILED_USERS_FINAL_ANALYSIS.md)
- [Migration Setup](./MIGRATION_SETUP.md)

