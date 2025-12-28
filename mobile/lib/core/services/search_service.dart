import 'package:dio/dio.dart';
import '../config/app_config.dart';

class SearchService {
  final Dio _dio = AppConfig.dioInstance();

  /// Global search - searches across listings, events, and tours
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

      final response = await _dio.get(
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
}

