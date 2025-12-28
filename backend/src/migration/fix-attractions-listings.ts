/**
 * Fix Attractions Listings
 * 
 * This script:
 * 1. Finds all listings in Attractions category
 * 2. Re-categorizes them based on their names/types
 * 3. Moves them to appropriate categories (Dining, Accommodation, etc.)
 * 4. Leaves Attractions category empty for future use
 * 
 * Run: ts-node src/migration/fix-attractions-listings.ts
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
  const logger = new Logger('FixAttractionsListings');

  // V1 Database Configuration
  const v1Config = {
    host: process.env.V1_DB_HOST || 'localhost',
    port: parseInt(process.env.V1_DB_PORT || '3306', 10),
    user: process.env.V1_DB_USER || 'root',
    password: process.env.V1_DB_PASSWORD || 'mysql',
    database: process.env.V1_DB_NAME || 'zoea',
  };

  logger.log('🔍 Fixing Attractions Category Listings...');
  logger.log('');

  let v1Connection: mysql.Connection | null = null;

  try {
    // Connect to V1 database
    v1Connection = await mysql.createConnection(v1Config);
    logger.log('✅ Connected to V1 database');

    // Get all categories
    const categories = await prisma.category.findMany({
      where: { parentId: null, isActive: true },
      select: { id: true, name: true, slug: true },
    });

    const categoryMap = new Map<string, string>();
    for (const cat of categories) {
      categoryMap.set(cat.slug, cat.id);
    }

    const attractionsCategoryId = categoryMap.get('attractions');
    if (!attractionsCategoryId) {
      logger.error('❌ Attractions category not found!');
      await app.close();
      process.exit(1);
    }

    // Get all listings in Attractions category
    const attractionsListings = await prisma.listing.findMany({
      where: {
        categoryId: attractionsCategoryId,
        deletedAt: null,
      },
      select: {
        id: true,
        name: true,
        type: true,
        categoryId: true,
      },
    });

    logger.log(`📊 Found ${attractionsListings.length} listings in Attractions category`);
    logger.log('');

    // Get V1 venues data for better matching
    const [v1Venues] = await v1Connection.execute(
      'SELECT venue_id, category_id, venue_name FROM venues'
    );
    const v1VenueMap = new Map<number, { category_id: number | null; venue_name: string }>();
    for (const venue of v1Venues as Array<{ venue_id: number; category_id: number | null; venue_name: string }>) {
      v1VenueMap.set(venue.venue_id, { category_id: venue.category_id, venue_name: venue.venue_name });
    }

    // V1 Category ID to V2 Category mapping
    const v1CategoryToV2Category: Record<number, string> = {
      4: categoryMap.get('accommodation') || '',      // Accommodation
      5: categoryMap.get('dining') || '',             // Restaurants
      7: categoryMap.get('dining') || '',              // Cafes
      8: categoryMap.get('nightlife') || '',          // Nightlife
      12: categoryMap.get('nightlife') || '',         // Night Clubs
      18: categoryMap.get('experiences') || '',       // Tours & Travel
      19: categoryMap.get('attractions') || '',       // Attractions (but we'll move these)
      21: categoryMap.get('shopping') || '',          // Shopping
    };

    // Function to determine correct category from listing name
    const getCorrectCategory = (listingName: string, listingType: string | null): string | null => {
      const name = listingName?.toLowerCase() || '';
      
      // Restaurant patterns
      if (name.includes('restaurant') || name.includes('resto') || 
          name.includes('dining') || name.includes('bistro') ||
          name.includes('kitchen') || name.includes('food') ||
          name.includes('curry') || name.includes('khana') ||
          name.includes('italian') || name.includes('pizza') ||
          name.includes('grill') || name.includes('steak') ||
          name.includes('cucina') || name.includes('fusion')) {
        return categoryMap.get('dining') || null;
      }
      
      // Cafe patterns
      if (name.includes('cafe') || name.includes('coffee') || 
          name.includes('café') || name.includes('espresso') ||
          name.includes('tea') || name.includes('brew')) {
        return categoryMap.get('dining') || null;
      }
      
      // Hotel patterns
      if (name.includes('hotel') || name.includes('resort') || 
          name.includes('lodge') || name.includes('accommodation') ||
          name.includes('guest house') || name.includes('apartment') ||
          name.includes('residence') || name.includes('inn')) {
        return categoryMap.get('accommodation') || null;
      }
      
      // Bar/Nightlife patterns
      if (name.includes('bar') || name.includes('pub') || 
          name.includes('lounge') || name.includes('nightlife') ||
          name.includes('club') || name.includes('wine bar') ||
          name.includes('cocktail') || name.includes('atelier du vin')) {
        return categoryMap.get('nightlife') || null;
      }
      
      // Tour patterns
      if (name.includes('tour') || name.includes('safari') || 
          name.includes('travel') || name.includes('adventure') ||
          name.includes('gorilla') || name.includes('primate')) {
        return categoryMap.get('experiences') || null;
      }
      
      // Shopping patterns
      if (name.includes('mall') || name.includes('shopping') || 
          name.includes('market') || name.includes('boutique') ||
          name.includes('store') || name.includes('shop')) {
        return categoryMap.get('shopping') || null;
      }
      
      // Entertainment/Cinema (could be experiences or attractions, but user wants attractions empty)
      if (name.includes('cinema') || name.includes('theater') || 
          name.includes('theatre') || name.includes('play') ||
          name.includes('bounce') || name.includes('park') ||
          name.includes('mosque') || name.includes('church')) {
        // These could stay as attractions, but user wants it empty
        // Let's move entertainment to experiences
        return categoryMap.get('experiences') || null;
      }
      
      // If we can't determine, default to Dining (most common)
      return categoryMap.get('dining') || null;
    };

    let moved = 0;
    let kept = 0;
    let errors = 0;

    logger.log('🔄 Re-categorizing listings...');
    logger.log('');

    for (const listing of attractionsListings) {
      try {
        const correctCategoryId = getCorrectCategory(listing.name || '', listing.type);
        
        if (!correctCategoryId || correctCategoryId === attractionsCategoryId) {
          // Can't determine or already correct - but user wants attractions empty
          // Move to Dining as default
          const defaultCategoryId = categoryMap.get('dining');
          if (defaultCategoryId && defaultCategoryId !== attractionsCategoryId) {
            await prisma.listing.update({
              where: { id: listing.id },
              data: { categoryId: defaultCategoryId },
            });
            moved++;
            logger.log(`  ✅ Moved: ${listing.name} → Dining (default)`);
          } else {
            kept++;
          }
        } else {
          // Move to correct category
          await prisma.listing.update({
            where: { id: listing.id },
            data: { categoryId: correctCategoryId },
          });
          
          const targetCategory = categories.find(c => c.id === correctCategoryId);
          moved++;
          logger.log(`  ✅ Moved: ${listing.name} → ${targetCategory?.name || 'Unknown'}`);
          
          if (moved % 20 === 0) {
            logger.log(`  📊 Progress: ${moved} moved, ${kept} kept, ${errors} errors`);
          }
        }
      } catch (error: any) {
        errors++;
        logger.error(`  ❌ Error updating ${listing.name}: ${error.message}`);
      }
    }

    logger.log('');
    logger.log('✅ Fix Complete!');
    logger.log(`  Moved: ${moved} listings`);
    logger.log(`  Kept: ${kept} listings`);
    logger.log(`  Errors: ${errors} listings`);
    logger.log('');

    // Show final counts
    const finalAttractionsCount = await prisma.listing.count({
      where: {
        categoryId: attractionsCategoryId,
        deletedAt: null,
      },
    });

    logger.log(`📊 Final Attractions category listings count: ${finalAttractionsCount}`);
    logger.log('');

    // Show distribution
    logger.log('📊 Listings by Category (after fix):');
    for (const cat of categories) {
      const count = await prisma.listing.count({
        where: {
          categoryId: cat.id,
          deletedAt: null,
        },
      });
      logger.log(`  - ${cat.name}: ${count} listings`);
    }

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

