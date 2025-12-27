import 'package:dio/dio.dart';
import '../config/app_config.dart';

class FavoritesService {
  final Dio _dio = AppConfig.dioInstance();

  /// Get all user favorites
  /// Returns list of favorites (listings, events, tours)
  /// Supports pagination: {page, limit, type}
  Future<Map<String, dynamic>> getFavorites({
    int? page,
    int? limit,
    String? type, // 'listing', 'event', or 'tour'
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;
      if (type != null) queryParams['type'] = type;

      final response = await _dio.get(
        AppConfig.favoritesEndpoint,
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        // API returns: {data: [...], meta: {total, page, limit, totalPages}}
        return data;
      } else {
        throw Exception('Failed to fetch favorites: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to fetch favorites.';
      
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
      throw Exception('Error fetching favorites: $e');
    }
  }

  /// Add listing to favorites
  Future<Map<String, dynamic>> addListingToFavorites(String listingId) async {
    try {
      final response = await _dio.post(
        AppConfig.favoritesEndpoint,
        data: {
          'listingId': listingId,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to add to favorites: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to add to favorites.';
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data?['message'] ?? e.response!.statusMessage;
        
        if (statusCode == 401) {
          errorMessage = 'Unauthorized. Please login again.';
        } else if (statusCode == 409) {
          errorMessage = 'Item is already in favorites.';
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
      throw Exception('Error adding to favorites: $e');
    }
  }

  /// Add event to favorites
  Future<Map<String, dynamic>> addEventToFavorites(String eventId) async {
    try {
      final response = await _dio.post(
        '/favorites',
        data: {
          'eventId': eventId,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to add to favorites: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to add to favorites.';
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data?['message'] ?? e.response!.statusMessage;
        
        if (statusCode == 401) {
          errorMessage = 'Unauthorized. Please login again.';
        } else if (statusCode == 409) {
          errorMessage = 'Item is already in favorites.';
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
      throw Exception('Error adding to favorites: $e');
    }
  }

  /// Add tour to favorites
  Future<Map<String, dynamic>> addTourToFavorites(String tourId) async {
    try {
      final response = await _dio.post(
        '/favorites',
        data: {
          'tourId': tourId,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to add to favorites: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to add to favorites.';
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data?['message'] ?? e.response!.statusMessage;
        
        if (statusCode == 401) {
          errorMessage = 'Unauthorized. Please login again.';
        } else if (statusCode == 409) {
          errorMessage = 'Item is already in favorites.';
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
      throw Exception('Error adding to favorites: $e');
    }
  }

  /// Remove item from favorites
  /// Provide one of: listingId, eventId, or tourId
  Future<void> removeFromFavorites({
    String? listingId,
    String? eventId,
    String? tourId,
  }) async {
    try {
      // Validate that exactly one ID is provided
      final idCount = [listingId, eventId, tourId].where((id) => id != null).length;
      if (idCount != 1) {
        throw Exception('Must provide exactly one of: listingId, eventId, or tourId');
      }

      final queryParams = <String, dynamic>{};
      if (listingId != null) queryParams['listingId'] = listingId;
      if (eventId != null) queryParams['eventId'] = eventId;
      if (tourId != null) queryParams['tourId'] = tourId;

      final response = await _dio.delete(
        AppConfig.favoritesEndpoint,
        queryParameters: queryParams,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to remove from favorites: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to remove from favorites.';
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data?['message'] ?? e.response!.statusMessage;
        
        if (statusCode == 401) {
          errorMessage = 'Unauthorized. Please login again.';
        } else if (statusCode == 404) {
          errorMessage = 'Favorite not found.';
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
      throw Exception('Error removing from favorites: $e');
    }
  }

  /// Toggle favorite status (add if not favorited, remove if favorited)
  /// Provide one of: listingId, eventId, or tourId
  Future<Map<String, dynamic>> toggleFavorite({
    String? listingId,
    String? eventId,
    String? tourId,
  }) async {
    try {
      // Validate that exactly one ID is provided
      final idCount = [listingId, eventId, tourId].where((id) => id != null).length;
      if (idCount != 1) {
        throw Exception('Must provide exactly one of: listingId, eventId, or tourId');
      }

      final data = <String, dynamic>{};
      if (listingId != null) data['listingId'] = listingId;
      if (eventId != null) data['eventId'] = eventId;
      if (tourId != null) data['tourId'] = tourId;

      final response = await _dio.post(
        '${AppConfig.favoritesEndpoint}/toggle',
        data: data,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to toggle favorite: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to toggle favorite.';
      
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
      throw Exception('Error toggling favorite: $e');
    }
  }

  /// Check if an item is favorited
  /// Provide one of: listingId, eventId, or tourId
  /// Returns true if favorited, false otherwise
  Future<bool> checkIfFavorited({
    String? listingId,
    String? eventId,
    String? tourId,
  }) async {
    try {
      // Validate that exactly one ID is provided
      final idCount = [listingId, eventId, tourId].where((id) => id != null).length;
      if (idCount != 1) {
        throw Exception('Must provide exactly one of: listingId, eventId, or tourId');
      }

      final queryParams = <String, dynamic>{};
      if (listingId != null) queryParams['listingId'] = listingId;
      if (eventId != null) queryParams['eventId'] = eventId;
      if (tourId != null) queryParams['tourId'] = tourId;

      final response = await _dio.get(
        '${AppConfig.favoritesEndpoint}/check',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return data['isFavorite'] == true || data['favorited'] == true;
      } else {
        return false;
      }
    } catch (e) {
      // If error, return false (assume not favorited)
      return false;
    }
  }

  /// Check if a listing is favorited (convenience method)
  Future<bool> checkIfListingFavorited(String listingId) async {
    return checkIfFavorited(listingId: listingId);
  }

  /// Check if an event is favorited (convenience method)
  Future<bool> checkIfEventFavorited(String eventId) async {
    return checkIfFavorited(eventId: eventId);
  }

  /// Check if a tour is favorited (convenience method)
  Future<bool> checkIfTourFavorited(String tourId) async {
    return checkIfFavorited(tourId: tourId);
  }
}

