/**
 * Check Shopping Listings Migration
 * 
 * This script checks:
 * 1. V1 shopping category IDs
 * 2. V1 venues in shopping categories
 * 3. V2 listings that should be in shopping category
 * 
 * Run: ts-node src/migration/check-shopping-listings.ts
 */

import { NestFactory } from '@nestjs/core';
import { AppModule } from '../app.module';
import { PrismaService } from '../prisma/prisma.service';
import * as mysql from 'mysql2/promise';
import { Logger } from '@nestjs/common';

async function bootstrap() {
  const app = await NestFactory.createApplicationContext(AppModule);
  const prisma = app.get(PrismaService);
  const logger = new Logger('CheckShoppingListings');

  // V1 Database Configuration
  const v1Config = {
    host: process.env.V1_DB_HOST || 'localhost',
    port: parseInt(process.env.V1_DB_PORT || '3306', 10),
    user: process.env.V1_DB_USER || 'root',
    password: process.env.V1_DB_PASSWORD || 'mysql',
    database: process.env.V1_DB_NAME || 'zoea',
  };

  logger.log('🔍 Checking Shopping Listings Migration...');
  logger.log('');

  let v1Connection: mysql.Connection | null = null;

  try {
    // Connect to V1 database
    v1Connection = await mysql.createConnection(v1Config);
    logger.log('✅ Connected to V1 database');

    // Check V1 categories for shopping-related ones
    logger.log('📋 Checking V1 categories...');
    const [categories] = await v1Connection.execute(
      `SELECT category_id, category_name 
       FROM categories 
       WHERE category_name LIKE '%shop%' 
          OR category_name LIKE '%mall%' 
          OR category_name LIKE '%market%' 
          OR category_name LIKE '%boutique%' 
          OR category_name LIKE '%store%'
          OR category_name LIKE '%retail%'
       ORDER BY category_id`
    );
    
    const shoppingCategories = categories as Array<{ category_id: number; category_name: string }>;
    logger.log(`Found ${shoppingCategories.length} shopping-related categories in V1:`);
    shoppingCategories.forEach(cat => {
      logger.log(`  - Category ${cat.category_id}: ${cat.category_name}`);
    });
    logger.log('');

    if (shoppingCategories.length === 0) {
      // Check all categories to see what exists
      const [allCategories] = await v1Connection.execute(
        'SELECT category_id, category_name FROM categories ORDER BY category_id'
      );
      logger.log('📋 All V1 categories:');
      (allCategories as Array<{ category_id: number; category_name: string }>).forEach(cat => {
        logger.log(`  - Category ${cat.category_id}: ${cat.category_name}`);
      });
      logger.log('');
    }

    // Check V1 venues in shopping categories
    if (shoppingCategories.length > 0) {
      const categoryIds = shoppingCategories.map(c => c.category_id);
      const placeholders = categoryIds.map(() => '?').join(',');
      
      const [venues] = await v1Connection.execute(
        `SELECT v.venue_id, v.venue_name, v.category_id, c.category_name 
         FROM venues v 
         LEFT JOIN categories c ON v.category_id = c.category_id 
         WHERE v.category_id IN (${placeholders})
         ORDER BY v.category_id, v.venue_name
         LIMIT 50`,
        categoryIds
      );
      
      const shoppingVenues = venues as Array<{ venue_id: number; venue_name: string; category_id: number; category_name: string }>;
      logger.log(`📊 Found ${shoppingVenues.length} venues in shopping categories (showing first 50):`);
      shoppingVenues.forEach(venue => {
        logger.log(`  - Venue ${venue.venue_id}: ${venue.venue_name} (Category: ${venue.category_name})`);
      });
      logger.log('');

      // Check if these venues were migrated to V2
      const venueIds = shoppingVenues.map(v => v.venue_id);
      const v2Listings = await prisma.listing.findMany({
        where: {
          legacyId: { in: venueIds },
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

      logger.log(`📊 Found ${v2Listings.length} migrated listings from shopping venues:`);
      v2Listings.forEach(listing => {
        logger.log(`  - Listing ${listing.id}: ${listing.name} (legacyId: ${listing.legacyId}, type: ${listing.type}, categoryId: ${listing.categoryId})`);
      });
      logger.log('');

      // Check current shopping category in V2
      const shoppingCategory = await prisma.category.findUnique({
        where: { slug: 'shopping' },
        include: {
          _count: { select: { listings: true } },
        },
      });

      if (shoppingCategory) {
        logger.log(`📊 V2 Shopping Category:`);
        logger.log(`  - ID: ${shoppingCategory.id}`);
        logger.log(`  - Name: ${shoppingCategory.name}`);
        logger.log(`  - Slug: ${shoppingCategory.slug}`);
        logger.log(`  - Current Listings Count: ${shoppingCategory._count.listings}`);
        logger.log('');
      } else {
        logger.warn('⚠️  Shopping category not found in V2!');
        logger.log('');
      }

      // Check listings that should be in shopping but aren't
      const listingsNotInShopping = v2Listings.filter(
        listing => listing.categoryId !== shoppingCategory?.id
      );

      if (listingsNotInShopping.length > 0) {
        logger.log(`⚠️  Found ${listingsNotInShopping.length} listings from shopping venues that are NOT in shopping category:`);
        listingsNotInShopping.forEach(listing => {
          logger.log(`  - ${listing.name} (legacyId: ${listing.legacyId}, current categoryId: ${listing.categoryId})`);
        });
      }
    }

    await app.close();
  } catch (error) {
    logger.error('❌ Error checking shopping listings:', error);
    await app.close();
    process.exit(1);
  } finally {
    if (v1Connection) {
      await v1Connection.end();
    }
  }
}

bootstrap();

