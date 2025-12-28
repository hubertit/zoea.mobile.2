/**
 * Migrate Specific Sponsored Venues to V2 Featured Listings (Standalone)
 * 
 * This script migrates specific V1 venue IDs to V2 featured listings.
 * Uses Prisma directly without NestJS initialization.
 * 
 * Run: ts-node src/migration/migrate-sponsored-standalone.ts
 */

import { PrismaClient } from '@prisma/client';
import * as dotenv from 'dotenv';
import * as path from 'path';

// Load environment variables
dotenv.config({ path: path.join(__dirname, '../../.env') });

// Set DATABASE_URL if not already set (use default from env.example)
if (!process.env.DATABASE_URL) {
  process.env.DATABASE_URL = 'postgresql://admin:Zoea2025Secure@172.16.40.61:5432/main';
}

const prisma = new PrismaClient();

// Sponsored venue IDs from exported SQL file
const sponsoredVenueIds = [
  423,   // Caiman Gaucho Grill
  1111,  // Villa Kigali
  1112,  // A and M Car Rental Services
  1113,  // The Rock Cocktail Bar & Bistro
  1114,  // Spa by Villa Kigali
  1116,  // Y & T Burger - Wine
  1117,  // Flame Tree Restaurant
  1118,  // Select Boutique Restaurant
  1119,  // Kigali Marriott Hotel
  1120,  // Four Points by Sheraton Kigali
  1121,  // Steffi Metz Kigali
];

async function bootstrap() {
  try {
    console.log('🚀 Starting Sponsored → Featured Migration...');
    console.log(`📋 Migrating ${sponsoredVenueIds.length} sponsored venues to featured listings\n`);

    let updated = 0;
    let notFound = 0;
    let alreadyFeatured = 0;

    for (const venueId of sponsoredVenueIds) {
      try {
        // Find V2 listing by legacy_id using raw SQL
        const listings = await prisma.$queryRaw<Array<{ id: string; name: string; is_featured: boolean }>>`
          SELECT id, name, is_featured
          FROM listings
          WHERE legacy_id = ${venueId}
          LIMIT 1
        `;

        if (!listings || listings.length === 0) {
          console.log(`⚠️  Listing not found for V1 venue ${venueId}`);
          notFound++;
          continue;
        }

        const listing = listings[0];

        // Check if already featured
        if (listing.is_featured) {
          console.log(`ℹ️  Listing ${listing.id} (${listing.name || 'N/A'}) is already featured`);
          alreadyFeatured++;
          continue;
        }

        // Update listing to featured using raw SQL
        await prisma.$executeRaw`
          UPDATE listings
          SET is_featured = true, updated_at = NOW()
          WHERE id = ${listing.id}::uuid
        `;

        console.log(`✅ Updated listing ${listing.id} (${listing.name || 'N/A'}) to featured`);
        updated++;
      } catch (error: any) {
        console.error(`❌ Error processing venue ${venueId}: ${error.message}`);
      }
    }

    // Summary
    console.log('\n📊 Migration Summary:');
    console.log(`  Total sponsored venues: ${sponsoredVenueIds.length}`);
    console.log(`  ✅ Updated to featured: ${updated}`);
    console.log(`  ℹ️  Already featured: ${alreadyFeatured}`);
    console.log(`  ⚠️  Not found in V2: ${notFound}`);

    // Verify: Count featured listings in V2
    const featuredCount = await prisma.$queryRaw<Array<{ count: bigint }>>`
      SELECT COUNT(*) as count
      FROM listings
      WHERE is_featured = true AND deleted_at IS NULL
    `;

    console.log(`\n✨ Total featured listings in V2: ${featuredCount[0]?.count || 0}`);
    console.log('✅ Migration completed successfully');

    await prisma.$disconnect();
    process.exit(0);
  } catch (error: any) {
    console.error('❌ Migration failed:', error);
    await prisma.$disconnect();
    process.exit(1);
  }
}

bootstrap();

