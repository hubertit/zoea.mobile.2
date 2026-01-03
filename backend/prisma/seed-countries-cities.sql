-- Seed Countries and Cities
-- This script adds South Africa, Nigeria, and cities for all countries

-- Add South Africa
INSERT INTO countries (name, code, code_2, phone_code, currency_code, currency_symbol, flag_emoji, default_language, supported_languages, timezone, is_active, launched_at)
VALUES ('South Africa', 'ZAF', 'ZA', '+27', 'ZAR', 'R', '🇿🇦', 'en', ARRAY['en', 'af', 'zu', 'xh'], 'Africa/Johannesburg', true, NOW())
ON CONFLICT (code) DO UPDATE SET is_active = true;

-- Add Nigeria
INSERT INTO countries (name, code, code_2, phone_code, currency_code, currency_symbol, flag_emoji, default_language, supported_languages, timezone, is_active, launched_at)
VALUES ('Nigeria', 'NGA', 'NG', '+234', 'NGN', '₦', '🇳🇬', 'en', ARRAY['en', 'yo', 'ig', 'ha'], 'Africa/Lagos', true, NOW())
ON CONFLICT (code) DO UPDATE SET is_active = true;

-- Get country IDs
DO $$
DECLARE
    rwanda_id UUID;
    south_africa_id UUID;
    nigeria_id UUID;
    kenya_id UUID;
    uganda_id UUID;
    tanzania_id UUID;
BEGIN
    -- Get country IDs
    SELECT id INTO rwanda_id FROM countries WHERE code = 'RWA';
    SELECT id INTO south_africa_id FROM countries WHERE code = 'ZAF';
    SELECT id INTO nigeria_id FROM countries WHERE code = 'NGA';
    SELECT id INTO kenya_id FROM countries WHERE code = 'KEN';
    SELECT id INTO uganda_id FROM countries WHERE code = 'UGA';
    SELECT id INTO tanzania_id FROM countries WHERE code = 'TZA';

    -- Rwanda Cities
    IF rwanda_id IS NOT NULL THEN
        INSERT INTO cities (country_id, name, slug, timezone, is_active) VALUES
        (rwanda_id, 'Kigali', 'kigali', 'Africa/Kigali', true),
        (rwanda_id, 'Butare', 'butare', 'Africa/Kigali', true),
        (rwanda_id, 'Gitarama', 'gitarama', 'Africa/Kigali', true),
        (rwanda_id, 'Ruhengeri', 'ruhengeri', 'Africa/Kigali', true),
        (rwanda_id, 'Gisenyi', 'gisenyi', 'Africa/Kigali', true),
        (rwanda_id, 'Byumba', 'byumba', 'Africa/Kigali', true),
        (rwanda_id, 'Cyangugu', 'cyangugu', 'Africa/Kigali', true),
        (rwanda_id, 'Kibungo', 'kibungo', 'Africa/Kigali', true),
        (rwanda_id, 'Kibuye', 'kibuye', 'Africa/Kigali', true),
        (rwanda_id, 'Huye', 'huye', 'Africa/Kigali', true),
        (rwanda_id, 'Rusizi', 'rusizi', 'Africa/Kigali', true),
        (rwanda_id, 'Nyagatare', 'nyagatare', 'Africa/Kigali', true),
        (rwanda_id, 'Musanze', 'musanze', 'Africa/Kigali', true),
        (rwanda_id, 'Rubavu', 'rubavu', 'Africa/Kigali', true),
        (rwanda_id, 'Nyamagabe', 'nyamagabe', 'Africa/Kigali', true),
        (rwanda_id, 'Nyanza', 'nyanza', 'Africa/Kigali', true),
        (rwanda_id, 'Ruhango', 'ruhango', 'Africa/Kigali', true),
        (rwanda_id, 'Muhanga', 'muhanga', 'Africa/Kigali', true),
        (rwanda_id, 'Kamonyi', 'kamonyi', 'Africa/Kigali', true),
        (rwanda_id, 'Karongi', 'karongi', 'Africa/Kigali', true)
        ON CONFLICT (country_id, slug) DO UPDATE SET is_active = true;
    END IF;

    -- South Africa Cities
    IF south_africa_id IS NOT NULL THEN
        INSERT INTO cities (country_id, name, slug, timezone, is_active) VALUES
        (south_africa_id, 'Johannesburg', 'johannesburg', 'Africa/Johannesburg', true),
        (south_africa_id, 'Cape Town', 'cape-town', 'Africa/Johannesburg', true),
        (south_africa_id, 'Durban', 'durban', 'Africa/Johannesburg', true),
        (south_africa_id, 'Pretoria', 'pretoria', 'Africa/Johannesburg', true),
        (south_africa_id, 'Port Elizabeth', 'port-elizabeth', 'Africa/Johannesburg', true),
        (south_africa_id, 'Bloemfontein', 'bloemfontein', 'Africa/Johannesburg', true),
        (south_africa_id, 'East London', 'east-london', 'Africa/Johannesburg', true),
        (south_africa_id, 'Polokwane', 'polokwane', 'Africa/Johannesburg', true),
        (south_africa_id, 'Nelspruit', 'nelspruit', 'Africa/Johannesburg', true),
        (south_africa_id, 'Kimberley', 'kimberley', 'Africa/Johannesburg', true),
        (south_africa_id, 'Rustenburg', 'rustenburg', 'Africa/Johannesburg', true),
        (south_africa_id, 'Welkom', 'welkom', 'Africa/Johannesburg', true),
        (south_africa_id, 'Pietermaritzburg', 'pietermaritzburg', 'Africa/Johannesburg', true),
        (south_africa_id, 'Benoni', 'benoni', 'Africa/Johannesburg', true),
        (south_africa_id, 'Tembisa', 'tembisa', 'Africa/Johannesburg', true),
        (south_africa_id, 'Vereeniging', 'vereeniging', 'Africa/Johannesburg', true),
        (south_africa_id, 'Boksburg', 'boksburg', 'Africa/Johannesburg', true),
        (south_africa_id, 'Soweto', 'soweto', 'Africa/Johannesburg', true),
        (south_africa_id, 'Sandton', 'sandton', 'Africa/Johannesburg', true),
        (south_africa_id, 'Centurion', 'centurion', 'Africa/Johannesburg', true)
        ON CONFLICT (country_id, slug) DO UPDATE SET is_active = true;
    END IF;

    -- Nigeria Cities
    IF nigeria_id IS NOT NULL THEN
        INSERT INTO cities (country_id, name, slug, timezone, is_active) VALUES
        (nigeria_id, 'Lagos', 'lagos', 'Africa/Lagos', true),
        (nigeria_id, 'Kano', 'kano', 'Africa/Lagos', true),
        (nigeria_id, 'Ibadan', 'ibadan', 'Africa/Lagos', true),
        (nigeria_id, 'Abuja', 'abuja', 'Africa/Lagos', true),
        (nigeria_id, 'Port Harcourt', 'port-harcourt', 'Africa/Lagos', true),
        (nigeria_id, 'Benin City', 'benin-city', 'Africa/Lagos', true),
        (nigeria_id, 'Kaduna', 'kaduna', 'Africa/Lagos', true),
        (nigeria_id, 'Aba', 'aba', 'Africa/Lagos', true),
        (nigeria_id, 'Maiduguri', 'maiduguri', 'Africa/Lagos', true),
        (nigeria_id, 'Ilorin', 'ilorin', 'Africa/Lagos', true),
        (nigeria_id, 'Warri', 'warri', 'Africa/Lagos', true),
        (nigeria_id, 'Onitsha', 'onitsha', 'Africa/Lagos', true),
        (nigeria_id, 'Abeokuta', 'abeokuta', 'Africa/Lagos', true),
        (nigeria_id, 'Enugu', 'enugu', 'Africa/Lagos', true),
        (nigeria_id, 'Zaria', 'zaria', 'Africa/Lagos', true),
        (nigeria_id, 'Jos', 'jos', 'Africa/Lagos', true),
        (nigeria_id, 'Calabar', 'calabar', 'Africa/Lagos', true),
        (nigeria_id, 'Uyo', 'uyo', 'Africa/Lagos', true),
        (nigeria_id, 'Akure', 'akure', 'Africa/Lagos', true),
        (nigeria_id, 'Owerri', 'owerri', 'Africa/Lagos', true)
        ON CONFLICT (country_id, slug) DO UPDATE SET is_active = true;
    END IF;

    -- Kenya Cities
    IF kenya_id IS NOT NULL THEN
        INSERT INTO cities (country_id, name, slug, timezone, is_active) VALUES
        (kenya_id, 'Nairobi', 'nairobi', 'Africa/Nairobi', true),
        (kenya_id, 'Mombasa', 'mombasa', 'Africa/Nairobi', true),
        (kenya_id, 'Kisumu', 'kisumu', 'Africa/Nairobi', true),
        (kenya_id, 'Nakuru', 'nakuru', 'Africa/Nairobi', true),
        (kenya_id, 'Eldoret', 'eldoret', 'Africa/Nairobi', true),
        (kenya_id, 'Thika', 'thika', 'Africa/Nairobi', true),
        (kenya_id, 'Malindi', 'malindi', 'Africa/Nairobi', true),
        (kenya_id, 'Kitale', 'kitale', 'Africa/Nairobi', true),
        (kenya_id, 'Garissa', 'garissa', 'Africa/Nairobi', true),
        (kenya_id, 'Kakamega', 'kakamega', 'Africa/Nairobi', true)
        ON CONFLICT (country_id, slug) DO UPDATE SET is_active = true;
    END IF;

    -- Uganda Cities
    IF uganda_id IS NOT NULL THEN
        INSERT INTO cities (country_id, name, slug, timezone, is_active) VALUES
        (uganda_id, 'Kampala', 'kampala', 'Africa/Kampala', true),
        (uganda_id, 'Gulu', 'gulu', 'Africa/Kampala', true),
        (uganda_id, 'Lira', 'lira', 'Africa/Kampala', true),
        (uganda_id, 'Mbarara', 'mbarara', 'Africa/Kampala', true),
        (uganda_id, 'Jinja', 'jinja', 'Africa/Kampala', true),
        (uganda_id, 'Mbale', 'mbale', 'Africa/Kampala', true),
        (uganda_id, 'Mukono', 'mukono', 'Africa/Kampala', true),
        (uganda_id, 'Masaka', 'masaka', 'Africa/Kampala', true),
        (uganda_id, 'Entebbe', 'entebbe', 'Africa/Kampala', true),
        (uganda_id, 'Arua', 'arua', 'Africa/Kampala', true)
        ON CONFLICT (country_id, slug) DO UPDATE SET is_active = true;
    END IF;

    -- Tanzania Cities
    IF tanzania_id IS NOT NULL THEN
        INSERT INTO cities (country_id, name, slug, timezone, is_active) VALUES
        (tanzania_id, 'Dar es Salaam', 'dar-es-salaam', 'Africa/Dar_es_Salaam', true),
        (tanzania_id, 'Dodoma', 'dodoma', 'Africa/Dar_es_Salaam', true),
        (tanzania_id, 'Mwanza', 'mwanza', 'Africa/Dar_es_Salaam', true),
        (tanzania_id, 'Arusha', 'arusha', 'Africa/Dar_es_Salaam', true),
        (tanzania_id, 'Mbeya', 'mbeya', 'Africa/Dar_es_Salaam', true),
        (tanzania_id, 'Morogoro', 'morogoro', 'Africa/Dar_es_Salaam', true),
        (tanzania_id, 'Tanga', 'tanga', 'Africa/Dar_es_Salaam', true),
        (tanzania_id, 'Zanzibar', 'zanzibar', 'Africa/Dar_es_Salaam', true),
        (tanzania_id, 'Kigoma', 'kigoma', 'Africa/Dar_es_Salaam', true),
        (tanzania_id, 'Mtwara', 'mtwara', 'Africa/Dar_es_Salaam', true)
        ON CONFLICT (country_id, slug) DO UPDATE SET is_active = true;
    END IF;
END $$;

