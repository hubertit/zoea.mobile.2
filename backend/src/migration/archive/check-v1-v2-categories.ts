/**
 * Check V1 vs V2 Categories
 * 
 * This script compares V1 categories with V2 categories to see
 * which V1 categories are missing in V2.
 * 
 * Run: ts-node src/migration/check-v1-v2-categories.ts
 */

import { NestFactory } from '@nestjs/core';
import { AppModule } from '../app.module';
import { PrismaService } from '../prisma/prisma.service';
import * as mysql from 'mysql2/promise';
import { Logger } from '@nestjs/common';

async function bootstrap() {
  const app = await NestFactory.createApplicationContext(AppModule);
  const prisma = app.get(PrismaService);
  const logger = new Logger('CheckV1V2Categories');

  // V1 Database Configuration
  const v1Config = {
    host: process.env.V1_DB_HOST || 'localhost',
    port: parseInt(process.env.V1_DB_PORT || '3306', 10),
    user: process.env.V1_DB_USER || 'root',
    password: process.env.V1_DB_PASSWORD || 'mysql',
    database: process.env.V1_DB_NAME || 'zoea',
  };

  logger.log('🔍 Checking V1 vs V2 Categories...');
  logger.log('V1 Database:', v1Config.host, v1Config.database);
  logger.log('');

  let v1Connection: mysql.Connection | null = null;

  try {
    // Connect to V1 database
    v1Connection = await mysql.createConnection(v1Config);
    logger.log('✅ Connected to V1 database');

    // Get all V1 categories (parent and child)
    const [v1Categories] = await v1Connection.execute(
      `SELECT 
        category_id, 
        parent_id, 
        category_name, 
        category_status,
        is_child
      FROM categories 
      WHERE category_status = 'Active'
      ORDER BY parent_id, category_id`
    );
    const v1CategoriesList = v1Categories as Array<{
      category_id: number;
      parent_id: number;
      category_name: string;
      category_status: string;
      is_child: number;
    }>;

    logger.log(`📊 Found ${v1CategoriesList.length} active categories in V1`);
    logger.log('');

    // Get all V2 categories
    const v2Categories = await prisma.category.findMany({
      where: { isActive: true },
      select: { id: true, name: true, slug: true, parentId: true },
      orderBy: [{ parentId: 'asc' }, { name: 'asc' }],
    });

    logger.log(`📊 Found ${v2Categories.length} active categories in V2`);
    logger.log('');

    // Create maps for easier lookup
    const v2CategoryNames = new Set(v2Categories.map(c => c.name.toLowerCase().trim()));
    const v2CategorySlugs = new Set(v2Categories.map(c => c.slug.toLowerCase().trim()));

    // Separate V1 categories into parent and child
    const v1ParentCategories = v1CategoriesList.filter(c => c.parent_id === 0 || c.parent_id === null);
    const v1ChildCategories = v1CategoriesList.filter(c => c.parent_id !== 0 && c.parent_id !== null);

    logger.log('📋 V1 Parent Categories:');
    v1ParentCategories.forEach(cat => {
      const exists = v2CategoryNames.has(cat.category_name.toLowerCase().trim());
      const status = exists ? '✅' : '❌';
      logger.log(`  ${status} ${cat.category_name} (ID: ${cat.category_id})`);
    });
    logger.log('');

    logger.log('📋 V1 Child Categories:');
    v1ChildCategories.forEach(cat => {
      const exists = v2CategoryNames.has(cat.category_name.toLowerCase().trim());
      const status = exists ? '✅' : '❌';
      const parent = v1CategoriesList.find(p => p.category_id === cat.parent_id);
      logger.log(`  ${status} ${cat.category_name} (ID: ${cat.category_id}, Parent: ${parent?.category_name || 'Unknown'})`);
    });
    logger.log('');

    // Find missing categories
    const missingParentCategories = v1ParentCategories.filter(
      cat => !v2CategoryNames.has(cat.category_name.toLowerCase().trim())
    );
    const missingChildCategories = v1ChildCategories.filter(
      cat => !v2CategoryNames.has(cat.category_name.toLowerCase().trim())
    );

    logger.log('📊 Summary:');
    logger.log(`  V1 Parent Categories: ${v1ParentCategories.length}`);
    logger.log(`  V1 Child Categories: ${v1ChildCategories.length}`);
    logger.log(`  V2 Categories: ${v2Categories.length}`);
    logger.log('');

    if (missingParentCategories.length > 0) {
      logger.log(`❌ Missing ${missingParentCategories.length} V1 Parent Categories in V2:`);
      missingParentCategories.forEach(cat => {
        logger.log(`  - ${cat.category_name} (ID: ${cat.category_id})`);
      });
      logger.log('');
    }

    if (missingChildCategories.length > 0) {
      logger.log(`❌ Missing ${missingChildCategories.length} V1 Child Categories in V2:`);
      missingChildCategories.forEach(cat => {
        const parent = v1CategoriesList.find(p => p.category_id === cat.parent_id);
        logger.log(`  - ${cat.category_name} (ID: ${cat.category_id}, Parent: ${parent?.category_name || 'Unknown'})`);
      });
      logger.log('');
    }

    if (missingParentCategories.length === 0 && missingChildCategories.length === 0) {
      logger.log('✅ All V1 categories exist in V2!');
    } else {
      logger.log(`⚠️  Total missing: ${missingParentCategories.length + missingChildCategories.length} categories`);
    }

    // Show V2 categories that don't exist in V1 (new categories)
    const v1CategoryNames = new Set(v1CategoriesList.map(c => c.category_name.toLowerCase().trim()));
    const newV2Categories = v2Categories.filter(
      cat => !v1CategoryNames.has(cat.name.toLowerCase().trim())
    );

    if (newV2Categories.length > 0) {
      logger.log('');
      logger.log(`📊 V2 Categories that are NEW (not in V1): ${newV2Categories.length}`);
      newV2Categories.forEach(cat => {
        logger.log(`  - ${cat.name} (${cat.slug})`);
      });
    }

    await v1Connection.end();
    await app.close();
    process.exit(0);
  } catch (error) {
    logger.error('❌ Check failed:', error);
    if (v1Connection) {
      await v1Connection.end();
    }
    await app.close();
    process.exit(1);
  }
}

bootstrap();

