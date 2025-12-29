/**
 * Fix Missing Legacy IDs for V1 Categories
 * 
 * This script finds categories in V2 that exist in V1 but don't have legacyId,
 * and updates them with their V1 category_id.
 * 
 * Run: ts-node src/migration/fix-missing-legacy-ids.ts
 */

import { NestFactory } from '@nestjs/core';
import { AppModule } from '../app.module';
import { PrismaService } from '../prisma/prisma.service';
import * as mysql from 'mysql2/promise';
import { Logger } from '@nestjs/common';

async function bootstrap() {
  const app = await NestFactory.createApplicationContext(AppModule);
  const prisma = app.get(PrismaService);
  const logger = new Logger('FixMissingLegacyIds');

  // V1 Database Configuration
  const v1Config = {
    host: process.env.V1_DB_HOST || 'localhost',
    port: parseInt(process.env.V1_DB_PORT || '3306', 10),
    user: process.env.V1_DB_USER || 'root',
    password: process.env.V1_DB_PASSWORD || 'mysql',
    database: process.env.V1_DB_NAME || 'zoea',
  };

  logger.log('🔄 Fixing Missing Legacy IDs for V1 Categories...');
  logger.log('V1 Database:', v1Config.host, v1Config.database);
  logger.log('');

  let v1Connection: mysql.Connection | null = null;

  try {
    // Connect to V1 database
    v1Connection = await mysql.createConnection(v1Config);
    logger.log('✅ Connected to V1 database');

    // Get ALL V1 categories (including locked ones)
    const [allV1Categories] = await v1Connection.execute(
      `SELECT 
        category_id, 
        category_name,
        category_status
      FROM categories 
      ORDER BY category_id`
    );
    const allV1CategoriesList = allV1Categories as Array<{
      category_id: number;
      category_name: string;
      category_status: string;
    }>;

    logger.log(`📊 Found ${allV1CategoriesList.length} total categories in V1`);
    logger.log('');

    // Create a map of V1 category names to category_id (normalized)
    const v1CategoryNameMap = new Map<string, number>();
    for (const v1Cat of allV1CategoriesList) {
      const normalizedName = v1Cat.category_name.trim().toLowerCase();
      // Use first occurrence (lowest category_id wins)
      if (!v1CategoryNameMap.has(normalizedName)) {
        v1CategoryNameMap.set(normalizedName, v1Cat.category_id);
      }
    }

    // Get V2 categories without legacyId
    const v2CategoriesWithoutLegacyId = await prisma.category.findMany({
      where: {
        legacyId: null,
        isActive: true,
      },
      select: {
        id: true,
        name: true,
        slug: true,
        parentId: true,
      },
    });

    logger.log(`📊 Found ${v2CategoriesWithoutLegacyId.length} V2 categories without legacyId`);
    logger.log('');

    let updated = 0;
    let skipped = 0;
    let errors = 0;

    logger.log('🔄 Checking and updating categories...');
    logger.log('');

    for (const v2Cat of v2CategoriesWithoutLegacyId) {
      try {
        const normalizedName = v2Cat.name.trim().toLowerCase();
        const v1CategoryId = v1CategoryNameMap.get(normalizedName);

        if (!v1CategoryId) {
          logger.debug(`  ⏭️  Skipping "${v2Cat.name}" - not found in V1 (new V2 category)`);
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
    logger.log('✅ Fix Complete!');
    logger.log(`  Updated: ${updated} categories`);
    logger.log(`  Skipped: ${skipped} categories (not in V1 or duplicate legacyId)`);
    logger.log(`  Errors: ${errors} categories`);
    logger.log('');

    // Show final summary
    const categoriesWithLegacyId = await prisma.category.count({
      where: {
        legacyId: { not: null },
        isActive: true,
      },
    });

    const categoriesWithoutLegacyId = await prisma.category.count({
      where: {
        legacyId: null,
        isActive: true,
      },
    });

    logger.log(`📊 Final Summary:`);
    logger.log(`  Categories with legacyId: ${categoriesWithLegacyId}`);
    logger.log(`  Categories without legacyId: ${categoriesWithoutLegacyId} (new V2 categories)`);
    logger.log('');

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

