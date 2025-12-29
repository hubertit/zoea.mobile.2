/**
 * Verify Listing Categories Match V1
 * 
 * This script verifies that listings with legacyId are assigned to
 * categories that match their original V1 category assignments.
 * 
 * Run: ts-node src/migration/verify-listing-categories.ts
 */

import { NestFactory } from '@nestjs/core';
import { AppModule } from '../app.module';
import { PrismaService } from '../prisma/prisma.service';
import * as mysql from 'mysql2/promise';
import { Logger } from '@nestjs/common';

async function bootstrap() {
  const app = await NestFactory.createApplicationContext(AppModule);
  const prisma = app.get(PrismaService);
  const logger = new Logger('VerifyListingCategories');

  // V1 Database Configuration
  const v1Config = {
    host: process.env.V1_DB_HOST || 'localhost',
    port: parseInt(process.env.V1_DB_PORT || '3306', 10),
    user: process.env.V1_DB_USER || 'root',
    password: process.env.V1_DB_PASSWORD || 'mysql',
    database: process.env.V1_DB_NAME || 'zoea',
  };

  logger.log('🔍 Verifying Listing Categories Match V1...');
  logger.log('V1 Database:', v1Config.host, v1Config.database);
  logger.log('');

  let v1Connection: mysql.Connection | null = null;

  try {
    // Connect to V1 database
    v1Connection = await mysql.createConnection(v1Config);
    logger.log('✅ Connected to V1 database');

    // Get all V1 venues with their category_ids
    const [v1Venues] = await v1Connection.execute(
      'SELECT venue_id, category_id, venue_name FROM venues WHERE category_id IS NOT NULL AND category_id != 0'
    );
    const v1VenuesList = v1Venues as Array<{
      venue_id: number;
      category_id: number;
      venue_name: string;
    }>;

    logger.log(`📊 Found ${v1VenuesList.length} venues with categories in V1`);
    logger.log('');

    // Get all V2 categories with legacyId
    const v2Categories = await prisma.category.findMany({
      where: {
        legacyId: { not: null },
        isActive: true,
      },
      select: {
        id: true,
        name: true,
        slug: true,
        legacyId: true,
      },
    });

    // Create map: V1 category_id -> V2 category UUID (using legacyId)
    const v1CategoryIdToV2CategoryId = new Map<number, string>();
    for (const v2Cat of v2Categories) {
      if (v2Cat.legacyId !== null && v2Cat.legacyId !== undefined) {
        v1CategoryIdToV2CategoryId.set(v2Cat.legacyId, v2Cat.id);
      }
    }

    logger.log(`📊 Found ${v2Categories.length} V2 categories with legacyId`);
    logger.log(`📊 Built mapping for ${v1CategoryIdToV2CategoryId.size} categories`);
    logger.log('');

    // Get all V2 listings with legacyId
    const v2Listings = await prisma.listing.findMany({
      where: {
        legacyId: { not: null },
        deletedAt: null,
      },
      select: {
        id: true,
        legacyId: true,
        name: true,
        categoryId: true,
      },
    });

    logger.log(`📊 Found ${v2Listings.length} listings with legacyId in V2`);
    logger.log('');

    // Create map of legacyId -> category_id from V1 venues
    const legacyIdToV1CategoryId = new Map<number, number>();
    for (const venue of v1VenuesList) {
      legacyIdToV1CategoryId.set(venue.venue_id, venue.category_id);
    }

    let correct = 0;
    let incorrect = 0;
    let noV1Category = 0;
    let noMapping = 0;
    const incorrectListings: Array<{
      name: string;
      legacyId: number;
      v1CategoryId: number;
      currentV2CategoryId: string | null;
      correctV2CategoryId: string | null;
    }> = [];

    logger.log('🔄 Verifying listings...');
    logger.log('');

    for (const listing of v2Listings) {
      if (!listing.legacyId) continue;

      const v1CategoryId = legacyIdToV1CategoryId.get(listing.legacyId);
      
      if (!v1CategoryId) {
        noV1Category++;
        continue;
      }

      const correctV2CategoryId = v1CategoryIdToV2CategoryId.get(v1CategoryId);
      
      if (!correctV2CategoryId) {
        noMapping++;
        continue;
      }

      if (listing.categoryId === correctV2CategoryId) {
        correct++;
      } else {
        incorrect++;
        incorrectListings.push({
          name: listing.name || 'Unknown',
          legacyId: listing.legacyId,
          v1CategoryId: v1CategoryId,
          currentV2CategoryId: listing.categoryId,
          correctV2CategoryId: correctV2CategoryId,
        });
      }
    }

    logger.log('');
    logger.log('✅ Verification Complete!');
    logger.log(`  Correct: ${correct} listings`);
    logger.log(`  Incorrect: ${incorrect} listings`);
    logger.log(`  No V1 category: ${noV1Category} listings`);
    logger.log(`  No mapping: ${noMapping} listings`);
    logger.log('');

    if (incorrect > 0) {
      logger.log(`❌ Found ${incorrect} listings with incorrect categories:`);
      incorrectListings.slice(0, 20).forEach(listing => {
        logger.log(`  - ${listing.name} (legacyId: ${listing.legacyId}, V1 category: ${listing.v1CategoryId})`);
      });
      if (incorrectListings.length > 20) {
        logger.log(`  ... and ${incorrectListings.length - 20} more`);
      }
      logger.log('');
      logger.log('💡 Run restore-original-categories.ts to fix these listings');
    } else {
      logger.log('✅ All listings are correctly assigned to their original V1 categories!');
    }

    await v1Connection.end();
    await app.close();
    process.exit(0);
  } catch (error) {
    logger.error('❌ Verification failed:', error);
    if (v1Connection) {
      await v1Connection.end();
    }
    await app.close();
    process.exit(1);
  }
}

bootstrap();

