import 'package:dio/dio.dart';
import '../config/app_config.dart';

class ReviewsService {
  final Dio _dio = AppConfig.dioInstance();

  /// Get reviews with filters
  /// Supports filtering by: listingId, eventId, userId, rating
  /// Returns paginated response: {data: [...], meta: {total, page, limit, totalPages}}
  Future<Map<String, dynamic>> getReviews({
    String? listingId,
    String? eventId,
    String? userId,
    int? rating,
    int? page,
    int? limit,
    String? sortBy, // 'newest', 'oldest', 'highest', 'lowest'
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (listingId != null) queryParams['listingId'] = listingId;
      if (eventId != null) queryParams['eventId'] = eventId;
      if (userId != null) queryParams['userId'] = userId;
      if (rating != null) queryParams['rating'] = rating;
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;
      if (sortBy != null) queryParams['sortBy'] = sortBy;

      final response = await _dio.get(
        '/reviews',
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        // API returns: {data: [...], meta: {total, page, limit, totalPages}}
        return data;
      } else {
        throw Exception('Failed to fetch reviews: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to fetch reviews.';
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data?['message'] ?? e.response!.statusMessage;
        
        if (statusCode == 401) {
          errorMessage = 'Unauthorized. Please login again.';
        } else {
          errorMessage = message ?? errorMessage;
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
                 e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Connection timeout. Please check your internet connection.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'No internet connection. Please check your network.';
      }
      
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Error fetching reviews: $e');
    }
  }

  /// Get reviews for a specific listing
  Future<Map<String, dynamic>> getListingReviews({
    required String listingId,
    int? page,
    int? limit,
    String? sortBy,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'targetType': 'listing',
        'targetId': listingId,
      };
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;
      if (sortBy != null) queryParams['sortBy'] = sortBy;

      final response = await _dio.get(
        '/reviews',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return data;
      } else {
        throw Exception('Failed to fetch listing reviews: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to fetch listing reviews.';
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data?['message'] ?? e.response!.statusMessage;
        
        if (statusCode == 401) {
          errorMessage = 'Unauthorized. Please login again.';
        } else {
          errorMessage = message ?? errorMessage;
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
                 e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Connection timeout. Please check your internet connection.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'No internet connection. Please check your network.';
      }
      
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Error fetching listing reviews: $e');
    }
  }

  /// Get reviews for a specific event
  Future<Map<String, dynamic>> getEventReviews({
    required String eventId,
    int? page,
    int? limit,
    String? sortBy,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'targetType': 'event',
        'targetId': eventId,
      };
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;
      if (sortBy != null) queryParams['sortBy'] = sortBy;

      final response = await _dio.get(
        '/reviews',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return data;
      } else {
        throw Exception('Failed to fetch event reviews: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to fetch event reviews.';
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data?['message'] ?? e.response!.statusMessage;
        
        if (statusCode == 401) {
          errorMessage = 'Unauthorized. Please login again.';
        } else {
          errorMessage = message ?? errorMessage;
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
                 e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Connection timeout. Please check your internet connection.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'No internet connection. Please check your network.';
      }
      
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Error fetching event reviews: $e');
    }
  }

  /// Get a single review by ID
  Future<Map<String, dynamic>> getReviewById(String reviewId) async {
    try {
      final response = await _dio.get('/reviews/$reviewId');

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to fetch review: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to fetch review.';
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data?['message'] ?? e.response!.statusMessage;
        
        if (statusCode == 401) {
          errorMessage = 'Unauthorized. Please login again.';
        } else if (statusCode == 404) {
          errorMessage = 'Review not found.';
        } else {
          errorMessage = message ?? errorMessage;
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
                 e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Connection timeout. Please check your internet connection.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'No internet connection. Please check your network.';
      }
      
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Error fetching review: $e');
    }
  }

  /// Create a new review
  /// targetType: 'listing', 'event', or 'tour'
  /// targetId: ID of the target being reviewed
  Future<Map<String, dynamic>> createReview({
    required String targetType,
    required String targetId,
    required int rating,
    required String content,
    String? title,
    List<String>? images,
  }) async {
    try {
      final data = <String, dynamic>{
        'targetType': targetType,
        'targetId': targetId,
        'rating': rating,
        'content': content,
      };
      
      if (title != null) data['title'] = title;
      if (images != null && images.isNotEmpty) {
        data['images'] = images;
      }

      final response = await _dio.post('/reviews', data: data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to create review: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to create review.';
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data?['message'] ?? e.response!.statusMessage;
        
        if (statusCode == 401) {
          errorMessage = 'Unauthorized. Please login again.';
        } else if (statusCode == 400) {
          errorMessage = message ?? 'Invalid review data.';
        } else if (statusCode == 409) {
          errorMessage = 'You have already reviewed this item.';
        } else {
          errorMessage = message ?? errorMessage;
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
                 e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Connection timeout. Please check your internet connection.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'No internet connection. Please check your network.';
      }
      
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Error creating review: $e');
    }
  }

  /// Update an existing review
  Future<Map<String, dynamic>> updateReview({
    required String reviewId,
    int? rating,
    String? content,
    String? title,
    List<String>? images,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (rating != null) data['rating'] = rating;
      if (content != null) data['content'] = content;
      if (title != null) data['title'] = title;
      if (images != null) data['images'] = images;

      final response = await _dio.put('/reviews/$reviewId', data: data);

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to update review: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to update review.';
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data?['message'] ?? e.response!.statusMessage;
        
        if (statusCode == 401) {
          errorMessage = 'Unauthorized. Please login again.';
        } else if (statusCode == 403) {
          errorMessage = 'You can only update your own reviews.';
        } else if (statusCode == 404) {
          errorMessage = 'Review not found.';
        } else {
          errorMessage = message ?? errorMessage;
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
                 e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Connection timeout. Please check your internet connection.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'No internet connection. Please check your network.';
      }
      
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Error updating review: $e');
    }
  }

  /// Delete a review
  Future<void> deleteReview(String reviewId) async {
    try {
      final response = await _dio.delete('/reviews/$reviewId');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete review: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to delete review.';
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data?['message'] ?? e.response!.statusMessage;
        
        if (statusCode == 401) {
          errorMessage = 'Unauthorized. Please login again.';
        } else if (statusCode == 403) {
          errorMessage = 'You can only delete your own reviews.';
        } else if (statusCode == 404) {
          errorMessage = 'Review not found.';
        } else {
          errorMessage = message ?? errorMessage;
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
                 e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Connection timeout. Please check your internet connection.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'No internet connection. Please check your network.';
      }
      
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Error deleting review: $e');
    }
  }

  /// Get current user's reviews
  Future<Map<String, dynamic>> getMyReviews({
    int? page,
    int? limit,
    String? sortBy,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;
      if (sortBy != null) queryParams['sortBy'] = sortBy;

      final response = await _dio.get(
        '/reviews/my',
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return data;
      } else {
        throw Exception('Failed to fetch my reviews: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to fetch my reviews.';
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data?['message'] ?? e.response!.statusMessage;
        
        if (statusCode == 401) {
          errorMessage = 'Unauthorized. Please login again.';
        } else {
          errorMessage = message ?? errorMessage;
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
                 e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Connection timeout. Please check your internet connection.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'No internet connection. Please check your network.';
      }
      
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Error fetching my reviews: $e');
    }
  }

  /// Mark a review as helpful or not helpful
  Future<Map<String, dynamic>> markReviewHelpful({
    required String reviewId,
    required bool helpful,
  }) async {
    try {
      final response = await _dio.post(
        '/reviews/$reviewId/helpful',
        data: {'helpful': helpful},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to mark review as helpful: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to mark review as helpful.';
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data?['message'] ?? e.response!.statusMessage;
        
        if (statusCode == 401) {
          errorMessage = 'Unauthorized. Please login again.';
        } else if (statusCode == 404) {
          errorMessage = 'Review not found.';
        } else {
          errorMessage = message ?? errorMessage;
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
                 e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Connection timeout. Please check your internet connection.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'No internet connection. Please check your network.';
      }
      
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Error marking review as helpful: $e');
    }
  }
}

