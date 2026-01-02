import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { Prisma } from '@prisma/client';

@Injectable()
export class ToursService {
  constructor(private prisma: PrismaService) {}

  async findAll(params: {
    page?: number;
    limit?: number;
    status?: string;
    cityId?: string;
    countryId?: string;
    categoryId?: string;
    type?: string;
    difficulty?: string;
    minPrice?: number;
    maxPrice?: number;
    search?: string;
  }) {
    const { page = 1, limit = 20, status, cityId, countryId, categoryId, type, difficulty, minPrice, maxPrice, search } = params;
    const skip = (page - 1) * limit;

    const where: Prisma.TourWhereInput = {
      deletedAt: null,
      ...(status && { status: status as any }),
      ...(cityId && { cityId }),
      ...(countryId && { countryId }),
      ...(categoryId && { categoryId }),
      ...(type && { type }),
      ...(difficulty && { difficultyLevel: difficulty }),
      ...(minPrice && { pricePerPerson: { gte: minPrice } }),
      ...(maxPrice && { pricePerPerson: { lte: maxPrice } }),
      ...(search && {
        OR: [
          { name: { contains: search, mode: 'insensitive' } },
          { description: { contains: search, mode: 'insensitive' } },
        ],
      }),
    };

    const [tours, total] = await Promise.all([
      this.prisma.tour.findMany({
        where,
        skip,
        take: limit,
        include: {
          category: { select: { id: true, name: true, slug: true } },
          city: { select: { id: true, name: true } },
          country: { select: { id: true, name: true } },
          operator: { select: { id: true, companyName: true, isVerified: true, averageRating: true } },
          images: { include: { media: true }, take: 1, where: { isPrimary: true } },
          _count: { select: { reviews: true, bookings: true } },
        },
        orderBy: [{ isFeatured: 'desc' }, { rating: 'desc' }],
      }),
      this.prisma.tour.count({ where }),
    ]);

    return {
      data: tours,
      meta: { total, page, limit, totalPages: Math.ceil(total / limit) },
    };
  }

  async findOne(id: string) {
    const tour = await this.prisma.tour.findUnique({
      where: { id },
      include: {
        category: true,
        city: true,
        country: true,
        operator: {
          select: {
            id: true,
            companyName: true,
            description: true,
            isVerified: true,
            averageRating: true,
            totalTours: true,
            totalCustomers: true,
            contactEmail: true,
            contactPhone: true,
          },
        },
        images: { include: { media: true }, orderBy: { sortOrder: 'asc' } },
        schedules: {
          where: { date: { gte: new Date() }, isAvailable: true },
          orderBy: { date: 'asc' },
          take: 30,
        },
        reviews: {
          where: { status: 'approved', deletedAt: null },
          take: 10,
          orderBy: { createdAt: 'desc' },
          include: { user: { select: { id: true, fullName: true, profileImageId: true } } },
        },
        _count: { select: { reviews: true, bookings: true, favorites: true } },
      },
    });

    if (!tour) throw new NotFoundException('Tour not found');
    return tour;
  }

  async findBySlug(slug: string) {
    const tour = await this.prisma.tour.findUnique({
      where: { slug },
      include: {
        category: true,
        city: true,
        country: true,
        operator: { select: { id: true, companyName: true, isVerified: true } },
        images: { include: { media: true }, orderBy: { sortOrder: 'asc' } },
        schedules: { where: { date: { gte: new Date() }, isAvailable: true }, take: 30 },
        _count: { select: { reviews: true, bookings: true } },
      },
    });

    if (!tour) throw new NotFoundException('Tour not found');
    return tour;
  }

  async getFeatured(limit = 10) {
    return this.prisma.tour.findMany({
      where: { isFeatured: true, status: 'active', deletedAt: null },
      take: limit,
      include: {
        city: { select: { id: true, name: true } },
        images: { include: { media: true }, take: 1, where: { isPrimary: true } },
      },
      orderBy: { rating: 'desc' },
    });
  }

  async getSchedules(tourId: string, startDate?: Date, endDate?: Date, includeUnavailable = false) {
    return this.prisma.tourSchedule.findMany({
      where: {
        tourId,
        ...(includeUnavailable ? {} : { isAvailable: true }),
        date: {
          gte: startDate || new Date(),
          ...(endDate && { lte: endDate }),
        },
      },
      orderBy: { date: 'asc' },
    });
  }

  async createSchedule(userId: string, tourId: string, data: {
    date: string;
    startTime?: string;
    availableSpots: number;
    priceOverride?: number;
    isAvailable?: boolean;
  }) {
    // Verify user owns the tour
    const tour = await this.prisma.tour.findFirst({
      where: { id: tourId, deletedAt: null },
      include: {
        operator: {
          select: { userId: true },
        },
      },
    });

    if (!tour) {
      throw new NotFoundException('Tour not found');
    }

    if (tour.operator?.userId !== userId) {
      throw new ForbiddenException('You do not have permission to create schedules for this tour');
    }

    const scheduleDate = new Date(data.date);
    const startTime = data.startTime ? new Date(`1970-01-01T${data.startTime}`) : null;

    return this.prisma.tourSchedule.create({
      data: {
        tourId,
        date: scheduleDate,
        startTime: startTime,
        availableSpots: data.availableSpots,
        bookedSpots: 0,
        priceOverride: data.priceOverride,
        isAvailable: data.isAvailable ?? true,
      },
    });
  }

  async updateSchedule(userId: string, scheduleId: string, data: {
    date?: string;
    startTime?: string;
    availableSpots?: number;
    priceOverride?: number;
    isAvailable?: boolean;
  }) {
    // Verify user owns the tour
    const schedule = await this.prisma.tourSchedule.findFirst({
      where: { id: scheduleId },
      include: {
        tour: {
          include: {
            operator: {
              select: { userId: true },
            },
          },
        },
      },
    });

    if (!schedule) {
      throw new NotFoundException('Schedule not found');
    }

    if (schedule.tour.operator?.userId !== userId) {
      throw new ForbiddenException('You do not have permission to update this schedule');
    }

    const updateData: any = {};
    if (data.date !== undefined) updateData.date = new Date(data.date);
    if (data.startTime !== undefined) {
      updateData.startTime = data.startTime ? new Date(`1970-01-01T${data.startTime}`) : null;
    }
    if (data.availableSpots !== undefined) updateData.availableSpots = data.availableSpots;
    if (data.priceOverride !== undefined) updateData.priceOverride = data.priceOverride;
    if (data.isAvailable !== undefined) updateData.isAvailable = data.isAvailable;

    return this.prisma.tourSchedule.update({
      where: { id: scheduleId },
      data: updateData,
    });
  }

  async deleteSchedule(userId: string, scheduleId: string) {
    // Verify user owns the tour
    const schedule = await this.prisma.tourSchedule.findFirst({
      where: { id: scheduleId },
      include: {
        tour: {
          include: {
            operator: {
              select: { userId: true },
            },
          },
        },
      },
    });

    if (!schedule) {
      throw new NotFoundException('Schedule not found');
    }

    if (schedule.tour.operator?.userId !== userId) {
      throw new ForbiddenException('You do not have permission to delete this schedule');
    }

    return this.prisma.tourSchedule.delete({
      where: { id: scheduleId },
    });
  }

  async create(userId: string, data: Prisma.TourCreateInput) {
    // Verify operator exists and user owns it
    if (data.operator?.connect?.id) {
      const operator = await this.prisma.tourOperatorProfile.findFirst({
        where: {
          id: data.operator.connect.id,
          userId,
        },
      });

      if (!operator) {
        throw new ForbiddenException('You do not have permission to create tours for this operator');
      }
    }

    return this.prisma.tour.create({ data });
  }

  async update(id: string, userId: string, data: Prisma.TourUpdateInput) {
    // Verify user owns the tour
    const tour = await this.prisma.tour.findFirst({
      where: { id, deletedAt: null },
      include: {
        operator: {
          select: { userId: true },
        },
      },
    });

    if (!tour) {
      throw new NotFoundException('Tour not found');
    }

    if (tour.operator?.userId !== userId) {
      throw new ForbiddenException('You do not have permission to update this tour');
    }

    return this.prisma.tour.update({ where: { id }, data });
  }

  async delete(id: string, userId: string) {
    // Verify user owns the tour
    const tour = await this.prisma.tour.findFirst({
      where: { id, deletedAt: null },
      include: {
        operator: {
          select: { userId: true },
        },
      },
    });

    if (!tour) {
      throw new NotFoundException('Tour not found');
    }

    if (tour.operator?.userId !== userId) {
      throw new ForbiddenException('You do not have permission to delete this tour');
    }

    return this.prisma.tour.update({
      where: { id },
      data: { deletedAt: new Date() },
    });
  }

  async verifyOperatorAccess(operatorId: string, userId: string): Promise<boolean> {
    const operator = await this.prisma.tourOperatorProfile.findFirst({
      where: { id: operatorId, userId },
    });
    return !!operator;
  }

  async findByOperator(operatorId: string, params?: { page?: number; limit?: number; status?: string }) {
    const { page = 1, limit = 20, status } = params || {};
    const skip = (page - 1) * limit;

    const where: Prisma.TourWhereInput = {
      operatorId,
      deletedAt: null,
      ...(status && { status: status as any }),
    };

    const [tours, total] = await Promise.all([
      this.prisma.tour.findMany({
        where,
        skip,
        take: limit,
        include: {
          category: { select: { id: true, name: true } },
          city: { select: { id: true, name: true } },
          country: { select: { id: true, name: true } },
          images: { include: { media: true }, take: 1, where: { isPrimary: true } },
          _count: { select: { reviews: true, bookings: true } },
        },
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.tour.count({ where }),
    ]);

    return {
      data: tours,
      meta: { total, page, limit, totalPages: Math.ceil(total / limit) },
    };
  }
}

