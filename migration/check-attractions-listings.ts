/**
 * Check Attractions Listings
 * 
 * This script checks what listings are in the Attractions category
 * and identifies which ones should be moved to other categories
 * 
 * Run: ts-node src/migration/check-attractions-listings.ts
 */

import { NestFactory } from '@nestjs/core';
import { AppModule } from '../app.module';
import { PrismaService } from '../prisma/prisma.service';
import { Logger } from '@nestjs/common';

async function bootstrap() {
  const app = await NestFactory.createApplicationContext(AppModule);
  const prisma = app.get(PrismaService);
  const logger = new Logger('CheckAttractionsListings');

  logger.log('🔍 Checking Attractions Category Listings...');
  logger.log('');

  try {
    // Get Attractions category
    const attractionsCategory = await prisma.category.findUnique({
      where: { slug: 'attractions' },
      include: {
        _count: { select: { listings: true } },
      },
    });

    if (!attractionsCategory) {
      logger.error('❌ Attractions category not found!');
      await app.close();
      process.exit(1);
    }

    logger.log(`📊 Attractions Category:`);
    logger.log(`  - ID: ${attractionsCategory.id}`);
    logger.log(`  - Name: ${attractionsCategory.name}`);
    logger.log(`  - Slug: ${attractionsCategory.slug}`);
    logger.log(`  - Current Listings Count: ${attractionsCategory._count.listings}`);
    logger.log('');

    // Get all listings in Attractions category
    const attractionsListings = await prisma.listing.findMany({
      where: {
        categoryId: attractionsCategory.id,
        deletedAt: null,
      },
      select: {
        id: true,
        name: true,
        type: true,
        categoryId: true,
      },
      orderBy: { name: 'asc' },
    });

    logger.log(`📋 Found ${attractionsListings.length} listings in Attractions category:`);
    logger.log('');

    // Group by type
    const byType = new Map<string, typeof attractionsListings>();
    for (const listing of attractionsListings) {
      const type = listing.type || 'null';
      if (!byType.has(type)) {
        byType.set(type, []);
      }
      byType.get(type)!.push(listing);
    }

    for (const [type, listings] of byType.entries()) {
      logger.log(`  📦 Type: ${type} (${listings.length} listings)`);
      listings.slice(0, 10).forEach(listing => {
        logger.log(`     - ${listing.name}`);
      });
      if (listings.length > 10) {
        logger.log(`     ... and ${listings.length - 10} more`);
      }
      logger.log('');
    }

    // Get all other categories for reference
    const allCategories = await prisma.category.findMany({
      where: {
        parentId: null,
        isActive: true,
      },
      select: {
        id: true,
        name: true,
        slug: true,
        _count: { select: { listings: true } },
      },
      orderBy: { sortOrder: 'asc' },
    });

    logger.log('📊 All Parent Categories:');
    for (const cat of allCategories) {
      logger.log(`  - ${cat.name} (${cat.slug}): ${cat._count.listings} listings`);
    }

    await app.close();
  } catch (error) {
    logger.error('❌ Error checking attractions listings:', error);
    await app.close();
    process.exit(1);
  }
}

bootstrap();

