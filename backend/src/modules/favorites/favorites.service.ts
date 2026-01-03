import { Injectable, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class FavoritesService {
  constructor(private prisma: PrismaService) {}

  async findAll(userId: string, params: { page?: number; limit?: number; type?: string }) {
    const { page = 1, limit = 20, type } = params;
    const skip = (page - 1) * limit;

    const where = {
      userId,
      ...(type === 'listing' && { listingId: { not: null } }),
      ...(type === 'event' && { eventId: { not: null } }),
      ...(type === 'tour' && { tourId: { not: null } }),
    };

    const [favorites, total] = await Promise.all([
      this.prisma.favorite.findMany({
        where,
        skip,
        take: limit,
        include: {
          listing: {
            select: {
              id: true,
              name: true,
              slug: true,
              type: true,
              minPrice: true,
              maxPrice: true,
              currency: true,
              rating: true,
              reviewCount: true,
              city: { select: { name: true } },
              images: { include: { media: true }, take: 1, where: { isPrimary: true } },
            },
          },
          event: {
            select: {
              id: true,
              name: true,
              slug: true,
              startDate: true,
              endDate: true,
              locationName: true,
              city: { select: { name: true } },
              attachments: { include: { media: true }, take: 1, where: { isMainFlyer: true } },
            },
          },
          tour: {
            select: {
              id: true,
              name: true,
              slug: true,
              pricePerPerson: true,
              currency: true,
              rating: true,
              durationHours: true,
              city: { select: { name: true } },
              images: { include: { media: true }, take: 1, where: { isPrimary: true } },
            },
          },
        },
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.favorite.count({ where }),
    ]);

    return {
      data: favorites,
      meta: { total, page, limit, totalPages: Math.ceil(total / limit) },
    };
  }

  async add(userId: string, data: { listingId?: string; eventId?: string; tourId?: string; notes?: string }) {
    if (!data.listingId && !data.eventId && !data.tourId) {
      throw new BadRequestException('Must provide listingId, eventId, or tourId');
    }

    // Check if already favorited
    const existing = await this.prisma.favorite.findFirst({
      where: {
        userId,
        ...(data.listingId && { listingId: data.listingId }),
        ...(data.eventId && { eventId: data.eventId }),
        ...(data.tourId && { tourId: data.tourId }),
      },
    });

    if (existing) {
      return existing;
    }

    const favorite = await this.prisma.favorite.create({
      data: {
        userId,
        ...data,
      },
    });

    // Update favorite count
    if (data.listingId) {
      await this.prisma.listing.update({
        where: { id: data.listingId },
        data: { favoriteCount: { increment: 1 } },
      });
    } else if (data.tourId) {
      await this.prisma.tour.update({
        where: { id: data.tourId },
        data: { favoriteCount: { increment: 1 } },
      });
    }

    return favorite;
  }

  async remove(userId: string, data: { listingId?: string; eventId?: string; tourId?: string }) {
    const favorite = await this.prisma.favorite.findFirst({
      where: {
        userId,
        ...(data.listingId && { listingId: data.listingId }),
        ...(data.eventId && { eventId: data.eventId }),
        ...(data.tourId && { tourId: data.tourId }),
      },
    });

    if (!favorite) {
      return { success: true };
    }

    await this.prisma.favorite.delete({
      where: { id: favorite.id },
    });

    // Update favorite count
    if (data.listingId) {
      await this.prisma.listing.update({
        where: { id: data.listingId },
        data: { favoriteCount: { decrement: 1 } },
      });
    } else if (data.tourId) {
      await this.prisma.tour.update({
        where: { id: data.tourId },
        data: { favoriteCount: { decrement: 1 } },
      });
    }

    return { success: true };
  }

  async toggle(userId: string, data: { listingId?: string; eventId?: string; tourId?: string }) {
    const existing = await this.prisma.favorite.findFirst({
      where: {
        userId,
        ...(data.listingId && { listingId: data.listingId }),
        ...(data.eventId && { eventId: data.eventId }),
        ...(data.tourId && { tourId: data.tourId }),
      },
    });

    if (existing) {
      await this.remove(userId, data);
      return { isFavorite: false };
    } else {
      await this.add(userId, data);
      return { isFavorite: true };
    }
  }

  async isFavorite(userId: string, data: { listingId?: string; eventId?: string; tourId?: string }) {
    const favorite = await this.prisma.favorite.findFirst({
      where: {
        userId,
        ...(data.listingId && { listingId: data.listingId }),
        ...(data.eventId && { eventId: data.eventId }),
        ...(data.tourId && { tourId: data.tourId }),
      },
    });

    return { isFavorite: !!favorite };
  }
}

