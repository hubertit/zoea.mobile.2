import apiClient from './client';

export type ReviewStatus = 'pending' | 'approved' | 'rejected';

export interface Review {
  id: string;
  rating: number;
  title?: string | null;
  content?: string | null;
  comment?: string | null;
  pros?: string[] | null;
  cons?: string[] | null;
  status: ReviewStatus;
  helpfulCount?: number | null;
  userId: string;
  listingId?: string | null;
  eventId?: string | null;
  tourId?: string | null;
  bookingId?: string | null;
  createdAt: string;
  updatedAt: string;
  user?: { id: string; fullName: string; profileImageId?: string | null } | null;
  listing?: { id: string; name: string; type: string; category?: { id: string; name: string; slug: string } | null } | null;
  event?: { id: string; name: string; eventContext?: { id: string; name: string; slug: string } | null } | null;
  tour?: { id: string; name: string; category?: { id: string; name: string; slug: string } | null } | null;
  booking?: { id: string; bookingNumber: string } | null;
}

export interface ListReviewsParams {
  page?: number;
  limit?: number;
  listingId?: string;
  eventId?: string;
  tourId?: string;
  userId?: string;
  status?: ReviewStatus;
  search?: string;
}

export interface ListReviewsResponse {
  data: Review[];
  meta: {
    total: number;
    page: number;
    limit: number;
    totalPages: number;
  };
}

export interface UpdateReviewStatusParams {
  status: ReviewStatus;
}

export const ReviewsAPI = {
  /**
   * List reviews with filters and pagination
   */
  listReviews: async (params: ListReviewsParams = {}): Promise<ListReviewsResponse> => {
    const response = await apiClient.get<ListReviewsResponse>('/reviews', { params });
    return response.data;
  },

  /**
   * Get review by ID
   */
  getReviewById: async (id: string): Promise<Review> => {
    const response = await apiClient.get<Review>(`/reviews/${id}`);
    return response.data;
  },

  /**
   * Update review status (for admin moderation)
   * Note: This uses the regular update endpoint with status field
   */
  updateReviewStatus: async (id: string, data: UpdateReviewStatusParams): Promise<Review> => {
    const response = await apiClient.put<Review>(`/reviews/${id}`, { status: data.status });
    return response.data;
  },

  /**
   * Delete review (admin only - can delete any review)
   */
  deleteReview: async (id: string): Promise<void> => {
    await apiClient.delete(`/admin/reviews/${id}`);
  },
};

