/**
 * Populate Listing Descriptions
 * 
 * This script generates and populates missing descriptions and shortDescriptions
 * for accommodation listings based on their available data (name, type, location, amenities, etc.)
 * 
 * Run: ts-node src/migration/populate-listing-descriptions.ts
 */

import { NestFactory } from '@nestjs/core';
import { AppModule } from '../app.module';
import { PrismaService } from '../prisma/prisma.service';
import { Logger } from '@nestjs/common';

// Generate description based on listing data
function generateDescription(listing: any): { description: string; shortDescription: string } {
  const name = listing.name || 'this accommodation';
  const type = listing.type || 'hotel';
  const city = listing.city?.name || '';
  const country = listing.country?.name || 'Rwanda';
  const address = listing.address || '';
  const rating = listing.rating ? parseFloat(listing.rating.toString()) : null;
  const location = city ? `${city}, ${country}` : country;
  
  // Get amenities
  const amenities = listing.amenities || [];
  const amenityNames = amenities
    .map((a: any) => a.amenity?.name)
    .filter((n: string) => n)
    .slice(0, 5);
  
  // Build amenity text
  let amenityText = '';
  if (amenityNames.length > 0) {
    if (amenityNames.length === 1) {
      amenityText = ` featuring ${amenityNames[0]}`;
    } else if (amenityNames.length === 2) {
      amenityText = ` featuring ${amenityNames[0]} and ${amenityNames[1]}`;
    } else {
      const lastAmenity = amenityNames.pop();
      amenityText = ` featuring ${amenityNames.join(', ')}, and ${lastAmenity}`;
    }
  }
  
  // Type-specific descriptions
  const typeDescriptions: Record<string, string> = {
    hotel: 'hotel',
    restaurant: 'restaurant',
    cafe: 'café',
    bar: 'bar',
    club: 'nightclub',
    lounge: 'lounge',
    tour: 'tour experience',
    attraction: 'attraction',
    boutique: 'boutique',
    mall: 'shopping mall',
    market: 'market',
  };
  
  const typeName = typeDescriptions[type] || 'accommodation';
  const ratingText = rating && rating >= 4.5 ? ' highly-rated' : rating && rating >= 4.0 ? ' well-rated' : '';
  
  // Generate full description
  const description = `${name} is a${ratingText} ${typeName} located in ${location}${address ? ` at ${address}` : ''}.${amenityText ? ` Our establishment offers${amenityText}.` : ''} Experience comfort, quality service, and a memorable stay in the heart of ${country}.`;
  
  // Generate short description (max 500 chars, but aim for ~150)
  const shortDescription = `${name} - A ${typeName} in ${location}${amenityText ? ` with${amenityText}` : ''}.`;
  
  return {
    description: description.substring(0, 2000), // Ensure it fits in database
    shortDescription: shortDescription.substring(0, 500),
  };
}

async function bootstrap() {
  const app = await NestFactory.createApplicationContext(AppModule);
  const prisma = app.get(PrismaService);
  const logger = new Logger('PopulateListingDescriptions');

  logger.log('📝 Starting Listing Description Population...');
  logger.log('');

  try {
    // Get accommodation category ID
    const accommodationCategory = await prisma.category.findFirst({
      where: { slug: 'accommodation' },
      select: { id: true },
    });

    if (!accommodationCategory) {
      logger.error('❌ Accommodation category not found!');
      await app.close();
      process.exit(1);
    }

    // Get all accommodation listings with related data
    const listings = await prisma.listing.findMany({
      where: {
        categoryId: accommodationCategory.id,
        deletedAt: null,
      },
      include: {
        city: true,
        country: true,
        category: true,
        amenities: {
          include: {
            amenity: true,
          },
        },
      },
    });

    logger.log(`📊 Found ${listings.length} accommodation listings`);
    logger.log('');

    // Analyze missing descriptions
    let missingDescription = 0;
    let missingShortDescription = 0;

    for (const listing of listings) {
      if (!listing.description) missingDescription++;
      if (!listing.shortDescription) missingShortDescription++;
    }

    logger.log('📊 Missing Data Analysis:');
    logger.log(`  Full descriptions: ${missingDescription} listings`);
    logger.log(`  Short descriptions: ${missingShortDescription} listings`);
    logger.log('');

    logger.log('🔄 Populating missing descriptions...');
    logger.log('');

    let descriptionsUpdated = 0;
    let shortDescriptionsUpdated = 0;
    let errors = 0;

    for (const listing of listings) {
      try {
        const updates: any = {};
        let hasUpdates = false;

        // Generate and update description if missing
        if (!listing.description) {
          const { description, shortDescription } = generateDescription(listing);
          updates.description = description;
          if (!listing.shortDescription) {
            updates.shortDescription = shortDescription;
            shortDescriptionsUpdated++;
          }
          descriptionsUpdated++;
          hasUpdates = true;
        } else if (!listing.shortDescription) {
          // Only generate short description if full description exists
          const { shortDescription } = generateDescription(listing);
          updates.shortDescription = shortDescription;
          shortDescriptionsUpdated++;
          hasUpdates = true;
        }

        if (hasUpdates) {
          await prisma.listing.update({
            where: { id: listing.id },
            data: updates,
          });
        }

        if ((descriptionsUpdated + shortDescriptionsUpdated) % 10 === 0) {
          logger.log(`  ✅ Processed ${descriptionsUpdated + shortDescriptionsUpdated} updates...`);
        }
      } catch (error: any) {
        errors++;
        logger.error(`  ❌ Error processing ${listing.name || listing.id}: ${error.message}`);
      }
    }

    logger.log('');
    logger.log('✅ Population Complete!');
    logger.log(`  Full descriptions added: ${descriptionsUpdated}`);
    logger.log(`  Short descriptions added: ${shortDescriptionsUpdated}`);
    logger.log(`  Errors: ${errors}`);
    logger.log('');

    // Verify results
    const updatedListings = await prisma.listing.findMany({
      where: {
        categoryId: accommodationCategory.id,
        deletedAt: null,
      },
      select: {
        id: true,
        name: true,
        description: true,
        shortDescription: true,
      },
    });

    logger.log('📊 Final Statistics:');
    logger.log(`  Total listings: ${updatedListings.length}`);
    logger.log(`  With full description: ${updatedListings.filter(l => l.description).length}`);
    logger.log(`  With short description: ${updatedListings.filter(l => l.shortDescription).length}`);

    await app.close();
    process.exit(0);
  } catch (error) {
    logger.error('❌ Population failed:', error);
    await app.close();
    process.exit(1);
  }
}

bootstrap();

