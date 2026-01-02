import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

export interface ContentSearchParams {
  query: string;
  types?: ('listing' | 'tour' | 'product' | 'service')[];
  limit?: number;
  lat?: number;
  lng?: number;
  radius?: number; // km
}

export interface SearchResult {
  type: 'listing' | 'tour' | 'product' | 'service';
  id: string;
  title: string;
  subtitle: string;
  imageUrl?: string;
  rating?: number;
  price?: number;
  currency?: string;
  distance?: number; // km
  route: string;
  params: Record<string, any>;
}

@Injectable()
export class ContentSearchService {
  constructor(private prisma: PrismaService) {}

  /**
   * Global content search across all types (excluding events)
   * This is the main "tool" the AI assistant uses
   */
  async searchContent(params: ContentSearchParams): Promise<SearchResult[]> {
    const {
      query,
      types = ['listing', 'tour', 'product', 'service'],
      limit = 10,
      lat,
      lng,
      radius = 50,
    } = params;

    const results: SearchResult[] = [];

    // Search listings
    if (types.includes('listing')) {
      const listings = await this.searchListings(query, limit, lat, lng, radius);
      results.push(...listings);
    }

    // Search tours
    if (types.includes('tour')) {
      const tours = await this.searchTours(query, limit, lat, lng, radius);
      results.push(...tours);
    }

    // Search products
    if (types.includes('product')) {
      const products = await this.searchProducts(query, limit);
      results.push(...products);
    }

    // Search services
    if (types.includes('service')) {
      const services = await this.searchServices(query, limit);
      results.push(...services);
    }

    // Sort by relevance/rating and limit
    return results
      .sort((a, b) => (b.rating || 0) - (a.rating || 0))
      .slice(0, limit);
  }

  private async searchListings(
    query: string,
    limit: number,
    lat?: number,
    lng?: number,
    radius?: number,
  ): Promise<SearchResult[]> {
    const listings = await this.prisma.listing.findMany({
      where: {
        deletedAt: null,
        status: 'active',
        OR: [
          { name: { contains: query, mode: 'insensitive' } },
          { description: { contains: query, mode: 'insensitive' } },
          { tags: { some: { tag: { name: { contains: query, mode: 'insensitive' } } } } },
        ],
      },
      take: Math.ceil(limit / 4),
      include: {
        city: { select: { name: true } },
        category: { select: { name: true } },
        images: { include: { media: true }, take: 1, where: { isPrimary: true } },
      },
      orderBy: [{ isFeatured: 'desc' }, { rating: 'desc' }],
    });

    return listings.map(listing => ({
      type: 'listing' as const,
      id: listing.id,
      title: listing.name,
      subtitle: `${listing.city?.name || ''} • ${listing.category?.name || ''}`,
      imageUrl: listing.images[0]?.media?.url,
      rating: listing.rating ? parseFloat(listing.rating.toString()) : undefined,
      route: '/listing/:id',
      params: { id: listing.id },
    }));
  }

  private async searchTours(
    query: string,
    limit: number,
    lat?: number,
    lng?: number,
    radius?: number,
  ): Promise<SearchResult[]> {
    const tours = await this.prisma.tour.findMany({
      where: {
        deletedAt: null,
        status: 'active',
        OR: [
          { name: { contains: query, mode: 'insensitive' } },
          { description: { contains: query, mode: 'insensitive' } },
        ],
      },
      take: Math.ceil(limit / 4),
      include: {
        city: { select: { name: true } },
      },
      orderBy: [{ isFeatured: 'desc' }, { rating: 'desc' }],
    });

    return tours.map(tour => {
      const durationText = tour.durationDays 
        ? `${tour.durationDays} day${tour.durationDays > 1 ? 's' : ''}`
        : tour.durationHours 
        ? `${tour.durationHours}h`
        : 'Tour';

      return {
        type: 'tour' as const,
        id: tour.id,
        title: tour.name || 'Tour',
        subtitle: `${tour.city?.name || ''} • ${durationText}`,
        imageUrl: undefined, // Tours have complex image relations, will handle separately
        rating: tour.rating ? parseFloat(tour.rating.toString()) : undefined,
        price: tour.pricePerPerson ? parseFloat(tour.pricePerPerson.toString()) : undefined,
        currency: tour.currency || 'RWF',
        route: '/tour/:id',
        params: { id: tour.id },
      };
    });
  }

  private async searchProducts(query: string, limit: number): Promise<SearchResult[]> {
    const products = await this.prisma.product.findMany({
      where: {
        deletedAt: null,
        status: 'active',
        OR: [
          { name: { contains: query, mode: 'insensitive' } },
          { description: { contains: query, mode: 'insensitive' } },
        ],
      },
      take: Math.ceil(limit / 4),
      include: {
        listing: { select: { name: true } },
      },
      orderBy: { createdAt: 'desc' },
    });

    return products.map(product => ({
      type: 'product' as const,
      id: product.id,
      title: product.name,
      subtitle: product.listing?.name || 'Product',
      imageUrl: undefined, // Products have array of image IDs, will handle separately
      price: product.basePrice ? parseFloat(product.basePrice.toString()) : undefined,
      currency: product.currency || 'RWF',
      route: '/product/:id',
      params: { id: product.id },
    }));
  }

  private async searchServices(query: string, limit: number): Promise<SearchResult[]> {
    const services = await this.prisma.service.findMany({
      where: {
        deletedAt: null,
        status: 'active',
        OR: [
          { name: { contains: query, mode: 'insensitive' } },
          { description: { contains: query, mode: 'insensitive' } },
        ],
      },
      take: Math.ceil(limit / 4),
      include: {
        listing: { select: { name: true } },
      },
      orderBy: { createdAt: 'desc' },
    });

    return services.map(service => ({
      type: 'service' as const,
      id: service.id,
      title: service.name,
      subtitle: service.listing?.name || 'Service',
      imageUrl: undefined, // Services have array of image IDs, will handle separately
      price: service.basePrice ? parseFloat(service.basePrice.toString()) : undefined,
      currency: service.currency || 'RWF',
      route: '/service/:id',
      params: { id: service.id },
    }));
  }

  /**
   * Get all categories (for AI to understand taxonomy)
   */
  async getCategories() {
    return this.prisma.category.findMany({
      select: { id: true, name: true, slug: true, description: true },
      orderBy: { name: 'asc' },
    });
  }
}

