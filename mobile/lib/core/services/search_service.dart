import 'package:dio/dio.dart';
import '../config/app_config.dart';

class SearchService {
  /// Get authenticated Dio instance for API calls
  Future<Dio> _getDio() async {
    return AppConfig.authenticatedDioInstance();
  }

  /// Global search - searches across listings, events, and tours
  /// Works for both logged-in and anonymous users
  /// Automatically saves search history (with userId if logged in, without userId if anonymous)
  /// Returns: {listings: [...], events: [...], tours: [...]}
  Future<Map<String, dynamic>> search({
    required String query,
    String? category,
    String? type,
    String? city,
    double? latitude,
    double? longitude,
    double? radiusKm,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'q': query,
      };
      
      if (category != null) queryParams['category'] = category;
      if (type != null) queryParams['type'] = type;
      if (city != null) queryParams['city'] = city;
      if (latitude != null) queryParams['latitude'] = latitude;
      if (longitude != null) queryParams['longitude'] = longitude;
      if (radiusKm != null) queryParams['radius'] = radiusKm;

      final dio = await _getDio();
      final response = await dio.get(
        AppConfig.searchEndpoint,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        // API returns: {listings: [...], events: [...], tours: [...]}
        return {
          'listings': data['listings'] ?? [],
          'events': data['events'] ?? [],
          'tours': data['tours'] ?? [],
        };
      } else {
        throw Exception('Failed to search: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to search.';
      
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
      throw Exception('Error searching: $e');
    }
  }

  /// Search only listings
  Future<List<Map<String, dynamic>>> searchListings({
    required String query,
    String? category,
    String? type,
    String? city,
    double? latitude,
    double? longitude,
    double? radiusKm,
  }) async {
    try {
      final results = await search(
        query: query,
        category: category,
        type: type,
        city: city,
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
      );
      
      final listings = results['listings'] as List?;
      return listings != null 
          ? List<Map<String, dynamic>>.from(listings)
          : [];
    } catch (e) {
      throw Exception('Error searching listings: $e');
    }
  }

  /// Search only events
  Future<List<Map<String, dynamic>>> searchEvents({
    required String query,
    String? category,
    String? city,
    double? latitude,
    double? longitude,
    double? radiusKm,
  }) async {
    try {
      final results = await search(
        query: query,
        category: category,
        city: city,
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
      );
      
      final events = results['events'] as List?;
      return events != null 
          ? List<Map<String, dynamic>>.from(events)
          : [];
    } catch (e) {
      throw Exception('Error searching events: $e');
    }
  }

  /// Search only tours
  Future<List<Map<String, dynamic>>> searchTours({
    required String query,
    String? category,
    String? city,
    double? latitude,
    double? longitude,
    double? radiusKm,
  }) async {
    try {
      final results = await search(
        query: query,
        category: category,
        city: city,
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
      );
      
      final tours = results['tours'] as List?;
      return tours != null 
          ? List<Map<String, dynamic>>.from(tours)
          : [];
    } catch (e) {
      throw Exception('Error searching tours: $e');
    }
  }

  /// Get user's search history
  /// Returns: List of search history items with query, createdAt, filters
  Future<List<Map<String, dynamic>>> getSearchHistory({int limit = 10}) async {
    try {
      final dio = await _getDio();
      final response = await dio.get(
        '${AppConfig.searchEndpoint}/history',
        queryParameters: {'limit': limit},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        }
        return [];
      } else {
        throw Exception('Failed to fetch search history: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to fetch search history.';
      
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
      throw Exception('Error fetching search history: $e');
    }
  }

  /// Get trending searches (popular searches from last 7 days)
  /// Returns: {trendingSearches: [...], featuredListings: [...], upcomingEvents: [...], popularTours: [...]}
  Future<Map<String, dynamic>> getTrendingSearches({
    String? cityId,
    String? countryId,
  }) async {
    try {
      final dio = await _getDio();
      final queryParams = <String, dynamic>{};
      
      if (cityId != null) queryParams['cityId'] = cityId;
      if (countryId != null) queryParams['countryId'] = countryId;

      final response = await dio.get(
        '${AppConfig.searchEndpoint}/trending',
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to fetch trending searches: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to fetch trending searches.';
      
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
      throw Exception('Error fetching trending searches: $e');
    }
  }

  /// Clear user's search history
  Future<void> clearSearchHistory() async {
    try {
      final dio = await _getDio();
      final response = await dio.delete('${AppConfig.searchEndpoint}/history');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      } else {
        throw Exception('Failed to clear search history: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to clear search history.';
      
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
      throw Exception('Error clearing search history: $e');
    }
  }
}

