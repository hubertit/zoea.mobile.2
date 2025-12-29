/**
 * Update Listing Ratings
 * 
 * This script updates all listings to have ratings between 3.5 and 5.0 stars
 * Ratings are randomly distributed within this range
 * 
 * Run: ts-node src/migration/update-listing-ratings.ts
 */

import { NestFactory } from '@nestjs/core';
import { AppModule } from '../app.module';
import { PrismaService } from '../prisma/prisma.service';
import { Logger } from '@nestjs/common';
import { Prisma } from '@prisma/client';

async function bootstrap() {
  const app = await NestFactory.createApplicationContext(AppModule);
  const prisma = app.get(PrismaService);
  const logger = new Logger('UpdateListingRatings');

  logger.log('⭐ Updating Listing Ratings...');
  logger.log('Setting all ratings between 3.5 and 5.0 stars');
  logger.log('');

  try {
    // Get all active listings
    const listings = await prisma.listing.findMany({
      where: {
        deletedAt: null,
      },
      select: {
        id: true,
        name: true,
        rating: true,
      },
    });

    logger.log(`📊 Found ${listings.length} listings to update`);
    logger.log('');

    let updated = 0;
    let errors = 0;

    // Function to generate random rating between 3.5 and 5.0
    // Returns a value with 1 decimal place (e.g., 3.5, 3.7, 4.2, 4.9, 5.0)
    const generateRating = (): Prisma.Decimal => {
      // Generate random number between 3.5 and 5.0
      // Math.random() gives 0-1, so we multiply by 1.5 (5.0 - 3.5) and add 3.5
      const rating = Math.random() * 1.5 + 3.5;
      // Round to 1 decimal place
      const rounded = Math.round(rating * 10) / 10;
      // Ensure it's between 3.5 and 5.0
      const clamped = Math.max(3.5, Math.min(5.0, rounded));
      return new Prisma.Decimal(clamped.toFixed(1));
    };

    logger.log('🔄 Updating ratings...');
    logger.log('');

    for (const listing of listings) {
      try {
        const newRating = generateRating();
        
        await prisma.listing.update({
          where: { id: listing.id },
          data: { rating: newRating },
        });

        updated++;
        
        if (updated % 100 === 0) {
          logger.log(`  ✅ Updated ${updated} listings...`);
        }
      } catch (error: any) {
        errors++;
        logger.error(`  ❌ Error updating ${listing.name || listing.id}: ${error.message}`);
      }
    }

    logger.log('');
    logger.log('✅ Update Complete!');
    logger.log(`  Updated: ${updated} listings`);
    logger.log(`  Errors: ${errors} listings`);
    logger.log('');

    // Show rating distribution
    const ratingStats = await prisma.listing.groupBy({
      by: ['rating'],
      where: {
        deletedAt: null,
        rating: { not: null },
      },
      _count: {
        id: true,
      },
      orderBy: {
        rating: 'asc',
      },
    });

    logger.log('📊 Rating Distribution:');
    for (const stat of ratingStats.slice(0, 20)) {
      logger.log(`  ${stat.rating} stars: ${stat._count.id} listings`);
    }
    if (ratingStats.length > 20) {
      logger.log(`  ... and ${ratingStats.length - 20} more rating values`);
    }

    // Show min/max/average
    const minRating = await prisma.listing.findFirst({
      where: { deletedAt: null, rating: { not: null } },
      orderBy: { rating: 'asc' },
      select: { rating: true },
    });

    const maxRating = await prisma.listing.findFirst({
      where: { deletedAt: null, rating: { not: null } },
      orderBy: { rating: 'desc' },
      select: { rating: true },
    });

    const avgRatingResult = await prisma.listing.aggregate({
      where: { deletedAt: null, rating: { not: null } },
      _avg: { rating: true },
    });

    logger.log('');
    logger.log('📊 Rating Statistics:');
    logger.log(`  Min: ${minRating?.rating || 'N/A'} stars`);
    logger.log(`  Max: ${maxRating?.rating || 'N/A'} stars`);
    logger.log(`  Average: ${avgRatingResult._avg.rating ? avgRatingResult._avg.rating.toFixed(2) : 'N/A'} stars`);

    await app.close();
    process.exit(0);
  } catch (error) {
    logger.error('❌ Update failed:', error);
    await app.close();
    process.exit(1);
  }
}

bootstrap();

