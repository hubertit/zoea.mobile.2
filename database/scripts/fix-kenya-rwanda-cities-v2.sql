-- Fix Kenya cities issue: Move all Rwandan data to Rwanda and delete duplicate cities
-- Date: January 5, 2026
-- Version 2: Update all tables with foreign keys to cities

BEGIN;

DO $$
DECLARE
    rwanda_id UUID;
    kenya_id UUID;
    rwanda_kigali_id UUID;
    rwanda_musanze_id UUID;
    rwanda_rubavu_id UUID;
    rwanda_rusizi_id UUID;
    rwanda_karongi_id UUID;
    kenya_kigali_id UUID;
    kenya_musanze_id UUID;
    kenya_rubavu_id UUID;
    kenya_rusizi_id UUID;
    kenya_karongi_id UUID;
    affected_rows INT;
BEGIN
    -- Get country IDs
    SELECT id INTO rwanda_id FROM countries WHERE code = 'RWA';
    SELECT id INTO kenya_id FROM countries WHERE code = 'KEN';
    
    -- Get Rwanda city IDs (correct ones)
    SELECT id INTO rwanda_kigali_id FROM cities WHERE country_id = rwanda_id AND slug = 'kigali';
    SELECT id INTO rwanda_musanze_id FROM cities WHERE country_id = rwanda_id AND slug = 'musanze';
    SELECT id INTO rwanda_rubavu_id FROM cities WHERE country_id = rwanda_id AND slug = 'rubavu';
    SELECT id INTO rwanda_rusizi_id FROM cities WHERE country_id = rwanda_id AND slug = 'rusizi';
    SELECT id INTO rwanda_karongi_id FROM cities WHERE country_id = rwanda_id AND slug = 'karongi';
    
    -- Get Kenya city IDs (wrong ones that need to be deleted)
    SELECT id INTO kenya_kigali_id FROM cities WHERE country_id = kenya_id AND slug = 'kigali';
    SELECT id INTO kenya_musanze_id FROM cities WHERE country_id = kenya_id AND slug = 'musanze';
    SELECT id INTO kenya_rubavu_id FROM cities WHERE country_id = kenya_id AND slug = 'rubavu';
    SELECT id INTO kenya_rusizi_id FROM cities WHERE country_id = kenya_id AND slug = 'rusizi';
    SELECT id INTO kenya_karongi_id FROM cities WHERE country_id = kenya_id AND slug = 'karongi';
    
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Fixing Kenya/Rwanda City References';
    RAISE NOTICE '========================================';
    
    -- 1. UPDATE USERS
    RAISE NOTICE 'Updating users table...';
    UPDATE users SET city_id = rwanda_kigali_id, country_id = rwanda_id WHERE city_id = kenya_kigali_id;
    GET DIAGNOSTICS affected_rows = ROW_COUNT;
    RAISE NOTICE '  - Kigali: % rows updated', affected_rows;
    
    UPDATE users SET city_id = rwanda_musanze_id, country_id = rwanda_id WHERE city_id = kenya_musanze_id;
    UPDATE users SET city_id = rwanda_rubavu_id, country_id = rwanda_id WHERE city_id = kenya_rubavu_id;
    UPDATE users SET city_id = rwanda_rusizi_id, country_id = rwanda_id WHERE city_id = kenya_rusizi_id;
    UPDATE users SET city_id = rwanda_karongi_id, country_id = rwanda_id WHERE city_id = kenya_karongi_id;
    
    -- 2. UPDATE MERCHANT_PROFILES
    RAISE NOTICE 'Updating merchant_profiles table...';
    UPDATE merchant_profiles SET city_id = rwanda_kigali_id, country_id = rwanda_id WHERE city_id = kenya_kigali_id;
    GET DIAGNOSTICS affected_rows = ROW_COUNT;
    RAISE NOTICE '  - Kigali: % rows updated', affected_rows;
    
    UPDATE merchant_profiles SET city_id = rwanda_musanze_id, country_id = rwanda_id WHERE city_id = kenya_musanze_id;
    UPDATE merchant_profiles SET city_id = rwanda_rubavu_id, country_id = rwanda_id WHERE city_id = kenya_rubavu_id;
    UPDATE merchant_profiles SET city_id = rwanda_rusizi_id, country_id = rwanda_id WHERE city_id = kenya_rusizi_id;
    UPDATE merchant_profiles SET city_id = rwanda_karongi_id, country_id = rwanda_id WHERE city_id = kenya_karongi_id;
    
    -- 3. UPDATE ORGANIZER_PROFILES
    RAISE NOTICE 'Updating organizer_profiles table...';
    UPDATE organizer_profiles SET city_id = rwanda_kigali_id, country_id = rwanda_id WHERE city_id = kenya_kigali_id;
    UPDATE organizer_profiles SET city_id = rwanda_musanze_id, country_id = rwanda_id WHERE city_id = kenya_musanze_id;
    UPDATE organizer_profiles SET city_id = rwanda_rubavu_id, country_id = rwanda_id WHERE city_id = kenya_rubavu_id;
    UPDATE organizer_profiles SET city_id = rwanda_rusizi_id, country_id = rwanda_id WHERE city_id = kenya_rusizi_id;
    UPDATE organizer_profiles SET city_id = rwanda_karongi_id, country_id = rwanda_id WHERE city_id = kenya_karongi_id;
    
    -- 4. UPDATE TOUR_OPERATOR_PROFILES
    RAISE NOTICE 'Updating tour_operator_profiles table...';
    UPDATE tour_operator_profiles SET city_id = rwanda_kigali_id, country_id = rwanda_id WHERE city_id = kenya_kigali_id;
    UPDATE tour_operator_profiles SET city_id = rwanda_musanze_id, country_id = rwanda_id WHERE city_id = kenya_musanze_id;
    UPDATE tour_operator_profiles SET city_id = rwanda_rubavu_id, country_id = rwanda_id WHERE city_id = kenya_rubavu_id;
    UPDATE tour_operator_profiles SET city_id = rwanda_rusizi_id, country_id = rwanda_id WHERE city_id = kenya_rusizi_id;
    UPDATE tour_operator_profiles SET city_id = rwanda_karongi_id, country_id = rwanda_id WHERE city_id = kenya_karongi_id;
    
    -- 5. UPDATE LISTINGS
    RAISE NOTICE 'Updating listings table...';
    UPDATE listings SET city_id = rwanda_kigali_id, country_id = rwanda_id WHERE city_id = kenya_kigali_id;
    GET DIAGNOSTICS affected_rows = ROW_COUNT;
    RAISE NOTICE '  - Kigali: % rows updated', affected_rows;
    
    UPDATE listings SET city_id = rwanda_musanze_id, country_id = rwanda_id WHERE city_id = kenya_musanze_id;
    UPDATE listings SET city_id = rwanda_rubavu_id, country_id = rwanda_id WHERE city_id = kenya_rubavu_id;
    UPDATE listings SET city_id = rwanda_rusizi_id, country_id = rwanda_id WHERE city_id = kenya_rusizi_id;
    UPDATE listings SET city_id = rwanda_karongi_id, country_id = rwanda_id WHERE city_id = kenya_karongi_id;
    
    -- 6. UPDATE EVENTS
    RAISE NOTICE 'Updating events table...';
    UPDATE events SET city_id = rwanda_kigali_id, country_id = rwanda_id WHERE city_id = kenya_kigali_id;
    UPDATE events SET city_id = rwanda_musanze_id, country_id = rwanda_id WHERE city_id = kenya_musanze_id;
    UPDATE events SET city_id = rwanda_rubavu_id, country_id = rwanda_id WHERE city_id = kenya_rubavu_id;
    UPDATE events SET city_id = rwanda_rusizi_id, country_id = rwanda_id WHERE city_id = kenya_rusizi_id;
    UPDATE events SET city_id = rwanda_karongi_id, country_id = rwanda_id WHERE city_id = kenya_karongi_id;
    
    -- 7. UPDATE TOURS
    RAISE NOTICE 'Updating tours table...';
    UPDATE tours SET city_id = rwanda_kigali_id, country_id = rwanda_id WHERE city_id = kenya_kigali_id;
    UPDATE tours SET city_id = rwanda_musanze_id, country_id = rwanda_id WHERE city_id = kenya_musanze_id;
    UPDATE tours SET city_id = rwanda_rubavu_id, country_id = rwanda_id WHERE city_id = kenya_rubavu_id;
    UPDATE tours SET city_id = rwanda_rusizi_id, country_id = rwanda_id WHERE city_id = kenya_rusizi_id;
    UPDATE tours SET city_id = rwanda_karongi_id, country_id = rwanda_id WHERE city_id = kenya_karongi_id;
    
    -- 8. UPDATE PROFILE_VIEWS
    RAISE NOTICE 'Updating profile_views table...';
    UPDATE profile_views SET city_id = rwanda_kigali_id WHERE city_id = kenya_kigali_id;
    UPDATE profile_views SET city_id = rwanda_musanze_id WHERE city_id = kenya_musanze_id;
    UPDATE profile_views SET city_id = rwanda_rubavu_id WHERE city_id = kenya_rubavu_id;
    UPDATE profile_views SET city_id = rwanda_rusizi_id WHERE city_id = kenya_rusizi_id;
    UPDATE profile_views SET city_id = rwanda_karongi_id WHERE city_id = kenya_karongi_id;
    
    -- 9. UPDATE CONTENT_VIEWS
    RAISE NOTICE 'Updating content_views table...';
    UPDATE content_views SET city_id = rwanda_kigali_id WHERE city_id = kenya_kigali_id;
    GET DIAGNOSTICS affected_rows = ROW_COUNT;
    RAISE NOTICE '  - Kigali: % rows updated', affected_rows;
    
    UPDATE content_views SET city_id = rwanda_musanze_id WHERE city_id = kenya_musanze_id;
    UPDATE content_views SET city_id = rwanda_rubavu_id WHERE city_id = kenya_rubavu_id;
    UPDATE content_views SET city_id = rwanda_rusizi_id WHERE city_id = kenya_rusizi_id;
    UPDATE content_views SET city_id = rwanda_karongi_id WHERE city_id = kenya_karongi_id;
    
    -- 10. DELETE DUPLICATE KENYA CITIES
    RAISE NOTICE 'Deleting duplicate Kenya cities...';
    DELETE FROM cities WHERE id IN (kenya_kigali_id, kenya_musanze_id, kenya_rubavu_id, kenya_rusizi_id, kenya_karongi_id);
    GET DIAGNOSTICS affected_rows = ROW_COUNT;
    RAISE NOTICE '  - Deleted % duplicate cities from Kenya', affected_rows;
    
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Fix completed successfully!';
    RAISE NOTICE '========================================';
    
END $$;

-- Verification: Show city counts by country
SELECT 
    '==== CITY COUNTS BY COUNTRY ====' as info;

SELECT 
    c.name as country,
    COUNT(ci.id) as city_count
FROM countries c
LEFT JOIN cities ci ON c.id = ci.country_id
WHERE c.code IN ('KEN', 'RWA')
GROUP BY c.name
ORDER BY c.name;

-- Show Kenya cities
SELECT 
    '==== KENYA CITIES ====' as info;

SELECT ci.name as city
FROM cities ci
JOIN countries c ON ci.country_id = c.id
WHERE c.code = 'KEN'
ORDER BY ci.name;

-- Show Rwanda cities
SELECT 
    '==== RWANDA CITIES ====' as info;

SELECT ci.name as city
FROM cities ci
JOIN countries c ON ci.country_id = c.id
WHERE c.code = 'RWA'
ORDER BY ci.name;

COMMIT;

