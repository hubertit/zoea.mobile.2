import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/reviews_service.dart';

final reviewsServiceProvider = Provider<ReviewsService>((ref) {
  return ReviewsService();
});

/// Parameters for reviews query
class ReviewsParams {
  final String? listingId;
  final String? eventId;
  final String? userId;
  final int? rating;
  final int? page;
  final int? limit;
  final String? sortBy;

  const ReviewsParams({
    this.listingId,
    this.eventId,
    this.userId,
    this.rating,
    this.page,
    this.limit,
    this.sortBy,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReviewsParams &&
        other.listingId == listingId &&
        other.eventId == eventId &&
        other.userId == userId &&
        other.rating == rating &&
        other.page == page &&
        other.limit == limit &&
        other.sortBy == sortBy;
  }

  @override
  int get hashCode {
    return Object.hash(
      listingId,
      eventId,
      userId,
      rating,
      page,
      limit,
      sortBy,
    );
  }
}

/// Provider for reviews with filters
final reviewsProvider = FutureProvider.family<Map<String, dynamic>, ReviewsParams>((ref, params) async {
  final reviewsService = ref.watch(reviewsServiceProvider);
  return await reviewsService.getReviews(
    listingId: params.listingId,
    eventId: params.eventId,
    userId: params.userId,
    rating: params.rating,
    page: params.page,
    limit: params.limit,
    sortBy: params.sortBy,
  );
});

/// Parameters for listing reviews query
class ListingReviewsParams {
  final String listingId;
  final int? page;
  final int? limit;
  final String? sortBy;

  const ListingReviewsParams({
    required this.listingId,
    this.page,
    this.limit,
    this.sortBy,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListingReviewsParams &&
          runtimeType == other.runtimeType &&
          listingId == other.listingId &&
          page == other.page &&
          limit == other.limit &&
          sortBy == other.sortBy;

  @override
  int get hashCode =>
      listingId.hashCode ^
      page.hashCode ^
      limit.hashCode ^
      sortBy.hashCode;
}

/// Provider for listing reviews
final listingReviewsProvider = FutureProvider.family<Map<String, dynamic>, ListingReviewsParams>((ref, params) async {
  final reviewsService = ref.watch(reviewsServiceProvider);
  return await reviewsService.getListingReviews(
    listingId: params.listingId,
    page: params.page,
    limit: params.limit,
    sortBy: params.sortBy,
  );
});

/// Parameters for event reviews query
class EventReviewsParams {
  final String eventId;
  final int? page;
  final int? limit;
  final String? sortBy;

  const EventReviewsParams({
    required this.eventId,
    this.page,
    this.limit,
    this.sortBy,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventReviewsParams &&
          runtimeType == other.runtimeType &&
          eventId == other.eventId &&
          page == other.page &&
          limit == other.limit &&
          sortBy == other.sortBy;

  @override
  int get hashCode =>
      eventId.hashCode ^
      page.hashCode ^
      limit.hashCode ^
      sortBy.hashCode;
}

/// Provider for event reviews
final eventReviewsProvider = FutureProvider.family<Map<String, dynamic>, EventReviewsParams>((ref, params) async {
  final reviewsService = ref.watch(reviewsServiceProvider);
  return await reviewsService.getEventReviews(
    eventId: params.eventId,
    page: params.page,
    limit: params.limit,
    sortBy: params.sortBy,
  );
});

/// Provider for single review by ID
final reviewByIdProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, reviewId) async {
  final reviewsService = ref.watch(reviewsServiceProvider);
  return await reviewsService.getReviewById(reviewId);
});

/// Parameters for my reviews query
class MyReviewsParams {
  final int? page;
  final int? limit;
  final String? sortBy;

  const MyReviewsParams({
    this.page,
    this.limit,
    this.sortBy,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MyReviewsParams &&
          runtimeType == other.runtimeType &&
          page == other.page &&
          limit == other.limit &&
          sortBy == other.sortBy;

  @override
  int get hashCode => page.hashCode ^ limit.hashCode ^ sortBy.hashCode;
}

/// Provider for current user's reviews
final myReviewsProvider = FutureProvider.family<Map<String, dynamic>, MyReviewsParams>((ref, params) async {
  final reviewsService = ref.watch(reviewsServiceProvider);
  return await reviewsService.getMyReviews(
    page: params.page,
    limit: params.limit,
    sortBy: params.sortBy,
  );
});

