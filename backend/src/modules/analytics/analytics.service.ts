import { Injectable, Logger } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { BatchAnalyticsEventsDto, RecordContentViewDto, AnalyticsEventType } from './dto/analytics.dto';
import { Request } from 'express';

@Injectable()
export class AnalyticsService {
  private readonly logger = new Logger(AnalyticsService.name);

  constructor(private prisma: PrismaService) {}

  /**
   * Process batched analytics events from mobile app
   */
  async processBatchEvents(userId: string, dto: BatchAnalyticsEventsDto, req?: Request) {
    const processed = [];
    const errors = [];

    for (const event of dto.events) {
      try {
        switch (event.type) {
          case AnalyticsEventType.LISTING_VIEW:
            await this.recordListingView(userId, event.data, dto, req);
            break;
          case AnalyticsEventType.EVENT_VIEW:
            await this.recordEventView(userId, event.data, dto, req);
            break;
          case AnalyticsEventType.SEARCH:
            await this.recordSearch(userId, event.data, dto, req);
            break;
          case AnalyticsEventType.BOOKING_ATTEMPT:
          case AnalyticsEventType.BOOKING_COMPLETION:
            // These can be logged but don't need special handling here
            this.logger.debug(`Booking event: ${event.type}`, event.data);
            break;
          default:
            this.logger.debug(`Unhandled event type: ${event.type}`, event.data);
        }
        processed.push(event.type);
      } catch (error) {
        this.logger.error(`Error processing event ${event.type}:`, error);
        errors.push({ type: event.type, error: error.message });
      }
    }

    return {
      processed: processed.length,
      errors: errors.length,
      details: errors.length > 0 ? errors : undefined,
    };
  }

  /**
   * Record a listing view in content_views table
   */
  async recordListingView(
    userId: string | null,
    data: any,
    batchData: BatchAnalyticsEventsDto,
    req?: Request,
  ) {
    if (!data.listingId) {
      throw new Error('listingId is required for listing_view event');
    }

    // Get user profile data for viewer demographics
    let viewerAgeRange: string | null = null;
    let viewerGender: string | null = null;
    let viewerInterests: string[] = [];
    let cityId: string | null = null;
    let countryId: string | null = null;

    if (userId) {
      const user = await this.prisma.user.findUnique({
        where: { id: userId },
        select: {
          ageRange: true,
          gender: true,
          interests: true,
          cityId: true,
          countryId: true,
        },
      });

      if (user) {
        viewerAgeRange = user.ageRange;
        viewerGender = user.gender;
        viewerInterests = user.interests || [];
        cityId = user.cityId;
        countryId = user.countryId;
      }
    }

    // Get listing's city and country for location tracking
    const listing = await this.prisma.listing.findUnique({
      where: { id: data.listingId },
      select: { cityId: true, countryId: true },
    });

    const contentCityId = listing?.cityId || cityId;
    const contentCountryId = listing?.countryId || countryId;

    // Extract IP address from request
    const ipAddress = req?.ip || batchData.ipAddress || null;

    await this.prisma.content_views.create({
      data: {
        content_type: 'listing',
        content_id: data.listingId,
        user_id: userId || null,
        session_id: batchData.sessionId || null,
        viewer_age_range: viewerAgeRange,
        viewer_gender: viewerGender,
        viewer_interests: viewerInterests,
        source: data.source || batchData.deviceType || null,
        referrer: data.referrer || null,
        device_type: batchData.deviceType || null,
        os: batchData.os || null,
        browser: batchData.browser || null,
        app_version: batchData.appVersion || null,
        ip_address: ipAddress,
        city_id: contentCityId,
        country_id: contentCountryId,
        duration_seconds: data.durationSeconds || null,
        scroll_depth: data.scrollDepth || null,
        clicked_book: data.clickedBook || false,
        clicked_contact: data.clickedContact || false,
        added_to_favorites: data.addedToFavorites || false,
      },
    });

    // Also increment the viewCount on the listing
    await this.prisma.listing.update({
      where: { id: data.listingId },
      data: { viewCount: { increment: 1 } },
    });
  }

  /**
   * Record an event view in content_views table
   */
  async recordEventView(
    userId: string | null,
    data: any,
    batchData: BatchAnalyticsEventsDto,
    req?: Request,
  ) {
    if (!data.eventId) {
      throw new Error('eventId is required for event_view event');
    }

    // Get user profile data for viewer demographics
    let viewerAgeRange: string | null = null;
    let viewerGender: string | null = null;
    let viewerInterests: string[] = [];
    let cityId: string | null = null;
    let countryId: string | null = null;

    if (userId) {
      const user = await this.prisma.user.findUnique({
        where: { id: userId },
        select: {
          ageRange: true,
          gender: true,
          interests: true,
          cityId: true,
          countryId: true,
        },
      });

      if (user) {
        viewerAgeRange = user.ageRange;
        viewerGender = user.gender;
        viewerInterests = user.interests || [];
        cityId = user.cityId;
        countryId = user.countryId;
      }
    }

    // Get event's city and country for location tracking
    const event = await this.prisma.event.findUnique({
      where: { id: data.eventId },
      select: { cityId: true, countryId: true },
    });

    const contentCityId = event?.cityId || cityId;
    const contentCountryId = event?.countryId || countryId;

    // Extract IP address from request
    const ipAddress = req?.ip || batchData.ipAddress || null;

    await this.prisma.content_views.create({
      data: {
        content_type: 'event',
        content_id: data.eventId,
        user_id: userId || null,
        session_id: batchData.sessionId || null,
        viewer_age_range: viewerAgeRange,
        viewer_gender: viewerGender,
        viewer_interests: viewerInterests,
        source: data.source || batchData.deviceType || null,
        referrer: data.referrer || null,
        device_type: batchData.deviceType || null,
        os: batchData.os || null,
        browser: batchData.browser || null,
        app_version: batchData.appVersion || null,
        ip_address: ipAddress,
        city_id: contentCityId,
        country_id: contentCountryId,
        duration_seconds: data.durationSeconds || null,
        scroll_depth: data.scrollDepth || null,
        clicked_book: data.clickedBook || false,
        clicked_contact: data.clickedContact || false,
        added_to_favorites: data.addedToFavorites || false,
      },
    });
  }

  /**
   * Record a search query in search_analytics table
   */
  async recordSearch(
    userId: string | null,
    data: any,
    batchData: BatchAnalyticsEventsDto,
    req?: Request,
  ) {
    if (!data.query) {
      throw new Error('query is required for search event');
    }

    await this.prisma.search_analytics.create({
      data: {
        user_id: userId || null,
        session_id: batchData.sessionId || null,
        query: data.query,
        filters: data.filters || null,
        result_count: data.resultCount || null,
        clicked_result_id: data.clickedResultId || null,
        clicked_result_type: data.clickedResultType || null,
        clicked_position: data.clickedPosition || null,
        source: data.source || batchData.deviceType || null,
      },
    });
  }

  /**
   * Record a content view directly (for server-side tracking)
   */
  async recordContentView(userId: string | null, dto: RecordContentViewDto, req?: Request) {
    // Get user profile data for viewer demographics
    let viewerAgeRange: string | null = null;
    let viewerGender: string | null = null;
    let viewerInterests: string[] = [];
    let cityId: string | null = null;
    let countryId: string | null = null;

    if (userId) {
      const user = await this.prisma.user.findUnique({
        where: { id: userId },
        select: {
          ageRange: true,
          gender: true,
          interests: true,
          cityId: true,
          countryId: true,
        },
      });

      if (user) {
        viewerAgeRange = user.ageRange;
        viewerGender = user.gender;
        viewerInterests = user.interests || [];
        cityId = user.cityId;
        countryId = user.countryId;
      }
    }

    // Get content's city and country
    let contentCityId: string | null = cityId;
    let contentCountryId: string | null = countryId;

    if (dto.contentType === 'listing') {
      const listing = await this.prisma.listing.findUnique({
        where: { id: dto.contentId },
        select: { cityId: true, countryId: true },
      });
      if (listing) {
        contentCityId = listing.cityId;
        contentCountryId = listing.countryId;
      }
    } else if (dto.contentType === 'event') {
      const event = await this.prisma.event.findUnique({
        where: { id: dto.contentId },
        select: { cityId: true, countryId: true },
      });
      if (event) {
        contentCityId = event.cityId;
        contentCountryId = event.countryId;
      }
    }

    // Extract IP address from request
    const ipAddress = req?.ip || null;

    await this.prisma.content_views.create({
      data: {
        content_type: dto.contentType,
        content_id: dto.contentId,
        user_id: userId || null,
        session_id: dto.sessionId || null,
        viewer_age_range: viewerAgeRange,
        viewer_gender: viewerGender,
        viewer_interests: viewerInterests,
        source: dto.source || null,
        referrer: dto.referrer || null,
        device_type: null, // Will be set from request headers if needed
        os: null,
        browser: null,
        app_version: null,
        ip_address: ipAddress,
        city_id: contentCityId,
        country_id: contentCountryId,
        duration_seconds: dto.durationSeconds || null,
        scroll_depth: dto.scrollDepth || null,
        clicked_book: dto.clickedBook || false,
        clicked_contact: dto.clickedContact || false,
        added_to_favorites: dto.addedToFavorites || false,
      },
    });

    // Also increment the viewCount on the content
    if (dto.contentType === 'listing') {
      await this.prisma.listing.update({
        where: { id: dto.contentId },
        data: { viewCount: { increment: 1 } },
      });
    } else if (dto.contentType === 'event') {
      await this.prisma.event.update({
        where: { id: dto.contentId },
        data: { viewCount: { increment: 1 } },
      });
    }
  }

  /**
   * Get view count for a content item
   */
  async getContentViewCount(contentType: 'listing' | 'event', contentId: string): Promise<number> {
    return this.prisma.content_views.count({
      where: {
        content_type: contentType,
        content_id: contentId,
      },
    });
  }

  /**
   * Get unique viewer count for a content item
   */
  async getUniqueViewerCount(contentType: 'listing' | 'event', contentId: string): Promise<number> {
    const result = await this.prisma.content_views.groupBy({
      by: ['user_id'],
      where: {
        content_type: contentType,
        content_id: contentId,
        user_id: { not: null },
      },
    });
    return result.length;
  }

  /**
   * Get content views for a specific user (places visited)
   */
  async getMyContentViews(
    userId: string,
    options: {
      page?: number;
      limit?: number;
      contentType?: 'listing' | 'event';
    } = {},
  ) {
    const page = options.page || 1;
    const limit = options.limit || 20;
    const skip = (page - 1) * limit;

    const where: any = {
      user_id: userId,
    };

    if (options.contentType) {
      where.content_type = options.contentType;
    }

    // Get unique content views (group by content_id and content_type, get most recent view)
    const uniqueViews = await this.prisma.content_views.findMany({
      where,
      orderBy: { created_at: 'desc' },
      distinct: ['content_type', 'content_id'],
      select: {
        id: true,
        content_type: true,
        content_id: true,
        created_at: true,
      },
    });

    const total = uniqueViews.length;
    const paginatedViews = uniqueViews.slice(skip, skip + limit);

    // Get full content details for each view
    const contentViewsWithDetails = await Promise.all(
      paginatedViews.map(async (view) => {
        let content = null;

        if (view.content_type === 'listing') {
          content = await this.prisma.listing.findUnique({
            where: { id: view.content_id },
            include: {
              images: {
                take: 1,
                include: {
                  media: {
                    select: {
                      url: true,
                      thumbnailUrl: true,
                    },
                  },
                },
                orderBy: { sortOrder: 'asc' },
              },
              city: {
                select: {
                  name: true,
                  country: {
                    select: {
                      name: true,
                    },
                  },
                },
              },
              category: {
                select: {
                  name: true,
                  slug: true,
                },
              },
            },
          });
        } else if (view.content_type === 'event') {
          content = await this.prisma.event.findUnique({
            where: { id: view.content_id },
            include: {
              attachments: {
                take: 1,
                include: {
                  media: {
                    select: {
                      url: true,
                      thumbnailUrl: true,
                    },
                  },
                },
                orderBy: { sortOrder: 'asc' },
              },
              city: {
                select: {
                  name: true,
                  country: {
                    select: {
                      name: true,
                    },
                  },
                },
              },
              eventContext: {
                select: {
                  name: true,
                  slug: true,
                },
              },
            },
          });
        }

        return {
          id: view.id,
          contentType: view.content_type,
          contentId: view.content_id,
          viewedAt: view.created_at,
          content,
        };
      }),
    );

    return {
      data: contentViewsWithDetails,
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    };
  }
}

