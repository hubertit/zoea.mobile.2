/**
 * Backfill Category Legacy IDs
 * 
 * This script updates existing categories with their V1 legacy_id by matching
 * category names between V1 and V2 databases.
 * 
 * Run: ts-node src/migration/backfill-category-legacy-ids.ts
 */

import { NestFactory } from '@nestjs/core';
import { AppModule } from '../app.module';
import { PrismaService } from '../prisma/prisma.service';
import * as mysql from 'mysql2/promise';
import { Logger } from '@nestjs/common';

async function bootstrap() {
  const app = await NestFactory.createApplicationContext(AppModule);
  const prisma = app.get(PrismaService);
  const logger = new Logger('BackfillCategoryLegacyIds');

  // V1 Database Configuration
  const v1Config = {
    host: process.env.V1_DB_HOST || 'localhost',
    port: parseInt(process.env.V1_DB_PORT || '3306', 10),
    user: process.env.V1_DB_USER || 'root',
    password: process.env.V1_DB_PASSWORD || 'mysql',
    database: process.env.V1_DB_NAME || 'zoea',
  };

  logger.log('🔄 Backfilling Category Legacy IDs...');
  logger.log('V1 Database:', v1Config.host, v1Config.database);
  logger.log('');

  let v1Connection: mysql.Connection | null = null;

  try {
    // Connect to V1 database
    v1Connection = await mysql.createConnection(v1Config);
    logger.log('✅ Connected to V1 database');

    // Get all V1 categories
    const [v1Categories] = await v1Connection.execute(
      `SELECT 
        category_id, 
        category_name 
      FROM categories 
      WHERE category_status = 'Active'
      ORDER BY category_id`
    );
    const v1CategoriesList = v1Categories as Array<{
      category_id: number;
      category_name: string;
    }>;

    logger.log(`📊 Found ${v1CategoriesList.length} active categories in V1`);
    logger.log('');

    // Get all V2 categories without legacyId
    const v2Categories = await prisma.category.findMany({
      where: {
        legacyId: null,
        isActive: true,
      },
      select: {
        id: true,
        name: true,
        slug: true,
        legacyId: true,
      },
    });

    logger.log(`📊 Found ${v2Categories.length} V2 categories without legacyId`);
    logger.log('');

    // Create a map of V1 category names to category_id
    const v1CategoryNameMap = new Map<string, number>();
    for (const v1Cat of v1CategoriesList) {
      const normalizedName = v1Cat.category_name.trim().toLowerCase();
      // Only add if not already in map (first occurrence wins)
      if (!v1CategoryNameMap.has(normalizedName)) {
        v1CategoryNameMap.set(normalizedName, v1Cat.category_id);
      }
    }

    let updated = 0;
    let skipped = 0;
    let errors = 0;

    logger.log('🔄 Updating categories...');
    logger.log('');

    for (const v2Cat of v2Categories) {
      try {
        const normalizedName = v2Cat.name.trim().toLowerCase();
        const v1CategoryId = v1CategoryNameMap.get(normalizedName);

        if (!v1CategoryId) {
          logger.debug(`  ⏭️  Skipping "${v2Cat.name}" - no matching V1 category`);
          skipped++;
          continue;
        }

        // Check if this legacyId is already used by another category
        const existingWithLegacyId = await prisma.category.findFirst({
          where: {
            legacyId: v1CategoryId,
            id: { not: v2Cat.id },
          },
        });

        if (existingWithLegacyId) {
          logger.warn(`  ⚠️  Skipping "${v2Cat.name}" - legacyId ${v1CategoryId} already used by "${existingWithLegacyId.name}"`);
          skipped++;
          continue;
        }

        // Update the category with legacyId
        await prisma.category.update({
          where: { id: v2Cat.id },
          data: { legacyId: v1CategoryId },
        });

        logger.log(`  ✅ Updated "${v2Cat.name}" with legacyId: ${v1CategoryId}`);
        updated++;

        if (updated % 10 === 0) {
          logger.log(`  📊 Updated ${updated} categories...`);
        }
      } catch (error: any) {
        errors++;
        logger.error(`  ❌ Error updating "${v2Cat.name}": ${error.message}`);
      }
    }

    logger.log('');
    logger.log('✅ Backfill Complete!');
    logger.log(`  Updated: ${updated} categories`);
    logger.log(`  Skipped: ${skipped} categories (no match or duplicate legacyId)`);
    logger.log(`  Errors: ${errors} categories`);
    logger.log('');

    // Show summary of categories with legacyId
    const categoriesWithLegacyId = await prisma.category.count({
      where: {
        legacyId: { not: null },
        isActive: true,
      },
    });

    logger.log(`📊 Total categories with legacyId: ${categoriesWithLegacyId}`);
    logger.log('');

    await v1Connection.end();
    await app.close();
    process.exit(0);
  } catch (error) {
    logger.error('❌ Backfill failed:', error);
    if (v1Connection) {
      await v1Connection.end();
    }
    await app.close();
    process.exit(1);
  }
}

bootstrap();

