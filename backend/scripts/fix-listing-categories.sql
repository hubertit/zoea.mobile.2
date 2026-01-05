-- Fix Listing Category Mismatches
-- This script corrects listings that are in wrong categories after migration

-- Get the correct category IDs first
DO $$
DECLARE
    dining_category_id UUID;
    restaurants_category_id UUID;
    attractions_category_id UUID;
    accommodation_category_id UUID;
    nightlife_category_id UUID;
    shopping_category_id UUID;
BEGIN
    -- Get category IDs
    SELECT id INTO dining_category_id FROM categories WHERE slug = 'dining' AND parent_id IS NULL;
    SELECT id INTO restaurants_category_id FROM categories WHERE slug = 'restaurants' AND parent_id IS NOT NULL;
    SELECT id INTO attractions_category_id FROM categories WHERE slug = 'attractions' AND parent_id IS NULL;
    SELECT id INTO accommodation_category_id FROM categories WHERE slug = 'accommodation' AND parent_id IS NULL;
    SELECT id INTO nightlife_category_id FROM categories WHERE slug = 'nightlife' AND parent_id IS NULL;
    SELECT id INTO shopping_category_id FROM categories WHERE slug = 'shopping' AND parent_id IS NULL;

    RAISE NOTICE 'Category IDs found:';
    RAISE NOTICE 'Dining: %', dining_category_id;
    RAISE NOTICE 'Restaurants (subcategory): %', restaurants_category_id;
    RAISE NOTICE 'Attractions: %', attractions_category_id;
    RAISE NOTICE 'Accommodation: %', accommodation_category_id;
    RAISE NOTICE 'Nightlife: %', nightlife_category_id;
    RAISE NOTICE 'Shopping: %', shopping_category_id;

    -- Fix restaurants that are NOT in dining-related categories
    -- Move them to Restaurants subcategory
    UPDATE listings l
    SET category_id = restaurants_category_id,
        updated_at = NOW()
    FROM categories c
    LEFT JOIN categories pc ON c.parent_id = pc.id
    WHERE l.category_id = c.id
      AND l.type = 'restaurant'
      AND (pc.name != 'Dining' OR pc.name IS NULL)
      AND (c.name != 'Dining');

    RAISE NOTICE 'Fixed % restaurant listings', (SELECT COUNT(*) 
        FROM listings l
        WHERE l.type = 'restaurant' AND l.category_id = restaurants_category_id);

    -- Fix cafes that might be in wrong categories
    UPDATE listings l
    SET category_id = (SELECT id FROM categories WHERE slug = 'cafes' AND parent_id IS NOT NULL LIMIT 1),
        updated_at = NOW()
    FROM categories c
    LEFT JOIN categories pc ON c.parent_id = pc.id
    WHERE l.category_id = c.id
      AND l.type = 'cafe'
      AND (pc.name != 'Dining' OR pc.name IS NULL)
      AND (c.name != 'Dining');

    -- Fix attractions that are in Dining category
    -- Move them to main Attractions category
    UPDATE listings
    SET category_id = attractions_category_id,
        updated_at = NOW()
    WHERE type = 'attraction'
      AND category_id IN (
          SELECT id FROM categories 
          WHERE name = 'Dining' OR slug = 'dining'
      );

    RAISE NOTICE 'Fixed % attraction listings', (SELECT COUNT(*) 
        FROM listings 
        WHERE type = 'attraction' AND category_id = attractions_category_id);

    -- Fix hotels that might be in wrong categories
    UPDATE listings l
    SET category_id = accommodation_category_id,
        updated_at = NOW()
    FROM categories c
    WHERE l.category_id = c.id
      AND l.type = 'hotel'
      AND c.name != 'Accommodation'
      AND c.parent_id IS NOT NULL; -- Don't change if it's already in Accommodation parent

    -- Fix bars/clubs/lounges that might be in wrong categories
    UPDATE listings l
    SET category_id = nightlife_category_id,
        updated_at = NOW()
    FROM categories c
    LEFT JOIN categories pc ON c.parent_id = pc.id
    WHERE l.category_id = c.id
      AND l.type IN ('bar', 'club', 'lounge')
      AND (pc.name != 'Nightlife' OR pc.name IS NULL)
      AND (c.name != 'Nightlife');

    -- Fix boutiques/malls/markets that might be in wrong categories
    UPDATE listings l
    SET category_id = shopping_category_id,
        updated_at = NOW()
    FROM categories c
    LEFT JOIN categories pc ON c.parent_id = pc.id
    WHERE l.category_id = c.id
      AND l.type IN ('boutique', 'mall', 'market')
      AND (pc.name != 'Shopping' OR pc.name IS NULL)
      AND (c.name != 'Shopping');

END $$;

-- Verification query
SELECT 
    'After Fix: Restaurant in wrong categories' as status,
    COUNT(*) as count
FROM listings l
LEFT JOIN categories c ON l.category_id = c.id
LEFT JOIN categories pc ON c.parent_id = pc.id
WHERE l.type = 'restaurant'
  AND (pc.name != 'Dining' OR pc.name IS NULL)
  AND (c.name != 'Dining')

UNION ALL

SELECT 
    'After Fix: Attraction in Dining category' as status,
    COUNT(*) as count
FROM listings l
JOIN categories c ON l.category_id = c.id
WHERE l.type = 'attraction'
  AND (c.name = 'Dining' OR c.slug = 'dining')

UNION ALL

SELECT 
    'After Fix: Restaurants in Restaurants category' as status,
    COUNT(*) as count
FROM listings l
JOIN categories c ON l.category_id = c.id
WHERE l.type = 'restaurant'
  AND c.slug = 'restaurants';

