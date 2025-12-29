/**
 * Import All V1 Categories to V2
 * 
 * This script imports ALL original V1 categories into V2, preserving:
 * 1. Original category names
 * 2. Parent-child relationships
 * 3. Category hierarchy structure
 * 
 * Categories will be imported as-is from V1. You can merge them manually later.
 * 
 * Run: ts-node src/migration/import-v1-categories.ts
 */

import { NestFactory } from '@nestjs/core';
import { AppModule } from '../app.module';
import { PrismaService } from '../prisma/prisma.service';
import * as mysql from 'mysql2/promise';
import { Logger } from '@nestjs/common';

async function bootstrap() {
  const app = await NestFactory.createApplicationContext(AppModule);
  const prisma = app.get(PrismaService);
  const logger = new Logger('ImportV1Categories');

  // V1 Database Configuration
  const v1Config = {
    host: process.env.V1_DB_HOST || 'localhost',
    port: parseInt(process.env.V1_DB_PORT || '3306', 10),
    user: process.env.V1_DB_USER || 'root',
    password: process.env.V1_DB_PASSWORD || 'mysql',
    database: process.env.V1_DB_NAME || 'zoea',
  };

  logger.log('📥 Importing All V1 Categories to V2...');
  logger.log('V1 Database:', v1Config.host, v1Config.database);
  logger.log('');

  let v1Connection: mysql.Connection | null = null;

  try {
    // Connect to V1 database
    v1Connection = await mysql.createConnection(v1Config);
    logger.log('✅ Connected to V1 database');

    // Get all V1 categories (including locked ones if they have active children)
    // First get all categories regardless of status
    const [allV1Categories] = await v1Connection.execute(
      `SELECT 
        category_id, 
        parent_id, 
        category_name, 
        category_description,
        category_status,
        is_child
      FROM categories 
      ORDER BY parent_id, category_id`
    );
    const allV1CategoriesList = allV1Categories as Array<{
      category_id: number;
      parent_id: number;
      category_name: string;
      category_description: string;
      category_status: string;
      is_child: number;
    }>;

    // Get active categories
    const activeV1Categories = allV1CategoriesList.filter(c => c.category_status === 'Active');
    
    // Find parent categories that have active children but are locked themselves
    const activeChildCategoryIds = new Set(activeV1Categories.map(c => c.category_id));
    const parentsWithActiveChildren = new Set(
      activeV1Categories
        .filter(c => c.parent_id !== 0 && c.parent_id !== null)
        .map(c => c.parent_id)
    );

    // Include locked parent categories if they have active children (both top-level and nested)
    const v1CategoriesList = allV1CategoriesList.filter(c => 
      c.category_status === 'Active' || 
      (c.parent_id === 0 && parentsWithActiveChildren.has(c.category_id)) ||
      (c.parent_id !== 0 && c.parent_id !== null && parentsWithActiveChildren.has(c.category_id))
    );

    logger.log(`📊 Found ${v1CategoriesList.length} active categories in V1`);
    logger.log('');

    // Get existing V2 categories to check for duplicates
    const existingV2Categories = await prisma.category.findMany({
      where: { isActive: true },
      select: { id: true, name: true, slug: true },
    });

    const v2CategoryNames = new Set(existingV2Categories.map(c => c.name.toLowerCase().trim()));
    const v2CategorySlugs = new Set(existingV2Categories.map(c => c.slug.toLowerCase().trim()));

    // Helper function to generate slug from name
    function generateSlug(name: string): string {
      return name
        .toLowerCase()
        .trim()
        .replace(/[^a-z0-9]+/g, '-')
        .replace(/^-+|-+$/g, '');
    }

    // Helper function to ensure unique slug
    function ensureUniqueSlug(baseSlug: string, existingSlugs: Set<string>): string {
      let slug = baseSlug;
      let counter = 1;
      while (existingSlugs.has(slug)) {
        slug = `${baseSlug}-${counter}`;
        counter++;
      }
      existingSlugs.add(slug);
      return slug;
    }

    // Separate parent and child categories
    const v1ParentCategories = v1CategoriesList.filter(c => c.parent_id === 0 || c.parent_id === null);
    const v1ChildCategories = v1CategoriesList.filter(c => c.parent_id !== 0 && c.parent_id !== null);
    
    // Sort child categories by depth - process parent children before their grandchildren
    // This ensures that when we import a child category, its parent is already in the map
    const getCategoryDepth = (categoryId: number, allCategories: typeof v1CategoriesList, depth = 0): number => {
      if (depth > 10) return depth; // Safety limit
      const cat = allCategories.find(c => c.category_id === categoryId);
      if (!cat || cat.parent_id === 0 || cat.parent_id === null) return depth;
      return getCategoryDepth(cat.parent_id, allCategories, depth + 1);
    };
    
    v1ChildCategories.sort((a, b) => {
      const depthA = getCategoryDepth(a.category_id, allV1CategoriesList);
      const depthB = getCategoryDepth(b.category_id, allV1CategoriesList);
      return depthA - depthB; // Process shallower categories first
    });

    logger.log(`📋 V1 Parent Categories: ${v1ParentCategories.length}`);
    logger.log(`📋 V1 Child Categories: ${v1ChildCategories.length}`);
    logger.log('');

    // Map to store V1 category_id -> V2 category UUID
    const v1ToV2CategoryMap = new Map<number, string>();

    let created = 0;
    let skipped = 0;
    let errors = 0;

    // First, import all parent categories
    logger.log('🔄 Importing parent categories...');
    logger.log('');

    for (const v1Cat of v1ParentCategories) {
      try {
        // Check if category already exists by name
        if (v2CategoryNames.has(v1Cat.category_name.toLowerCase().trim())) {
          logger.warn(`⚠️  Skipping "${v1Cat.category_name}" - already exists in V2`);
          // Find existing category and add to map
          const existing = existingV2Categories.find(
            c => c.name.toLowerCase().trim() === v1Cat.category_name.toLowerCase().trim()
          );
          if (existing) {
            v1ToV2CategoryMap.set(v1Cat.category_id, existing.id);
          }
          skipped++;
          continue;
        }

        // Generate slug
        const baseSlug = generateSlug(v1Cat.category_name);
        const slug = ensureUniqueSlug(baseSlug, v2CategorySlugs);

        // Create category in V2
        const v2Category = await prisma.category.create({
          data: {
            name: v1Cat.category_name.trim(),
            slug: slug,
            description: v1Cat.category_description || null,
            parentId: null, // Parent categories have no parent
            isActive: true,
            sortOrder: v1Cat.category_id, // Use V1 category_id as sort order
            legacyId: v1Cat.category_id, // Store V1 category_id as legacyId
          },
        });

        v1ToV2CategoryMap.set(v1Cat.category_id, v2Category.id);
        v2CategoryNames.add(v1Cat.category_name.toLowerCase().trim());
        v2CategorySlugs.add(slug);

        logger.log(`  ✅ Created: ${v1Cat.category_name} (${slug})`);
        created++;
      } catch (error: any) {
        errors++;
        logger.error(`  ❌ Error creating "${v1Cat.category_name}": ${error.message}`);
      }
    }

    logger.log('');
    logger.log(`✅ Created ${created} parent categories, skipped ${skipped}, errors ${errors}`);
    logger.log('');

    // Refresh existing V2 categories to include newly created ones
    const allV2Categories = await prisma.category.findMany({
      where: { isActive: true },
      select: { id: true, name: true, slug: true },
    });
    const allV2CategoryNames = new Set(allV2Categories.map(c => c.name.toLowerCase().trim()));
    const allV2CategorySlugs = new Set(allV2Categories.map(c => c.slug.toLowerCase().trim()));

    // Now import child categories
    created = 0;
    skipped = 0;
    errors = 0;

    logger.log('🔄 Importing child categories...');
    logger.log('');

    for (const v1Cat of v1ChildCategories) {
      try {
        // Check if parent category was imported
        const parentV2Id = v1ToV2CategoryMap.get(v1Cat.parent_id);
        if (!parentV2Id) {
          logger.warn(`⚠️  Skipping "${v1Cat.category_name}" - parent category (ID: ${v1Cat.parent_id}) not found`);
          skipped++;
          continue;
        }

        // Check if category already exists by name (check both initial list and newly created)
        if (allV2CategoryNames.has(v1Cat.category_name.toLowerCase().trim())) {
          logger.warn(`⚠️  Skipping "${v1Cat.category_name}" - already exists in V2`);
          // Find existing category and add to map (check both lists)
          const existing = allV2Categories.find(
            c => c.name.toLowerCase().trim() === v1Cat.category_name.toLowerCase().trim()
          ) || existingV2Categories.find(
            c => c.name.toLowerCase().trim() === v1Cat.category_name.toLowerCase().trim()
          );
          if (existing) {
            v1ToV2CategoryMap.set(v1Cat.category_id, existing.id);
            logger.debug(`  📌 Mapped existing V1 category ${v1Cat.category_id} (${v1Cat.category_name}) to V2 ${existing.id}`);
          } else {
            logger.warn(`  ⚠️  Could not find existing category "${v1Cat.category_name}" in V2 database`);
          }
          skipped++;
          continue;
        }

        // Generate slug
        const baseSlug = generateSlug(v1Cat.category_name);
        const slug = ensureUniqueSlug(baseSlug, v2CategorySlugs);

        // Create category in V2
        const v2Category = await prisma.category.create({
          data: {
            name: v1Cat.category_name.trim(),
            slug: slug,
            description: v1Cat.category_description || null,
            parentId: parentV2Id, // Set parent relationship
            isActive: true,
            sortOrder: v1Cat.category_id, // Use V1 category_id as sort order
            legacyId: v1Cat.category_id, // Store V1 category_id as legacyId
          },
        });

        v1ToV2CategoryMap.set(v1Cat.category_id, v2Category.id);
        allV2CategoryNames.add(v1Cat.category_name.toLowerCase().trim());
        allV2CategorySlugs.add(slug);
        allV2Categories.push({ id: v2Category.id, name: v2Category.name, slug: v2Category.slug });

        logger.log(`  ✅ Created: ${v1Cat.category_name} (${slug}) → Parent: ${v1Cat.parent_id}`);
        created++;
      } catch (error: any) {
        errors++;
        logger.error(`  ❌ Error creating "${v1Cat.category_name}": ${error.message}`);
      }
    }

    logger.log('');
    logger.log(`✅ Created ${created} child categories, skipped ${skipped}, errors ${errors}`);
    logger.log('');

    // Show final summary
    const totalV2Categories = await prisma.category.count({
      where: { isActive: true },
    });

    logger.log('📊 Final Summary:');
    logger.log(`  Total V2 categories: ${totalV2Categories}`);
    logger.log(`  V1 categories imported: ${v1ToV2CategoryMap.size}`);
    logger.log('');

    // Show category tree structure
    logger.log('📋 V2 Category Structure (after import):');
    const v2ParentCategories = await prisma.category.findMany({
      where: { parentId: null, isActive: true },
      include: { children: true },
      orderBy: { sortOrder: 'asc' },
    });

    for (const parent of v2ParentCategories) {
      logger.log(`  ${parent.name} (${parent.slug})`);
      if (parent.children.length > 0) {
        for (const child of parent.children) {
          logger.log(`    └─ ${child.name} (${child.slug})`);
        }
      }
    }

    await v1Connection.end();
    await app.close();
    process.exit(0);
  } catch (error) {
    logger.error('❌ Import failed:', error);
    if (v1Connection) {
      await v1Connection.end();
    }
    await app.close();
    process.exit(1);
  }
}

bootstrap();

