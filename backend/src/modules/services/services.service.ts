import { Injectable, NotFoundException, BadRequestException, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { Prisma } from '@prisma/client';
import { CreateServiceDto, UpdateServiceDto, ServiceQueryDto, CreateServiceBookingDto, UpdateServiceBookingDto } from './dto/service.dto';

@Injectable()
export class ServicesService {
  constructor(private prisma: PrismaService) {}

  async findAll(params: ServiceQueryDto & { listingId?: string }) {
    const { page = 1, limit = 20, listingId, status, search, category, minPrice, maxPrice, isFeatured, sortBy = 'popular' } = params;
    const skip = (page - 1) * limit;

    const where: Prisma.ServiceWhereInput = {
      deletedAt: null,
      ...(listingId && { listingId }),
      ...(status && { status: status as any }),
      ...(category && { category }),
      ...(minPrice && { basePrice: { gte: minPrice } }),
      ...(maxPrice && { basePrice: { lte: maxPrice } }),
      ...(isFeatured !== undefined && { isFeatured }),
      ...(search && {
        OR: [
          { name: { contains: search, mode: 'insensitive' } },
          { description: { contains: search, mode: 'insensitive' } },
          { shortDescription: { contains: search, mode: 'insensitive' } },
        ],
      }),
    };

    // Build orderBy based on sortBy parameter
    let orderBy: Prisma.ServiceOrderByWithRelationInput[] | Prisma.ServiceOrderByWithRelationInput;
    
    switch (sortBy) {
      case 'name_asc':
        orderBy = { name: 'asc' };
        break;
      case 'name_desc':
        orderBy = { name: 'desc' };
        break;
      case 'price_asc':
        orderBy = { basePrice: 'asc' };
        break;
      case 'price_desc':
        orderBy = { basePrice: 'desc' };
        break;
      case 'createdAt_desc':
        orderBy = { createdAt: 'desc' };
        break;
      case 'createdAt_asc':
        orderBy = { createdAt: 'asc' };
        break;
      case 'popular':
      default:
        // Default: featured first, then by booking count, then by creation date
        orderBy = [{ isFeatured: 'desc' }, { bookingCount: 'desc' }, { createdAt: 'desc' }];
        break;
    }

    const [services, total] = await Promise.all([
      this.prisma.service.findMany({
        where,
        skip,
        take: limit,
        include: {
          listing: { 
            select: { 
              id: true, 
              name: true, 
              slug: true,
              merchantId: true,
            } 
          },
          _count: { 
            select: { 
              serviceBookings: true, 
              orderItems: true,
            } 
          },
        },
        orderBy,
      }),
      this.prisma.service.count({ where }),
    ]);

    return {
      data: services,
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  async findOne(id: string) {
    const service = await this.prisma.service.findFirst({
      where: { id, deletedAt: null },
      include: {
        listing: { 
          select: { 
            id: true, 
            name: true, 
            slug: true,
            merchantId: true,
          } 
        },
        _count: { 
          select: { 
            serviceBookings: true, 
            orderItems: true,
          } 
        },
      },
    });

    if (!service) {
      throw new NotFoundException(`Service with ID ${id} not found`);
    }

    return service;
  }

  async findByListing(listingId: string, params: ServiceQueryDto) {
    return this.findAll({ ...params, listingId });
  }

  async create(userId: string, createServiceDto: CreateServiceDto) {
    // Verify listing exists and user owns it
    const listing = await this.prisma.listing.findFirst({
      where: { 
        id: createServiceDto.listingId,
        deletedAt: null,
      },
      include: {
        merchant: {
          select: { userId: true },
        },
      },
    });

    if (!listing) {
      throw new NotFoundException(`Listing with ID ${createServiceDto.listingId} not found`);
    }

    if (listing.merchant?.userId !== userId) {
      throw new ForbiddenException('You do not have permission to create services for this listing');
    }

    // Generate slug if not provided
    let slug = createServiceDto.slug;
    if (!slug) {
      slug = createServiceDto.name
        .toLowerCase()
        .replace(/[^a-z0-9]+/g, '-')
        .replace(/(^-|-$)/g, '');
      
      // Ensure uniqueness
      const existing = await this.prisma.service.findFirst({
        where: { slug },
      });
      
      if (existing) {
        slug = `${slug}-${Date.now()}`;
      }
    } else {
      // Check if slug is unique
      const existing = await this.prisma.service.findFirst({
        where: { slug },
      });
      
      if (existing) {
        throw new BadRequestException(`Service with slug "${slug}" already exists`);
      }
    }

    const service = await this.prisma.service.create({
      data: {
        listingId: createServiceDto.listingId,
        name: createServiceDto.name,
        slug,
        description: createServiceDto.description,
        shortDescription: createServiceDto.shortDescription,
        basePrice: createServiceDto.basePrice,
        currency: createServiceDto.currency || 'RWF',
        priceUnit: createServiceDto.priceUnit || 'fixed',
        durationMinutes: createServiceDto.durationMinutes,
        requiresBooking: createServiceDto.requiresBooking ?? true,
        advanceBookingDays: createServiceDto.advanceBookingDays ?? 7,
        maxConcurrentBookings: createServiceDto.maxConcurrentBookings ?? 1,
        availabilitySchedule: createServiceDto.availabilitySchedule,
        isAvailable: createServiceDto.isAvailable ?? true,
        category: createServiceDto.category,
        tags: createServiceDto.tags || [],
        images: createServiceDto.images || [],
        status: createServiceDto.status || 'active',
        isFeatured: createServiceDto.isFeatured ?? false,
      },
      include: {
        listing: { 
          select: { 
            id: true, 
            name: true, 
            slug: true,
          } 
        },
      },
    });

    return service;
  }

  async update(id: string, userId: string, updateServiceDto: UpdateServiceDto) {
    const service = await this.findOne(id);

    // Verify user owns the listing
    const listing = await this.prisma.listing.findFirst({
      where: { 
        id: service.listingId,
        deletedAt: null,
      },
      include: {
        merchant: {
          select: { userId: true },
        },
      },
    });

    if (!listing || listing.merchant?.userId !== userId) {
      throw new ForbiddenException('You do not have permission to update this service');
    }

    // Check slug uniqueness if being updated
    if (updateServiceDto.slug && updateServiceDto.slug !== service.slug) {
      const existing = await this.prisma.service.findFirst({
        where: { slug: updateServiceDto.slug },
      });
      
      if (existing) {
        throw new BadRequestException(`Service with slug "${updateServiceDto.slug}" already exists`);
      }
    }

    const updated = await this.prisma.service.update({
      where: { id },
      data: {
        ...(updateServiceDto.name !== undefined && { name: updateServiceDto.name }),
        ...(updateServiceDto.slug !== undefined && { slug: updateServiceDto.slug }),
        ...(updateServiceDto.description !== undefined && { description: updateServiceDto.description }),
        ...(updateServiceDto.shortDescription !== undefined && { shortDescription: updateServiceDto.shortDescription }),
        ...(updateServiceDto.basePrice !== undefined && { basePrice: updateServiceDto.basePrice }),
        ...(updateServiceDto.currency !== undefined && { currency: updateServiceDto.currency }),
        ...(updateServiceDto.priceUnit !== undefined && { priceUnit: updateServiceDto.priceUnit as any }),
        ...(updateServiceDto.durationMinutes !== undefined && { durationMinutes: updateServiceDto.durationMinutes }),
        ...(updateServiceDto.requiresBooking !== undefined && { requiresBooking: updateServiceDto.requiresBooking }),
        ...(updateServiceDto.advanceBookingDays !== undefined && { advanceBookingDays: updateServiceDto.advanceBookingDays }),
        ...(updateServiceDto.maxConcurrentBookings !== undefined && { maxConcurrentBookings: updateServiceDto.maxConcurrentBookings }),
        ...(updateServiceDto.availabilitySchedule !== undefined && { availabilitySchedule: updateServiceDto.availabilitySchedule }),
        ...(updateServiceDto.isAvailable !== undefined && { isAvailable: updateServiceDto.isAvailable }),
        ...(updateServiceDto.category !== undefined && { category: updateServiceDto.category }),
        ...(updateServiceDto.tags !== undefined && { tags: updateServiceDto.tags }),
        ...(updateServiceDto.images !== undefined && { images: updateServiceDto.images }),
        ...(updateServiceDto.status !== undefined && { status: updateServiceDto.status as any }),
        ...(updateServiceDto.isFeatured !== undefined && { isFeatured: updateServiceDto.isFeatured }),
      },
      include: {
        listing: { 
          select: { 
            id: true, 
            name: true, 
            slug: true,
          } 
        },
      },
    });

    return updated;
  }

  async remove(id: string, userId: string) {
    const service = await this.findOne(id);

    // Verify user owns the listing
    const listing = await this.prisma.listing.findFirst({
      where: { 
        id: service.listingId,
        deletedAt: null,
      },
      include: {
        merchant: {
          select: { userId: true },
        },
      },
    });

    if (!listing || listing.merchant?.userId !== userId) {
      throw new ForbiddenException('You do not have permission to delete this service');
    }

    // Soft delete
    await this.prisma.service.update({
      where: { id },
      data: { deletedAt: new Date() },
    });

    return { message: 'Service deleted successfully' };
  }

  // Service Bookings
  async createBooking(serviceId: string, userId: string | null, createBookingDto: CreateServiceBookingDto) {
    const service = await this.findOne(serviceId);

    if (!service.isAvailable) {
      throw new BadRequestException('Service is not available for booking');
    }

    // Parse booking date
    const bookingDate = new Date(createBookingDto.bookingDate);
    if (isNaN(bookingDate.getTime())) {
      throw new BadRequestException('Invalid booking date format');
    }

    // Check if booking is within advance booking days
    if (service.advanceBookingDays) {
      const maxDate = new Date();
      maxDate.setDate(maxDate.getDate() + service.advanceBookingDays);
      if (bookingDate > maxDate) {
        throw new BadRequestException(`Booking can only be made up to ${service.advanceBookingDays} days in advance`);
      }
    }

    // Check concurrent bookings
    if (service.maxConcurrentBookings) {
      const concurrentBookings = await this.prisma.serviceBooking.count({
        where: {
          serviceId,
          bookingDate: bookingDate,
          bookingTime: createBookingDto.bookingTime,
          status: { in: ['pending', 'confirmed'] },
        },
      });

      if (concurrentBookings >= service.maxConcurrentBookings) {
        throw new BadRequestException('This time slot is already fully booked');
      }
    }

    const booking = await this.prisma.serviceBooking.create({
      data: {
        userId: userId || undefined,
        serviceId,
        listingId: service.listingId,
        orderId: createBookingDto.orderId,
        orderItemId: createBookingDto.orderItemId,
        bookingDate: bookingDate,
        bookingTime: createBookingDto.bookingTime,
        durationMinutes: service.durationMinutes,
        customerName: createBookingDto.customerName,
        customerEmail: createBookingDto.customerEmail,
        customerPhone: createBookingDto.customerPhone,
        status: 'pending',
        specialRequests: createBookingDto.specialRequests,
      },
      include: {
        service: {
          select: { id: true, name: true, slug: true },
        },
        listing: {
          select: { id: true, name: true, slug: true },
        },
      },
    });

    // Update service booking count
    await this.prisma.service.update({
      where: { id: serviceId },
      data: {
        bookingCount: { increment: 1 },
      },
    });

    return booking;
  }

  async updateBooking(bookingId: string, userId: string, updateBookingDto: UpdateServiceBookingDto) {
    const booking = await this.prisma.serviceBooking.findFirst({
      where: { id: bookingId },
      include: {
        service: {
          include: {
            listing: {
              include: {
                merchant: {
                  select: { userId: true },
                },
              },
            },
          },
        },
      },
    });

    if (!booking) {
      throw new NotFoundException(`Service booking with ID ${bookingId} not found`);
    }

    // Verify user owns the booking or the listing
    const isOwner = booking.userId === userId;
    const isListingOwner = booking.service.listing.merchant?.userId === userId;

    if (!isOwner && !isListingOwner) {
      throw new ForbiddenException('You do not have permission to update this booking');
    }

    const updated = await this.prisma.serviceBooking.update({
      where: { id: bookingId },
      data: {
        ...(updateBookingDto.status !== undefined && { status: updateBookingDto.status as any }),
        ...(updateBookingDto.specialRequests !== undefined && { specialRequests: updateBookingDto.specialRequests }),
      },
      include: {
        service: {
          select: { id: true, name: true, slug: true },
        },
        listing: {
          select: { id: true, name: true, slug: true },
        },
      },
    });

    return updated;
  }

  async getBookings(serviceId: string, userId: string) {
    const service = await this.findOne(serviceId);

    // Verify user owns the listing
    const listing = await this.prisma.listing.findFirst({
      where: { 
        id: service.listingId,
        deletedAt: null,
      },
      include: {
        merchant: {
          select: { userId: true },
        },
      },
    });

    if (!listing || listing.merchant?.userId !== userId) {
      throw new ForbiddenException('You do not have permission to view bookings for this service');
    }

    const bookings = await this.prisma.serviceBooking.findMany({
      where: { serviceId },
      orderBy: [
        { bookingDate: 'asc' },
        { bookingTime: 'asc' },
      ],
      include: {
        user: {
          select: { id: true, fullName: true, email: true, phoneNumber: true },
        },
      },
    });

    return bookings;
  }
}

