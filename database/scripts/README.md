# Database Scripts

This directory contains SQL scripts for database operations, migrations, and data fixes.

## Contents

### City/Country Scripts
- `add-african-cities.sql` - Add African cities to database
- `add-african-cities-v2.sql` - Updated version of African cities script
- `fix-kenya-rwanda-cities.sql` - Fix Kenya and Rwanda cities
- `fix-kenya-rwanda-cities-v2.sql` - Updated version of city fixes
- `cleanup-countries.sql` - Cleanup countries data

### Listing Scripts
- `SET_FEATURED_LISTINGS.sql` - Set featured listings

## Usage

⚠️ **Warning**: Always backup your database before running these scripts.

```bash
# Example: Run a script
psql -U your_user -d your_database -f add-african-cities.sql
```

## Organization

Scripts are organized by purpose:
- **Cities/Countries**: Scripts for managing geographic data
- **Listings**: Scripts for managing listing data
- **Migrations**: Use Prisma migrations in `backend/prisma/migrations/` instead

## Notes

- Always test scripts on a development database first
- Review scripts before execution
- Document any manual changes made
- Keep scripts versioned and documented

