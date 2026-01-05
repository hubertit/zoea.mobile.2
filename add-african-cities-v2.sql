-- Add major cities for African countries in Zoea database
-- Date: January 5, 2026
-- Version 2: Don't delete Kenya cities, just add new ones

BEGIN;

-- Get country IDs
DO $$
DECLARE
    burundi_id UUID;
    drc_id UUID;
    ethiopia_id UUID;
    ghana_id UUID;
    kenya_id UUID;
    nigeria_id UUID;
    south_africa_id UUID;
    tanzania_id UUID;
    uganda_id UUID;
BEGIN
    -- Get country IDs
    SELECT id INTO burundi_id FROM countries WHERE code = 'BDI';
    SELECT id INTO drc_id FROM countries WHERE code = 'COD';
    SELECT id INTO ethiopia_id FROM countries WHERE code = 'ETH';
    SELECT id INTO ghana_id FROM countries WHERE code = 'GHA';
    SELECT id INTO kenya_id FROM countries WHERE code = 'KEN';
    SELECT id INTO nigeria_id FROM countries WHERE code = 'NGA';
    SELECT id INTO south_africa_id FROM countries WHERE code = 'ZAF';
    SELECT id INTO tanzania_id FROM countries WHERE code = 'TZA';
    SELECT id INTO uganda_id FROM countries WHERE code = 'UGA';

    -- ============================================
    -- BURUNDI CITIES
    -- ============================================
    INSERT INTO cities (id, country_id, name, slug, timezone, created_at) VALUES
    (uuid_generate_v4(), burundi_id, 'Bujumbura', 'bujumbura', 'Africa/Bujumbura', NOW()),
    (uuid_generate_v4(), burundi_id, 'Gitega', 'gitega', 'Africa/Bujumbura', NOW()),
    (uuid_generate_v4(), burundi_id, 'Muyinga', 'muyinga', 'Africa/Bujumbura', NOW()),
    (uuid_generate_v4(), burundi_id, 'Ngozi', 'ngozi', 'Africa/Bujumbura', NOW()),
    (uuid_generate_v4(), burundi_id, 'Ruyigi', 'ruyigi', 'Africa/Bujumbura', NOW())
    ON CONFLICT (country_id, slug) DO NOTHING;

    -- ============================================
    -- DEMOCRATIC REPUBLIC OF CONGO CITIES
    -- ============================================
    INSERT INTO cities (id, country_id, name, slug, timezone, created_at) VALUES
    (uuid_generate_v4(), drc_id, 'Kinshasa', 'kinshasa', 'Africa/Kinshasa', NOW()),
    (uuid_generate_v4(), drc_id, 'Lubumbashi', 'lubumbashi', 'Africa/Lubumbashi', NOW()),
    (uuid_generate_v4(), drc_id, 'Mbuji-Mayi', 'mbuji-mayi', 'Africa/Lubumbashi', NOW()),
    (uuid_generate_v4(), drc_id, 'Kananga', 'kananga', 'Africa/Lubumbashi', NOW()),
    (uuid_generate_v4(), drc_id, 'Kisangani', 'kisangani', 'Africa/Lubumbashi', NOW()),
    (uuid_generate_v4(), drc_id, 'Bukavu', 'bukavu', 'Africa/Lubumbashi', NOW()),
    (uuid_generate_v4(), drc_id, 'Goma', 'goma', 'Africa/Lubumbashi', NOW())
    ON CONFLICT (country_id, slug) DO NOTHING;

    -- ============================================
    -- ETHIOPIA CITIES
    -- ============================================
    INSERT INTO cities (id, country_id, name, slug, timezone, created_at) VALUES
    (uuid_generate_v4(), ethiopia_id, 'Addis Ababa', 'addis-ababa', 'Africa/Addis_Ababa', NOW()),
    (uuid_generate_v4(), ethiopia_id, 'Dire Dawa', 'dire-dawa', 'Africa/Addis_Ababa', NOW()),
    (uuid_generate_v4(), ethiopia_id, 'Mekelle', 'mekelle', 'Africa/Addis_Ababa', NOW()),
    (uuid_generate_v4(), ethiopia_id, 'Gondar', 'gondar', 'Africa/Addis_Ababa', NOW()),
    (uuid_generate_v4(), ethiopia_id, 'Bahir Dar', 'bahir-dar', 'Africa/Addis_Ababa', NOW()),
    (uuid_generate_v4(), ethiopia_id, 'Hawassa', 'hawassa', 'Africa/Addis_Ababa', NOW())
    ON CONFLICT (country_id, slug) DO NOTHING;

    -- ============================================
    -- GHANA CITIES
    -- ============================================
    INSERT INTO cities (id, country_id, name, slug, timezone, created_at) VALUES
    (uuid_generate_v4(), ghana_id, 'Accra', 'accra', 'Africa/Accra', NOW()),
    (uuid_generate_v4(), ghana_id, 'Kumasi', 'kumasi', 'Africa/Accra', NOW()),
    (uuid_generate_v4(), ghana_id, 'Tamale', 'tamale', 'Africa/Accra', NOW()),
    (uuid_generate_v4(), ghana_id, 'Sekondi-Takoradi', 'sekondi-takoradi', 'Africa/Accra', NOW()),
    (uuid_generate_v4(), ghana_id, 'Cape Coast', 'cape-coast', 'Africa/Accra', NOW()),
    (uuid_generate_v4(), ghana_id, 'Tema', 'tema', 'Africa/Accra', NOW())
    ON CONFLICT (country_id, slug) DO NOTHING;

    -- ============================================
    -- KENYA CITIES
    -- Note: Keep existing cities, just add proper Kenyan cities
    -- ============================================
    INSERT INTO cities (id, country_id, name, slug, timezone, created_at) VALUES
    (uuid_generate_v4(), kenya_id, 'Nairobi', 'nairobi', 'Africa/Nairobi', NOW()),
    (uuid_generate_v4(), kenya_id, 'Mombasa', 'mombasa', 'Africa/Nairobi', NOW()),
    (uuid_generate_v4(), kenya_id, 'Kisumu', 'kisumu', 'Africa/Nairobi', NOW()),
    (uuid_generate_v4(), kenya_id, 'Nakuru', 'nakuru', 'Africa/Nairobi', NOW()),
    (uuid_generate_v4(), kenya_id, 'Eldoret', 'eldoret', 'Africa/Nairobi', NOW()),
    (uuid_generate_v4(), kenya_id, 'Malindi', 'malindi', 'Africa/Nairobi', NOW())
    ON CONFLICT (country_id, slug) DO NOTHING;

    -- ============================================
    -- NIGERIA CITIES
    -- ============================================
    INSERT INTO cities (id, country_id, name, slug, timezone, created_at) VALUES
    (uuid_generate_v4(), nigeria_id, 'Lagos', 'lagos', 'Africa/Lagos', NOW()),
    (uuid_generate_v4(), nigeria_id, 'Abuja', 'abuja', 'Africa/Lagos', NOW()),
    (uuid_generate_v4(), nigeria_id, 'Kano', 'kano', 'Africa/Lagos', NOW()),
    (uuid_generate_v4(), nigeria_id, 'Ibadan', 'ibadan', 'Africa/Lagos', NOW()),
    (uuid_generate_v4(), nigeria_id, 'Port Harcourt', 'port-harcourt', 'Africa/Lagos', NOW()),
    (uuid_generate_v4(), nigeria_id, 'Benin City', 'benin-city', 'Africa/Lagos', NOW()),
    (uuid_generate_v4(), nigeria_id, 'Kaduna', 'kaduna', 'Africa/Lagos', NOW())
    ON CONFLICT (country_id, slug) DO NOTHING;

    -- ============================================
    -- SOUTH AFRICA CITIES
    -- ============================================
    INSERT INTO cities (id, country_id, name, slug, timezone, created_at) VALUES
    (uuid_generate_v4(), south_africa_id, 'Johannesburg', 'johannesburg', 'Africa/Johannesburg', NOW()),
    (uuid_generate_v4(), south_africa_id, 'Cape Town', 'cape-town', 'Africa/Johannesburg', NOW()),
    (uuid_generate_v4(), south_africa_id, 'Durban', 'durban', 'Africa/Johannesburg', NOW()),
    (uuid_generate_v4(), south_africa_id, 'Pretoria', 'pretoria', 'Africa/Johannesburg', NOW()),
    (uuid_generate_v4(), south_africa_id, 'Port Elizabeth', 'port-elizabeth', 'Africa/Johannesburg', NOW()),
    (uuid_generate_v4(), south_africa_id, 'Bloemfontein', 'bloemfontein', 'Africa/Johannesburg', NOW())
    ON CONFLICT (country_id, slug) DO NOTHING;

    -- ============================================
    -- TANZANIA CITIES
    -- ============================================
    INSERT INTO cities (id, country_id, name, slug, timezone, created_at) VALUES
    (uuid_generate_v4(), tanzania_id, 'Dar es Salaam', 'dar-es-salaam', 'Africa/Dar_es_Salaam', NOW()),
    (uuid_generate_v4(), tanzania_id, 'Dodoma', 'dodoma', 'Africa/Dar_es_Salaam', NOW()),
    (uuid_generate_v4(), tanzania_id, 'Arusha', 'arusha', 'Africa/Dar_es_Salaam', NOW()),
    (uuid_generate_v4(), tanzania_id, 'Mwanza', 'mwanza', 'Africa/Dar_es_Salaam', NOW()),
    (uuid_generate_v4(), tanzania_id, 'Zanzibar City', 'zanzibar-city', 'Africa/Dar_es_Salaam', NOW()),
    (uuid_generate_v4(), tanzania_id, 'Mbeya', 'mbeya', 'Africa/Dar_es_Salaam', NOW())
    ON CONFLICT (country_id, slug) DO NOTHING;

    -- ============================================
    -- UGANDA CITIES
    -- ============================================
    INSERT INTO cities (id, country_id, name, slug, timezone, created_at) VALUES
    (uuid_generate_v4(), uganda_id, 'Kampala', 'kampala', 'Africa/Kampala', NOW()),
    (uuid_generate_v4(), uganda_id, 'Entebbe', 'entebbe', 'Africa/Kampala', NOW()),
    (uuid_generate_v4(), uganda_id, 'Jinja', 'jinja', 'Africa/Kampala', NOW()),
    (uuid_generate_v4(), uganda_id, 'Mbarara', 'mbarara', 'Africa/Kampala', NOW()),
    (uuid_generate_v4(), uganda_id, 'Gulu', 'gulu', 'Africa/Kampala', NOW()),
    (uuid_generate_v4(), uganda_id, 'Fort Portal', 'fort-portal', 'Africa/Kampala', NOW())
    ON CONFLICT (country_id, slug) DO NOTHING;

    RAISE NOTICE 'Successfully added cities for all African countries!';
END $$;

-- Show summary
SELECT 
    c.name as country,
    COUNT(ci.id) as city_count
FROM countries c
LEFT JOIN cities ci ON c.id = ci.country_id
WHERE c.code IN ('BDI', 'COD', 'ETH', 'GHA', 'KEN', 'NGA', 'ZAF', 'TZA', 'UGA', 'RWA')
GROUP BY c.name
ORDER BY c.name;

COMMIT;

