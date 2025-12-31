import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../../prisma/prisma.service';
import { ReviewsService } from '../../reviews/reviews.service';
import { AdminListReviewsDto } from './dto/list-reviews.dto';

@Injectable()
export class AdminReviewsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly reviewsService: ReviewsService,
  ) {}

  async listReviews(params: AdminListReviewsDto) {
    const page = params.page ?? 1;
    const limit = params.limit ?? 20;
    const skip = (page - 1) * limit;

    const where: any = {
      deletedAt: null,
    };

    const andFilters = [];

    if (params.search) {
      const searchTerm = params.search.trim();
      andFilters.push({
        OR: [
          { user: { fullName: { contains: searchTerm, mode: 'insensitive' } } },
          { listing: { name: { contains: searchTerm, mode: 'insensitive' } } },
          { event: { name: { contains: searchTerm, mode: 'insensitive' } } },
          { tour: { name: { contains: searchTerm, mode: 'insensitive' } } },
          { title: { contains: searchTerm, mode: 'insensitive' } },
          { content: { contains: searchTerm, mode: 'insensitive' } },
          { comment: { contains: searchTerm, mode: 'insensitive' } },
        ],
      });
    }

    if (params.status) {
      andFilters.push({ status: params.status });
    }

    if (params.listingId) {
      andFilters.push({ listingId: params.listingId });
    }

    if (params.eventId) {
      andFilters.push({ eventId: params.eventId });
    }

    if (params.tourId) {
      andFilters.push({ tourId: params.tourId });
    }

    if (params.userId) {
      andFilters.push({ userId: params.userId });
    }

    if (andFilters.length) {
      where.AND = andFilters;
    }

    const [data, total] = await Promise.all([
      this.prisma.review.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
        include: {
          user: { select: { id: true, fullName: true, profileImageId: true } },
          listing: {
            select: {
              id: true,
              name: true,
              type: true,
              category: { select: { id: true, name: true, slug: true } },
            },
          },
          event: {
            select: {
              id: true,
              name: true,
              eventContext: { select: { id: true, name: true, slug: true } },
            },
          },
          tour: {
            select: {
              id: true,
              name: true,
              category: { select: { id: true, name: true, slug: true } },
            },
          },
          booking: { select: { id: true, bookingNumber: true } },
        },
      }),
      this.prisma.review.count({ where }),
    ]);

    return {
      data,
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit) || 1,
      },
    };
  }

  async deleteReview(id: string) {
    const review = await this.prisma.review.findUnique({
      where: { id },
    });

    if (!review) {
      throw new NotFoundException('Review not found');
    }

    // Soft delete the review
    await this.prisma.review.update({
      where: { id },
      data: { deletedAt: new Date() },
    });

    // Update average rating for the related listing/event/tour
    await this.reviewsService.updateAverageRating(
      review.listingId,
      review.eventId,
      review.tourId,
    );

    return { success: true, id, deletedAt: new Date() };
  }
}

