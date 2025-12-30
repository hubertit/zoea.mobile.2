import { PrismaClient } from '@prisma/client';
import * as dotenv from 'dotenv';

/**
 * Script to move categories under Experiences
 * Moves: Hiking, National Parks, Museums
 * 
 * Usage: npx ts-node scripts/move-categories-to-experiences.ts
 * 
 * Make sure DATABASE_URL is set in .env file
 */

// Load environment variables
dotenv.config();

const prisma = new PrismaClient();

async function moveCategoriesToExperiences() {
  try {
    console.log('Starting category reorganization...\n');

    // Step 1: Find Experiences category
    console.log('Step 1: Finding "Experiences" category...');
    const experiencesCategory = await prisma.category.findFirst({
      where: {
        slug: { equals: 'experiences', mode: 'insensitive' },
        isActive: true,
      },
    });

    if (!experiencesCategory) {
      console.error('❌ "Experiences" category not found!');
      throw new Error('Experiences category not found');
    }

    console.log(`✅ Found "Experiences" category:`);
    console.log(`   ID: ${experiencesCategory.id}`);
    console.log(`   Name: ${experiencesCategory.name}`);
    console.log(`   Slug: ${experiencesCategory.slug}\n`);

    // Step 2: Find categories to move
    const categoriesToMove = ['hiking', 'national-parks', 'museums'];
    const foundCategories = [];

    for (const slug of categoriesToMove) {
      console.log(`Step 2: Finding "${slug}" category...`);
      const category = await prisma.category.findFirst({
        where: {
          slug: { equals: slug, mode: 'insensitive' },
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

      if (category) {
        console.log(`✅ Found "${category.name}" category:`);
        console.log(`   ID: ${category.id}`);
        console.log(`   Name: ${category.name}`);
        console.log(`   Slug: ${category.slug}`);
        console.log(`   Current Parent ID: ${category.parentId || 'None (main category)'}`);
        console.log(`   Listings: ${category._count.listings} | Tours: ${category._count.tours}`);

        // Check if already a subcategory of Experiences
        if (category.parentId === experiencesCategory.id) {
          console.log(`   ℹ️  Already a subcategory of Experiences. Skipping.\n`);
        } else {
          foundCategories.push(category);
          console.log(`   ⏳ Will be moved under Experiences\n`);
        }
      } else {
        console.log(`   ⚠️  Category "${slug}" not found. Skipping.\n`);
      }
    }

    if (foundCategories.length === 0) {
      console.log('ℹ️  No categories need to be moved. All are already under Experiences or not found.');
      return;
    }

    // Step 3: Update categories
    console.log(`Step 3: Moving ${foundCategories.length} category/categories under Experiences...\n`);

    for (const category of foundCategories) {
      const updatedCategory = await prisma.category.update({
        where: {
          id: category.id,
        },
        data: {
          parentId: experiencesCategory.id,
        },
        include: {
          parent: true,
        },
      });

      console.log(`✅ Moved "${updatedCategory.name}" under "${updatedCategory.parent?.name}"`);
    }

    // Step 4: Verify the change
    console.log('\nStep 4: Verifying the changes...');
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
      console.log(`✅ Verification successful!`);
      console.log(`\n📁 ${experiencesWithChildren.name} now has ${experiencesWithChildren.children.length} subcategories:`);
      experiencesWithChildren.children.forEach((child) => {
        console.log(`   • ${child.name} (${child.slug})`);
      });
    }

    console.log('\n✅ Category reorganization complete!');
  } catch (error) {
    console.error('❌ Error reorganizing categories:', error);
    throw error;
  } finally {
    await prisma.$disconnect();
  }
}

moveCategoriesToExperiences()
  .then(() => {
    console.log('\n✅ Script completed successfully');
    process.exit(0);
  })
  .catch((error) => {
    console.error('\n❌ Script failed:', error);
    process.exit(1);
  });

