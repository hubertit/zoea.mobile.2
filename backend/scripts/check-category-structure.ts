import { NestFactory } from '@nestjs/core';
import { AppModule } from '../src/app.module';
import { PrismaService } from '../src/prisma/prisma.service';
import { Logger } from '@nestjs/common';

/**
 * Script to check current category structure
 * Shows all parent categories and their subcategories
 */

interface CategoryNode {
  id: string;
  name: string;
  slug: string;
  parentId: string | null;
  children: CategoryNode[];
  listingCount: number;
  tourCount: number;
}

async function checkCategoryStructure() {
  const app = await NestFactory.createApplicationContext(AppModule);
  const prisma = app.get(PrismaService);
  const logger = new Logger('CheckCategoryStructure');

  try {
    logger.log('Fetching all categories...');

    // Get all categories with their children and counts
    const allCategories = await prisma.category.findMany({
      where: {
        isActive: true,
      },
      include: {
        children: {
          where: { isActive: true },
          orderBy: { sortOrder: 'asc' },
        },
        _count: {
          select: {
            listings: true,
            tours: true,
          },
        },
      },
      orderBy: { sortOrder: 'asc' },
    });

    // Separate parent and child categories
    const parentCategories = allCategories.filter((cat) => !cat.parentId);
    const childCategories = allCategories.filter((cat) => cat.parentId);

    logger.log('\n=== PARENT CATEGORIES ===\n');

    parentCategories.forEach((category) => {
      const listingCount = category._count.listings;
      const tourCount = category._count.tours;
      const childCount = category.children.length;

      console.log(`📁 ${category.name} (${category.slug})`);
      console.log(`   ID: ${category.id}`);
      console.log(`   Listings: ${listingCount} | Tours: ${tourCount} | Subcategories: ${childCount}`);

      if (category.children.length > 0) {
        console.log(`   └─ Subcategories:`);
        category.children.forEach((child) => {
          const childListingCount = child._count?.listings || 0;
          const childTourCount = child._count?.tours || 0;
          console.log(`      • ${child.name} (${child.slug}) - Listings: ${childListingCount}, Tours: ${childTourCount}`);
        });
      }
      console.log('');
    });

    if (childCategories.length > 0) {
      logger.log('\n=== ORPHANED SUBCATEGORIES (have parentId but parent not found) ===\n');
      childCategories.forEach((category) => {
        const parent = allCategories.find((c) => c.id === category.parentId);
        if (!parent) {
          console.log(`⚠️  ${category.name} (${category.slug})`);
          console.log(`   ID: ${category.id}`);
          console.log(`   Parent ID: ${category.parentId} (NOT FOUND)`);
          console.log('');
        }
      });
    }

    // Check for specific categories mentioned
    logger.log('\n=== CHECKING SPECIFIC CATEGORIES ===\n');

    const targetCategories = ['attractions', 'experiences', 'hiking'];
    for (const slug of targetCategories) {
      const category = allCategories.find((c) => c.slug.toLowerCase() === slug.toLowerCase());
      if (category) {
        console.log(`✅ ${category.name} (${category.slug})`);
        console.log(`   ID: ${category.id}`);
        console.log(`   Parent: ${category.parentId ? 'Has parent' : 'NO PARENT (main category)'}`);
        if (category.parentId) {
          const parent = allCategories.find((c) => c.id === category.parentId);
          console.log(`   Parent Name: ${parent?.name || 'NOT FOUND'}`);
        }
        console.log(`   Listings: ${category._count.listings} | Tours: ${category._count.tours}`);
        console.log(`   Subcategories: ${category.children.length}`);
        if (category.children.length > 0) {
          category.children.forEach((child) => {
            console.log(`      • ${child.name} (${child.slug})`);
          });
        }
        console.log('');
      } else {
        console.log(`❌ Category "${slug}" not found`);
        console.log('');
      }
    }

    logger.log('✅ Category structure check complete!');
  } catch (error) {
    logger.error('Error checking category structure:', error);
    throw error;
  } finally {
    await app.close();
  }
}

checkCategoryStructure()
  .then(() => {
    console.log('\n✅ Script completed successfully');
    process.exit(0);
  })
  .catch((error) => {
    console.error('\n❌ Script failed:', error);
    process.exit(1);
  });

