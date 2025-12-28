import { NestFactory } from '@nestjs/core';
import { AppModule } from '../app.module';
import { PrismaService } from '../prisma/prisma.service';
import { Logger } from '@nestjs/common';

async function bootstrap() {
  const app = await NestFactory.createApplicationContext(AppModule);
  const prisma = app.get(PrismaService);
  const logger = new Logger('DeleteAdminListingAndVenue792');

  logger.log('🗑️  Deleting Admin Listing and Venue 792...');
  logger.log('');

  // Find listings to delete
  // Search for "admin" in name and also check for venue 792 by searching in name or slug
  const listingsToDelete = await prisma.listing.findMany({
    where: {
      OR: [
        { name: { contains: 'admin', mode: 'insensitive' } },
        { name: { contains: '792', mode: 'insensitive' } },
        { slug: { contains: '792', mode: 'insensitive' } },
      ],
      deletedAt: null, // Only find non-deleted listings
    },
    select: {
      id: true,
      name: true,
      slug: true,
    },
  });

  logger.log(`📊 Found ${listingsToDelete.length} listings to delete:`);
  listingsToDelete.forEach((listing) => {
    logger.log(`  - ${listing.name} (ID: ${listing.id}, Slug: ${listing.slug})`);
  });
  logger.log('');

  if (listingsToDelete.length === 0) {
    logger.log('✅ No listings found to delete.');
    await app.close();
    process.exit(0);
  }

  // Delete the listings (soft delete by setting deletedAt)
  logger.log('🔄 Deleting listings...');
  logger.log('');

  let deletedCount = 0;
  for (const listing of listingsToDelete) {
    try {
      await prisma.listing.update({
        where: { id: listing.id },
        data: { deletedAt: new Date() },
      });
      deletedCount++;
      logger.log(`  ✅ Deleted: ${listing.name} (${listing.id})`);
    } catch (error) {
      logger.error(`  ❌ Error deleting ${listing.name} (${listing.id}): ${error}`);
    }
  }

  logger.log('');
  logger.log('✅ Deletion Complete!');
  logger.log(`  Deleted: ${deletedCount} listings`);
  logger.log(`  Errors: ${listingsToDelete.length - deletedCount} listings`);

  await app.close();
  process.exit(0);
}

bootstrap();

