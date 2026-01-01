# Enable Shop Mode for All Listings

## Option 1: Run SQL Directly on Server (Recommended)

Connect to your database server and run:

```sql
UPDATE listings
SET 
  is_shop_enabled = true,
  shop_settings = jsonb_build_object(
    'acceptsOnlineOrders', true,
    'deliveryEnabled', false,
    'pickupEnabled', true,
    'dineInEnabled', false
  )
WHERE is_shop_enabled IS NULL OR is_shop_enabled = false;
```

Or use the SQL file:
```bash
psql -h 172.16.40.61 -U admin -d main -f src/migration/enable-shop-mode-sql.sql
```

## Option 2: Run TypeScript Script

From the backend directory:
```bash
npx ts-node src/migration/enable-shop-mode.ts
```

Make sure DATABASE_URL is set in .env file.

## Verify

After running, check the results:
```sql
SELECT 
  COUNT(*) as total_listings,
  COUNT(*) FILTER (WHERE is_shop_enabled = true) as shop_enabled_count
FROM listings;
```
