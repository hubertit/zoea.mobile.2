import { Injectable, NotFoundException, BadRequestException, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { Prisma } from '@prisma/client';

@Injectable()
export class MerchantsService {
  constructor(private prisma: PrismaService) {}

  // ============ BUSINESS PROFILE ============
  async getMyBusinesses(userId: string) {
    return this.prisma.merchantProfile.findMany({
      where: { userId, deletedAt: null },
      include: {
        city: { select: { id: true, name: true } },
        country: { select: { id: true, name: true } },
        media: { select: { id: true, url: true } },
        _count: { select: { listings: true, bookings: true } },
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async getBusiness(userId: string, businessId: string) {
    const business = await this.prisma.merchantProfile.findFirst({
      where: { id: businessId, userId, deletedAt: null },
      include: {
        city: true,
        country: true,
        districts: true,
        media: true,
        listings: {
          where: { deletedAt: null },
          take: 10,
          orderBy: { createdAt: 'desc' },
          include: {
            images: { include: { media: true }, take: 1, where: { isPrimary: true } },
          },
        },
        _count: { select: { listings: true, bookings: true } },
      },
    });

    if (!business) throw new NotFoundException('Business not found');
    return business;
  }

  async createBusiness(userId: string, data: any) {
    return this.prisma.merchantProfile.create({
      data: {
        userId,
        businessName: data.businessName,
        businessType: data.businessType,
        businessRegistrationNumber: data.businessRegistrationNumber,
        taxId: data.taxId,
        description: data.description,
        businessEmail: data.businessEmail,
        businessPhone: data.businessPhone,
        website: data.website,
        socialLinks: data.socialLinks,
        countryId: data.countryId,
        cityId: data.cityId,
        districtId: data.districtId,
        address: data.address,
        logoId: data.logoId,
        registrationStatus: 'pending',
      },
      include: {
        city: { select: { id: true, name: true } },
        country: { select: { id: true, name: true } },
      },
    });
  }

  async updateBusiness(userId: string, businessId: string, data: any) {
    const business = await this.prisma.merchantProfile.findFirst({
      where: { id: businessId, userId, deletedAt: null },
    });

    if (!business) throw new NotFoundException('Business not found');

    return this.prisma.merchantProfile.update({
      where: { id: businessId },
      data: {
        ...data,
        updatedAt: new Date(),
      },
      include: {
        city: { select: { id: true, name: true } },
        country: { select: { id: true, name: true } },
      },
    });
  }

  async deleteBusiness(userId: string, businessId: string) {
    const business = await this.prisma.merchantProfile.findFirst({
      where: { id: businessId, userId, deletedAt: null },
    });

    if (!business) throw new NotFoundException('Business not found');

    await this.prisma.merchantProfile.update({
      where: { id: businessId },
      data: { deletedAt: new Date() },
    });

    return { success: true };
  }

  // ============ LISTINGS ============
  async getListings(userId: string, businessId: string, params: { page?: number; limit?: number; status?: string }) {
    await this.verifyBusinessOwnership(userId, businessId);

    const { page = 1, limit = 20, status } = params;
    const skip = (page - 1) * limit;

    const where: Prisma.ListingWhereInput = {
      merchantId: businessId,
      deletedAt: null,
      ...(status && { status: status as any }),
    };

    const [listings, total] = await Promise.all([
      this.prisma.listing.findMany({
        where,
        skip,
        take: limit,
        include: {
          category: { select: { id: true, name: true } },
          city: { select: { id: true, name: true } },
          images: { include: { media: true }, orderBy: { sortOrder: 'asc' }, take: 5 },
          _count: { select: { bookings: true, reviews: true } },
        },
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.listing.count({ where }),
    ]);

    return { data: listings, meta: { total, page, limit, totalPages: Math.ceil(total / limit) } };
  }

  async getListing(userId: string, businessId: string, listingId: string) {
    await this.verifyBusinessOwnership(userId, businessId);

    const listing = await this.prisma.listing.findFirst({
      where: { id: listingId, merchantId: businessId, deletedAt: null },
      include: {
        category: true,
        city: true,
        country: true,
        district: true,
        merchant: { select: { id: true, businessName: true } },
        images: { include: { media: true }, orderBy: { sortOrder: 'asc' } },
        amenities: { include: { amenity: true } },
        tags: { include: { tag: true } },
        roomTypes: { where: { isActive: true }, orderBy: { basePrice: 'asc' } },
        restaurantTables: { where: { isActive: true }, orderBy: { tableNumber: 'asc' } },
        _count: { select: { bookings: true, reviews: true, favorites: true } },
      },
    });

    if (!listing) throw new NotFoundException('Listing not found');
    return listing;
  }

  async createListing(userId: string, businessId: string, data: any) {
    await this.verifyBusinessOwnership(userId, businessId);

    const slug = data.slug || this.generateSlug(data.name);

    // Build location if coordinates provided
    let locationData = {};
    if (data.latitude && data.longitude) {
      locationData = {
        location: Prisma.sql`ST_SetSRID(ST_MakePoint(${data.longitude}, ${data.latitude}), 4326)`,
      };
    }

    const listing = await this.prisma.listing.create({
      data: {
        merchantId: businessId,
        name: data.name,
        slug,
        description: data.description,
        shortDescription: data.shortDescription,
        type: data.type,
        categoryId: data.categoryId,
        countryId: data.countryId,
        cityId: data.cityId,
        districtId: data.districtId,
        address: data.address,
        postalCode: data.postalCode,
        locationName: data.locationName,
        minPrice: data.minPrice,
        maxPrice: data.maxPrice,
        currency: data.currency || 'RWF',
        priceUnit: data.priceUnit,
        contactPhone: data.contactPhone,
        contactEmail: data.contactEmail,
        website: data.website,
        operatingHours: data.operatingHours,
        metaTitle: data.metaTitle,
        metaDescription: data.metaDescription,
        status: 'draft',
        ...locationData,
      },
      include: {
        category: { select: { id: true, name: true } },
        city: { select: { id: true, name: true } },
      },
    });

    // Add amenities if provided
    if (data.amenityIds?.length) {
      await this.prisma.listingAmenity.createMany({
        data: data.amenityIds.map((amenityId: string) => ({
          listingId: listing.id,
          amenityId,
        })),
      });
    }

    // Add tags if provided
    if (data.tagIds?.length) {
      await this.prisma.listingTag.createMany({
        data: data.tagIds.map((tagId: string) => ({
          listingId: listing.id,
          tagId,
        })),
      });
    }

    return listing;
  }

  async updateListing(userId: string, businessId: string, listingId: string, data: any) {
    await this.verifyBusinessOwnership(userId, businessId);

    const listing = await this.prisma.listing.findFirst({
      where: { id: listingId, merchantId: businessId, deletedAt: null },
    });

    if (!listing) throw new NotFoundException('Listing not found');

    const { amenityIds, tagIds, latitude, longitude, ...updateData } = data;

    const updated = await this.prisma.listing.update({
      where: { id: listingId },
      data: {
        ...updateData,
      },
      include: {
        category: { select: { id: true, name: true } },
        city: { select: { id: true, name: true } },
      },
    });

    // Update amenities if provided
    if (amenityIds) {
      await this.prisma.listingAmenity.deleteMany({ where: { listingId } });
      if (amenityIds.length) {
        await this.prisma.listingAmenity.createMany({
          data: amenityIds.map((amenityId: string) => ({ listingId, amenityId })),
        });
      }
    }

    // Update tags if provided
    if (tagIds) {
      await this.prisma.listingTag.deleteMany({ where: { listingId } });
      if (tagIds.length) {
        await this.prisma.listingTag.createMany({
          data: tagIds.map((tagId: string) => ({ listingId, tagId })),
        });
      }
    }

    return updated;
  }

  async deleteListing(userId: string, businessId: string, listingId: string) {
    await this.verifyBusinessOwnership(userId, businessId);

    const listing = await this.prisma.listing.findFirst({
      where: { id: listingId, merchantId: businessId, deletedAt: null },
    });

    if (!listing) throw new NotFoundException('Listing not found');

    await this.prisma.listing.update({
      where: { id: listingId },
      data: { deletedAt: new Date() },
    });

    return { success: true };
  }

  async submitListing(userId: string, businessId: string, listingId: string) {
    await this.verifyBusinessOwnership(userId, businessId);

    const listing = await this.prisma.listing.findFirst({
      where: { id: listingId, merchantId: businessId, deletedAt: null },
    });

    if (!listing) throw new NotFoundException('Listing not found');
    if (listing.status !== 'draft') throw new BadRequestException('Only draft listings can be submitted');

    return this.prisma.listing.update({
      where: { id: listingId },
      data: { status: 'pending_review' },
    });
  }

  // ============ LISTING IMAGES ============
  async addListingImage(userId: string, businessId: string, listingId: string, data: { mediaId: string; isPrimary?: boolean; caption?: string }) {
    await this.verifyBusinessOwnership(userId, businessId);

    const listing = await this.prisma.listing.findFirst({
      where: { id: listingId, merchantId: businessId, deletedAt: null },
    });

    if (!listing) throw new NotFoundException('Listing not found');

    const maxOrder = await this.prisma.listingImage.aggregate({
      where: { listingId },
      _max: { sortOrder: true },
    });

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
        isPrimary: data.isPrimary || false,
        caption: data.caption,
        sortOrder: (maxOrder._max.sortOrder || 0) + 1,
      },
      include: { media: true },
    });
  }

  async removeListingImage(userId: string, businessId: string, listingId: string, imageId: string) {
    await this.verifyBusinessOwnership(userId, businessId);

    const image = await this.prisma.listingImage.findFirst({
      where: { id: imageId, listingId },
      include: { listing: true },
    });

    if (!image || image.listing.merchantId !== businessId) {
      throw new NotFoundException('Image not found');
    }

    await this.prisma.listingImage.delete({ where: { id: imageId } });
    return { success: true };
  }

  // ============ ROOM TYPES (Hotels) ============
  async getRoomTypes(userId: string, businessId: string, listingId: string) {
    await this.verifyBusinessOwnership(userId, businessId);

    return this.prisma.roomType.findMany({
      where: { listingId, isActive: true },
      orderBy: { basePrice: 'asc' },
    });
  }

  async createRoomType(userId: string, businessId: string, listingId: string, data: any) {
    await this.verifyBusinessOwnership(userId, businessId);

    const listing = await this.prisma.listing.findFirst({
      where: { id: listingId, merchantId: businessId, deletedAt: null, type: 'hotel' },
    });

    if (!listing) throw new NotFoundException('Hotel listing not found');

    return this.prisma.roomType.create({
      data: {
        listingId,
        name: data.name,
        description: data.description,
        maxOccupancy: data.maxOccupancy,
        bedType: data.bedType,
        bedCount: data.bedCount,
        roomSize: data.roomSize,
        basePrice: data.basePrice,
        currency: data.currency || 'RWF',
        totalRooms: data.totalRooms,
        amenities: data.amenities || [],
      },
    });
  }

  async updateRoomType(userId: string, businessId: string, roomTypeId: string, data: any) {
    const roomType = await this.prisma.roomType.findUnique({
      where: { id: roomTypeId },
      include: { listing: true },
    });

    if (!roomType || roomType.listing.merchantId !== businessId) {
      throw new NotFoundException('Room type not found');
    }

    await this.verifyBusinessOwnership(userId, businessId);

    return this.prisma.roomType.update({
      where: { id: roomTypeId },
      data,
    });
  }

  async deleteRoomType(userId: string, businessId: string, roomTypeId: string) {
    const roomType = await this.prisma.roomType.findUnique({
      where: { id: roomTypeId },
      include: { listing: true },
    });

    if (!roomType || roomType.listing.merchantId !== businessId) {
      throw new NotFoundException('Room type not found');
    }

    await this.verifyBusinessOwnership(userId, businessId);

    await this.prisma.roomType.update({
      where: { id: roomTypeId },
      data: { isActive: false },
    });

    return { success: true };
  }

  // ============ TABLES (Restaurants) ============
  async getTables(userId: string, businessId: string, listingId: string) {
    await this.verifyBusinessOwnership(userId, businessId);

    return this.prisma.restaurantTable.findMany({
      where: { listingId, isActive: true },
      orderBy: { tableNumber: 'asc' },
    });
  }

  async createTable(userId: string, businessId: string, listingId: string, data: any) {
    await this.verifyBusinessOwnership(userId, businessId);

    const listing = await this.prisma.listing.findFirst({
      where: { id: listingId, merchantId: businessId, deletedAt: null, type: 'restaurant' },
    });

    if (!listing) throw new NotFoundException('Restaurant listing not found');

    return this.prisma.restaurantTable.create({
      data: {
        listingId,
        tableNumber: data.tableNumber,
        capacity: data.capacity,
        minCapacity: data.minCapacity || 1,
        location: data.location,
        isActive: true,
      },
    });
  }

  async updateTable(userId: string, businessId: string, tableId: string, data: any) {
    const table = await this.prisma.restaurantTable.findUnique({
      where: { id: tableId },
      include: { listing: true },
    });

    if (!table || table.listing.merchantId !== businessId) {
      throw new NotFoundException('Table not found');
    }

    await this.verifyBusinessOwnership(userId, businessId);

    return this.prisma.restaurantTable.update({
      where: { id: tableId },
      data,
    });
  }

  async deleteTable(userId: string, businessId: string, tableId: string) {
    const table = await this.prisma.restaurantTable.findUnique({
      where: { id: tableId },
      include: { listing: true },
    });

    if (!table || table.listing.merchantId !== businessId) {
      throw new NotFoundException('Table not found');
    }

    await this.verifyBusinessOwnership(userId, businessId);

    await this.prisma.restaurantTable.update({
      where: { id: tableId },
      data: { isActive: false },
    });

    return { success: true };
  }

  // ============ BOOKINGS ============
  async getBookings(userId: string, businessId: string, params: { page?: number; limit?: number; status?: string; listingId?: string; startDate?: string; endDate?: string }) {
    await this.verifyBusinessOwnership(userId, businessId);

    const { page = 1, limit = 20, status, listingId, startDate, endDate } = params;
    const skip = (page - 1) * limit;

    const where: Prisma.BookingWhereInput = {
      merchantId: businessId,
      ...(status && { status: status as any }),
      ...(listingId && { listingId }),
      ...(startDate && { createdAt: { gte: new Date(startDate) } }),
      ...(endDate && { createdAt: { lte: new Date(endDate) } }),
    };

    const [bookings, total] = await Promise.all([
      this.prisma.booking.findMany({
        where,
        skip,
        take: limit,
        include: {
          user: { select: { id: true, fullName: true, email: true, phoneNumber: true } },
          listing: { select: { id: true, name: true, type: true } },
          roomType: { select: { id: true, name: true } },
          table: { select: { id: true, tableNumber: true } },
          guests: true,
        },
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.booking.count({ where }),
    ]);

    return { data: bookings, meta: { total, page, limit, totalPages: Math.ceil(total / limit) } };
  }

  async getBooking(userId: string, businessId: string, bookingId: string) {
    await this.verifyBusinessOwnership(userId, businessId);

    const booking = await this.prisma.booking.findFirst({
      where: { id: bookingId, merchantId: businessId },
      include: {
        user: { select: { id: true, fullName: true, email: true, phoneNumber: true, profileImage: true } },
        listing: { select: { id: true, name: true, type: true, address: true } },
        roomType: true,
        table: true,
        guests: true,
        transactions: { orderBy: { createdAt: 'desc' } },
      },
    });

    if (!booking) throw new NotFoundException('Booking not found');
    return booking;
  }

  async updateBookingStatus(userId: string, businessId: string, bookingId: string, data: { status: string; notes?: string; cancellationReason?: string }) {
    await this.verifyBusinessOwnership(userId, businessId);

    const booking = await this.prisma.booking.findFirst({
      where: { id: bookingId, merchantId: businessId },
    });

    if (!booking) throw new NotFoundException('Booking not found');

    const updateData: any = { status: data.status };

    if (data.status === 'confirmed') {
      updateData.confirmedAt = new Date();
    } else if (data.status === 'cancelled') {
      updateData.cancelledAt = new Date();
      updateData.cancellationReason = data.cancellationReason;
    } else if (data.status === 'completed') {
      updateData.completedAt = new Date();
    }

    if (data.notes) {
      updateData.internalNotes = data.notes;
    }

    return this.prisma.booking.update({
      where: { id: bookingId },
      data: updateData,
      include: {
        user: { select: { id: true, fullName: true, email: true } },
        listing: { select: { id: true, name: true } },
      },
    });
  }

  // ============ REVIEWS ============
  async getReviews(userId: string, businessId: string, params: { page?: number; limit?: number; listingId?: string; rating?: number }) {
    await this.verifyBusinessOwnership(userId, businessId);

    const { page = 1, limit = 20, listingId, rating } = params;
    const skip = (page - 1) * limit;

    // Get all listing IDs for this business
    const listings = await this.prisma.listing.findMany({
      where: { merchantId: businessId, deletedAt: null },
      select: { id: true },
    });

    const listingIds = listings.map(l => l.id);

    const where: Prisma.ReviewWhereInput = {
      listingId: listingId ? listingId : { in: listingIds },
      deletedAt: null,
      ...(rating && { rating }),
    };

    const [reviews, total] = await Promise.all([
      this.prisma.review.findMany({
        where,
        skip,
        take: limit,
        include: {
          user: { select: { id: true, fullName: true, profileImage: true } },
          listing: { select: { id: true, name: true } },
        },
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.review.count({ where }),
    ]);

    return { data: reviews, meta: { total, page, limit, totalPages: Math.ceil(total / limit) } };
  }

  async respondToReview(userId: string, businessId: string, reviewId: string, response: string) {
    await this.verifyBusinessOwnership(userId, businessId);

    const review = await this.prisma.review.findUnique({
      where: { id: reviewId },
      include: { listing: true },
    });

    if (!review || review.listing?.merchantId !== businessId) {
      throw new NotFoundException('Review not found');
    }

    return this.prisma.review.update({
      where: { id: reviewId },
      data: {
        response,
        responseAt: new Date(),
        responseBy: userId,
      },
    });
  }

  // ============ ANALYTICS ============
  async getDashboard(userId: string, businessId: string) {
    await this.verifyBusinessOwnership(userId, businessId);

    const now = new Date();
    const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);
    const startOfLastMonth = new Date(now.getFullYear(), now.getMonth() - 1, 1);
    const endOfLastMonth = new Date(now.getFullYear(), now.getMonth(), 0);

    const [
      business,
      totalListings,
      activeListings,
      totalBookingsThisMonth,
      totalBookingsLastMonth,
      revenueThisMonth,
      revenueLastMonth,
      pendingBookings,
      recentBookings,
      topListings,
      reviewStats,
    ] = await Promise.all([
      this.prisma.merchantProfile.findUnique({
        where: { id: businessId },
        select: { totalRevenue: true, totalBookings: true, averageRating: true },
      }),
      this.prisma.listing.count({ where: { merchantId: businessId, deletedAt: null } }),
      this.prisma.listing.count({ where: { merchantId: businessId, deletedAt: null, status: 'active' } }),
      this.prisma.booking.count({
        where: { merchantId: businessId, createdAt: { gte: startOfMonth } },
      }),
      this.prisma.booking.count({
        where: { merchantId: businessId, createdAt: { gte: startOfLastMonth, lte: endOfLastMonth } },
      }),
      this.prisma.booking.aggregate({
        where: { merchantId: businessId, createdAt: { gte: startOfMonth }, status: 'completed' },
        _sum: { totalAmount: true },
      }),
      this.prisma.booking.aggregate({
        where: { merchantId: businessId, createdAt: { gte: startOfLastMonth, lte: endOfLastMonth }, status: 'completed' },
        _sum: { totalAmount: true },
      }),
      this.prisma.booking.count({
        where: { merchantId: businessId, status: 'pending' },
      }),
      this.prisma.booking.findMany({
        where: { merchantId: businessId },
        take: 5,
        orderBy: { createdAt: 'desc' },
        include: {
          user: { select: { fullName: true } },
          listing: { select: { name: true } },
        },
      }),
      this.prisma.listing.findMany({
        where: { merchantId: businessId, deletedAt: null },
        take: 5,
        orderBy: { bookingCount: 'desc' },
        select: { id: true, name: true, bookingCount: true, rating: true },
      }),
      this.prisma.review.aggregate({
        where: {
          listing: { merchantId: businessId },
          deletedAt: null,
        },
        _avg: { rating: true },
        _count: true,
      }),
    ]);

    return {
      overview: {
        totalRevenue: business?.totalRevenue || 0,
        totalBookings: business?.totalBookings || 0,
        averageRating: business?.averageRating || 0,
        totalListings,
        activeListings,
      },
      thisMonth: {
        bookings: totalBookingsThisMonth,
        revenue: Number(revenueThisMonth._sum.totalAmount) || 0,
        bookingsChange: totalBookingsLastMonth > 0 
          ? ((totalBookingsThisMonth - totalBookingsLastMonth) / totalBookingsLastMonth * 100).toFixed(1)
          : 0,
        revenueChange: Number(revenueLastMonth._sum.totalAmount || 0) > 0
          ? (((Number(revenueThisMonth._sum.totalAmount) || 0) - (Number(revenueLastMonth._sum.totalAmount) || 0)) / (Number(revenueLastMonth._sum.totalAmount) || 1) * 100).toFixed(1)
          : 0,
      },
      pendingBookings,
      recentBookings,
      topListings,
      reviews: {
        averageRating: reviewStats._avg.rating || 0,
        totalReviews: reviewStats._count,
      },
    };
  }

  async getRevenueAnalytics(userId: string, businessId: string, params: { startDate?: string; endDate?: string; groupBy?: string }) {
    await this.verifyBusinessOwnership(userId, businessId);

    const { startDate, endDate, groupBy = 'day' } = params;

    const start = startDate ? new Date(startDate) : new Date(new Date().setMonth(new Date().getMonth() - 1));
    const end = endDate ? new Date(endDate) : new Date();

    const bookings = await this.prisma.booking.findMany({
      where: {
        merchantId: businessId,
        status: 'completed',
        createdAt: { gte: start, lte: end },
      },
      select: {
        totalAmount: true,
        currency: true,
        createdAt: true,
        bookingType: true,
      },
      orderBy: { createdAt: 'asc' },
    });

    // Group by period
    const grouped = bookings.reduce((acc: any, booking) => {
      let key: string;
      const date = new Date(booking.createdAt!);
      
      switch (groupBy) {
        case 'week':
          const weekStart = new Date(date);
          weekStart.setDate(date.getDate() - date.getDay());
          key = weekStart.toISOString().split('T')[0];
          break;
        case 'month':
          key = `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}`;
          break;
        case 'year':
          key = String(date.getFullYear());
          break;
        default:
          key = date.toISOString().split('T')[0];
      }

      if (!acc[key]) {
        acc[key] = { period: key, revenue: 0, bookings: 0 };
      }
      acc[key].revenue += Number(booking.totalAmount) || 0;
      acc[key].bookings += 1;
      return acc;
    }, {});

    return {
      data: Object.values(grouped),
      summary: {
        totalRevenue: bookings.reduce((sum, b) => sum + (Number(b.totalAmount) || 0), 0),
        totalBookings: bookings.length,
        period: { start, end },
      },
    };
  }

  async getBookingAnalytics(userId: string, businessId: string, params: { startDate?: string; endDate?: string }) {
    await this.verifyBusinessOwnership(userId, businessId);

    const { startDate, endDate } = params;
    const start = startDate ? new Date(startDate) : new Date(new Date().setMonth(new Date().getMonth() - 1));
    const end = endDate ? new Date(endDate) : new Date();

    const [byStatus, byType, byListing] = await Promise.all([
      this.prisma.booking.groupBy({
        by: ['status'],
        where: { merchantId: businessId, createdAt: { gte: start, lte: end } },
        _count: true,
      }),
      this.prisma.booking.groupBy({
        by: ['bookingType'],
        where: { merchantId: businessId, createdAt: { gte: start, lte: end } },
        _count: true,
        _sum: { totalAmount: true },
      }),
      this.prisma.booking.groupBy({
        by: ['listingId'],
        where: { merchantId: businessId, createdAt: { gte: start, lte: end } },
        _count: true,
        _sum: { totalAmount: true },
      }),
    ]);

    // Get listing names
    const listingIds = byListing.map(b => b.listingId).filter(Boolean) as string[];
    const listings = await this.prisma.listing.findMany({
      where: { id: { in: listingIds } },
      select: { id: true, name: true },
    });
    const listingMap = new Map(listings.map(l => [l.id, l.name]));

    return {
      byStatus: byStatus.map(s => ({ status: s.status, count: s._count })),
      byType: byType.map(t => ({ type: t.bookingType, count: t._count, revenue: t._sum.totalAmount || 0 })),
      byListing: byListing.map(l => ({
        listingId: l.listingId,
        listingName: listingMap.get(l.listingId!) || 'Unknown',
        count: l._count,
        revenue: l._sum.totalAmount || 0,
      })).sort((a, b) => b.count - a.count).slice(0, 10),
    };
  }

  // ============ PROMOTIONS ============
  // Note: Promotions in the schema use merchantIds (array) - merchants can be part of promotions
  async getPromotions(userId: string, businessId: string, params: { page?: number; limit?: number; active?: boolean }) {
    await this.verifyBusinessOwnership(userId, businessId);

    const { page = 1, limit = 20, active } = params;
    const skip = (page - 1) * limit;

    const where: Prisma.PromotionWhereInput = {
      merchantIds: { has: businessId },
      ...(active !== undefined && { isActive: active }),
    };

    const [promotions, total] = await Promise.all([
      this.prisma.promotion.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.promotion.count({ where }),
    ]);

    return { data: promotions, meta: { total, page, limit } };
  }

  // Note: Promotions are typically created by admins, not merchants
  // This method allows merchants to opt-in to existing promotions
  async joinPromotion(userId: string, businessId: string, promotionId: string) {
    await this.verifyBusinessOwnership(userId, businessId);

    const promotion = await this.prisma.promotion.findUnique({
      where: { id: promotionId },
    });

    if (!promotion) throw new NotFoundException('Promotion not found');
    if (!promotion.isActive) throw new BadRequestException('Promotion is not active');

    // Add business to promotion's merchantIds
    const merchantIds = promotion.merchantIds || [];
    if (merchantIds.includes(businessId)) {
      throw new BadRequestException('Already participating in this promotion');
    }

    return this.prisma.promotion.update({
      where: { id: promotionId },
      data: {
        merchantIds: [...merchantIds, businessId],
      },
    });
  }

  async leavePromotion(userId: string, businessId: string, promotionId: string) {
    await this.verifyBusinessOwnership(userId, businessId);

    const promotion = await this.prisma.promotion.findUnique({
      where: { id: promotionId },
    });

    if (!promotion) throw new NotFoundException('Promotion not found');

    const merchantIds = (promotion.merchantIds || []).filter(id => id !== businessId);

    return this.prisma.promotion.update({
      where: { id: promotionId },
      data: { merchantIds },
    });
  }

  async getAvailablePromotions(userId: string, businessId: string) {
    await this.verifyBusinessOwnership(userId, businessId);

    const now = new Date();
    return this.prisma.promotion.findMany({
      where: {
        isActive: true,
        startDate: { lte: now },
        endDate: { gte: now },
        NOT: { merchantIds: { has: businessId } },
      },
      orderBy: { createdAt: 'desc' },
      take: 20,
    });
  }

  // ============ HELPERS ============
  private async verifyBusinessOwnership(userId: string, businessId: string) {
    const business = await this.prisma.merchantProfile.findFirst({
      where: { id: businessId, userId, deletedAt: null },
    });

    if (!business) {
      throw new ForbiddenException('You do not have access to this business');
    }

    return business;
  }

  private generateSlug(name: string): string {
    return name
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, '-')
      .replace(/(^-|-$)/g, '')
      + '-' + Date.now().toString(36);
  }
}

