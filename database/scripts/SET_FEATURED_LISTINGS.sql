-- Set Featured Listings for Recommendations
-- Run this SQL to mark some high-quality listings as featured
-- This will make them appear in the "Add from Recommendations" screen

-- Option 1: Mark top-rated active listings as featured
UPDATE listings 
SET is_featured = true 
WHERE rating >= 4.5 
  AND status = 'active' 
  AND deleted_at IS NULL
LIMIT 20;

-- Option 2: Mark specific categories of listings as featured
UPDATE listings 
SET is_featured = true 
WHERE status = 'active' 
  AND deleted_at IS NULL
  AND type IN ('hotel', 'restaurant', 'attraction')
  AND rating >= 4.0
LIMIT 30;

-- Option 3: Mark listings from major cities as featured
UPDATE listings l
SET is_featured = true 
FROM cities c
WHERE l.city_id = c.id
  AND c.name IN ('Kigali', 'Nairobi', 'Kampala', 'Dar es Salaam')
  AND l.status = 'active' 
  AND l.deleted_at IS NULL
  AND l.rating >= 4.0
LIMIT 25;

-- Verify featured listings
SELECT 
  l.id,
  l.name,
  l.type,
  l.rating,
  c.name as city_name,
  l.is_featured
FROM listings l
LEFT JOIN cities c ON l.city_id = c.id
WHERE l.is_featured = true
  AND l.status = 'active'
  AND l.deleted_at IS NULL
ORDER BY l.rating DESC;

-- Count featured listings by country
SELECT 
  co.name as country,
  COUNT(*) as featured_count
FROM listings l
JOIN cities c ON l.city_id = c.id
JOIN countries co ON c.country_id = co.id
WHERE l.is_featured = true
  AND l.status = 'active'
  AND l.deleted_at IS NULL
GROUP BY co.name
ORDER BY featured_count DESC;

