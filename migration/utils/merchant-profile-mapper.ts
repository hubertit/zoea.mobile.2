/**
 * Merchant Profile Mapping Utility for V1 → V2 Migration
 * 
 * Handles the relationship:
 * - V1: User (1) → (many) Venues
 * - V2: User (1) → (many) MerchantProfiles (1) → (many) Listings
 * 
 * Strategy:
 * - Group venues by user_id
 * - Create merchant profiles for users with venues
 * - Each venue becomes a listing linked to a merchant profile
 * - If a user has multiple venues, we can create multiple merchant profiles
 *   OR group venues into a single merchant profile (configurable)
 */

import { PrismaService } from '../../prisma/prisma.service';

export interface VenueGroupingStrategy {
  /**
   * 'one_per_venue' - Create one merchant profile per venue
   * 'group_by_category' - Group venues by category into merchant profiles
   * 'single_per_user' - Create one merchant profile per user (all venues)
   */
  type: 'one_per_venue' | 'group_by_category' | 'single_per_user';
}

/**
 * Get or create merchant profile for a user and venue
 * 
 * Strategy options:
 * 1. one_per_venue: Each venue gets its own merchant profile
 * 2. group_by_category: Venues with same category share a merchant profile
 * 3. single_per_user: All venues for a user share one merchant profile
 */
export async function getOrCreateMerchantProfile(
  userId: string,
  venue: {
    venue_id: number;
    venue_name: string;
    category_id: number;
    venue_email?: string;
    venue_phone?: string;
    venue_website?: string;
    country_id: number;
    location_id: number;
  },
  strategy: VenueGroupingStrategy = { type: 'one_per_venue' },
  prisma: PrismaService
): Promise<string | null> {
  let merchantProfile = null;

  switch (strategy.type) {
    case 'one_per_venue':
      // Create one merchant profile per venue (most flexible)
      merchantProfile = await prisma.merchantProfile.findFirst({
        where: {
          userId: userId,
          businessName: venue.venue_name,
        },
      });

      if (!merchantProfile) {
        // Get country and city IDs
        const { getOrCreateCountry, getOrCreateCity } = await import('./location-mapper');
        const countryId = await getOrCreateCountry(venue.country_id, prisma);
        const cityId = await getOrCreateCity(venue.location_id, venue.country_id, prisma);

        // Truncate fields to fit database constraints
        const businessName = (venue.venue_name || `Business ${venue.venue_id}`).substring(0, 255);
        const businessEmail = venue.venue_email ? venue.venue_email.substring(0, 255) : null;
        const businessPhone = venue.venue_phone ? venue.venue_phone.substring(0, 20) : null;
        const website = venue.venue_website ? venue.venue_website.substring(0, 500) : null;
        
        merchantProfile = await prisma.merchantProfile.create({
          data: {
            userId: userId,
            businessName: businessName,
            businessEmail: businessEmail,
            businessPhone: businessPhone,
            website: website,
            countryId: countryId || null,
            cityId: cityId || null,
            registrationStatus: 'approved', // Auto-approve migrated merchants
            isVerified: true, // Mark as verified since they were active in V1
            submittedAt: new Date(),
            verifiedAt: new Date(),
          },
        });
      }
      break;

    case 'group_by_category':
      // Find existing merchant profile for this user and category
      merchantProfile = await prisma.merchantProfile.findFirst({
        where: {
          userId: userId,
          businessType: getBusinessTypeFromCategory(venue.category_id),
        },
      });

      if (!merchantProfile) {
        const { getOrCreateCountry, getOrCreateCity } = await import('./location-mapper');
        const countryId = await getOrCreateCountry(venue.country_id, prisma);
        const cityId = await getOrCreateCity(venue.location_id, venue.country_id, prisma);

        // Use first venue's details for the merchant profile
        // Truncate fields to fit database constraints
        const businessName = `${venue.venue_name || `Business ${venue.venue_id}`} (Business)`.substring(0, 255);
        const businessEmail = venue.venue_email ? venue.venue_email.substring(0, 255) : null;
        const businessPhone = venue.venue_phone ? venue.venue_phone.substring(0, 20) : null;
        
        merchantProfile = await prisma.merchantProfile.create({
          data: {
            userId: userId,
            businessName: businessName,
            businessType: getBusinessTypeFromCategory(venue.category_id),
            businessEmail: businessEmail,
            businessPhone: businessPhone,
            countryId: countryId || null,
            cityId: cityId || null,
            registrationStatus: 'approved',
            isVerified: true,
            submittedAt: new Date(),
            verifiedAt: new Date(),
          },
        });
      }
      break;

    case 'single_per_user':
      // Find or create single merchant profile for user
      merchantProfile = await prisma.merchantProfile.findFirst({
        where: {
          userId: userId,
        },
      });

      if (!merchantProfile) {
        // Use first venue's details or user's details
        const { getOrCreateCountry, getOrCreateCity } = await import('./location-mapper');
        const countryId = await getOrCreateCountry(venue.country_id, prisma);
        const cityId = await getOrCreateCity(venue.location_id, venue.country_id, prisma);

        merchantProfile = await prisma.merchantProfile.create({
          data: {
            userId: userId,
            businessName: venue.venue_name, // Or use user's name
            businessEmail: venue.venue_email || null,
            businessPhone: venue.venue_phone || null,
            countryId: countryId || null,
            cityId: cityId || null,
            registrationStatus: 'approved',
            isVerified: true,
            submittedAt: new Date(),
            verifiedAt: new Date(),
          },
        });
      }
      break;
  }

  return merchantProfile?.id || null;
}

/**
 * Get business type (listing_type) from V1 category_id
 * Maps V1 categories to V2 listing types
 */
function getBusinessTypeFromCategory(
  categoryId: number
): 'hotel' | 'restaurant' | 'tour' | 'attraction' | 'bar' | 'cafe' | 'fast_food' | 'lounge' | 'club' | null {
  // V1 Category ID to V2 Listing Type mapping
  // Based on V1 categories: 4=Accommodation, 5=Restaurants, 7=Take a coffee, 8=Nightlife, 18=Tour and Travel, etc.
  const categoryMap: Record<number, 'hotel' | 'restaurant' | 'tour' | 'attraction' | 'bar' | 'cafe' | 'fast_food' | 'lounge' | 'club'> = {
    4: 'hotel',           // Accommodation
    5: 'restaurant',      // Restaurants
    7: 'cafe',            // Take a coffee
    8: 'bar',             // Nightlife (default to bar)
    12: 'club',           // Night Clubs
    18: 'tour',           // Tour and Travel
    24: 'lounge',         // Lounges
    25: 'bar',            // Karaoke Bars
    26: 'bar',            // Bars
    27: 'bar',            // Wine Bars
    28: 'bar',            // Sports Bars
    29: 'bar',            // Cocktail Bars
    30: 'bar',            // Rooftop Bars
  };

  return categoryMap[categoryId] || null;
}

/**
 * Batch create merchant profiles for a user's venues
 * Groups venues and creates appropriate merchant profiles
 */
export async function batchCreateMerchantProfilesForUser(
  userId: string,
  venues: Array<{
    venue_id: number;
    venue_name: string;
    category_id: number;
    venue_email?: string;
    venue_phone?: string;
    venue_website?: string;
    country_id: number;
    location_id: number;
  }>,
  strategy: VenueGroupingStrategy = { type: 'one_per_venue' },
  prisma: PrismaService
): Promise<Map<number, string>> {
  // Map: venue_id → merchant_profile_id
  const venueToMerchantMap = new Map<number, string>();

  if (strategy.type === 'one_per_venue') {
    // Create one merchant profile per venue
    for (const venue of venues) {
      const merchantId = await getOrCreateMerchantProfile(userId, venue, strategy, prisma);
      if (merchantId) {
        venueToMerchantMap.set(venue.venue_id, merchantId);
      }
    }
  } else if (strategy.type === 'group_by_category') {
    // Group venues by category
    const venuesByCategory = new Map<number, typeof venues>();
    for (const venue of venues) {
      if (!venuesByCategory.has(venue.category_id)) {
        venuesByCategory.set(venue.category_id, []);
      }
      venuesByCategory.get(venue.category_id)!.push(venue);
    }

    // Create one merchant profile per category
    for (const [categoryId, categoryVenues] of venuesByCategory) {
      const firstVenue = categoryVenues[0];
      const merchantId = await getOrCreateMerchantProfile(userId, firstVenue, strategy, prisma);
      if (merchantId) {
        // Link all venues in this category to this merchant profile
        for (const venue of categoryVenues) {
          venueToMerchantMap.set(venue.venue_id, merchantId);
        }
      }
    }
  } else {
    // single_per_user: Create one merchant profile for all venues
    if (venues.length > 0) {
      const firstVenue = venues[0];
      const merchantId = await getOrCreateMerchantProfile(userId, firstVenue, strategy, prisma);
      if (merchantId) {
        // Link all venues to this merchant profile
        for (const venue of venues) {
          venueToMerchantMap.set(venue.venue_id, merchantId);
        }
      }
    }
  }

  return venueToMerchantMap;
}

