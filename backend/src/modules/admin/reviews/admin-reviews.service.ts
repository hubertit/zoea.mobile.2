import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../../prisma/prisma.service';
import { ReviewsService } from '../../reviews/reviews.service';

@Injectable()
export class AdminReviewsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly reviewsService: ReviewsService,
  ) {}

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

