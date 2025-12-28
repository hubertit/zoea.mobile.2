import { Injectable, NotFoundException, BadRequestException, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { Prisma } from '@prisma/client';

@Injectable()
export class ListingsService {
  constructor(private prisma: PrismaService) {}

  async findAll(params: {
    page?: number;
    limit?: number;
    type?: string;
    status?: string;
    cityId?: string;
    countryId?: string;
    categoryId?: string;
    merchantId?: string;
    isFeatured?: boolean;
    minPrice?: number;
    maxPrice?: number;
    search?: string;
    amenities?: string[];
    rating?: number;
  }) {
    const { page = 1, limit = 20, type, status, cityId, countryId, categoryId, merchantId, isFeatured, minPrice, maxPrice, search, amenities, rating } = params;
    const skip = (page - 1) * limit;

    const where: Prisma.ListingWhereInput = {
      deletedAt: null,
      ...(type && { type: type as any }),
      ...(status && { status: status as any }),
      ...(cityId && { cityId }),
      ...(countryId && { countryId }),
      ...(categoryId && { categoryId }),
      ...(merchantId && { merchantId }),
      ...(isFeatured !== undefined && { isFeatured }),
      ...(minPrice && { minPrice: { gte: minPrice } }),
      ...(maxPrice && { maxPrice: { lte: maxPrice } }),
      ...(rating && { rating: { gte: rating } }),
      ...(search && {
        OR: [
          { name: { contains: search, mode: 'insensitive' } },
          { description: { contains: search, mode: 'insensitive' } },
        ],
      }),
      ...(amenities?.length && {
        amenities: { some: { amenityId: { in: amenities } } },
      }),
    };

    const [listings, total] = await Promise.all([
      this.prisma.listing.findMany({
        where,
        skip,
        take: limit,
        include: {
          category: { select: { id: true, name: true, slug: true, icon: true } },
          city: { select: { id: true, name: true, slug: true } },
          country: { select: { id: true, name: true, code: true } },
          images: { include: { media: true }, orderBy: { sortOrder: 'asc' } },
          _count: { select: { reviews: true, bookings: true, favorites: true } },
        },
        orderBy: [{ isFeatured: 'desc' }, { rating: 'desc' }, { createdAt: 'desc' }],
      }),
      this.prisma.listing.count({ where }),
    ]);

    return {
      data: listings,
      meta: { total, page, limit, totalPages: Math.ceil(total / limit) },
    };
  }

  async findOne(id: string) {
    const listing = await this.prisma.listing.findUnique({
      where: { id },
      include: {
        category: true,
        city: true,
        country: true,
        district: true,
        merchant: { select: { id: true, businessName: true, isVerified: true, averageRating: true, userId: true } },
        images: { include: { media: true }, orderBy: { sortOrder: 'asc' } },
        amenities: { include: { amenity: true } },
        tags: { include: { tag: true } },
        roomTypes: { where: { isActive: true }, orderBy: { basePrice: 'asc' } },
        restaurantTables: { where: { isActive: true } },
        reviews: { 
          where: { status: 'approved', deletedAt: null },
          take: 10,
          orderBy: { createdAt: 'desc' },
          include: { user: { select: { id: true, fullName: true, profileImageId: true } } }
        },
        _count: { select: { reviews: true, bookings: true, favorites: true } },
      },
    });

    if (!listing) throw new NotFoundException('Listing not found');

    await this.prisma.listing.update({
      where: { id },
      data: { viewCount: { increment: 1 } },
    });

    return listing;
  }

  async findBySlug(slug: string) {
    const listing = await this.prisma.listing.findUnique({
      where: { slug },
      include: {
        category: true,
        city: true,
        country: true,
        merchant: { select: { id: true, businessName: true, isVerified: true } },
        images: { include: { media: true }, orderBy: { sortOrder: 'asc' } },
        amenities: { include: { amenity: true } },
        roomTypes: { where: { isActive: true } },
        _count: { select: { reviews: true, bookings: true } },
      },
    });

    if (!listing) throw new NotFoundException('Listing not found');
    return listing;
  }

  async findByType(type: string, params: { page?: number; limit?: number; cityId?: string }) {
    return this.findAll({ ...params, type, status: 'active' });
  }

  async getFeatured(limit = 10) {
    return this.prisma.listing.findMany({
      where: { isFeatured: true, status: 'active', deletedAt: null },
      take: limit,
      include: {
        category: { select: { id: true, name: true, icon: true } },
        city: { select: { id: true, name: true } },
        images: { include: { media: true }, take: 1, where: { isPrimary: true } },
      },
      orderBy: { rating: 'desc' },
    });
  }

  async getNearby(latitude: number, longitude: number, radiusKm = 10, limit = 20) {
    const listings = await this.prisma.$queryRaw`
      SELECT l.*, 
        ST_Distance(l.location::geography, ST_SetSRID(ST_MakePoint(${longitude}, ${latitude}), 4326)::geography) / 1000 as distance_km
      FROM listings l
      WHERE l.status = 'active' 
        AND l.deleted_at IS NULL
        AND l.location IS NOT NULL
        AND ST_DWithin(l.location::geography, ST_SetSRID(ST_MakePoint(${longitude}, ${latitude}), 4326)::geography, ${radiusKm * 1000})
      ORDER BY distance_km
      LIMIT ${limit}
    `;
    return listings;
  }

  async getRandom(limit = 10) {
    // Get random listing IDs using PostgreSQL's random() function
    // Only select ID to avoid geography column deserialization issues
    const listings = await this.prisma.$queryRaw<Array<{ id: string }>>`
      SELECT l.id
      FROM listings l
      WHERE l.status = 'active' 
        AND l.deleted_at IS NULL
      ORDER BY RANDOM()
      LIMIT ${limit}
    `;
    
    // Fetch full details with relations for each listing
    const listingIds = listings.map((l) => l.id);
    
    if (listingIds.length === 0) {
      return [];
    }
    
    return this.prisma.listing.findMany({
      where: {
        id: { in: listingIds },
        status: 'active',
        deletedAt: null,
      },
      include: {
        category: { select: { id: true, name: true, icon: true } },
        city: { select: { id: true, name: true } },
        images: { include: { media: true }, take: 1, where: { isPrimary: true } },
      },
    });
  }

  // ============ MERCHANT LISTING MANAGEMENT ============
  async getMyListings(merchantId: string, params: { page?: number; limit?: number; status?: string }) {
    return this.findAll({ ...params, merchantId });
  }

  async create(merchantId: string, data: {
    name: string;
    slug?: string;
    description?: string;
    shortDescription?: string;
    type: string;
    categoryId?: string;
    countryId?: string;
    cityId?: string;
    districtId?: string;
    address?: string;
    postalCode?: string;
    locationName?: string;
    minPrice?: number;
    maxPrice?: number;
    currency?: string;
    priceUnit?: string;
    contactPhone?: string;
    contactEmail?: string;
    website?: string;
    operatingHours?: any;
    metaTitle?: string;
    metaDescription?: string;
  }) {
    // Generate slug if not provided
    const slug = data.slug || this.generateSlug(data.name);

    // Check slug uniqueness
    const existing = await this.prisma.listing.findUnique({ where: { slug } });
    if (existing) throw new BadRequestException('Slug already exists');

    return this.prisma.listing.create({
      data: {
        merchantId,
        name: data.name,
        slug,
        description: data.description,
        shortDescription: data.shortDescription,
        type: data.type as any,
        categoryId: data.categoryId,
        status: 'draft',
        countryId: data.countryId,
        cityId: data.cityId,
        districtId: data.districtId,
        address: data.address,
        postalCode: data.postalCode,
        locationName: data.locationName,
        minPrice: data.minPrice,
        maxPrice: data.maxPrice,
        currency: data.currency || 'RWF',
        priceUnit: data.priceUnit as any,
        contactPhone: data.contactPhone,
        contactEmail: data.contactEmail,
        website: data.website,
        operatingHours: data.operatingHours,
        metaTitle: data.metaTitle,
        metaDescription: data.metaDescription,
      },
      include: {
        category: true,
        city: true,
        country: true,
      },
    });
  }

  async update(id: string, merchantId: string, data: Partial<{
    name: string;
    slug: string;
    description: string;
    shortDescription: string;
    categoryId: string;
    countryId: string;
    cityId: string;
    districtId: string;
    address: string;
    postalCode: string;
    locationName: string;
    minPrice: number;
    maxPrice: number;
    currency: string;
    priceUnit: string;
    contactPhone: string;
    contactEmail: string;
    website: string;
    operatingHours: any;
    metaTitle: string;
    metaDescription: string;
  }>) {
    const listing = await this.prisma.listing.findUnique({ where: { id } });
    if (!listing) throw new NotFoundException('Listing not found');
    if (listing.merchantId !== merchantId) throw new ForbiddenException('Not authorized');

    if (data.slug && data.slug !== listing.slug) {
      const existing = await this.prisma.listing.findFirst({
        where: { slug: data.slug, id: { not: id } },
      });
      if (existing) throw new BadRequestException('Slug already exists');
    }

    return this.prisma.listing.update({
      where: { id },
      data: {
        ...data,
        priceUnit: data.priceUnit as any,
      },
    });
  }

  async submitForReview(id: string, merchantId: string) {
    const listing = await this.prisma.listing.findUnique({ where: { id } });
    if (!listing) throw new NotFoundException('Listing not found');
    if (listing.merchantId !== merchantId) throw new ForbiddenException('Not authorized');
    if (listing.status !== 'draft') throw new BadRequestException('Only draft listings can be submitted');

    return this.prisma.listing.update({
      where: { id },
      data: { status: 'pending_review' },
    });
  }

  async delete(id: string, merchantId?: string) {
    const listing = await this.prisma.listing.findUnique({ where: { id } });
    if (!listing) throw new NotFoundException('Listing not found');
    if (merchantId && listing.merchantId !== merchantId) throw new ForbiddenException('Not authorized');

    return this.prisma.listing.update({
      where: { id },
      data: { deletedAt: new Date() },
    });
  }

  // ============ IMAGES ============
  async addImage(listingId: string, merchantId: string, data: { mediaId: string; isPrimary?: boolean; caption?: string }) {
    const listing = await this.prisma.listing.findUnique({ where: { id: listingId } });
    if (!listing) throw new NotFoundException('Listing not found');
    if (listing.merchantId !== merchantId) throw new ForbiddenException('Not authorized');

    const count = await this.prisma.listingImage.count({ where: { listingId } });

    if (data.isPrimary) {
      await this.prisma.listingImage.updateMany({
        where: { listingId },
        data: { isPrimary: false },
      });
    }

    return this.prisma.listingImage.create({
      data: {
        listingId,
        mediaId: data.mediaId,
        isPrimary: data.isPrimary || count === 0,
        caption: data.caption,
        sortOrder: count,
      },
      include: { media: true },
    });
  }

  async removeImage(listingId: string, imageId: string, merchantId: string) {
    const listing = await this.prisma.listing.findUnique({ where: { id: listingId } });
    if (!listing) throw new NotFoundException('Listing not found');
    if (listing.merchantId !== merchantId) throw new ForbiddenException('Not authorized');

    await this.prisma.listingImage.delete({ where: { id: imageId } });
    return { success: true };
  }

  async reorderImages(listingId: string, merchantId: string, imageIds: string[]) {
    const listing = await this.prisma.listing.findUnique({ where: { id: listingId } });
    if (!listing) throw new NotFoundException('Listing not found');
    if (listing.merchantId !== merchantId) throw new ForbiddenException('Not authorized');

    await Promise.all(
      imageIds.map((id, index) =>
        this.prisma.listingImage.update({
          where: { id },
          data: { sortOrder: index },
        })
      )
    );

    return { success: true };
  }

  // ============ AMENITIES ============
  async setAmenities(listingId: string, merchantId: string, amenityIds: string[]) {
    const listing = await this.prisma.listing.findUnique({ where: { id: listingId } });
    if (!listing) throw new NotFoundException('Listing not found');
    if (listing.merchantId !== merchantId) throw new ForbiddenException('Not authorized');

    await this.prisma.listingAmenity.deleteMany({ where: { listingId } });
    
    if (amenityIds.length > 0) {
      await this.prisma.listingAmenity.createMany({
        data: amenityIds.map(amenityId => ({ listingId, amenityId })),
      });
    }

    return this.prisma.listing.findUnique({
      where: { id: listingId },
      include: { amenities: { include: { amenity: true } } },
    });
  }

  // ============ ROOM TYPES (Hotels) ============
  async getRoomTypes(listingId: string) {
    return this.prisma.roomType.findMany({
      where: { listingId, isActive: true },
      include: {
        availability: {
          where: { date: { gte: new Date() } },
          orderBy: { date: 'asc' },
          take: 30,
        },
      },
      orderBy: { basePrice: 'asc' },
    });
  }

  async createRoomType(listingId: string, merchantId: string, data: {
    name: string;
    description?: string;
    maxOccupancy: number;
    bedType?: string;
    bedCount?: number;
    roomSize?: number;
    basePrice: number;
    currency?: string;
    totalRooms: number;
    amenities?: string[];
  }) {
    const listing = await this.prisma.listing.findUnique({ where: { id: listingId } });
    if (!listing) throw new NotFoundException('Listing not found');
    if (listing.merchantId !== merchantId) throw new ForbiddenException('Not authorized');
    if (listing.type !== 'hotel') throw new BadRequestException('Room types only for hotels');

    return this.prisma.roomType.create({
      data: {
        listingId,
        name: data.name,
        description: data.description,
        maxOccupancy: data.maxOccupancy,
        bedType: data.bedType,
        bedCount: data.bedCount || 1,
        roomSize: data.roomSize,
        basePrice: data.basePrice,
        currency: data.currency || 'RWF',
        totalRooms: data.totalRooms,
        amenities: data.amenities || [],
      },
    });
  }

  async updateRoomType(roomTypeId: string, merchantId: string, data: Partial<{
    name: string;
    description: string;
    maxOccupancy: number;
    bedType: string;
    bedCount: number;
    roomSize: number;
    basePrice: number;
    totalRooms: number;
    amenities: string[];
    isActive: boolean;
  }>) {
    const roomType = await this.prisma.roomType.findUnique({
      where: { id: roomTypeId },
      include: { listing: { select: { merchantId: true } } },
    });
    if (!roomType) throw new NotFoundException('Room type not found');
    if (!roomType.listing || roomType.listing.merchantId !== merchantId) throw new ForbiddenException('Not authorized');

    const { merchantId: _, ...updateData } = data as any;
    return this.prisma.roomType.update({
      where: { id: roomTypeId },
      data: updateData,
    });
  }

  async deleteRoomType(roomTypeId: string, merchantId: string) {
    const roomType = await this.prisma.roomType.findUnique({
      where: { id: roomTypeId },
      include: { listing: { select: { merchantId: true } } },
    });
    if (!roomType) throw new NotFoundException('Room type not found');
    if (roomType.listing.merchantId !== merchantId) throw new ForbiddenException('Not authorized');

    return this.prisma.roomType.update({
      where: { id: roomTypeId },
      data: { isActive: false },
    });
  }

  // ============ RESTAURANT TABLES ============
  async getTables(listingId: string) {
    return this.prisma.restaurantTable.findMany({
      where: { listingId, isActive: true },
      orderBy: { tableNumber: 'asc' },
    });
  }

  async createTable(listingId: string, merchantId: string, data: {
    tableNumber: string;
    capacity: number;
    minCapacity?: number;
    location?: string;
  }) {
    const listing = await this.prisma.listing.findUnique({ where: { id: listingId } });
    if (!listing) throw new NotFoundException('Listing not found');
    if (listing.merchantId !== merchantId) throw new ForbiddenException('Not authorized');
    if (listing.type !== 'restaurant') throw new BadRequestException('Tables only for restaurants');

    return this.prisma.restaurantTable.create({
      data: {
        listingId,
        tableNumber: data.tableNumber,
        capacity: data.capacity,
        minCapacity: data.minCapacity || 1,
        location: data.location,
      },
    });
  }

  async updateTable(tableId: string, merchantId: string, data: Partial<{
    tableNumber: string;
    capacity: number;
    minCapacity: number;
    location: string;
    status: string;
    isActive: boolean;
  }>) {
    const table = await this.prisma.restaurantTable.findUnique({
      where: { id: tableId },
      include: { listing: { select: { merchantId: true } } },
    });
    if (!table) throw new NotFoundException('Table not found');
    if (!table.listing || table.listing.merchantId !== merchantId) throw new ForbiddenException('Not authorized');

    const { merchantId: _, ...updateData } = data as any;
    return this.prisma.restaurantTable.update({
      where: { id: tableId },
      data: { ...updateData, status: updateData.status as any },
    });
  }

  async deleteTable(tableId: string, merchantId: string) {
    const table = await this.prisma.restaurantTable.findUnique({
      where: { id: tableId },
      include: { listing: { select: { merchantId: true } } },
    });
    if (!table) throw new NotFoundException('Table not found');
    if (table.listing.merchantId !== merchantId) throw new ForbiddenException('Not authorized');

    return this.prisma.restaurantTable.update({
      where: { id: tableId },
      data: { isActive: false },
    });
  }

  async checkAvailability(listingId: string, checkIn: Date, checkOut: Date, guests: number) {
    const roomTypes = await this.prisma.roomType.findMany({
      where: {
        listingId,
        isActive: true,
        maxOccupancy: { gte: guests },
      },
      include: {
        availability: {
          where: {
            date: { gte: checkIn, lt: checkOut },
            availableCount: { gt: 0 },
            isBlocked: false,
          },
        },
      },
    });

    return roomTypes.filter(rt => {
      const nights = Math.ceil((checkOut.getTime() - checkIn.getTime()) / (1000 * 60 * 60 * 24));
      return rt.availability.length >= nights;
    });
  }

  private generateSlug(name: string): string {
    return name
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, '-')
      .replace(/(^-|-$)/g, '')
      + '-' + Date.now().toString(36);
  }
}
