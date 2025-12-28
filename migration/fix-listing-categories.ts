/**
 * Fix Listing Categories and Types
 * 
 * This script updates existing V2 listings with:
 * 1. type (listing_type enum) based on V1 category_id
 * 2. categoryId (UUID) based on the type mapping
 * 
 * Run: ts-node src/migration/fix-listing-categories.ts
 */

import { NestFactory } from '@nestjs/core';
import { AppModule } from '../app.module';
import { PrismaService } from '../prisma/prisma.service';
import * as mysql from 'mysql2/promise';

// V1 Category ID to V2 Listing Type mapping (expanded to cover all categories)
const categoryToTypeMap: Record<number, 'hotel' | 'restaurant' | 'tour' | 'attraction' | 'bar' | 'cafe' | 'fast_food' | 'lounge' | 'club' | 'mall' | 'market' | 'boutique' | null> = {
  4: 'hotel',           // Accommodation
  5: 'restaurant',      // Restaurants
  7: 'cafe',            // Take a coffee
  8: 'bar',             // Nightlife (default to bar)
  12: 'club',           // Night Clubs
  13: 'restaurant',     // Additional restaurant category
  16: 'restaurant',     // Additional restaurant category
  18: 'tour',           // Tour and Travel
  19: 'attraction',     // Attractions
  20: 'restaurant',     // Additional restaurant category
  21: 'boutique',       // Shopping (category 21 is Shopping in V1)
  24: 'lounge',         // Lounges
  25: 'bar',            // Karaoke Bars
  26: 'bar',            // Bars
  27: 'bar',            // Wine Bars
  28: 'bar',            // Sports Bars
  29: 'bar',            // Cocktail Bars
  30: 'bar',            // Rooftop Bars
  31: 'restaurant',     // Additional restaurant category
  32: 'restaurant',     // Additional restaurant category
  34: 'restaurant',     // Additional restaurant category
  38: 'restaurant',     // Additional restaurant category
  39: 'restaurant',     // Additional restaurant category
  43: 'restaurant',     // Additional restaurant category
  45: 'restaurant',     // Additional restaurant category
  47: 'restaurant',     // Additional restaurant category
  49: 'restaurant',     // Additional restaurant category
  51: 'restaurant',     // Additional restaurant category
  54: 'restaurant',     // Additional restaurant category
  55: 'restaurant',     // Additional restaurant category
  56: 'restaurant',     // Additional restaurant category
  60: 'restaurant',     // Additional restaurant category
  61: 'restaurant',     // Additional restaurant category
  62: 'restaurant',     // Additional restaurant category
  63: 'restaurant',     // Additional restaurant category
  64: 'restaurant',     // Additional restaurant category
  65: 'restaurant',     // Additional restaurant category
  66: 'restaurant',     // Additional restaurant category
  68: 'restaurant',     // Additional restaurant category
  69: 'restaurant',     // Additional restaurant category
  70: 'restaurant',     // Additional restaurant category
  71: 'restaurant',     // Additional restaurant category
  72: 'restaurant',     // Additional restaurant category
  77: 'restaurant',     // Additional restaurant category
  78: 'restaurant',     // Additional restaurant category
  79: 'attraction',     // Attractions/Entertainment
};

// V2 Type to Category UUID mapping
const typeToCategoryMap: Record<string, string> = {
  hotel: 'bd4d61fe-0db8-40d6-b76a-3578bfb2e8e3',           // Hotels & Resorts → Accommodation
  restaurant: '17592625-d465-4039-b168-6369251eaa9b',     // Restaurants & Cafes → Dining
  cafe: '17592625-d465-4039-b168-6369251eaa9b',            // Restaurants & Cafes → Dining
  bar: 'e7a3ccf5-1e2c-4d50-9ff3-9b145f294f3d',             // Bars & Nightlife → Nightlife
  club: 'e7a3ccf5-1e2c-4d50-9ff3-9b145f294f3d',            // Bars & Nightlife → Nightlife
  lounge: 'e7a3ccf5-1e2c-4d50-9ff3-9b145f294f3d',          // Bars & Nightlife → Nightlife
  tour: '7189f215-1aef-4dba-b92c-05cdde123ff3',            // Tours & Experiences → Experiences
  attraction: '29cca857-0675-40fe-a0d1-38fd181fa3f8',      // Attractions
  fast_food: '17592625-d465-4039-b168-6369251eaa9b',       // Restaurants & Cafes → Dining
  mall: 'b8d1cafd-c113-42d8-9d00-7eb06ff357fd',            // Shopping
  market: 'b8d1cafd-c113-42d8-9d00-7eb06ff357fd',          // Shopping
  boutique: 'b8d1cafd-c113-42d8-9d00-7eb06ff357fd',        // Shopping
};

// For listings that can't be mapped, default to Dining category (most common)
// Attractions should remain empty for manual population
const DEFAULT_CATEGORY_ID = '17592625-d465-4039-b168-6369251eaa9b'; // Dining

async function bootstrap() {
  const app = await NestFactory.createApplicationContext(AppModule);
  const prisma = app.get(PrismaService);

  // V1 Database Configuration
  const v1Config = {
    host: process.env.V1_DB_HOST || 'localhost',
    port: parseInt(process.env.V1_DB_PORT || '3306', 10),
    user: process.env.V1_DB_USER || 'root',
    password: process.env.V1_DB_PASSWORD || 'mysql',
    database: process.env.V1_DB_NAME || 'zoea',
  };

  console.log('🔧 Starting Listing Category Fix...');
  console.log('V1 Database:', v1Config.host, v1Config.database);
  console.log('');

  let v1Connection: mysql.Connection | null = null;

  try {
    // Connect to V1 database
    v1Connection = await mysql.createConnection(v1Config);
    console.log('✅ Connected to V1 database');

    // Get all venues from V1 (including those with category_id = 0 or null for name-based inference)
    const [venues] = await v1Connection.execute(
      'SELECT venue_id, category_id, venue_name FROM venues'
    );
    const v1Venues = venues as Array<{ venue_id: number; category_id: number | null; venue_name: string }>;
    console.log(`📊 Found ${v1Venues.length} total venues in V1`);

    // Get all listings from V2 with legacyId
    const v2Listings = await prisma.listing.findMany({
      where: {
        legacyId: { not: null },
        deletedAt: null,
      },
      select: {
        id: true,
        legacyId: true,
        name: true,
        type: true,
        categoryId: true,
      },
    });
    console.log(`📊 Found ${v2Listings.length} listings with legacyId in V2`);
    console.log('');

    // Create a map of legacyId -> category_id and venue_name
    const legacyIdToCategory = new Map<number, number | null>();
    const legacyIdToName = new Map<number, string>();
    for (const venue of v1Venues) {
      legacyIdToCategory.set(venue.venue_id, venue.category_id);
      legacyIdToName.set(venue.venue_id, venue.venue_name);
    }

    let updated = 0;
    let skipped = 0;
    let errors = 0;

    console.log('🔄 Updating listings...');
    console.log('');

    for (const listing of v2Listings) {
      try {
        let v1CategoryId: number | null | undefined = null;
        let v1VenueName = listing.name || '';
        
        if (listing.legacyId) {
          v1CategoryId = legacyIdToCategory.get(listing.legacyId) ?? null;
          v1VenueName = legacyIdToName.get(listing.legacyId) || listing.name || '';
        }
        
        // Map V1 category_id to V2 type (if category_id exists and is not 0)
        let v2Type = v1CategoryId && v1CategoryId !== 0 ? categoryToTypeMap[v1CategoryId] : null;
        
        // If listing already has a type but no categoryId, use the existing type
        if (!v2Type && listing.type) {
          v2Type = listing.type as any;
        }
        
        // If not in mapping or category_id is 0/null, try to infer from venue name
        if (!v2Type) {
          const venueName = v1VenueName.toLowerCase() || listing.name?.toLowerCase() || '';
          
          // Restaurant patterns
          if (venueName.includes('restaurant') || venueName.includes('resto') || 
              venueName.includes('dining') || venueName.includes('bistro') ||
              venueName.includes('kitchen') || venueName.includes('food') ||
              venueName.includes('curry') || venueName.includes('khana') ||
              venueName.includes('italian') || venueName.includes('pizza') ||
              venueName.includes('grill') || venueName.includes('steak')) {
            v2Type = 'restaurant';
          } 
          // Cafe patterns
          else if (venueName.includes('cafe') || venueName.includes('coffee') || 
                   venueName.includes('café') || venueName.includes('espresso') ||
                   venueName.includes('tea') || venueName.includes('brew')) {
            v2Type = 'cafe';
          } 
          // Hotel patterns
          else if (venueName.includes('hotel') || venueName.includes('resort') || 
                   venueName.includes('lodge') || venueName.includes('accommodation') ||
                   venueName.includes('guest house') || venueName.includes('apartment') ||
                   venueName.includes('residence') || venueName.includes('inn')) {
            v2Type = 'hotel';
          } 
          // Bar/Nightlife patterns
          else if (venueName.includes('bar') || venueName.includes('pub') || 
                   venueName.includes('lounge') || venueName.includes('nightlife') ||
                   venueName.includes('club') || venueName.includes('wine bar') ||
                   venueName.includes('cocktail')) {
            v2Type = 'bar';
          } 
          // Tour patterns
          else if (venueName.includes('tour') || venueName.includes('safari') || 
                   venueName.includes('travel') || venueName.includes('adventure') ||
                   venueName.includes('gorilla') || venueName.includes('primate')) {
            v2Type = 'tour';
          } 
          // Shopping patterns
          else if (venueName.includes('mall') || venueName.includes('shopping mall') || 
                   venueName.includes('shopping center') || venueName.includes('shopping complex')) {
            v2Type = 'mall';
          }
          else if (venueName.includes('market') || venueName.includes('souk') || 
                   venueName.includes('bazaar')) {
            v2Type = 'market';
          }
          else if ((venueName.includes('boutique') && !venueName.includes('hotel')) || 
                   venueName.includes('store') || venueName.includes('shop') ||
                   venueName.includes('retail')) {
            v2Type = 'boutique';
          }
          // Attraction patterns (default for everything else)
          else {
            v2Type = 'attraction';
          }
        }
        
        if (!v2Type) {
          skipped++;
          continue;
        }

        // Map type to categoryId (use default if not found)
        const categoryId = typeToCategoryMap[v2Type] || DEFAULT_CATEGORY_ID;

        // Always update if type or categoryId is missing, even if partially set
        const needsUpdate = listing.type !== v2Type || listing.categoryId !== categoryId;
        if (!needsUpdate) {
          skipped++;
          continue;
        }

        // Update the listing
        await prisma.listing.update({
          where: { id: listing.id },
          data: {
            type: v2Type as any,
            categoryId: categoryId,
          },
        });

        updated++;
        if (updated % 50 === 0) {
          console.log(`  ✅ Updated ${updated} listings...`);
        }
      } catch (error: any) {
        errors++;
        console.error(`  ❌ Error updating listing ${listing.id} (legacyId: ${listing.legacyId}):`, error.message);
      }
    }

    console.log('');
    console.log('✅ Fix Complete!');
    console.log(`  Updated: ${updated} listings`);
    console.log(`  Skipped: ${skipped} listings (no category mapping or already correct)`);
    console.log(`  Errors: ${errors} listings`);

    await v1Connection.end();
    await app.close();
    process.exit(0);
  } catch (error) {
    console.error('❌ Fix failed:', error);
    if (v1Connection) {
      await v1Connection.end();
    }
    await app.close();
    process.exit(1);
  }
}

bootstrap();

