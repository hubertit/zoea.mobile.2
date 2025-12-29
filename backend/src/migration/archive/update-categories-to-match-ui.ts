import { NestFactory } from '@nestjs/core';
import { AppModule } from '../app.module';
import { PrismaService } from '../prisma/prisma.service';
import { Logger } from '@nestjs/common';

/**
 * Migration script to update category names and structure to match UI/UX design
 * 
 * UI/UX Categories:
 * 1. Events
 * 2. Dining (subcategories: Restaurants, Cafes, Fast Food)
 * 3. Experiences (subcategories: Adventure, Cultural, Nature, Water)
 * 4. Nightlife (subcategories: Bars, Clubs, Lounges)
 * 5. Accommodation (subcategories: Hotels, Hostels, Resorts)
 * 6. Shopping (subcategories: Malls, Markets, Boutiques)
 * 7. Attractions (separate category, will add listings to it)
 * 
 * Current Backend Categories:
 * 1. Hotels & Resorts → Accommodation
 * 2. Restaurants & Cafes → Dining
 * 3. Bars & Nightlife → Nightlife
 * 4. Tours & Experiences → Experiences
 * 5. Events & Entertainment → Events
 * 6. Shopping → Shopping
 * 7. Attractions → Attractions (keep as separate parent)
 * 
 * NOTE: Subcategories are stored in the SAME table as parent categories
 * using a self-referential relationship (parentId field).
 */

interface CategoryUpdate {
  id: string;
  newName: string;
  newSlug: string;
  subcategories: Array<{ name: string; slug: string; sortOrder: number }>;
}

const categoryUpdates: CategoryUpdate[] = [
  {
    id: 'bd4d61fe-0db8-40d6-b76a-3578bfb2e8e3', // Hotels & Resorts
    newName: 'Accommodation',
    newSlug: 'accommodation',
    subcategories: [
      { name: 'Hotels', slug: 'hotels', sortOrder: 1 },
      { name: 'Hostels', slug: 'hostels', sortOrder: 2 },
      { name: 'Resorts', slug: 'resorts', sortOrder: 3 },
    ],
  },
  {
    id: '17592625-d465-4039-b168-6369251eaa9b', // Restaurants & Cafes
    newName: 'Dining',
    newSlug: 'dining',
    subcategories: [
      { name: 'Restaurants', slug: 'restaurants', sortOrder: 1 },
      { name: 'Cafes', slug: 'cafes', sortOrder: 2 },
      { name: 'Fast Food', slug: 'fast-food', sortOrder: 3 },
    ],
  },
  {
    id: 'e7a3ccf5-1e2c-4d50-9ff3-9b145f294f3d', // Bars & Nightlife
    newName: 'Nightlife',
    newSlug: 'nightlife',
    subcategories: [
      { name: 'Bars', slug: 'bars', sortOrder: 1 },
      { name: 'Clubs', slug: 'clubs', sortOrder: 2 },
      { name: 'Lounges', slug: 'lounges', sortOrder: 3 },
    ],
  },
  {
    id: '7189f215-1aef-4dba-b92c-05cdde123ff3', // Tours & Experiences
    newName: 'Experiences',
    newSlug: 'experiences',
    subcategories: [
      { name: 'Adventure', slug: 'adventure', sortOrder: 1 },
      { name: 'Cultural', slug: 'cultural', sortOrder: 2 },
      { name: 'Nature', slug: 'nature', sortOrder: 3 },
      { name: 'Water', slug: 'water', sortOrder: 4 },
    ],
  },
  {
    id: '0ecf49af-3b9e-48cc-b6c8-7b4b192efd05', // Events & Entertainment
    newName: 'Events',
    newSlug: 'events',
    subcategories: [], // Events might not need subcategories, or we can add them later
  },
  {
    id: 'b8d1cafd-c113-42d8-9d00-7eb06ff357fd', // Shopping
    newName: 'Shopping',
    newSlug: 'shopping',
    subcategories: [
      { name: 'Malls', slug: 'malls', sortOrder: 1 },
      { name: 'Markets', slug: 'markets', sortOrder: 2 },
      { name: 'Boutiques', slug: 'boutiques', sortOrder: 3 },
    ],
  },
  // Attractions - keep as separate parent category (will add listings to it)
  {
    id: '29cca857-0675-40fe-a0d1-38fd181fa3f8', // Attractions
    newName: 'Attractions',
    newSlug: 'attractions',
    subcategories: [], // No subcategories for now, can add later if needed
  },
];

async function bootstrap() {
  const app = await NestFactory.createApplicationContext(AppModule);
  const prisma = app.get(PrismaService);
  const logger = new Logger('UpdateCategoriesToMatchUI');

  logger.log('🔄 Starting category update to match UI/UX design...');
  logger.log('');

  try {
    for (const update of categoryUpdates) {
      // Check if category exists
      const existingCategory = await prisma.category.findUnique({
        where: { id: update.id },
        include: { children: true },
      });

      if (!existingCategory) {
        logger.warn(`⚠️  Category ${update.id} not found, skipping...`);
        continue;
      }

      logger.log(`📝 Updating category: ${existingCategory.name} → ${update.newName}`);

      // Update parent category name and slug
      await prisma.category.update({
        where: { id: update.id },
        data: {
          name: update.newName,
          slug: update.newSlug,
        },
      });

      // Delete existing subcategories if any
      if (existingCategory.children.length > 0) {
        logger.log(`  🗑️  Deleting ${existingCategory.children.length} existing subcategories...`);
        await prisma.category.deleteMany({
          where: { parentId: update.id },
        });
      }

      // Create new subcategories
      if (update.subcategories.length > 0) {
        logger.log(`  ➕ Creating ${update.subcategories.length} subcategories...`);
        for (const subcat of update.subcategories) {
          // Check if subcategory already exists (by slug)
          const existingSubcat = await prisma.category.findUnique({
            where: { slug: subcat.slug },
          });

          if (existingSubcat) {
            // Update existing subcategory
            await prisma.category.update({
              where: { id: existingSubcat.id },
              data: {
                name: subcat.name,
                parentId: update.id,
                sortOrder: subcat.sortOrder,
              },
            });
            logger.log(`    ✅ Updated subcategory: ${subcat.name}`);
          } else {
            // Create new subcategory
            await prisma.category.create({
              data: {
                name: subcat.name,
                slug: subcat.slug,
                parentId: update.id,
                sortOrder: subcat.sortOrder,
                isActive: true,
              },
            });
            logger.log(`    ✅ Created subcategory: ${subcat.name}`);
          }
        }
      }

      logger.log(`  ✅ Completed: ${update.newName}`);
      logger.log('');
    }

    // Update sort order for parent categories to match UI order
    const sortOrderMap: Record<string, number> = {
      'accommodation': 1,
      'dining': 2,
      'nightlife': 3,
      'experiences': 4,
      'events': 5,
      'shopping': 6,
      'attractions': 7,
    };

    logger.log('📊 Updating sort order for parent categories...');
    for (const [slug, order] of Object.entries(sortOrderMap)) {
      await prisma.category.updateMany({
        where: { slug, parentId: null },
        data: { sortOrder: order },
      });
    }

    logger.log('');
    logger.log('✅ Category update complete!');
    logger.log('');

    // Display summary
    const allCategories = await prisma.category.findMany({
      where: { parentId: null },
      include: { children: true },
      orderBy: { sortOrder: 'asc' },
    });

    logger.log('📋 Final Category Structure:');
    logger.log('');
    for (const cat of allCategories) {
      logger.log(`  ${cat.name} (${cat.slug})`);
      if (cat.children.length > 0) {
        for (const child of cat.children) {
          logger.log(`    └─ ${child.name} (${child.slug})`);
        }
      }
    }

    await app.close();
  } catch (error) {
    logger.error('❌ Error updating categories:', error);
    await app.close();
    process.exit(1);
  }
}

bootstrap();

