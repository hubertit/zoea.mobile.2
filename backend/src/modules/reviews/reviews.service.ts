import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class ReviewsService {
  constructor(private prisma: PrismaService) {}

  async findAll(params: {
    page?: number;
    limit?: number;
    listingId?: string;
    eventId?: string;
    tourId?: string;
    userId?: string;
    status?: string;
  }) {
    const { page = 1, limit = 20, listingId, eventId, tourId, userId, status } = params;
    const skip = (page - 1) * limit;

    const where = {
      deletedAt: null,
      ...(listingId && { listingId }),
      ...(eventId && { eventId }),
      ...(tourId && { tourId }),
      ...(userId && { userId }),
      ...(status && { status: status as any }),
    };

    const [reviews, total] = await Promise.all([
      this.prisma.review.findMany({
        where,
        skip,
        take: limit,
        include: {
          user: { select: { id: true, fullName: true, profileImageId: true } },
          listing: { 
            select: { 
              id: true, 
              name: true, 
              type: true,
              category: { select: { id: true, name: true, slug: true } },
            } 
          },
          event: { 
            select: { 
              id: true, 
              name: true,
              eventContext: { select: { id: true, name: true, slug: true } },
            } 
          },
          tour: { 
            select: { 
              id: true, 
              name: true,
              category: { select: { id: true, name: true, slug: true } },
            } 
          },
        },
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.review.count({ where }),
    ]);

    return {
      data: reviews,
      meta: { total, page, limit, totalPages: Math.ceil(total / limit) },
    };
  }

  async findOne(id: string) {
    const review = await this.prisma.review.findUnique({
      where: { id },
      include: {
        user: { select: { id: true, fullName: true, profileImageId: true } },
        listing: { select: { id: true, name: true, type: true } },
        event: { select: { id: true, name: true } },
        tour: { select: { id: true, name: true } },
        booking: { select: { id: true, bookingNumber: true } },
      },
    });

    if (!review) throw new NotFoundException('Review not found');
    return review;
  }

  async create(userId: string, data: {
    listingId?: string;
    eventId?: string;
    tourId?: string;
    bookingId?: string;
    rating: number;
    title?: string;
    content?: string;
    pros?: string[];
    cons?: string[];
  }) {
    if (!data.listingId && !data.eventId && !data.tourId) {
      throw new BadRequestException('Must provide listingId, eventId, or tourId');
    }

    if (data.rating < 1 || data.rating > 5) {
      throw new BadRequestException('Rating must be between 1 and 5');
    }

    // Check for existing review
    const existingReview = await this.prisma.review.findFirst({
      where: {
        userId,
        ...(data.listingId && { listingId: data.listingId }),
        ...(data.eventId && { eventId: data.eventId }),
        ...(data.tourId && { tourId: data.tourId }),
        deletedAt: null,
      },
    });

    if (existingReview) {
      throw new BadRequestException('You have already reviewed this item');
    }

    const review = await this.prisma.review.create({
      data: {
        userId,
        ...data,
        status: 'pending',
      },
      include: {
        user: { select: { id: true, fullName: true } },
      },
    });

    // Update average rating
    await this.updateAverageRating(data.listingId, data.eventId, data.tourId);

    return review;
  }

  async update(id: string, userId: string, data: {
    rating?: number;
    title?: string;
    content?: string;
    pros?: string[];
    cons?: string[];
  }) {
    const review = await this.prisma.review.findUnique({ where: { id } });
    
    if (!review) throw new NotFoundException('Review not found');
    if (review.userId !== userId) throw new BadRequestException('Not authorized to update this review');

    const updated = await this.prisma.review.update({
      where: { id },
      data: { ...data, status: 'pending' }, // Reset to pending for re-moderation
    });

    await this.updateAverageRating(review.listingId, review.eventId, review.tourId);
    return updated;
  }

  async delete(id: string, userId: string) {
    const review = await this.prisma.review.findUnique({ where: { id } });
    
    if (!review) throw new NotFoundException('Review not found');
    if (review.userId !== userId) throw new BadRequestException('Not authorized to delete this review');

    await this.prisma.review.update({
      where: { id },
      data: { deletedAt: new Date() },
    });

    await this.updateAverageRating(review.listingId, review.eventId, review.tourId);
    return { success: true };
  }

  async markHelpful(reviewId: string, userId: string, isHelpful: boolean) {
    const existing = await this.prisma.review_votes.findUnique({
      where: { user_id_review_id: { user_id: userId, review_id: reviewId } },
    });

    if (existing) {
      if (existing.is_helpful === isHelpful) {
        // Remove vote
        await this.prisma.review_votes.delete({
          where: { user_id_review_id: { user_id: userId, review_id: reviewId } },
        });
        await this.prisma.review.update({
          where: { id: reviewId },
          data: { helpfulCount: { decrement: isHelpful ? 1 : 0 } },
        });
      } else {
        // Change vote
        await this.prisma.review_votes.update({
          where: { user_id_review_id: { user_id: userId, review_id: reviewId } },
          data: { is_helpful: isHelpful },
        });
        await this.prisma.review.update({
          where: { id: reviewId },
          data: { helpfulCount: { increment: isHelpful ? 1 : -1 } },
        });
      }
    } else {
      await this.prisma.review_votes.create({
        data: { user_id: userId, review_id: reviewId, is_helpful: isHelpful },
      });
      if (isHelpful) {
        await this.prisma.review.update({
          where: { id: reviewId },
          data: { helpfulCount: { increment: 1 } },
        });
      }
    }

    return { success: true };
  }

  private async updateAverageRating(listingId?: string | null, eventId?: string | null, tourId?: string | null) {
    if (listingId) {
      const result = await this.prisma.review.aggregate({
        where: { listingId, status: 'approved', deletedAt: null },
        _avg: { rating: true },
        _count: true,
      });
      await this.prisma.listing.update({
        where: { id: listingId },
        data: { rating: result._avg.rating || 0, reviewCount: result._count },
      });
    }
    if (eventId) {
      const result = await this.prisma.review.aggregate({
        where: { eventId, status: 'approved', deletedAt: null },
        _avg: { rating: true },
        _count: true,
      });
      // Events don't have rating field in schema, but could add if needed
    }
    if (tourId) {
      const result = await this.prisma.review.aggregate({
        where: { tourId, status: 'approved', deletedAt: null },
        _avg: { rating: true },
        _count: true,
      });
      await this.prisma.tour.update({
        where: { id: tourId },
        data: { rating: result._avg.rating || 0, reviewCount: result._count },
      });
    }
  }
}

