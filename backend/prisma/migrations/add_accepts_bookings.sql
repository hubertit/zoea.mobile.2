-- Add accepts_bookings column to listings table
ALTER TABLE listings ADD COLUMN IF NOT EXISTS accepts_bookings BOOLEAN DEFAULT false;

-- Set accepts_bookings to true for all listings in dining-related categories
-- This includes categories with slugs: dining, restaurants, cafe, fastfood
UPDATE listings 
SET accepts_bookings = true 
WHERE category_id IN (
  SELECT id FROM categories 
  WHERE slug IN ('dining', 'restaurants', 'cafe', 'fastfood', 'restaurant', 'cafes', 'fast-food')
  OR LOWER(name) LIKE '%dining%'
  OR LOWER(name) LIKE '%restaurant%'
  OR LOWER(name) LIKE '%cafe%'
  OR LOWER(name) LIKE '%fast food%'
  OR LOWER(name) LIKE '%fastfood%'
);

