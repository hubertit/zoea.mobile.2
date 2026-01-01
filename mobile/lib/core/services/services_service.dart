import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../models/service.dart';

class ServicesService {
  final Dio _dio = AppConfig.dioInstance();

  /// Get authenticated Dio instance for authenticated endpoints
  Future<Dio> _getDio() async {
    return AppConfig.authenticatedDioInstance();
  }

  /// Get all services with filters and sorting
  Future<Map<String, dynamic>> getServices({
    int? page,
    int? limit,
    String? listingId,
    String? status,
    String? search,
    String? category,
    double? minPrice,
    double? maxPrice,
    bool? isFeatured,
    String? sortBy,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;
      if (listingId != null) queryParams['listingId'] = listingId;
      if (status != null) queryParams['status'] = status;
      if (search != null) queryParams['search'] = search;
      if (category != null) queryParams['category'] = category;
      if (minPrice != null) queryParams['minPrice'] = minPrice;
      if (maxPrice != null) queryParams['maxPrice'] = maxPrice;
      if (isFeatured != null) queryParams['isFeatured'] = isFeatured;
      if (sortBy != null && sortBy.isNotEmpty) queryParams['sortBy'] = sortBy;

      final response = await _dio.get(
        AppConfig.servicesEndpoint,
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to fetch services: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to fetch services.';
      
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
      throw Exception('Error fetching services: $e');
    }
  }

  /// Get service by ID
  Future<Service> getServiceById(String id) async {
    try {
      final response = await _dio.get('${AppConfig.servicesEndpoint}/$id');

      if (response.statusCode == 200) {
        return Service.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to fetch service: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to fetch service.';
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data?['message'] ?? e.response!.statusMessage;
        
        if (statusCode == 401) {
          errorMessage = 'Unauthorized. Please login again.';
        } else if (statusCode == 404) {
          errorMessage = 'Service not found.';
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
      throw Exception('Error fetching service: $e');
    }
  }

  /// Book a service
  Future<ServiceBooking> bookService(String serviceId, Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        '${AppConfig.servicesEndpoint}/$serviceId/bookings',
        data: data,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return ServiceBooking.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to book service: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to book service.';
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data?['message'] ?? e.response!.statusMessage;
        
        if (statusCode == 400) {
          final errorData = e.response!.data;
          if (errorData is Map && errorData['message'] != null) {
            errorMessage = errorData['message'].toString();
          } else {
            errorMessage = message ?? 'Invalid booking data. Please check your input.';
          }
        } else if (statusCode == 404) {
          errorMessage = 'Service not found.';
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
      throw Exception('Error booking service: $e');
    }
  }
}

