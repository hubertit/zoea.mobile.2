/**
 * Check for Duplicate Categories in V2
 * 
 * This script checks for duplicate category names or slugs in V2.
 * 
 * Run: ts-node src/migration/check-duplicate-categories.ts
 */

import { NestFactory } from '@nestjs/core';
import { AppModule } from '../app.module';
import { PrismaService } from '../prisma/prisma.service';
import { Logger } from '@nestjs/common';

async function bootstrap() {
  const app = await NestFactory.createApplicationContext(AppModule);
  const prisma = app.get(PrismaService);
  const logger = new Logger('CheckDuplicateCategories');

  logger.log('🔍 Checking for duplicate categories in V2...');
  logger.log('');

  try {
    // Get all categories
    const allCategories = await prisma.category.findMany({
      where: { isActive: true },
      select: { id: true, name: true, slug: true, parentId: true },
      orderBy: [{ name: 'asc' }],
    });

    logger.log(`📊 Total active categories: ${allCategories.length}`);
    logger.log('');

    // Check for duplicate names
    const nameMap = new Map<string, Array<{ id: string; name: string; slug: string; parentId: string | null }>>();
    for (const cat of allCategories) {
      const key = cat.name.toLowerCase().trim();
      if (!nameMap.has(key)) {
        nameMap.set(key, []);
      }
      nameMap.get(key)!.push(cat);
    }

    const duplicateNames = Array.from(nameMap.entries()).filter(([_, cats]) => cats.length > 1);

    if (duplicateNames.length > 0) {
      logger.warn(`⚠️  Found ${duplicateNames.length} duplicate category names:`);
      for (const [name, cats] of duplicateNames) {
        logger.warn(`  "${name}" appears ${cats.length} times:`);
        for (const cat of cats) {
          const parent = cat.parentId ? allCategories.find(c => c.id === cat.parentId) : null;
          logger.warn(`    - ID: ${cat.id}, Slug: ${cat.slug}, Parent: ${parent?.name || 'None'}`);
        }
      }
      logger.log('');
    } else {
      logger.log('✅ No duplicate category names found');
      logger.log('');
    }

    // Check for duplicate slugs
    const slugMap = new Map<string, Array<{ id: string; name: string; slug: string; parentId: string | null }>>();
    for (const cat of allCategories) {
      const key = cat.slug.toLowerCase().trim();
      if (!slugMap.has(key)) {
        slugMap.set(key, []);
      }
      slugMap.get(key)!.push(cat);
    }

    const duplicateSlugs = Array.from(slugMap.entries()).filter(([_, cats]) => cats.length > 1);

    if (duplicateSlugs.length > 0) {
      logger.error(`❌ Found ${duplicateSlugs.length} duplicate category slugs (CRITICAL - slugs must be unique):`);
      for (const [slug, cats] of duplicateSlugs) {
        logger.error(`  "${slug}" appears ${cats.length} times:`);
        for (const cat of cats) {
          const parent = cat.parentId ? allCategories.find(c => c.id === cat.parentId) : null;
          logger.error(`    - ID: ${cat.id}, Name: ${cat.name}, Parent: ${parent?.name || 'None'}`);
        }
      }
      logger.log('');
    } else {
      logger.log('✅ No duplicate category slugs found');
      logger.log('');
    }

    // Check for categories with same name but different parents (might be intentional)
    const sameNameDifferentParent = duplicateNames.filter(([_, cats]) => {
      const parentIds = new Set(cats.map(c => c.parentId || 'null'));
      return parentIds.size > 1;
    });

    if (sameNameDifferentParent.length > 0) {
      logger.log(`ℹ️  Categories with same name but different parents (${sameNameDifferentParent.length}):`);
      for (const [name, cats] of sameNameDifferentParent) {
        logger.log(`  "${name}":`);
        for (const cat of cats) {
          const parent = cat.parentId ? allCategories.find(c => c.id === cat.parentId) : null;
          logger.log(`    - Under parent: ${parent?.name || 'None'} (${cat.slug})`);
        }
      }
      logger.log('');
    }

    // Summary
    logger.log('📊 Summary:');
    logger.log(`  Total categories: ${allCategories.length}`);
    logger.log(`  Duplicate names: ${duplicateNames.length}`);
    logger.log(`  Duplicate slugs: ${duplicateSlugs.length}`);
    logger.log(`  Same name, different parent: ${sameNameDifferentParent.length}`);

    if (duplicateSlugs.length > 0) {
      logger.error('');
      logger.error('❌ CRITICAL: Duplicate slugs found! This will cause database errors.');
      logger.error('   You need to fix these before the application can work properly.');
      await app.close();
      process.exit(1);
    }

    if (duplicateNames.length > 0 && sameNameDifferentParent.length === 0) {
      logger.warn('');
      logger.warn('⚠️  Warning: Duplicate category names found with same parent.');
      logger.warn('   These might cause confusion but are technically allowed.');
    }

    await app.close();
    process.exit(0);
  } catch (error) {
    logger.error('❌ Check failed:', error);
    await app.close();
    process.exit(1);
  }
}

bootstrap();

