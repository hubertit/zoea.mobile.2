import { Injectable, NotFoundException } from '@nestjs/common';
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

  async getSchedules(tourId: string, startDate?: Date, endDate?: Date) {
    return this.prisma.tourSchedule.findMany({
      where: {
        tourId,
        isAvailable: true,
        date: {
          gte: startDate || new Date(),
          ...(endDate && { lte: endDate }),
        },
      },
      orderBy: { date: 'asc' },
    });
  }

  async create(data: Prisma.TourCreateInput) {
    return this.prisma.tour.create({ data });
  }

  async update(id: string, data: Prisma.TourUpdateInput) {
    return this.prisma.tour.update({ where: { id }, data });
  }

  async delete(id: string) {
    return this.prisma.tour.update({
      where: { id },
      data: { deletedAt: new Date() },
    });
  }
}

