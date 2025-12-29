/**
 * Fix Shopping Listings
 * 
 * This script:
 * 1. Finds V1 shopping category IDs
 * 2. Finds V1 venues in shopping categories
 * 3. Maps them to V2 listings by matching venue names
 * 4. Updates V2 listings to have correct type (mall, market, boutique) and shopping categoryId
 * 
 * Run: ts-node src/migration/fix-shopping-listings.ts
 */

import { NestFactory } from '@nestjs/core';
import { AppModule } from '../app.module';
import { PrismaService } from '../prisma/prisma.service';
import * as mysql from 'mysql2/promise';
import { Logger } from '@nestjs/common';
import { listing_type } from '@prisma/client';

async function bootstrap() {
  const app = await NestFactory.createApplicationContext(AppModule);
  const prisma = app.get(PrismaService);
  const logger = new Logger('FixShoppingListings');

  // V1 Database Configuration
  const v1Config = {
    host: process.env.V1_DB_HOST || 'localhost',
    port: parseInt(process.env.V1_DB_PORT || '3306', 10),
    user: process.env.V1_DB_USER || 'root',
    password: process.env.V1_DB_PASSWORD || 'mysql',
    database: process.env.V1_DB_NAME || 'zoea',
  };

  logger.log('🛍️  Fixing Shopping Listings...');
  logger.log('');

  let v1Connection: mysql.Connection | null = null;

  try {
    // Connect to V1 database
    v1Connection = await mysql.createConnection(v1Config);
    logger.log('✅ Connected to V1 database');

    // Get shopping category ID from V2
    const shoppingCategory = await prisma.category.findUnique({
      where: { slug: 'shopping' },
    });

    if (!shoppingCategory) {
      logger.error('❌ Shopping category not found in V2!');
      await app.close();
      process.exit(1);
    }

    logger.log(`✅ Found Shopping category: ${shoppingCategory.name} (${shoppingCategory.id})`);
    logger.log('');

    // Check V1 categories for shopping-related ones
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
    logger.log(`📋 Found ${shoppingCategories.length} shopping-related categories in V1:`);
    shoppingCategories.forEach(cat => {
      logger.log(`  - Category ${cat.category_id}: ${cat.category_name}`);
    });
    logger.log('');

    if (shoppingCategories.length === 0) {
      logger.warn('⚠️  No shopping categories found in V1. Checking all categories...');
      const [allCategories] = await v1Connection.execute(
        'SELECT category_id, category_name FROM categories ORDER BY category_id LIMIT 50'
      );
      logger.log('First 50 V1 categories:');
      (allCategories as Array<{ category_id: number; category_name: string }>).forEach(cat => {
        logger.log(`  - Category ${cat.category_id}: ${cat.category_name}`);
      });
      logger.log('');
    }

    // Get all V1 venues in shopping categories
    let shoppingVenues: Array<{ venue_id: number; venue_name: string; category_id: number; category_name: string }> = [];
    
    if (shoppingCategories.length > 0) {
      const categoryIds = shoppingCategories.map(c => c.category_id);
      const placeholders = categoryIds.map(() => '?').join(',');
      
      const [venues] = await v1Connection.execute(
        `SELECT v.venue_id, v.venue_name, v.category_id, c.category_name 
         FROM venues v 
         LEFT JOIN categories c ON v.category_id = c.category_id 
         WHERE v.category_id IN (${placeholders})
         ORDER BY v.category_id, v.venue_name`,
        categoryIds
      );
      
      shoppingVenues = venues as Array<{ venue_id: number; venue_name: string; category_id: number; category_name: string }>;
      logger.log(`📊 Found ${shoppingVenues.length} venues in shopping categories`);
    }

    // Also check venues by name patterns (in case category wasn't set correctly)
    const [nameBasedVenues] = await v1Connection.execute(
      `SELECT v.venue_id, v.venue_name, v.category_id, c.category_name 
       FROM venues v 
       LEFT JOIN categories c ON v.category_id = c.category_id 
       WHERE (v.venue_name LIKE '%mall%' 
          OR v.venue_name LIKE '%market%' 
          OR v.venue_name LIKE '%boutique%' 
          OR v.venue_name LIKE '%shop%'
          OR v.venue_name LIKE '%store%'
          OR v.venue_name LIKE '%retail%')
         AND v.venue_id NOT IN (${shoppingVenues.length > 0 ? shoppingVenues.map(v => v.venue_id).join(',') || '0' : '0'})
       LIMIT 100`
    );
    
    const nameBasedShoppingVenues = nameBasedVenues as Array<{ venue_id: number; venue_name: string; category_id: number; category_name: string }>;
    logger.log(`📊 Found ${nameBasedShoppingVenues.length} additional venues by name patterns`);
    
    const allShoppingVenues = [...shoppingVenues, ...nameBasedShoppingVenues];
    logger.log(`📊 Total shopping-related venues: ${allShoppingVenues.length}`);
    logger.log('');

    if (allShoppingVenues.length === 0) {
      logger.warn('⚠️  No shopping venues found in V1!');
      await app.close();
      process.exit(0);
    }

    // Get all V2 listings
    const v2Listings = await prisma.listing.findMany({
      where: {
        deletedAt: null,
      },
      select: {
        id: true,
        name: true,
        type: true,
        categoryId: true,
      },
    });

    logger.log(`📊 Found ${v2Listings.length} listings in V2`);
    logger.log('');

    // Function to determine listing type from venue name
    const getListingType = (venueName: string): listing_type => {
      const name = venueName.toLowerCase();
      
      // Exclude venues that shouldn't be shopping (coffee shops, hotels, restaurants)
      if (name.includes('coffee shop') || name.includes('cafe') || name.includes('restaurant')) {
        // Skip these - they should be in their respective categories
        return null as any;
      }
      
      if (name.includes('mall') || name.includes('shopping mall') || name.includes('shopping center') || name.includes('shopping complex')) {
        return 'mall';
      } else if (name.includes('market') || name.includes('souk') || name.includes('bazaar')) {
        return 'market';
      } else if (name.includes('boutique') && !name.includes('hotel')) {
        // Boutique shops, but not boutique hotels
        return 'boutique';
      } else if (name.includes('store') || name.includes('shop') || name.includes('retail')) {
        return 'boutique';
      }
      // Default to boutique for general shopping
      return 'boutique';
    };

    // Match V1 venues to V2 listings by name (fuzzy matching)
    let updated = 0;
    let notFound = 0;
    let alreadyCorrect = 0;

    logger.log('🔄 Matching and updating listings...');
    logger.log('');

    for (const venue of allShoppingVenues) {
      // Try to find matching listing by name
      const matchingListing = v2Listings.find(listing => {
        const listingName = listing.name?.toLowerCase() || '';
        const venueName = venue.venue_name.toLowerCase();
        
        // Exact match or close match
        return listingName === venueName || 
               listingName.includes(venueName.substring(0, 10)) ||
               venueName.includes(listingName.substring(0, 10));
      });

      if (!matchingListing) {
        notFound++;
        if (notFound <= 10) {
          logger.log(`  ⚠️  No match found for: ${venue.venue_name}`);
        }
        continue;
      }

      // Determine the correct type
      const correctType = getListingType(venue.venue_name);
      
      // Skip if type is null (shouldn't be shopping)
      if (!correctType) {
        continue;
      }
      
      // Check if already correct
      if (matchingListing.type === correctType && matchingListing.categoryId === shoppingCategory.id) {
        alreadyCorrect++;
        continue;
      }

      // Update the listing
      try {
        await prisma.listing.update({
          where: { id: matchingListing.id },
          data: {
            type: correctType,
            categoryId: shoppingCategory.id,
          },
        });

        updated++;
        logger.log(`  ✅ Updated: ${matchingListing.name} → type: ${correctType}, category: Shopping`);
        
        if (updated % 10 === 0) {
          logger.log(`  📊 Progress: ${updated} updated, ${alreadyCorrect} already correct, ${notFound} not found`);
        }
      } catch (error: any) {
        logger.error(`  ❌ Error updating ${matchingListing.name}: ${error.message}`);
      }
    }

    logger.log('');
    logger.log('✅ Fix Complete!');
    logger.log(`  Updated: ${updated} listings`);
    logger.log(`  Already correct: ${alreadyCorrect} listings`);
    logger.log(`  Not found: ${notFound} listings`);
    logger.log('');

    // Show final count
    const finalCount = await prisma.listing.count({
      where: {
        categoryId: shoppingCategory.id,
        deletedAt: null,
      },
    });
    logger.log(`📊 Final Shopping category listings count: ${finalCount}`);

    await v1Connection.end();
    await app.close();
    process.exit(0);
  } catch (error) {
    logger.error('❌ Fix failed:', error);
    if (v1Connection) {
      await v1Connection.end();
    }
    await app.close();
    process.exit(1);
  }
}

bootstrap();

