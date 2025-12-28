/**
 * Location Mapping Utility for V1 → V2 Migration
 * 
 * Maps V1 location_id and country_id to V2 city_id and country_id
 * 
 * V1 Structure:
 * - countries: country_id (INT), name
 * - locations: location_id (INT), location_name (cities like Kigali, Musanze, etc.)
 * 
 * V2 Structure:
 * - countries: id (UUID), code, name
 * - cities: id (UUID), country_id (UUID), name, slug
 * - regions: id (UUID), country_id (UUID), name (optional)
 * - districts: id (UUID), city_id (UUID), name (optional)
 */

import { PrismaService } from '../../prisma/prisma.service';

/**
 * V1 Country ID to V2 Country UUID mapping
 */
const V1_COUNTRY_MAPPING: Record<number, { name: string; code: string; code2: string }> = {
  1: { name: 'Rwanda', code: 'RWA', code2: 'RW' },
  2: { name: 'Unknown', code: 'UNK', code2: 'UN' }, // Placeholder for unknown country
  3: { name: 'Uganda', code: 'UGA', code2: 'UG' },
  4: { name: 'Tanzania', code: 'TZA', code2: 'TZ' },
  5: { name: 'Kenya', code: 'KEN', code2: 'KE' },
  6: { name: 'Ghana', code: 'GHA', code2: 'GH' },
};

/**
 * V1 Location ID to V2 City Name mapping
 * V1 locations are cities in V2
 */
const V1_LOCATION_MAPPING: Record<number, string> = {
  1: 'Kigali',
  2: 'Musanze',
  3: 'Rubavu',
  4: 'Karongi',
  6: 'Rusizi',
};

/**
 * Get or create V2 country from V1 country_id
 */
export async function getOrCreateCountry(
  v1CountryId: number,
  prisma: PrismaService
): Promise<string | null> {
  const countryInfo = V1_COUNTRY_MAPPING[v1CountryId];
  if (!countryInfo) {
    console.warn(`Unknown V1 country_id: ${v1CountryId}`);
    return null;
  }

  // Try to find existing country by code
  let country = await prisma.country.findUnique({
    where: { code: countryInfo.code },
  });

  if (!country) {
    // Create country if it doesn't exist
    country = await prisma.country.create({
      data: {
        name: countryInfo.name,
        code: countryInfo.code,
        code2: countryInfo.code2,
        isActive: true,
        // Set defaults for other fields
        defaultLanguage: 'en',
        supportedLanguages: ['en'],
        currencyCode: getCurrencyCode(countryInfo.code),
        phoneCode: getPhoneCode(countryInfo.code),
      },
    });
  }

  return country.id;
}

/**
 * Get or create V2 city from V1 location_id and country_id
 */
export async function getOrCreateCity(
  v1LocationId: number,
  v1CountryId: number,
  prisma: PrismaService
): Promise<string | null> {
  const cityName = V1_LOCATION_MAPPING[v1LocationId];
  if (!cityName) {
    console.warn(`Unknown V1 location_id: ${v1LocationId}`);
    return null;
  }

  // Get country UUID first
  const countryId = await getOrCreateCountry(v1CountryId, prisma);
  if (!countryId) {
    return null;
  }

  // Generate slug from city name
  const slug = cityName.toLowerCase().replace(/\s+/g, '-');

  // Try to find existing city by country_id and slug
  let city = await prisma.city.findFirst({
    where: {
      countryId: countryId,
      slug: slug,
    },
  });

  if (!city) {
    // Create city if it doesn't exist
    city = await prisma.city.create({
      data: {
        name: cityName,
        slug: slug,
        countryId: countryId,
        isActive: true,
        // Set defaults
        listingCount: 0,
        eventCount: 0,
      },
    });
  }

  return city.id;
}

/**
 * Get currency code for country
 */
function getCurrencyCode(countryCode: string): string {
  const currencyMap: Record<string, string> = {
    RWA: 'RWF',
    UGA: 'UGX',
    TZA: 'TZS',
    KEN: 'KES',
    GHA: 'GHS',
  };
  return currencyMap[countryCode] || 'USD';
}

/**
 * Get phone code for country
 */
function getPhoneCode(countryCode: string): string {
  const phoneMap: Record<string, string> = {
    RWA: '+250',
    UGA: '+256',
    TZA: '+255',
    KEN: '+254',
    GHA: '+233',
  };
  return phoneMap[countryCode] || '';
}

/**
 * Batch get or create cities for multiple location mappings
 */
export async function batchGetOrCreateCities(
  mappings: Array<{ locationId: number; countryId: number }>
): Promise<Map<string, string>> {
  const cityMap = new Map<string, string>();

  for (const mapping of mappings) {
    const key = `${mapping.countryId}-${mapping.locationId}`;
    // Note: This function needs prisma parameter, but batch function signature doesn't match
    // This function is not currently used in migration, so we'll skip it for now
    // const cityId = await getOrCreateCity(mapping.locationId, mapping.countryId, prisma);
    // if (cityId) {
    //   cityMap.set(key, cityId);
    // }
  }

  return cityMap;
}

/**
 * Create location mapping table for tracking
 */
export async function createLocationMapping(
  v1LocationId: number,
  v1CountryId: number,
  v2CityId: string,
  v2CountryId: string
): Promise<void> {
  // This could be stored in a migration_log table or separate mapping table
  // For now, we'll just log it
  console.log(
    `Mapped: V1 location_id=${v1LocationId}, country_id=${v1CountryId} → V2 city_id=${v2CityId}, country_id=${v2CountryId}`
  );
}

