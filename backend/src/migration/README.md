# Migration Scripts

This directory contains migration scripts for the Zoea V1 to V2 database migration.

## Essential Scripts

### Core Migration
- **`migrate.ts`** - Main migration script entry point
- **`migration.service.ts`** - Core migration service with all migration logic
- **`migration.module.ts`** - NestJS module for migration

### Category Management
- **`import-v1-categories.ts`** - Imports all original V1 categories into V2, preserving hierarchy
- **`restore-original-categories.ts`** - Restores listings to their original V1 categories

## Utilities

The `utils/` directory contains utility functions used by migration scripts:
- `image-verifier.ts` - Verifies and validates images
- `location-mapper.ts` - Maps V1 locations to V2 cities
- `merchant-profile-mapper.ts` - Maps merchant profiles
- `user-data-cleaner.ts` - Cleans user data during migration

## Archived Scripts

The `archive/` directory contains temporary, one-time, or check scripts that were used during migration development and troubleshooting. These scripts are kept for reference but are not part of the main migration process.

### Running Migration Scripts

```bash
# Set environment variables
export DATABASE_URL="postgresql://admin:Zoea2025Secure@172.16.40.61:5432/main"
export JWT_SECRET="dummy-secret-for-migration"
export V1_DB_HOST="localhost"
export V1_DB_PORT="3306"
export V1_DB_USER="root"
export V1_DB_PASSWORD="mysql"
export V1_DB_NAME="zoea"

# Import V1 categories
npx ts-node src/migration/import-v1-categories.ts

# Restore listings to original categories
npx ts-node src/migration/restore-original-categories.ts

# Run main migration
npx ts-node src/migration/migrate.ts
```

## Notes

- All scripts require both V1 (MySQL) and V2 (PostgreSQL) database connections
- Scripts use `legacyId` to track migrated entities
- Category restoration only affects listings with `legacyId` (from V1 migration)

