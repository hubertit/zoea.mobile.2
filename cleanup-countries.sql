-- Clean up countries: Keep only Rwanda, Kenya, Uganda, South Africa, Nigeria
-- Date: January 5, 2026

BEGIN;

-- First, let's set all "Unknown" listings/data to Rwanda (default)
DO $$
DECLARE
    rwanda_id UUID;
    unknown_id UUID;
    rwanda_kigali_id UUID;
    affected_rows INT;
BEGIN
    SELECT id INTO rwanda_id FROM countries WHERE code = 'RWA';
    SELECT id INTO unknown_id FROM countries WHERE code = 'UNK';
    SELECT id INTO rwanda_kigali_id FROM cities WHERE country_id = rwanda_id AND slug = 'kigali';
    
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Moving Unknown country data to Rwanda';
    RAISE NOTICE '========================================';
    
    -- Update listings with Unknown country to Rwanda/Kigali
    UPDATE listings 
    SET country_id = rwanda_id, city_id = rwanda_kigali_id
    WHERE country_id = unknown_id;
    GET DIAGNOSTICS affected_rows = ROW_COUNT;
    RAISE NOTICE 'Moved % listings from Unknown to Rwanda', affected_rows;
    
    -- Update merchant profiles
    UPDATE merchant_profiles 
    SET country_id = rwanda_id, city_id = rwanda_kigali_id
    WHERE country_id = unknown_id;
    GET DIAGNOSTICS affected_rows = ROW_COUNT;
    RAISE NOTICE 'Moved % merchant profiles from Unknown to Rwanda', affected_rows;
    
    -- Update organizer profiles
    UPDATE organizer_profiles 
    SET country_id = rwanda_id, city_id = rwanda_kigali_id
    WHERE country_id = unknown_id;
    
    -- Update tour operator profiles
    UPDATE tour_operator_profiles 
    SET country_id = rwanda_id, city_id = rwanda_kigali_id
    WHERE country_id = unknown_id;
    
    -- Update events
    UPDATE events 
    SET country_id = rwanda_id, city_id = rwanda_kigali_id
    WHERE country_id = unknown_id;
    
    -- Update tours
    UPDATE tours 
    SET country_id = rwanda_id, city_id = rwanda_kigali_id
    WHERE country_id = unknown_id;
    
    -- Update users
    UPDATE users 
    SET country_id = rwanda_id, city_id = rwanda_kigali_id
    WHERE country_id = unknown_id;
    
END $$;

-- Now delete cities for countries we're removing
DELETE FROM cities 
WHERE country_id IN (
    SELECT id FROM countries 
    WHERE code IN ('BDI', 'COD', 'ETH', 'GHA', 'TZA', 'UNK')
);

-- Delete the countries we don't want
DELETE FROM countries 
WHERE code IN ('BDI', 'COD', 'ETH', 'GHA', 'TZA', 'UNK');

-- Show remaining countries
SELECT 
    '==== ACTIVE COUNTRIES ====' as info;

SELECT 
    name,
    code,
    (SELECT COUNT(*) FROM cities WHERE country_id = countries.id) as cities_count,
    (SELECT COUNT(*) FROM listings WHERE country_id = countries.id) as listings_count
FROM countries
ORDER BY name;

COMMIT;

