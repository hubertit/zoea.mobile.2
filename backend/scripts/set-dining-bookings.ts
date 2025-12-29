import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function setDiningBookings() {
  try {
    console.log('Setting acceptsBookings to true for dining-related listings...');

    // Find all dining-related categories
    const diningCategories = await prisma.category.findMany({
      where: {
        OR: [
          { slug: { in: ['dining', 'restaurants', 'cafe', 'fastfood', 'restaurant', 'cafes', 'fast-food'] } },
          { name: { contains: 'Dining', mode: 'insensitive' } },
          { name: { contains: 'Restaurant', mode: 'insensitive' } },
          { name: { contains: 'Cafe', mode: 'insensitive' } },
          { name: { contains: 'Fast Food', mode: 'insensitive' } },
          { name: { contains: 'Fastfood', mode: 'insensitive' } },
        ],
      },
    });

    console.log(`Found ${diningCategories.length} dining-related categories`);

    const categoryIds = diningCategories.map((cat) => cat.id);

    // Update all listings in these categories
    const result = await prisma.listing.updateMany({
      where: {
        categoryId: { in: categoryIds },
        deletedAt: null,
      },
      data: {
        acceptsBookings: true,
      },
    });

    console.log(`Updated ${result.count} listings to accept bookings`);
    console.log('Done!');
  } catch (error) {
    console.error('Error setting dining bookings:', error);
    throw error;
  } finally {
    await prisma.$disconnect();
  }
}

setDiningBookings();

