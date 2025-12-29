/**
 * Check Categories with Null Legacy IDs
 * 
 * This script shows which categories have null legacyId and explains why.
 * 
 * Run: ts-node src/migration/check-null-legacy-ids.ts
 */

import { NestFactory } from '@nestjs/core';
import { AppModule } from '../app.module';
import { PrismaService } from '../prisma/prisma.service';
import { Logger } from '@nestjs/common';

async function bootstrap() {
  const app = await NestFactory.createApplicationContext(AppModule);
  const prisma = app.get(PrismaService);
  const logger = new Logger('CheckNullLegacyIds');

  try {
    // Get categories with null legacyId
    const categoriesWithoutLegacyId = await prisma.category.findMany({
      where: {
        legacyId: null,
        isActive: true,
      },
      select: {
        id: true,
        name: true,
        slug: true,
        parentId: true,
        createdAt: true,
      },
      orderBy: {
        name: 'asc',
      },
    });

    // Get categories with legacyId for comparison
    const categoriesWithLegacyId = await prisma.category.findMany({
      where: {
        legacyId: { not: null },
        isActive: true,
      },
      select: {
        id: true,
        name: true,
        slug: true,
        legacyId: true,
        parentId: true,
      },
    });

    logger.log('');
    logger.log('📊 Categories with NULL legacyId:');
    logger.log(`  Total: ${categoriesWithoutLegacyId.length} categories`);
    logger.log('');

    // Separate parent and child categories
    const parentCategories = categoriesWithoutLegacyId.filter(c => !c.parentId);
    const childCategories = categoriesWithoutLegacyId.filter(c => c.parentId);

    logger.log(`  Parent Categories (${parentCategories.length}):`);
    parentCategories.forEach(cat => {
      logger.log(`    - ${cat.name} (${cat.slug})`);
    });
    logger.log('');

    logger.log(`  Child Categories (${childCategories.length}):`);
    childCategories.forEach(cat => {
      logger.log(`    - ${cat.name} (${cat.slug})`);
    });
    logger.log('');

    logger.log('📊 Categories WITH legacyId:');
    logger.log(`  Total: ${categoriesWithLegacyId.length} categories`);
    logger.log('');

    logger.log('💡 Why some categories have null legacyId:');
    logger.log('  1. New V2 categories that were created in V2 (not from V1 migration)');
    logger.log('  2. Categories that were created manually after migration');
    logger.log('  3. Categories that don\'t exist in V1 database');
    logger.log('');

    await app.close();
    process.exit(0);
  } catch (error) {
    logger.error('❌ Check failed:', error);
    await app.close();
    process.exit(1);
  }
}

bootstrap();

