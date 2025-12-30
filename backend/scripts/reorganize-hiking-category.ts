import { NestFactory } from '@nestjs/core';
import { AppModule } from '../src/app.module';
import { PrismaService } from '../src/prisma/prisma.service';
import { Logger } from '@nestjs/common';

/**
 * Script to reorganize Hiking category
 * Moves Hiking from a main category to a subcategory of Experiences
 * 
 * Steps:
 * 1. Find "Experiences" category (parent)
 * 2. Find "Hiking" category
 * 3. Update Hiking's parentId to point to Experiences
 * 4. Verify the change
 */

async function reorganizeHikingCategory() {
  const app = await NestFactory.createApplicationContext(AppModule);
  const prisma = app.get(PrismaService);
  const logger = new Logger('ReorganizeHikingCategory');

  try {
    logger.log('Starting category reorganization...\n');

    // Step 1: Find Experiences category
    logger.log('Step 1: Finding "Experiences" category...');
    const experiencesCategory = await prisma.category.findFirst({
      where: {
        slug: { equals: 'experiences', mode: 'insensitive' },
        isActive: true,
      },
    });

    if (!experiencesCategory) {
      logger.error('❌ "Experiences" category not found!');
      logger.log('Available categories:');
      const allCategories = await prisma.category.findMany({
        where: { isActive: true },
        select: { name: true, slug: true, parentId: true },
      });
      allCategories.forEach((cat) => {
        console.log(`  - ${cat.name} (${cat.slug}) - Parent: ${cat.parentId || 'None'}`);
      });
      throw new Error('Experiences category not found');
    }

    logger.log(`✅ Found "Experiences" category:`);
    logger.log(`   ID: ${experiencesCategory.id}`);
    logger.log(`   Name: ${experiencesCategory.name}`);
    logger.log(`   Slug: ${experiencesCategory.slug}\n`);

    // Step 2: Find Hiking category
    logger.log('Step 2: Finding "Hiking" category...');
    const hikingCategory = await prisma.category.findFirst({
      where: {
        slug: { equals: 'hiking', mode: 'insensitive' },
        isActive: true,
      },
      include: {
        _count: {
          select: {
            listings: true,
            tours: true,
          },
        },
      },
    });

    if (!hikingCategory) {
      logger.error('❌ "Hiking" category not found!');
      throw new Error('Hiking category not found');
    }

    logger.log(`✅ Found "Hiking" category:`);
    logger.log(`   ID: ${hikingCategory.id}`);
    logger.log(`   Name: ${hikingCategory.name}`);
    logger.log(`   Slug: ${hikingCategory.slug}`);
    logger.log(`   Current Parent ID: ${hikingCategory.parentId || 'None (main category)'}`);
    logger.log(`   Listings: ${hikingCategory._count.listings}`);
    logger.log(`   Tours: ${hikingCategory._count.tours}\n`);

    // Check if already a subcategory of Experiences
    if (hikingCategory.parentId === experiencesCategory.id) {
      logger.log('ℹ️  Hiking is already a subcategory of Experiences. No changes needed.');
      return;
    }

    // Step 3: Update Hiking's parentId
    logger.log('Step 3: Updating Hiking category to be a subcategory of Experiences...');
    
    const updatedCategory = await prisma.category.update({
      where: {
        id: hikingCategory.id,
      },
      data: {
        parentId: experiencesCategory.id,
      },
      include: {
        parent: true,
        _count: {
          select: {
            listings: true,
            tours: true,
          },
        },
      },
    });

    logger.log(`✅ Successfully updated Hiking category!`);
    logger.log(`   New Parent: ${updatedCategory.parent?.name} (${updatedCategory.parent?.slug})`);
    logger.log(`   Parent ID: ${updatedCategory.parentId}\n`);

    // Step 4: Verify the change
    logger.log('Step 4: Verifying the change...');
    const experiencesWithChildren = await prisma.category.findUnique({
      where: {
        id: experiencesCategory.id,
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
    });

    if (experiencesWithChildren) {
      logger.log(`✅ Verification successful!`);
      logger.log(`\n📁 ${experiencesWithChildren.name} now has ${experiencesWithChildren.children.length} subcategories:`);
      experiencesWithChildren.children.forEach((child) => {
        console.log(`   • ${child.name} (${child.slug})`);
      });
    }

    logger.log('\n✅ Category reorganization complete!');
  } catch (error) {
    logger.error('❌ Error reorganizing category:', error);
    throw error;
  } finally {
    await app.close();
  }
}

reorganizeHikingCategory()
  .then(() => {
    console.log('\n✅ Script completed successfully');
    process.exit(0);
  })
  .catch((error) => {
    console.error('\n❌ Script failed:', error);
    process.exit(1);
  });

