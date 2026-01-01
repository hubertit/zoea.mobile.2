-- Enable Shop Mode for All Listings
-- This script enables shop mode (is_shop_enabled = true) for all listings
-- Run: psql -h <host> -U <user> -d <database> -f enable-shop-mode-sql.sql

-- Update all listings to enable shop mode
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

-- Show count of updated listings
SELECT 
  COUNT(*) as total_listings,
  COUNT(*) FILTER (WHERE is_shop_enabled = true) as shop_enabled_count,
  COUNT(*) FILTER (WHERE is_shop_enabled = false) as shop_disabled_count
FROM listings;

-- Show breakdown by type
SELECT 
  type,
  COUNT(*) as total,
  COUNT(*) FILTER (WHERE is_shop_enabled = true) as enabled
FROM listings
GROUP BY type
ORDER BY type;

