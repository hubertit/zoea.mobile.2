/**
 * Populate Accommodation Listing Data
 * 
 * This script:
 * 1. Fetches all accommodation listings from the API/database
 * 2. Analyzes what data is missing (images, prices, amenities, room types)
 * 3. Generates and populates missing data in the database
 * 
 * Run: ts-node src/migration/populate-accommodation-data.ts
 */

import { NestFactory } from '@nestjs/core';
import { AppModule } from '../app.module';
import { PrismaService } from '../prisma/prisma.service';
import { Logger } from '@nestjs/common';
import { Prisma } from '@prisma/client';

// Mock Unsplash image URLs for hotels
const MOCK_HOTEL_IMAGES = [
  'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&h=600&fit=crop',
  'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=800&h=600&fit=crop',
  'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=800&h=600&fit=crop',
  'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=800&h=600&fit=crop',
  'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800&h=600&fit=crop',
  'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800&h=600&fit=crop',
  'https://images.unsplash.com/photo-1613490493576-7fde63acd811?w=800&h=600&fit=crop',
  'https://images.unsplash.com/photo-1564501049412-61c2a3083791?w=800&h=600&fit=crop',
  'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=800&h=600&fit=crop',
  'https://images.unsplash.com/photo-1596436889106-be35e843f974?w=800&h=600&fit=crop',
];

// Default amenities based on rating
function getDefaultAmenities(rating: number | null): string[] {
  const amenities: string[] = ['WiFi'];
  
  if (!rating || rating >= 3.5) {
    amenities.push('Parking');
  }
  if (!rating || rating >= 4.0) {
    amenities.push('Pool', 'Restaurant');
  }
  if (!rating || rating >= 4.5) {
    amenities.push('Spa', 'Fitness Center');
  }
  
  return amenities;
}

// Generate default price based on rating
function generateDefaultPrice(rating: number | null, listingId: string): { minPrice: number; maxPrice: number } {
  // Base price calculation: rating * 20000 RWF, minimum 50000
  const basePrice = rating && rating > 0 ? rating * 20000 : 50000;
  
  // Add variation based on listing ID hash for uniqueness
  const hash = listingId.split('').reduce((acc, char) => acc + char.charCodeAt(0), 0);
  const variation = (hash % 50000);
  
  const minPrice = Math.round(basePrice + variation);
  const maxPrice = Math.round(minPrice * 1.5); // 50% markup for max price
  
  return { minPrice, maxPrice };
}

// Generate default room types for hotels
function generateDefaultRoomTypes(listingId: string, minPrice: number): Array<{
  name: string;
  description: string;
  basePrice: number;
  maxOccupancy: number;
  bedType: string;
  totalRooms: number;
}> {
  const hash = listingId.split('').reduce((acc, char) => acc + char.charCodeAt(0), 0);
  const roomCount = 2 + (hash % 3); // 2-4 room types
  
  const roomTypes = [];
  const roomNames = ['Standard Room', 'Deluxe Room', 'Executive Suite', 'Presidential Suite'];
  const bedTypes = ['King Bed', 'Queen Bed', 'Twin Beds', 'Double Bed'];
  
  for (let i = 0; i < roomCount; i++) {
    const roomName = roomNames[i] || `Room Type ${i + 1}`;
    const basePrice = Math.round(minPrice * (1 + i * 0.3)); // Each room type is 30% more expensive
    const maxOccupancy = 2 + (i * 2); // 2, 4, 6, 8 guests
    const bedType = bedTypes[i % bedTypes.length];
    const totalRooms = 3 + (hash % 5); // 3-7 rooms per type
    
    roomTypes.push({
      name: roomName,
      description: `${bedType}, ${maxOccupancy} guests, Modern amenities`,
      basePrice,
      maxOccupancy,
      bedType,
      totalRooms,
    });
  }
  
  return roomTypes;
}

async function bootstrap() {
  const app = await NestFactory.createApplicationContext(AppModule);
  const prisma = app.get(PrismaService);
  const logger = new Logger('PopulateAccommodationData');

  logger.log('🏨 Starting Accommodation Data Population...');
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

    // Get all accommodation listings
    const listings = await prisma.listing.findMany({
      where: {
        categoryId: accommodationCategory.id,
        deletedAt: null,
      },
      include: {
        images: {
          include: { media: true },
          orderBy: { sortOrder: 'asc' },
        },
        amenities: {
          include: { amenity: true },
        },
        roomTypes: {
          where: { isActive: true },
        },
      },
    });

    logger.log(`📊 Found ${listings.length} accommodation listings`);
    logger.log('');

    // Analyze what's missing
    let missingImages = 0;
    let missingPrices = 0;
    let missingAmenities = 0;
    let missingRoomTypes = 0;

    for (const listing of listings) {
      if (listing.images.length === 0) missingImages++;
      if (!listing.minPrice || listing.minPrice.equals(0)) missingPrices++;
      if (listing.amenities.length === 0) missingAmenities++;
      if (listing.roomTypes.length === 0) missingRoomTypes++;
    }

    logger.log('📊 Missing Data Analysis:');
    logger.log(`  Images: ${missingImages} listings`);
    logger.log(`  Prices: ${missingPrices} listings`);
    logger.log(`  Amenities: ${missingAmenities} listings`);
    logger.log(`  Room Types: ${missingRoomTypes} listings`);
    logger.log('');

    // Get or create amenities
    const amenityMap = new Map<string, string>();
    const defaultAmenityNames = ['WiFi', 'Parking', 'Pool', 'Restaurant', 'Spa', 'Fitness Center'];
    
    for (const amenityName of defaultAmenityNames) {
      let amenity = await prisma.amenity.findFirst({
        where: { name: { equals: amenityName, mode: 'insensitive' } },
      });
      
      if (!amenity) {
        amenity = await prisma.amenity.create({
          data: {
            name: amenityName,
            slug: amenityName.toLowerCase().replace(/\s+/g, '-'),
            icon: 'star',
            category: 'general',
          },
        });
        logger.log(`  ✅ Created amenity: ${amenityName}`);
      }
      
      amenityMap.set(amenityName.toLowerCase(), amenity.id);
    }

    logger.log('');
    logger.log('🔄 Populating missing data...');
    logger.log('');

    let imagesAdded = 0;
    let pricesUpdated = 0;
    let amenitiesAdded = 0;
    let roomTypesAdded = 0;
    let errors = 0;

    for (const listing of listings) {
      try {
        // 1. Add images if missing
        if (listing.images.length === 0) {
          const imageIndex = listing.id.split('').reduce((acc, char) => acc + char.charCodeAt(0), 0) % MOCK_HOTEL_IMAGES.length;
          const imageUrl = MOCK_HOTEL_IMAGES[imageIndex];
          
          // Create media record
          const media = await prisma.media.create({
            data: {
              url: imageUrl,
              mediaType: 'image',
              fileName: `hotel-${listing.slug || listing.id}.jpg`,
              storageProvider: 'external',
              category: 'venue',
              altText: listing.name || 'Hotel image',
            },
          });

          // Create listing image
          await prisma.listingImage.create({
            data: {
              listingId: listing.id,
              mediaId: media.id,
              isPrimary: true,
              sortOrder: 0,
            },
          });

          imagesAdded++;
        }

        // 2. Add prices if missing
        if (!listing.minPrice || listing.minPrice.equals(0)) {
          const rating = listing.rating ? parseFloat(listing.rating.toString()) : null;
          const { minPrice, maxPrice } = generateDefaultPrice(rating, listing.id);
          
          await prisma.listing.update({
            where: { id: listing.id },
            data: {
              minPrice: new Prisma.Decimal(minPrice),
              maxPrice: new Prisma.Decimal(maxPrice),
              currency: 'RWF',
            },
          });

          pricesUpdated++;
        }

        // 3. Add amenities if missing
        if (listing.amenities.length === 0) {
          const rating = listing.rating ? parseFloat(listing.rating.toString()) : null;
          const defaultAmenities = getDefaultAmenities(rating);
          
          for (const amenityName of defaultAmenities) {
            const amenityId = amenityMap.get(amenityName.toLowerCase());
            if (amenityId) {
              // Check if already linked
              const existing = await prisma.listingAmenity.findFirst({
                where: {
                  listingId: listing.id,
                  amenityId: amenityId,
                },
              });

              if (!existing) {
                await prisma.listingAmenity.create({
                  data: {
                    listingId: listing.id,
                    amenityId: amenityId,
                  },
                });
              }
            }
          }

          amenitiesAdded++;
        }

        // 4. Add room types if missing (only for hotels)
        if (listing.type === 'hotel' && listing.roomTypes.length === 0) {
          const minPrice = listing.minPrice ? parseFloat(listing.minPrice.toString()) : 50000;
          const roomTypes = generateDefaultRoomTypes(listing.id, minPrice);
          
          for (const roomType of roomTypes) {
            await prisma.roomType.create({
              data: {
                listingId: listing.id,
                name: roomType.name,
                description: roomType.description,
                basePrice: new Prisma.Decimal(roomType.basePrice),
                maxOccupancy: roomType.maxOccupancy,
                bedType: roomType.bedType,
                totalRooms: roomType.totalRooms,
                currency: 'RWF',
                amenities: [],
                images: [],
                isActive: true,
              },
            });
          }

          roomTypesAdded += roomTypes.length;
        }

        if ((imagesAdded + pricesUpdated + amenitiesAdded + roomTypesAdded) % 10 === 0) {
          logger.log(`  ✅ Processed ${imagesAdded + pricesUpdated + amenitiesAdded + roomTypesAdded} updates...`);
        }
      } catch (error: any) {
        errors++;
        logger.error(`  ❌ Error processing ${listing.name || listing.id}: ${error.message}`);
      }
    }

    logger.log('');
    logger.log('✅ Population Complete!');
    logger.log(`  Images added: ${imagesAdded}`);
    logger.log(`  Prices updated: ${pricesUpdated}`);
    logger.log(`  Amenities added: ${amenitiesAdded} listings`);
    logger.log(`  Room types added: ${roomTypesAdded} room types`);
    logger.log(`  Errors: ${errors}`);
    logger.log('');

    // Verify results
    const updatedListings = await prisma.listing.findMany({
      where: {
        categoryId: accommodationCategory.id,
        deletedAt: null,
      },
      include: {
        images: true,
        amenities: true,
        roomTypes: { where: { isActive: true } },
      },
    });

    logger.log('📊 Final Statistics:');
    logger.log(`  Total listings: ${updatedListings.length}`);
    logger.log(`  With images: ${updatedListings.filter(l => l.images.length > 0).length}`);
    logger.log(`  With prices: ${updatedListings.filter(l => l.minPrice && !l.minPrice.equals(0)).length}`);
    logger.log(`  With amenities: ${updatedListings.filter(l => l.amenities.length > 0).length}`);
    logger.log(`  With room types: ${updatedListings.filter(l => l.roomTypes.length > 0).length}`);

    await app.close();
    process.exit(0);
  } catch (error) {
    logger.error('❌ Population failed:', error);
    await app.close();
    process.exit(1);
  }
}

bootstrap();

