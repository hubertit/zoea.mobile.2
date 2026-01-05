import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../models/itinerary.dart';

class ItineraryService {
  Dio? _dio;
  
  Future<Dio> get _getDio async {
    _dio ??= await AppConfig.authenticatedDioInstance();
    return _dio!;
  }

  /// Get all user itineraries
  Future<List<Itinerary>> getMyItineraries({
    int? page,
    int? limit,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;

      final dio = await _getDio;
      final response = await dio.get(
        '${AppConfig.itinerariesEndpoint}/my',
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final itinerariesData = (data is Map && data['data'] != null) 
            ? (data['data'] as List)
            : (data is List ? data : []);
        return (itinerariesData as List)
            .map((json) => Itinerary.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to fetch itineraries: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to fetch itineraries.';
      
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
      throw Exception('Error fetching itineraries: $e');
    }
  }

  /// Get a single itinerary by ID
  Future<Itinerary> getItineraryById(String itineraryId) async {
    try {
      final dio = await _getDio;
      final response = await dio.get('${AppConfig.itinerariesEndpoint}/$itineraryId');

      if (response.statusCode == 200) {
        final data = response.data;
        final itineraryData = data is Map ? (data['data'] ?? data) : data;
        return Itinerary.fromJson(itineraryData as Map<String, dynamic>);
      } else {
        throw Exception('Failed to fetch itinerary: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to fetch itinerary.';
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data?['message'] ?? e.response!.statusMessage;
        
        if (statusCode == 401) {
          errorMessage = 'Unauthorized. Please login again.';
        } else if (statusCode == 404) {
          errorMessage = 'Itinerary not found.';
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
      throw Exception('Error fetching itinerary: $e');
    }
  }

  /// Get shared itinerary by share token
  Future<Itinerary> getSharedItinerary(String shareToken) async {
    try {
      final dio = await _getDio;
      final response = await dio.get('${AppConfig.itinerariesEndpoint}/shared/$shareToken');

      if (response.statusCode == 200) {
        final data = response.data;
        final itineraryData = data is Map ? (data['data'] ?? data) : data;
        return Itinerary.fromJson(itineraryData as Map<String, dynamic>);
      } else {
        throw Exception('Failed to fetch shared itinerary: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to fetch shared itinerary.';
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data?['message'] ?? e.response!.statusMessage;
        
        if (statusCode == 404) {
          errorMessage = 'Shared itinerary not found or link has expired.';
        } else {
          errorMessage = message ?? errorMessage;
        }
      }
      
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Error fetching shared itinerary: $e');
    }
  }

  /// Create a new itinerary
  Future<Itinerary> createItinerary({
    required String title,
    String? description,
    required DateTime startDate,
    required DateTime endDate,
    String? location,
    String? cityId,
    String? countryId,
    bool isPublic = false,
    List<ItineraryItem>? items,
  }) async {
    try {
      final dio = await _getDio;
      final response = await dio.post(
        AppConfig.itinerariesEndpoint,
        data: {
          'title': title,
          if (description != null) 'description': description,
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
          if (location != null) 'location': location,
          if (cityId != null) 'cityId': cityId,
          if (countryId != null) 'countryId': countryId,
          'isPublic': isPublic,
          if (items != null && items.isNotEmpty) 'items': items.map((item) => item.toJson()).toList(),
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        final itineraryData = data is Map ? (data['data'] ?? data) : data;
        return Itinerary.fromJson(itineraryData as Map<String, dynamic>);
      } else {
        throw Exception('Failed to create itinerary: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to create itinerary.';
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data?['message'] ?? e.response!.statusMessage;
        
        if (statusCode == 401) {
          errorMessage = 'Unauthorized. Please login again.';
        } else {
          errorMessage = message ?? errorMessage;
        }
      }
      
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Error creating itinerary: $e');
    }
  }

  /// Update an itinerary
  Future<Itinerary> updateItinerary({
    required String itineraryId,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    String? location,
    String? cityId,
    String? countryId,
    bool? isPublic,
    List<ItineraryItem>? items,
  }) async {
    try {
      final dio = await _getDio;
      final data = <String, dynamic>{};
      if (title != null) data['title'] = title;
      if (description != null) data['description'] = description;
      if (startDate != null) data['startDate'] = startDate.toIso8601String();
      if (endDate != null) data['endDate'] = endDate.toIso8601String();
      if (location != null) data['location'] = location;
      if (cityId != null) data['cityId'] = cityId;
      if (countryId != null) data['countryId'] = countryId;
      if (isPublic != null) data['isPublic'] = isPublic;
      if (items != null) data['items'] = items.map((item) => item.toJson()).toList();

      final response = await dio.put(
        '${AppConfig.itinerariesEndpoint}/$itineraryId',
        data: data,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        final itineraryData = responseData is Map ? (responseData['data'] ?? responseData) : responseData;
        return Itinerary.fromJson(itineraryData as Map<String, dynamic>);
      } else {
        throw Exception('Failed to update itinerary: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to update itinerary.';
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data?['message'] ?? e.response!.statusMessage;
        
        if (statusCode == 401) {
          errorMessage = 'Unauthorized. Please login again.';
        } else if (statusCode == 404) {
          errorMessage = 'Itinerary not found.';
        } else {
          errorMessage = message ?? errorMessage;
        }
      }
      
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Error updating itinerary: $e');
    }
  }

  /// Delete an itinerary
  Future<void> deleteItinerary(String itineraryId) async {
    try {
      final dio = await _getDio;
      final response = await dio.delete('${AppConfig.itinerariesEndpoint}/$itineraryId');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete itinerary: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to delete itinerary.';
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data?['message'] ?? e.response!.statusMessage;
        
        if (statusCode == 401) {
          errorMessage = 'Unauthorized. Please login again.';
        } else if (statusCode == 404) {
          errorMessage = 'Itinerary not found.';
        } else {
          errorMessage = message ?? errorMessage;
        }
      }
      
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Error deleting itinerary: $e');
    }
  }

  /// Share an itinerary (generate share token)
  Future<String> shareItinerary(String itineraryId) async {
    try {
      final dio = await _getDio;
      final response = await dio.post('${AppConfig.itinerariesEndpoint}/$itineraryId/share');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        return data['shareToken'] ?? data['data']?['shareToken'] ?? '';
      } else {
        throw Exception('Failed to share itinerary: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to share itinerary.';
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data?['message'] ?? e.response!.statusMessage;
        
        if (statusCode == 401) {
          errorMessage = 'Unauthorized. Please login again.';
        } else if (statusCode == 404) {
          errorMessage = 'Itinerary not found.';
        } else {
          errorMessage = message ?? errorMessage;
        }
      }
      
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Error sharing itinerary: $e');
    }
  }

  /// Add item to itinerary
  Future<ItineraryItem> addItemToItinerary({
    required String itineraryId,
    required ItineraryItem item,
  }) async {
    try {
      final dio = await _getDio;
      final response = await dio.post(
        '${AppConfig.itinerariesEndpoint}/$itineraryId/items',
        data: item.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        final itemData = data is Map ? (data['data'] ?? data) : data;
        return ItineraryItem.fromJson(itemData as Map<String, dynamic>);
      } else {
        throw Exception('Failed to add item to itinerary: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to add item to itinerary.';
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data?['message'] ?? e.response!.statusMessage;
        
        if (statusCode == 401) {
          errorMessage = 'Unauthorized. Please login again.';
        } else if (statusCode == 404) {
          errorMessage = 'Itinerary not found.';
        } else {
          errorMessage = message ?? errorMessage;
        }
      }
      
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Error adding item to itinerary: $e');
    }
  }

  /// Update item in itinerary
  Future<ItineraryItem> updateItineraryItem({
    required String itineraryId,
    required String itemId,
    required ItineraryItem item,
  }) async {
    try {
      final dio = await _getDio;
      final response = await dio.put(
        '${AppConfig.itinerariesEndpoint}/$itineraryId/items/$itemId',
        data: item.toJson(),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final itemData = data is Map ? (data['data'] ?? data) : data;
        return ItineraryItem.fromJson(itemData as Map<String, dynamic>);
      } else {
        throw Exception('Failed to update item: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to update item.';
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data?['message'] ?? e.response!.statusMessage;
        
        if (statusCode == 401) {
          errorMessage = 'Unauthorized. Please login again.';
        } else if (statusCode == 404) {
          errorMessage = 'Item not found.';
        } else {
          errorMessage = message ?? errorMessage;
        }
      }
      
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Error updating item: $e');
    }
  }

  /// Remove item from itinerary
  Future<void> removeItemFromItinerary({
    required String itineraryId,
    required String itemId,
  }) async {
    try {
      final dio = await _getDio;
      final response = await dio.delete('${AppConfig.itinerariesEndpoint}/$itineraryId/items/$itemId');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to remove item: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to remove item.';
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data?['message'] ?? e.response!.statusMessage;
        
        if (statusCode == 401) {
          errorMessage = 'Unauthorized. Please login again.';
        } else if (statusCode == 404) {
          errorMessage = 'Item not found.';
        } else {
          errorMessage = message ?? errorMessage;
        }
      }
      
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Error removing item: $e');
    }
  }
}

