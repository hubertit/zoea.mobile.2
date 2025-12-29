/**
 * Count Parent Categories
 * 
 * Quick script to count how many parent categories exist in V2 database.
 * 
 * Run: ts-node src/migration/count-parent-categories.ts
 */

import { NestFactory } from '@nestjs/core';
import { AppModule } from '../app.module';
import { PrismaService } from '../prisma/prisma.service';
import { Logger } from '@nestjs/common';

async function bootstrap() {
  const app = await NestFactory.createApplicationContext(AppModule);
  const prisma = app.get(PrismaService);
  const logger = new Logger('CountParentCategories');

  try {
    // Count parent categories (where parentId is null)
    const parentCount = await prisma.category.count({
      where: {
        parentId: null,
        isActive: true,
      },
    });

    // Count all categories
    const totalCount = await prisma.category.count({
      where: {
        isActive: true,
      },
    });

    // Count child categories
    const childCount = totalCount - parentCount;

    // Get list of parent categories
    const parentCategories = await prisma.category.findMany({
      where: {
        parentId: null,
        isActive: true,
      },
      select: {
        id: true,
        name: true,
        slug: true,
        sortOrder: true,
      },
      orderBy: {
        sortOrder: 'asc',
      },
    });

    logger.log('');
    logger.log('📊 Category Statistics:');
    logger.log(`  Total Active Categories: ${totalCount}`);
    logger.log(`  Parent Categories: ${parentCount}`);
    logger.log(`  Child Categories: ${childCount}`);
    logger.log('');

    logger.log('📋 Parent Categories List:');
    parentCategories.forEach((cat, index) => {
      logger.log(`  ${index + 1}. ${cat.name} (${cat.slug}) - sortOrder: ${cat.sortOrder ?? 0}`);
    });
    logger.log('');

    await app.close();
    process.exit(0);
  } catch (error) {
    logger.error('❌ Count failed:', error);
    await app.close();
    process.exit(1);
  }
}

bootstrap();

