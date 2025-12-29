# Archived Migration Scripts

This directory contains temporary, one-time, or check scripts that were used during migration development and troubleshooting.

## Script Categories

### Check Scripts
- `check-attractions-listings.ts` - Check listings in Attractions category
- `check-duplicate-categories.ts` - Check for duplicate category names/slugs
- `check-shopping-listings.ts` - Check shopping-related listings
- `check-v1-v2-categories.ts` - Compare V1 vs V2 categories

### Fix Scripts
- `fix-attractions-listings.ts` - Fix listings in Attractions category
- `fix-listing-categories.ts` - Fix listing category assignments
- `fix-shopping-listings.ts` - Fix shopping listing categories

### Update Scripts
- `update-categories-to-match-ui.ts` - Update categories to match UI design
- `update-listing-ratings.ts` - Update listing ratings

### One-time Migration Scripts
- `migrate-sponsored-to-featured.ts` - Migrate sponsored venues to featured
- `migrate-sponsored-standalone.ts` - Standalone sponsored migration
- `migrate-specific-sponsored-venues.ts` - Migrate specific sponsored venues
- `migrate-user1-venues.ts` - Migrate venues for user1

### List/Extract Scripts
- `list-sponsored-venues.ts` - List sponsored venues
- `list-sponsored-venues-standalone.ts` - Standalone list script
- `list-sponsored-from-sql.ts` - Extract from SQL
- `extract-venue-ids-from-sql.ts` - Extract venue IDs from SQL
- `extract-sponsored.py` - Python script for extracting sponsored data

### Populate Scripts
- `populate-accommodation-data.ts` - Populate accommodation data
- `populate-listing-descriptions.ts` - Populate listing descriptions

### Delete Scripts
- `delete-admin-listing-and-venue-792.ts` - Delete specific listing/venue

## Note

These scripts are kept for reference but are not part of the main migration process. They were used for:
- Troubleshooting specific issues
- One-time data fixes
- Verification and checking
- Development and testing

