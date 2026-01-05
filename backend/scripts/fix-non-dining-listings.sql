-- Fix Non-Dining Listings that are incorrectly in Dining category
-- This fixes banks, ATMs, churches, hospitals, salons, etc that shouldn't be restaurants

-- Get category IDs
DO $$
DECLARE
    services_category_id UUID;
    banking_category_id UUID;
    emergency_services_category_id UUID;
    medical_services_category_id UUID;
    health_wellness_category_id UUID;
    govt_institutions_category_id UUID;
    embassies_category_id UUID;
    ministries_category_id UUID;
    religious_category_id UUID;
    churches_category_id UUID;
    temples_category_id UUID;
    police_category_id UUID;
    fire_category_id UUID;
    roadside_category_id UUID;
    shopping_category_id UUID;
    attractions_category_id UUID;
BEGIN
    -- Get main Services category
    SELECT id INTO services_category_id FROM categories WHERE slug = 'services' AND parent_id IS NULL;
    
    -- Get subcategories
    SELECT id INTO banking_category_id FROM categories WHERE slug = 'banking' LIMIT 1;
    SELECT id INTO emergency_services_category_id FROM categories WHERE slug = 'emergency-services' LIMIT 1;
    SELECT id INTO medical_services_category_id FROM categories WHERE slug = 'medical-services' LIMIT 1;
    SELECT id INTO health_wellness_category_id FROM categories WHERE slug = 'health-and-wellness' LIMIT 1;
    SELECT id INTO govt_institutions_category_id FROM categories WHERE slug = 'government-institutions' LIMIT 1;
    SELECT id INTO embassies_category_id FROM categories WHERE slug = 'embassies-and-consulates' LIMIT 1;
    SELECT id INTO ministries_category_id FROM categories WHERE slug = 'ministries' LIMIT 1;
    SELECT id INTO religious_category_id FROM categories WHERE slug = 'religious-institutions' AND parent_id IS NULL LIMIT 1;
    SELECT id INTO churches_category_id FROM categories WHERE slug = 'churches' LIMIT 1;
    SELECT id INTO temples_category_id FROM categories WHERE slug = 'temples' LIMIT 1;
    SELECT id INTO police_category_id FROM categories WHERE slug = 'police-stations' LIMIT 1;
    SELECT id INTO fire_category_id FROM categories WHERE slug = 'fire-stations' LIMIT 1;
    SELECT id INTO roadside_category_id FROM categories WHERE slug = 'road-side' LIMIT 1;
    SELECT id INTO shopping_category_id FROM categories WHERE slug = 'shopping' AND parent_id IS NULL LIMIT 1;
    SELECT id INTO attractions_category_id FROM categories WHERE slug = 'attractions' AND parent_id IS NULL LIMIT 1;

    RAISE NOTICE 'Moving banks and ATMs...';
    -- Fix Banks and ATMs
    UPDATE listings l
    SET category_id = COALESCE(banking_category_id, services_category_id),
        type = 'attraction',
        updated_at = NOW()
    FROM categories c
    LEFT JOIN categories pc ON c.parent_id = pc.id
    WHERE l.category_id = c.id
      AND ((c.slug = 'dining' AND c.parent_id IS NULL) OR pc.slug = 'dining')
      AND l.type = 'restaurant'
      AND (l.name ILIKE '%bank%' OR l.name ILIKE '%atm%');

    RAISE NOTICE 'Moving churches and temples...';
    -- Fix Churches
    UPDATE listings l
    SET category_id = COALESCE(churches_category_id, religious_category_id, services_category_id),
        type = 'attraction',
        updated_at = NOW()
    FROM categories c
    LEFT JOIN categories pc ON c.parent_id = pc.id
    WHERE l.category_id = c.id
      AND ((c.slug = 'dining' AND c.parent_id IS NULL) OR pc.slug = 'dining')
      AND l.type = 'restaurant'
      AND (l.name ILIKE '%church%' OR l.name ILIKE '%chapel%');

    -- Fix Temples
    UPDATE listings l
    SET category_id = COALESCE(temples_category_id, religious_category_id, services_category_id),
        type = 'attraction',
        updated_at = NOW()
    FROM categories c
    LEFT JOIN categories pc ON c.parent_id = pc.id
    WHERE l.category_id = c.id
      AND ((c.slug = 'dining' AND c.parent_id IS NULL) OR pc.slug = 'dining')
      AND l.type = 'restaurant'
      AND (l.name ILIKE '%temple%' OR l.name ILIKE '%mandal%');

    RAISE NOTICE 'Moving police stations...';
    -- Fix Police Stations
    UPDATE listings l
    SET category_id = COALESCE(police_category_id, emergency_services_category_id, services_category_id),
        type = 'attraction',
        updated_at = NOW()
    FROM categories c
    LEFT JOIN categories pc ON c.parent_id = pc.id
    WHERE l.category_id = c.id
      AND ((c.slug = 'dining' AND c.parent_id IS NULL) OR pc.slug = 'dining')
      AND l.type = 'restaurant'
      AND l.name ILIKE '%police%';

    RAISE NOTICE 'Moving hospitals and clinics...';
    -- Fix Hospitals and Medical Centers
    UPDATE listings l
    SET category_id = COALESCE(medical_services_category_id, health_wellness_category_id, services_category_id),
        type = 'attraction',
        updated_at = NOW()
    FROM categories c
    LEFT JOIN categories pc ON c.parent_id = pc.id
    WHERE l.category_id = c.id
      AND ((c.slug = 'dining' AND c.parent_id IS NULL) OR pc.slug = 'dining')
      AND l.type = 'restaurant'
      AND (l.name ILIKE '%hospital%' OR l.name ILIKE '%clinic%' OR l.name ILIKE '%medical%');

    RAISE NOTICE 'Moving salons...';
    -- Fix Salons
    UPDATE listings l
    SET category_id = COALESCE(health_wellness_category_id, services_category_id),
        type = 'attraction',
        updated_at = NOW()
    FROM categories c
    LEFT JOIN categories pc ON c.parent_id = pc.id
    WHERE l.category_id = c.id
      AND ((c.slug = 'dining' AND c.parent_id IS NULL) OR pc.slug = 'dining')
      AND l.type = 'restaurant'
      AND (l.name ILIKE '%salon%' OR l.name ILIKE '%spa%' OR l.name ILIKE '%hair%');

    RAISE NOTICE 'Moving embassies...';
    -- Fix Embassies
    UPDATE listings l
    SET category_id = COALESCE(embassies_category_id, govt_institutions_category_id, services_category_id),
        type = 'attraction',
        updated_at = NOW()
    FROM categories c
    LEFT JOIN categories pc ON c.parent_id = pc.id
    WHERE l.category_id = c.id
      AND ((c.slug = 'dining' AND c.parent_id IS NULL) OR pc.slug = 'dining')
      AND l.type = 'restaurant'
      AND l.name ILIKE '%embassy%';

    RAISE NOTICE 'Moving ministries...';
    -- Fix Ministries
    UPDATE listings l
    SET category_id = COALESCE(ministries_category_id, govt_institutions_category_id, services_category_id),
        type = 'attraction',
        updated_at = NOW()
    FROM categories c
    LEFT JOIN categories pc ON c.parent_id = pc.id
    WHERE l.category_id = c.id
      AND ((c.slug = 'dining' AND c.parent_id IS NULL) OR pc.slug = 'dining')
      AND l.type = 'restaurant'
      AND l.name ILIKE '%ministry%';

    RAISE NOTICE 'Moving garages...';
    -- Fix Garages
    UPDATE listings l
    SET category_id = COALESCE(roadside_category_id, services_category_id),
        type = 'attraction',
        updated_at = NOW()
    FROM categories c
    LEFT JOIN categories pc ON c.parent_id = pc.id
    WHERE l.category_id = c.id
      AND ((c.slug = 'dining' AND c.parent_id IS NULL) OR pc.slug = 'dining')
      AND l.type = 'restaurant'
      AND l.name ILIKE '%garage%';

    RAISE NOTICE 'Moving insurance companies...';
    -- Fix Insurance Companies
    UPDATE listings l
    SET category_id = COALESCE(banking_category_id, services_category_id),
        type = 'attraction',
        updated_at = NOW()
    FROM categories c
    LEFT JOIN categories pc ON c.parent_id = pc.id
    WHERE l.category_id = c.id
      AND ((c.slug = 'dining' AND c.parent_id IS NULL) OR pc.slug = 'dining')
      AND l.type = 'restaurant'
      AND l.name ILIKE '%insurance%';

    RAISE NOTICE 'Moving telecom companies...';
    -- Fix Telecom Companies
    UPDATE listings l
    SET category_id = services_category_id,
        type = 'attraction',
        updated_at = NOW()
    FROM categories c
    LEFT JOIN categories pc ON c.parent_id = pc.id
    WHERE l.category_id = c.id
      AND ((c.slug = 'dining' AND c.parent_id IS NULL) OR pc.slug = 'dining')
      AND l.type = 'restaurant'
      AND (l.name ILIKE '%airtel%' OR l.name ILIKE '%mtn%' OR l.name ILIKE '%telecom%');

    RAISE NOTICE 'Moving real estate...';
    -- Fix Real Estate
    UPDATE listings l
    SET category_id = services_category_id,
        type = 'attraction',
        updated_at = NOW()
    FROM categories c
    LEFT JOIN categories pc ON c.parent_id = pc.id
    WHERE l.category_id = c.id
      AND ((c.slug = 'dining' AND c.parent_id IS NULL) OR pc.slug = 'dining')
      AND l.type = 'restaurant'
      AND l.name ILIKE '%real estate%';

    RAISE NOTICE 'Moving galleries and craft markets...';
    -- Fix Galleries and Craft Markets
    UPDATE listings l
    SET category_id = COALESCE(shopping_category_id, attractions_category_id),
        type = 'attraction',
        updated_at = NOW()
    FROM categories c
    LEFT JOIN categories pc ON c.parent_id = pc.id
    WHERE l.category_id = c.id
      AND ((c.slug = 'dining' AND c.parent_id IS NULL) OR pc.slug = 'dining')
      AND l.type = 'restaurant'
      AND (l.name ILIKE '%gallery%' OR l.name ILIKE '%craft%' OR l.name ILIKE '%museum%');

    RAISE NOTICE 'Fix complete!';
END $$;

-- Verification: Check how many obvious non-restaurants are still in Dining
SELECT 
    'After Fix: Non-restaurants still in Dining' as status,
    COUNT(*) as count
FROM listings l
LEFT JOIN categories c ON l.category_id = c.id
LEFT JOIN categories pc ON c.parent_id = pc.id
WHERE ((c.slug = 'dining' AND c.parent_id IS NULL) OR pc.slug = 'dining')
  AND l.type = 'restaurant'
  AND (
    l.name ILIKE '%bank%' OR
    l.name ILIKE '%atm%' OR
    l.name ILIKE '%church%' OR
    l.name ILIKE '%temple%' OR
    l.name ILIKE '%police%' OR
    l.name ILIKE '%embassy%' OR
    l.name ILIKE '%ministry%' OR
    l.name ILIKE '%clinic%' OR
    l.name ILIKE '%medical%' OR
    l.name ILIKE '%hospital%' OR
    l.name ILIKE '%salon%' OR
    l.name ILIKE '%gallery%' OR
    l.name ILIKE '%garage%' OR
    l.name ILIKE '%insurance%' OR
    l.name ILIKE '%telecom%' OR
    l.name ILIKE '%airtel%' OR
    l.name ILIKE '%mtn%' OR
    l.name ILIKE '%real estate%' OR
    l.name ILIKE '%craft%'
  );

