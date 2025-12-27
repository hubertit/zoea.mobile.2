import 'package:dio/dio.dart';
import '../config/app_config.dart';

class FavoritesService {
  final Dio _dio = AppConfig.dioInstance();

  /// Get all user favorites
  /// Returns list of favorites (listings, events, tours)
  /// Supports pagination: {page, limit}
  Future<Map<String, dynamic>> getFavorites({
    int? page,
    int? limit,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;

      final response = await _dio.get(
        '/favorites',
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
        '/favorites',
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
  /// favoriteId: ID of the favorite record to remove
  Future<void> removeFromFavorites(String favoriteId) async {
    try {
      final response = await _dio.delete('/favorites/$favoriteId');

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

  /// Check if a listing is favorited
  /// Returns the favorite ID if favorited, null otherwise
  Future<String?> checkIfListingFavorited(String listingId) async {
    try {
      final response = await getFavorites();
      final favorites = response['data'] as List? ?? [];
      
      // Find favorite that matches listingId
      for (final favorite in favorites) {
        final favListingId = favorite['listingId']?.toString();
        if (favListingId == listingId) {
          return favorite['id']?.toString();
        }
      }
      
      return null;
    } catch (e) {
      // If error, return null (assume not favorited)
      return null;
    }
  }

  /// Check if an event is favorited
  /// Returns the favorite ID if favorited, null otherwise
  Future<String?> checkIfEventFavorited(String eventId) async {
    try {
      final response = await getFavorites();
      final favorites = response['data'] as List? ?? [];
      
      // Find favorite that matches eventId
      for (final favorite in favorites) {
        final favEventId = favorite['eventId']?.toString();
        if (favEventId == eventId) {
          return favorite['id']?.toString();
        }
      }
      
      return null;
    } catch (e) {
      // If error, return null (assume not favorited)
      return null;
    }
  }

  /// Check if a tour is favorited
  /// Returns the favorite ID if favorited, null otherwise
  Future<String?> checkIfTourFavorited(String tourId) async {
    try {
      final response = await getFavorites();
      final favorites = response['data'] as List? ?? [];
      
      // Find favorite that matches tourId
      for (final favorite in favorites) {
        final favTourId = favorite['tourId']?.toString();
        if (favTourId == tourId) {
          return favorite['id']?.toString();
        }
      }
      
      return null;
    } catch (e) {
      // If error, return null (assume not favorited)
      return null;
    }
  }
}

