/**
 * Enable Shop Mode for All Listings
 * 
 * This script enables shop mode (isShopEnabled = true) for all listings
 * so they can display products, services, and menus.
 * 
 * Run: npx ts-node src/migration/enable-shop-mode.ts
 */

import { NestFactory } from '@nestjs/core';
import { AppModule } from '../app.module';
import { PrismaService } from '../prisma/prisma.service';
import { Logger } from '@nestjs/common';

async function bootstrap() {
  const app = await NestFactory.createApplicationContext(AppModule);
  const prisma = app.get(PrismaService);
  const logger = new Logger('EnableShopMode');

  logger.log('🛍️  Enabling shop mode for all listings...');
  logger.log('');

  try {
    // Get total count of listings
    const totalListings = await prisma.listing.count();
    logger.log(`📊 Total listings: ${totalListings}`);

    // Count how many already have shop enabled
    const alreadyEnabled = await prisma.listing.count({
      where: { isShopEnabled: true },
    });
    logger.log(`✅ Already enabled: ${alreadyEnabled}`);
    logger.log(`🔄 Need to enable: ${totalListings - alreadyEnabled}`);
    logger.log('');

    // Update all listings to enable shop mode using raw SQL to handle NULL values
    const result = await prisma.$executeRaw`
      UPDATE listings
      SET 
        is_shop_enabled = true,
        shop_settings = jsonb_build_object(
          'acceptsOnlineOrders', true,
          'deliveryEnabled', false,
          'pickupEnabled', true,
          'dineInEnabled', false
        )
      WHERE is_shop_enabled IS NULL OR is_shop_enabled = false
    `;

    logger.log(`✅ Successfully enabled shop mode for ${result} listing(s)`);
    logger.log('');

    // Verify the update
    const enabledCount = await prisma.listing.count({
      where: { isShopEnabled: true },
    });
    logger.log(`📊 Verification: ${enabledCount} listings now have shop mode enabled`);
    logger.log('');

    // Show breakdown by listing type
    const breakdown = await prisma.listing.groupBy({
      by: ['type'],
      where: { isShopEnabled: true },
      _count: true,
    });

    logger.log('📋 Breakdown by type:');
    breakdown.forEach((item) => {
      logger.log(`   ${item.type}: ${item._count}`);
    });

    logger.log('');
    logger.log('✅ Shop mode enabled for all listings!');
    logger.log('⚠️  Note: You can disable shop mode later if needed');

    await app.close();
    process.exit(0);
  } catch (error) {
    logger.error('❌ Failed to enable shop mode:', error);
    await app.close();
    process.exit(1);
  }
}

bootstrap();

