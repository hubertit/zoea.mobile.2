import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class SearchService {
  constructor(private prisma: PrismaService) {}

  async search(params: {
    query: string;
    type?: string;
    cityId?: string;
    countryId?: string;
    page?: number;
    limit?: number;
    userId?: string;
  }) {
    const { query, type, cityId, countryId, page = 1, limit = 20, userId } = params;
    const skip = (page - 1) * limit;

    // Save search history for all searches (logged-in or anonymous)
    // For anonymous users: save query and timestamp (userId will be null)
    // For logged-in users: save query, timestamp, and userId
    if (query && query.trim().length > 0) {
      await this.prisma.searchHistory.create({
        data: {
          userId: userId || null, // null for anonymous users
          query: query.trim(),
          filters: { type, cityId, countryId },
        },
      });
    }

    const results: any = {};

    // Search listings
    if (!type || type === 'listing' || type === 'all') {
      const listings = await this.prisma.listing.findMany({
        where: {
          deletedAt: null,
          status: 'active',
          ...(cityId && { cityId }),
          ...(countryId && { countryId }),
          OR: [
            { name: { contains: query, mode: 'insensitive' } },
            { description: { contains: query, mode: 'insensitive' } },
            { tags: { some: { tag: { name: { contains: query, mode: 'insensitive' } } } } },
          ],
        },
        take: type === 'listing' ? limit : 5,
        skip: type === 'listing' ? skip : 0,
        include: {
          city: { select: { name: true } },
          category: { select: { id: true, name: true, slug: true } },
          images: { include: { media: true }, take: 1, where: { isPrimary: true } },
        },
        orderBy: [{ isFeatured: 'desc' }, { rating: 'desc' }],
      });
      results.listings = listings;
    }

    // Search events
    if (!type || type === 'event' || type === 'all') {
      const events = await this.prisma.event.findMany({
        where: {
          deletedAt: null,
          status: 'published',
          startDate: { gte: new Date() },
          ...(cityId && { cityId }),
          ...(countryId && { countryId }),
          OR: [
            { name: { contains: query, mode: 'insensitive' } },
            { description: { contains: query, mode: 'insensitive' } },
          ],
        },
        take: type === 'event' ? limit : 5,
        skip: type === 'event' ? skip : 0,
        include: {
          city: { select: { name: true } },
          attachments: { include: { media: true }, take: 1, where: { isMainFlyer: true } },
        },
        orderBy: { startDate: 'asc' },
      });
      results.events = events;
    }

    // Search tours
    if (!type || type === 'tour' || type === 'all') {
      const tours = await this.prisma.tour.findMany({
        where: {
          deletedAt: null,
          status: 'active',
          ...(cityId && { cityId }),
          ...(countryId && { countryId }),
          OR: [
            { name: { contains: query, mode: 'insensitive' } },
            { description: { contains: query, mode: 'insensitive' } },
          ],
        },
        take: type === 'tour' ? limit : 5,
        skip: type === 'tour' ? skip : 0,
        include: {
          city: { select: { name: true } },
          images: { include: { media: true }, take: 1, where: { isPrimary: true } },
        },
        orderBy: [{ isFeatured: 'desc' }, { rating: 'desc' }],
      });
      results.tours = tours;
    }

    return results;
  }

  async getSearchHistory(userId: string, limit = 5) {
    return this.prisma.searchHistory.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
      take: limit,
      distinct: ['query'],
    });
  }

  async clearSearchHistory(userId: string) {
    await this.prisma.searchHistory.deleteMany({
      where: { userId },
    });
    return { success: true };
  }

  async getTrending(cityId?: string, countryId?: string) {
    // Get trending searches
    const trending = await this.prisma.searchHistory.groupBy({
      by: ['query'],
      where: {
        createdAt: { gte: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000) }, // Last 7 days
      },
      _count: { query: true },
      orderBy: { _count: { query: 'desc' } },
      take: 5,
    });

    // Get featured content
    const [featuredListings, upcomingEvents, popularTours] = await Promise.all([
      this.prisma.listing.findMany({
        where: {
          isFeatured: true,
          status: 'active',
          deletedAt: null,
          ...(cityId && { cityId }),
          ...(countryId && { countryId }),
        },
        take: 5,
        include: {
          city: { select: { name: true } },
          images: { include: { media: true }, take: 1, where: { isPrimary: true } },
        },
      }),
      this.prisma.event.findMany({
        where: {
          status: 'published',
          deletedAt: null,
          startDate: { gte: new Date() },
          ...(cityId && { cityId }),
          ...(countryId && { countryId }),
        },
        take: 5,
        orderBy: { startDate: 'asc' },
        include: {
          city: { select: { name: true } },
          attachments: { include: { media: true }, take: 1, where: { isMainFlyer: true } },
        },
      }),
      this.prisma.tour.findMany({
        where: {
          status: 'active',
          deletedAt: null,
          ...(cityId && { cityId }),
          ...(countryId && { countryId }),
        },
        take: 5,
        orderBy: { bookingCount: 'desc' },
        include: {
          city: { select: { name: true } },
          images: { include: { media: true }, take: 1, where: { isPrimary: true } },
        },
      }),
    ]);

    return {
      trendingSearches: trending.map(t => t.query),
      featuredListings,
      upcomingEvents,
      popularTours,
    };
  }

  async getRecentlyViewed(userId: string, limit = 10) {
    return this.prisma.recentlyViewed.findMany({
      where: { userId },
      orderBy: { lastViewedAt: 'desc' },
      take: limit,
      include: {
        listing: {
          select: {
            id: true,
            name: true,
            slug: true,
            type: true,
            rating: true,
            images: { include: { media: true }, take: 1, where: { isPrimary: true } },
          },
        },
        event: {
          select: {
            id: true,
            name: true,
            slug: true,
            startDate: true,
            attachments: { include: { media: true }, take: 1, where: { isMainFlyer: true } },
          },
        },
        tour: {
          select: {
            id: true,
            name: true,
            slug: true,
            rating: true,
            images: { include: { media: true }, take: 1, where: { isPrimary: true } },
          },
        },
      },
    });
  }
}

