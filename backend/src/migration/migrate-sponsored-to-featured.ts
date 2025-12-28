/**
 * Migrate V1 Sponsored Listings to V2 Featured Listings
 * 
 * This script:
 * 1. Connects to V1 database
 * 2. Queries venues where sponsored > 0
 * 3. Matches them to V2 listings by legacyId
 * 4. Updates those listings to set isFeatured: true
 * 
 * Run: ts-node src/migration/migrate-sponsored-to-featured.ts
 */

import { NestFactory } from '@nestjs/core';
import { AppModule } from '../app.module';
import { PrismaService } from '../prisma/prisma.service';
import { Logger } from '@nestjs/common';
import * as mysql from 'mysql2/promise';

async function bootstrap() {
  const app = await NestFactory.createApplicationContext(AppModule);
  const prisma = app.get(PrismaService);
  const logger = new Logger('MigrateSponsoredToFeatured');

  // V1 Database Configuration
  const v1Config = {
    host: process.env.V1_DB_HOST || '172.16.40.61',
    port: parseInt(process.env.V1_DB_PORT || '3306', 10),
    user: process.env.V1_DB_USER || 'devsvknl_tarama',
    password: process.env.V1_DB_PASSWORD || 'Tarama@2024',
    database: process.env.V1_DB_NAME || 'devsvknl_tarama',
  };

  let v1Connection: mysql.Connection | null = null;

  try {
    logger.log('🚀 Starting Sponsored → Featured Migration...');
    logger.log(`Connecting to V1 database: ${v1Config.host}:${v1Config.port}/${v1Config.database}`);

    // Connect to V1 database
    v1Connection = await mysql.createConnection({
      host: v1Config.host,
      port: v1Config.port,
      user: v1Config.user,
      password: v1Config.password,
      database: v1Config.database,
    });

    logger.log('✅ Connected to V1 database');

    // Query V1 venues where sponsored > 0
    const [sponsoredVenues] = await v1Connection.execute(
      'SELECT venue_id, venue_name, sponsored FROM venues WHERE sponsored > 0 ORDER BY sponsored DESC, venue_id'
    ) as [any[], any];

    logger.log(`📊 Found ${sponsoredVenues.length} sponsored venues in V1`);

    if (sponsoredVenues.length === 0) {
      logger.warn('⚠️  No sponsored venues found in V1 database');
      await v1Connection.end();
      await app.close();
      process.exit(0);
    }

    // Log sponsored venues
    logger.log('\n📋 Sponsored Venues:');
    sponsoredVenues.forEach((venue: any) => {
      logger.log(`  - Venue ID: ${venue.venue_id}, Name: ${venue.venue_name}, Sponsored: ${venue.sponsored}`);
    });

    // Match to V2 listings and update
    let updated = 0;
    let notFound = 0;
    let alreadyFeatured = 0;

    for (const venue of sponsoredVenues) {
      try {
        // Find V2 listing by legacy_id using raw SQL (since it's not in Prisma schema)
        const listings = await prisma.$queryRaw<Array<{ id: string; name: string; is_featured: boolean }>>`
          SELECT id, name, is_featured
          FROM listings
          WHERE legacy_id = ${venue.venue_id}
          LIMIT 1
        `;

        if (!listings || listings.length === 0) {
          logger.warn(`⚠️  Listing not found for V1 venue ${venue.venue_id} (${venue.venue_name})`);
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

        logger.log(`✅ Updated listing ${listing.id} (${listing.name}) to featured`);
        updated++;
      } catch (error: any) {
        logger.error(`❌ Error processing venue ${venue.venue_id}: ${error.message}`);
      }
    }

    // Summary
    logger.log('\n📊 Migration Summary:');
    logger.log(`  Total sponsored venues in V1: ${sponsoredVenues.length}`);
    logger.log(`  ✅ Updated to featured: ${updated}`);
    logger.log(`  ℹ️  Already featured: ${alreadyFeatured}`);
    logger.log(`  ⚠️  Not found in V2: ${notFound}`);

    // Verify: Count featured listings in V2
    const featuredCount = await prisma.listing.count({
      where: {
        isFeatured: true,
        deletedAt: null,
      },
    });

    logger.log(`\n✨ Total featured listings in V2: ${featuredCount}`);

    await v1Connection.end();
    await app.close();
    logger.log('✅ Migration completed successfully');
    process.exit(0);
  } catch (error: any) {
    logger.error('❌ Migration failed:', error);
    if (v1Connection) {
      await v1Connection.end();
    }
    await app.close();
    process.exit(1);
  }
}

bootstrap();

