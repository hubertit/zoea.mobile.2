/**
 * Migrate Specific Sponsored Venues to V2 Featured Listings
 * 
 * This script migrates specific V1 venue IDs (from exported SQL) to V2 featured listings.
 * 
 * Run: ts-node src/migration/migrate-specific-sponsored-venues.ts
 */

import { NestFactory } from '@nestjs/core';
import { AppModule } from '../app.module';
import { PrismaService } from '../prisma/prisma.service';
import { Logger } from '@nestjs/common';

async function bootstrap() {
  const app = await NestFactory.createApplicationContext(AppModule);
  const prisma = app.get(PrismaService);
  const logger = new Logger('MigrateSponsoredVenues');

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

  try {
    logger.log('🚀 Starting Sponsored → Featured Migration...');
    logger.log(`📋 Migrating ${sponsoredVenueIds.length} sponsored venues to featured listings\n`);

    let updated = 0;
    let notFound = 0;
    let alreadyFeatured = 0;

    for (const venueId of sponsoredVenueIds) {
      try {
        // Find V2 listing by legacy_id using raw SQL (since it's not in Prisma schema)
        const listings = await prisma.$queryRaw<Array<{ id: string; name: string; is_featured: boolean }>>`
          SELECT id, name, is_featured
          FROM listings
          WHERE legacy_id = ${venueId}
          LIMIT 1
        `;

        if (!listings || listings.length === 0) {
          logger.warn(`⚠️  Listing not found for V1 venue ${venueId}`);
          notFound++;
          continue;
        }

        const listing = listings[0];

        // Check if already featured
        if (listing.is_featured) {
          logger.log(`ℹ️  Listing ${listing.id} (${listing.name}) is already featured`);
          alreadyFeatured++;
          continue;
        }

        // Update listing to featured using raw SQL
        await prisma.$executeRaw`
          UPDATE listings
          SET is_featured = true, updated_at = NOW()
          WHERE id = ${listing.id}::uuid
        `;

        logger.log(`✅ Updated listing ${listing.id} (${listing.name || 'N/A'}) to featured`);
        updated++;
      } catch (error: any) {
        logger.error(`❌ Error processing venue ${venueId}: ${error.message}`);
      }
    }

    // Summary
    logger.log('\n📊 Migration Summary:');
    logger.log(`  Total sponsored venues: ${sponsoredVenueIds.length}`);
    logger.log(`  ✅ Updated to featured: ${updated}`);
    logger.log(`  ℹ️  Already featured: ${alreadyFeatured}`);
    logger.log(`  ⚠️  Not found in V2: ${notFound}`);

    // Verify: Count featured listings in V2
    const featuredCount = await prisma.$queryRaw<Array<{ count: bigint }>>`
      SELECT COUNT(*) as count
      FROM listings
      WHERE is_featured = true AND deleted_at IS NULL
    `;

    logger.log(`\n✨ Total featured listings in V2: ${featuredCount[0]?.count || 0}`);

    await app.close();
    logger.log('✅ Migration completed successfully');
    process.exit(0);
  } catch (error: any) {
    logger.error('❌ Migration failed:', error);
    await app.close();
    process.exit(1);
  }
}

bootstrap();

