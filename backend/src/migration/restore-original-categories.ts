/**
 * Restore Original V1 Categories
 * 
 * This script restores listings to their original V1 categories by:
 * 1. Reading original V1 category names from V1 database
 * 2. Mapping V1 category_id directly to V2 category UUIDs based on original names
 * 3. Updating all listings to use the correct categories from V1
 * 
 * This fixes the issue where categories were incorrectly assigned during renaming.
 * 
 * IMPORTANT: This script ONLY updates listings with legacyId (from V1 migration).
 * It will NOT touch any new listings created in V2.
 * 
 * Run: ts-node src/migration/restore-original-categories.ts
 */

import { NestFactory } from '@nestjs/core';
import { AppModule } from '../app.module';
import { PrismaService } from '../prisma/prisma.service';
import * as mysql from 'mysql2/promise';
import { Logger } from '@nestjs/common';

// Map V1 category names to V2 category slugs
// This preserves the original V1 category structure
const v1CategoryNameToV2Slug: Record<string, string> = {
  // Parent categories
  'Accommodation': 'accommodation',
  'Restaurants': 'dining',
  'Events': 'events',
  'Nightlife': 'nightlife',
  'Shopping': 'shopping',
  'Experiences': 'experiences',
  'Kids': 'experiences', // Map Kids to Experiences for now
  'Services': 'experiences', // Map Services to Experiences for now
  'Real Estate': 'accommodation', // Map Real Estate to Accommodation
  'Real Estate ': 'accommodation', // Map Real Estate (with space) to Accommodation
  
  // Child categories - map to parent category
  'Take a coffee': 'dining', // Child of Restaurants
  'Night Clubs': 'nightlife', // Child of Nightlife
  'Lounges': 'nightlife', // Child of Nightlife
  'Karaoke Bars': 'nightlife', // Child of Nightlife
  'Bars': 'nightlife', // Child of Nightlife
  'Wine Bars': 'nightlife', // Child of Bars
  'Sports Bars': 'nightlife', // Child of Bars
  'Cocktail Bars': 'nightlife', // Child of Bars
  'Rooftop Bars': 'nightlife', // Child of Bars
  'Tour and Travel': 'experiences', // Child of Experiences
  'Fast Food': 'dining', // Child of Restaurants
  'Fine Dining': 'dining', // Child of Restaurants
  'Casual Dining': 'dining', // Child of Restaurants
  'Cuisines': 'dining', // Child of Restaurants
  'Italian': 'dining', // Child of Cuisines
  'Chinese': 'dining', // Child of Cuisines
  'Indian': 'dining', // Child of Cuisines
  'Continental': 'dining', // Child of Cuisines
  'Arts & Crafts': 'shopping', // Child of Shopping
};

// Helper function to get parent category name from V1
async function getParentCategoryName(
  v1Connection: mysql.Connection,
  categoryId: number
): Promise<string | null> {
  try {
    const [rows] = await v1Connection.execute(
      'SELECT category_id, parent_id, category_name FROM categories WHERE category_id = ?',
      [categoryId]
    );
    
    const category = (rows as Array<any>)[0];
    if (!category) return null;
    
    // If it's a parent category (parent_id = 0), return its name
    if (category.parent_id === 0 || category.parent_id === null) {
      return category.category_name;
    }
    
    // If it's a child category, get the parent category name
    const [parentRows] = await v1Connection.execute(
      'SELECT category_name FROM categories WHERE category_id = ?',
      [category.parent_id]
    );
    
    const parentCategory = (parentRows as Array<any>)[0];
    if (parentCategory) {
      return parentCategory.category_name;
    }
    
    // Fallback: return the category's own name
    return category.category_name;
  } catch (error) {
    console.error(`Error getting parent category for ${categoryId}:`, error);
    return null;
  }
}

async function bootstrap() {
  const app = await NestFactory.createApplicationContext(AppModule);
  const prisma = app.get(PrismaService);
  const logger = new Logger('RestoreOriginalCategories');

  // V1 Database Configuration
  const v1Config = {
    host: process.env.V1_DB_HOST || 'localhost',
    port: parseInt(process.env.V1_DB_PORT || '3306', 10),
    user: process.env.V1_DB_USER || 'root',
    password: process.env.V1_DB_PASSWORD || 'mysql',
    database: process.env.V1_DB_NAME || 'zoea',
  };

  logger.log('🔄 Starting Original Category Restoration...');
  logger.log('V1 Database:', v1Config.host, v1Config.database);
  logger.log('⚠️  IMPORTANT: This script ONLY updates listings with legacyId (from V1)');
  logger.log('');

  let v1Connection: mysql.Connection | null = null;

  try {
    // Connect to V1 database
    v1Connection = await mysql.createConnection(v1Config);
    logger.log('✅ Connected to V1 database');

    // Get ALL V2 categories (including child categories) to find imported V1 categories
    const v2Categories = await prisma.category.findMany({
      where: { isActive: true },
      select: { id: true, name: true, slug: true, parentId: true, legacyId: true },
    });

    if (v2Categories.length === 0) {
      logger.error('❌ No V2 categories found! Cannot proceed.');
      await app.close();
      process.exit(1);
    }

    // Create maps for different lookup methods
    const v2CategoryNameMap = new Map<string, string>();
    const v2CategoryLegacyIdMap = new Map<number, string>(); // V1 category_id -> V2 category UUID
    const v2ParentCategorySlugMap = new Map<string, string>();
    
    for (const cat of v2Categories) {
      v2CategoryNameMap.set(cat.name.trim(), cat.id);
      // Map by legacyId if available (most reliable method)
      if (cat.legacyId !== null && cat.legacyId !== undefined) {
        v2CategoryLegacyIdMap.set(cat.legacyId, cat.id);
      }
      // Only add parent categories to slug map
      if (!cat.parentId) {
        v2ParentCategorySlugMap.set(cat.slug, cat.id);
      }
    }

    logger.log(`📋 Found ${v2Categories.length} V2 categories (including ${v2Categories.filter(c => !c.parentId).length} parent categories)`);
    logger.log('');

    // Get all V1 categories
    const [v1Categories] = await v1Connection.execute(
      'SELECT category_id, parent_id, category_name FROM categories WHERE category_status = "Active"'
    );
    const v1CategoriesList = v1Categories as Array<{
      category_id: number;
      parent_id: number;
      category_name: string;
    }>;

    logger.log(`📊 Found ${v1CategoriesList.length} active categories in V1`);
    logger.log('');

    // Build mapping from V1 category_id to V2 category UUID
    // Use legacyId for direct mapping (fastest and most reliable)
    const v1CategoryIdToV2CategoryId = new Map<number, string>();

    // First, build direct mapping using legacyId (most reliable)
    for (const v2Cat of v2Categories) {
      if (v2Cat.legacyId !== null && v2Cat.legacyId !== undefined) {
        v1CategoryIdToV2CategoryId.set(v2Cat.legacyId, v2Cat.id);
        logger.debug(`  ✅ Direct mapping: V1 category ${v2Cat.legacyId} → V2 ${v2Cat.id} (${v2Cat.name})`);
      }
    }

    // Then, for any V1 categories not yet mapped, try name matching
    for (const v1Cat of v1CategoriesList) {
      // Skip if already mapped by legacyId
      if (v1CategoryIdToV2CategoryId.has(v1Cat.category_id)) {
        continue;
      }

      // Fallback: try to find exact match by category name in V2
      const v2CategoryIdByName = v2CategoryNameMap.get(v1Cat.category_name.trim());
      
      if (v2CategoryIdByName) {
        // Found exact match by name - this is an imported V1 category
        v1CategoryIdToV2CategoryId.set(v1Cat.category_id, v2CategoryIdByName);
        logger.log(`  ✅ Mapped V1 category ${v1Cat.category_id} (${v1Cat.category_name}) → V2 by name (${v2CategoryIdByName})`);
        continue;
      }

      // Fallback: Use the hardcoded mapping to parent categories
      const parentCategoryName = await getParentCategoryName(v1Connection, v1Cat.category_id);
      
      if (!parentCategoryName) {
        logger.warn(`⚠️  Could not find parent category for V1 category ${v1Cat.category_id} (${v1Cat.category_name})`);
        continue;
      }

      // Map to V2 slug based on parent category name
      const v2Slug = v1CategoryNameToV2Slug[parentCategoryName] || 
                     v1CategoryNameToV2Slug[v1Cat.category_name] ||
                     null;

      if (!v2Slug) {
        logger.warn(`⚠️  No mapping found for V1 category ${v1Cat.category_id} (${v1Cat.category_name}, parent: ${parentCategoryName})`);
        continue;
      }

      const v2CategoryId = v2ParentCategorySlugMap.get(v2Slug);
      if (!v2CategoryId) {
        logger.warn(`⚠️  V2 category with slug "${v2Slug}" not found`);
        continue;
      }

      v1CategoryIdToV2CategoryId.set(v1Cat.category_id, v2CategoryId);
      logger.log(`  ✅ Mapped V1 category ${v1Cat.category_id} (${v1Cat.category_name}) → V2 parent ${v2Slug} (${v2CategoryId})`);
    }

    logger.log('');
    logger.log(`📊 Built mapping for ${v1CategoryIdToV2CategoryId.size} categories`);
    logger.log('');

    // Get all V1 venues with their category_ids
    const [v1Venues] = await v1Connection.execute(
      'SELECT venue_id, category_id, venue_name FROM venues'
    );
    const v1VenuesList = v1Venues as Array<{
      venue_id: number;
      category_id: number | null;
      venue_name: string;
    }>;

    logger.log(`📊 Found ${v1VenuesList.length} venues in V1`);
    logger.log('');

    // Get all V2 listings with legacyId - ONLY update listings that came from V1
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

    logger.log(`📊 Found ${v2Listings.length} listings with legacyId in V2`);
    logger.log('');

    // Create a map of legacyId -> category_id from V1 venues
    const legacyIdToCategoryId = new Map<number, number | null>();
    const legacyIdToVenueName = new Map<number, string>();
    for (const venue of v1VenuesList) {
      legacyIdToCategoryId.set(venue.venue_id, venue.category_id);
      legacyIdToVenueName.set(venue.venue_id, venue.venue_name);
    }

    // Validate that all legacyIds have corresponding V1 venues
    const missingVenues: number[] = [];
    for (const listing of v2Listings) {
      if (listing.legacyId && !legacyIdToCategoryId.has(listing.legacyId)) {
        missingVenues.push(listing.legacyId);
      }
    }
    if (missingVenues.length > 0) {
      logger.warn(`⚠️  Found ${missingVenues.length} listings with legacyIds not found in V1 venues (first 10): ${missingVenues.slice(0, 10).join(', ')}`);
      logger.warn(`   These listings will be skipped to avoid breaking anything.`);
      logger.log('');
    }

    let updated = 0;
    let skipped = 0;
    let errors = 0;
    const categoryChanges: Map<string, { from: string; to: string; count: number }> = new Map();

    logger.log('🔄 Restoring categories...');
    logger.log('');

    for (const listing of v2Listings) {
      try {
        // Safety check: Only process listings with valid legacyId
        if (!listing.legacyId || typeof listing.legacyId !== 'number') {
          logger.warn(`⚠️  Skipping listing ${listing.id} (${listing.name}): invalid legacyId`);
          skipped++;
          continue;
        }

        // Safety check: Verify legacyId exists in V1
        if (!legacyIdToCategoryId.has(listing.legacyId)) {
          logger.warn(`⚠️  Skipping listing ${listing.id} (${listing.name}): legacyId ${listing.legacyId} not found in V1`);
          skipped++;
          continue;
        }

        const v1CategoryId = legacyIdToCategoryId.get(listing.legacyId);
        
        // Safety check: Skip if category_id is null, undefined, or 0
        if (v1CategoryId === null || v1CategoryId === undefined || v1CategoryId === 0) {
          logger.debug(`  ⏭️  Skipping listing ${listing.name} (legacyId: ${listing.legacyId}): no category in V1`);
          skipped++;
          continue;
        }

        // Get the correct V2 category ID from mapping
        const correctV2CategoryId = v1CategoryIdToV2CategoryId.get(v1CategoryId);
        
        if (!correctV2CategoryId) {
          logger.warn(`⚠️  No mapping found for listing ${listing.name} (legacyId: ${listing.legacyId}, v1CategoryId: ${v1CategoryId})`);
          skipped++;
          continue;
        }

        // Safety check: Verify the target category exists
        const targetCategoryExists = v2Categories.some(c => c.id === correctV2CategoryId);
        if (!targetCategoryExists) {
          logger.error(`❌ Target category ${correctV2CategoryId} does not exist for listing ${listing.name}`);
          errors++;
          continue;
        }

        // Check if update is needed (skip if already correct)
        if (listing.categoryId === correctV2CategoryId) {
          skipped++;
          continue;
        }

        // Safety check: Ensure current category exists (might be null or invalid)
        const currentCategory = v2Categories.find(c => c.id === listing.categoryId);
        const newCategory = v2Categories.find(c => c.id === correctV2CategoryId);

        if (!newCategory) {
          logger.error(`❌ Cannot find new category ${correctV2CategoryId} for listing ${listing.name}`);
          errors++;
          continue;
        }

        // Update the listing - only update categoryId, preserve everything else
        await prisma.listing.update({
          where: { id: listing.id },
          data: {
            categoryId: correctV2CategoryId,
          },
        });

        // Track category changes for reporting
        const changeKey = `${currentCategory?.slug || 'unknown'} → ${newCategory.slug}`;
        const change = categoryChanges.get(changeKey) || { 
          from: currentCategory?.name || 'Unknown/Null', 
          to: newCategory.name, 
          count: 0 
        };
        change.count++;
        categoryChanges.set(changeKey, change);

        updated++;
        if (updated % 50 === 0) {
          logger.log(`  ✅ Updated ${updated} listings...`);
        }
      } catch (error: any) {
        errors++;
        logger.error(`  ❌ Error updating listing ${listing.id} (legacyId: ${listing.legacyId}, name: ${listing.name}): ${error.message}`);
        // Continue processing other listings even if one fails
      }
    }

    logger.log('');
    logger.log('✅ Restoration Complete!');
    logger.log(`  Updated: ${updated} listings`);
    logger.log(`  Skipped: ${skipped} listings (no mapping or already correct)`);
    logger.log(`  Errors: ${errors} listings`);
    logger.log('');

    // Show category change summary
    if (categoryChanges.size > 0) {
      logger.log('📊 Category Changes Summary:');
      for (const [key, change] of categoryChanges.entries()) {
        logger.log(`  ${change.from} → ${change.to}: ${change.count} listings`);
      }
      logger.log('');
    }

    // Show final distribution
    logger.log('📊 Final Category Distribution:');
    for (const cat of v2Categories) {
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
    logger.error('❌ Restoration failed:', error);
    if (v1Connection) {
      await v1Connection.end();
    }
    await app.close();
    process.exit(1);
  }
}

bootstrap();

