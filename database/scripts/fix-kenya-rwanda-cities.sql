-- Fix Kenya cities issue: Move Rwandan merchants to Rwanda and delete duplicate cities
-- Date: January 5, 2026

BEGIN;

-- First, let's get the city IDs we need
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
    
    RAISE NOTICE 'Step 1: Updating merchant profiles to use correct Rwanda cities...';
    
    -- Update merchant profiles: Kigali
    UPDATE merchant_profiles 
    SET city_id = rwanda_kigali_id, country_id = rwanda_id
    WHERE city_id = kenya_kigali_id;
    
    -- Update merchant profiles: Musanze
    UPDATE merchant_profiles 
    SET city_id = rwanda_musanze_id, country_id = rwanda_id
    WHERE city_id = kenya_musanze_id;
    
    -- Update merchant profiles: Rubavu
    UPDATE merchant_profiles 
    SET city_id = rwanda_rubavu_id, country_id = rwanda_id
    WHERE city_id = kenya_rubavu_id;
    
    -- Update merchant profiles: Rusizi
    UPDATE merchant_profiles 
    SET city_id = rwanda_rusizi_id, country_id = rwanda_id
    WHERE city_id = kenya_rusizi_id;
    
    -- Update merchant profiles: Karongi
    UPDATE merchant_profiles 
    SET city_id = rwanda_karongi_id, country_id = rwanda_id
    WHERE city_id = kenya_karongi_id;
    
    RAISE NOTICE 'Step 2: Updating listings to use correct Rwanda cities...';
    
    -- Update listings: Kigali
    UPDATE listings 
    SET city_id = rwanda_kigali_id, country_id = rwanda_id
    WHERE city_id = kenya_kigali_id;
    
    -- Update listings: Musanze
    UPDATE listings 
    SET city_id = rwanda_musanze_id, country_id = rwanda_id
    WHERE city_id = kenya_musanze_id;
    
    -- Update listings: Rubavu
    UPDATE listings 
    SET city_id = rwanda_rubavu_id, country_id = rwanda_id
    WHERE city_id = kenya_rubavu_id;
    
    -- Update listings: Rusizi
    UPDATE listings 
    SET city_id = rwanda_rusizi_id, country_id = rwanda_id
    WHERE city_id = kenya_rusizi_id;
    
    -- Update listings: Karongi
    UPDATE listings 
    SET city_id = rwanda_karongi_id, country_id = rwanda_id
    WHERE city_id = kenya_karongi_id;
    
    RAISE NOTICE 'Step 3: Deleting duplicate Kenya cities...';
    
    -- Now delete the Kenya cities (should work since no more references)
    DELETE FROM cities WHERE id IN (kenya_kigali_id, kenya_musanze_id, kenya_rubavu_id, kenya_rusizi_id, kenya_karongi_id);
    
    RAISE NOTICE 'Step 4: Verifying changes...';
    
END $$;

-- Show summary
SELECT 
    'Merchant Profiles' as table_name,
    c.name as country,
    ci.name as city,
    COUNT(mp.id) as count
FROM merchant_profiles mp
JOIN cities ci ON mp.city_id = ci.id
JOIN countries c ON ci.country_id = c.id
WHERE ci.slug IN ('kigali', 'musanze', 'rubavu', 'rusizi', 'karongi')
GROUP BY c.name, ci.name
ORDER BY c.name, ci.name;

-- Show city counts by country
SELECT 
    c.name as country,
    COUNT(ci.id) as city_count,
    array_agg(ci.name ORDER BY ci.name) as cities
FROM countries c
LEFT JOIN cities ci ON c.id = ci.country_id
WHERE c.code IN ('KEN', 'RWA')
GROUP BY c.name
ORDER BY c.name;

COMMIT;

