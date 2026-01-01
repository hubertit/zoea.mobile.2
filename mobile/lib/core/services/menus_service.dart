import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../models/menu.dart';

class MenusService {
  final Dio _dio = AppConfig.dioInstance();

  /// Get authenticated Dio instance for authenticated endpoints
  Future<Dio> _getDio() async {
    return AppConfig.authenticatedDioInstance();
  }

  /// Get all menus
  Future<List<Menu>> getMenus({
    String? listingId,
    bool? isActive,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (listingId != null) queryParams['listingId'] = listingId;
      if (isActive != null) queryParams['isActive'] = isActive;

      final response = await _dio.get(
        AppConfig.menusEndpoint,
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
      if (data is List) {
        return data.map((m) => Menu.fromJson(m as Map<String, dynamic>)).toList();
      }
        return [];
      } else {
        throw Exception('Failed to fetch menus: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to fetch menus.';
      
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
      throw Exception('Error fetching menus: $e');
    }
  }

  /// Get menu by ID
  Future<Menu> getMenuById(String id) async {
    try {
      final response = await _dio.get('${AppConfig.menusEndpoint}/$id');

      if (response.statusCode == 200) {
        return Menu.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to fetch menu: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to fetch menu.';
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data?['message'] ?? e.response!.statusMessage;
        
        if (statusCode == 401) {
          errorMessage = 'Unauthorized. Please login again.';
        } else if (statusCode == 404) {
          errorMessage = 'Menu not found.';
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
      throw Exception('Error fetching menu: $e');
    }
  }

  /// Get all menu categories
  Future<List<MenuCategory>> getCategories() async {
    try {
      final response = await _dio.get('${AppConfig.menusEndpoint}/categories');

      if (response.statusCode == 200) {
        final data = response.data;
      if (data is List) {
        return data.map((c) => MenuCategory.fromJson(c as Map<String, dynamic>)).toList();
      }
        return [];
      } else {
        throw Exception('Failed to fetch categories: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to fetch categories.';
      
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
      throw Exception('Error fetching categories: $e');
    }
  }
}

