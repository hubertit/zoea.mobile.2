import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';

class ReviewsService {
  Dio? _dio;
  
  Future<Dio> get _getDio async {
    _dio ??= await AppConfig.authenticatedDioInstance();
    return _dio!;
  }

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

      final dio = await _getDio;
      final response = await dio.get(
        AppConfig.reviewsEndpoint,
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
        'listingId': listingId,
      };
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;
      if (sortBy != null) queryParams['sortBy'] = sortBy;

      final dio = await _getDio;
      final response = await dio.get(
        AppConfig.reviewsEndpoint,
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
        final data = e.response!.data;
        
        // Log full error for debugging
        debugPrint('ReviewsService Error: Status $statusCode, Message: $message, Data: $data');
        
        if (statusCode == 401) {
          errorMessage = 'Unauthorized. Please login again.';
        } else if (statusCode == 400) {
          errorMessage = message ?? 'Invalid request. Please check the listing ID.';
        } else if (statusCode == 404) {
          errorMessage = 'Reviews not found for this listing.';
        } else {
          errorMessage = message ?? errorMessage;
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
                 e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Connection timeout. Please check your internet connection.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'No internet connection. Please check your network.';
      } else {
        errorMessage = 'Network error: ${e.message}';
      }
      
      throw Exception(errorMessage);
    } catch (e) {
      debugPrint('ReviewsService Unexpected Error: $e');
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
        'eventId': eventId,
      };
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;
      if (sortBy != null) queryParams['sortBy'] = sortBy;

      final dio = await _getDio;
      final response = await dio.get(
        AppConfig.reviewsEndpoint,
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

  /// Get reviews for a specific tour
  Future<Map<String, dynamic>> getTourReviews({
    required String tourId,
    int? page,
    int? limit,
    String? sortBy,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'tourId': tourId,
      };
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;
      if (sortBy != null) queryParams['sortBy'] = sortBy;

      final dio = await _getDio;
      final response = await dio.get(
        AppConfig.reviewsEndpoint,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return data;
      } else {
        throw Exception('Failed to fetch tour reviews: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to fetch tour reviews.';
      
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
      throw Exception('Error fetching tour reviews: $e');
    }
  }

  /// Get a single review by ID
  Future<Map<String, dynamic>> getReviewById(String reviewId) async {
    try {
      final dio = await _getDio;
      final response = await dio.get('${AppConfig.reviewsEndpoint}/$reviewId');

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
  /// Provide one of: listingId, eventId, or tourId
  Future<Map<String, dynamic>> createReview({
    String? listingId,
    String? eventId,
    String? tourId,
    required int rating,
    required String content,
    String? title,
  }) async {
    try {
      // Validate that exactly one target ID is provided
      final targetCount = [listingId, eventId, tourId].where((id) => id != null).length;
      if (targetCount != 1) {
        throw Exception('Must provide exactly one of: listingId, eventId, or tourId');
      }

      final data = <String, dynamic>{
        'rating': rating,
        'content': content,
      };
      
      if (listingId != null) data['listingId'] = listingId;
      if (eventId != null) data['eventId'] = eventId;
      if (tourId != null) data['tourId'] = tourId;
      if (title != null) data['title'] = title;

      final dio = await _getDio;
      final response = await dio.post(AppConfig.reviewsEndpoint, data: data);

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
  }) async {
    try {
      final data = <String, dynamic>{};
      if (rating != null) data['rating'] = rating;
      if (content != null) data['content'] = content;
      if (title != null) data['title'] = title;

      final dio = await _getDio;
      final response = await dio.put('${AppConfig.reviewsEndpoint}/$reviewId', data: data);

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
      final dio = await _getDio;
      final response = await dio.delete('${AppConfig.reviewsEndpoint}/$reviewId');

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

      final dio = await _getDio;
      final response = await dio.get(
        '${AppConfig.reviewsEndpoint}/my',
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
      final dio = await _getDio;
      final response = await dio.post(
        '${AppConfig.reviewsEndpoint}/$reviewId/helpful',
        data: {'isHelpful': helpful},
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

