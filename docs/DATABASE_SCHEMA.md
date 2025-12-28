# Database Schema Documentation

## Overview

Zoea uses **PostgreSQL** as the primary database with **Prisma** as the ORM.

## Database Location

- **Schema File**: `backend/prisma/schema.prisma`
- **Migrations**: `backend/prisma/migrations/`
- **Connection**: Configured in `backend/.env` as `DATABASE_URL`

## Key Models

### User
- User accounts and authentication
- Profile information
- Preferences and settings

### Listing
- Business listings (hotels, restaurants, tours, etc.)
- Location data (PostGIS)
- Images, amenities, pricing
- Relations: Category, City, Country, Merchant

### Booking
- User bookings (hotel, restaurant, tour, event)
- Booking details (dates, guests, pricing)
- Payment information
- Relations: User, Listing, RoomType, Table, etc.

### Category
- Listing categories
- Hierarchical structure (parent-child)
- Relations: Listings

### Review
- User reviews and ratings
- Moderation status
- Relations: User, Listing, Event, Tour

### Favorite
- User favorites
- Relations: User, Listing, Event, Tour

## Schema Access

### Prisma Studio (GUI)

```bash
cd backend
npx prisma studio
```

Opens at `http://localhost:5555`

### Direct Database Access

```bash
psql -U postgres -d zoea_v2
```

## Common Queries

### Check Table Counts

```sql
SELECT 
  'users' as table_name, COUNT(*) as count FROM users
UNION ALL
SELECT 'listings', COUNT(*) FROM listings
UNION ALL
SELECT 'bookings', COUNT(*) FROM bookings
UNION ALL
SELECT 'reviews', COUNT(*) FROM reviews;
```

### Check Recent Bookings

```sql
SELECT 
  b.booking_number,
  b.booking_type,
  b.status,
  b.total_amount,
  l.name as listing_name,
  u.email as user_email
FROM bookings b
JOIN listings l ON b.listing_id = l.id
JOIN users u ON b.user_id = u.id
ORDER BY b.created_at DESC
LIMIT 10;
```

## Migration Workflow

1. Edit `prisma/schema.prisma`
2. Create migration: `npx prisma migrate dev --name migration_name`
3. Apply: `npx prisma migrate deploy` (production)
4. Generate client: `npx prisma generate`

## Backup & Restore

### Backup

```bash
pg_dump -U postgres zoea_v2 > backup.sql
```

### Restore

```bash
psql -U postgres zoea_v2 < backup.sql
```

## See Also

- `backend/prisma/schema.prisma` - Complete schema definition
- `backend/docs/` - Backend-specific documentation

