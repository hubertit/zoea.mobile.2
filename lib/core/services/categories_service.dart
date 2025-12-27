import 'package:dio/dio.dart';
import '../config/app_config.dart';

class CategoriesService {
  final Dio _dio = AppConfig.dioInstance();

  /// Get all categories
  /// Returns list of categories with their children (subcategories)
  Future<List<Map<String, dynamic>>> getCategories({
    bool? includeInactive,
    String? parentId,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (includeInactive != null) queryParams['includeInactive'] = includeInactive;
      if (parentId != null) queryParams['parentId'] = parentId;

      final response = await _dio.get(
        '/categories',
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        } else if (data is Map && data['data'] != null) {
          return List<Map<String, dynamic>>.from(data['data']);
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

  /// Get a single category by ID
  Future<Map<String, dynamic>> getCategoryById(String categoryId) async {
    try {
      final response = await _dio.get('/categories/$categoryId');

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to fetch category: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to fetch category.';
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data?['message'] ?? e.response!.statusMessage;
        
        if (statusCode == 401) {
          errorMessage = 'Unauthorized. Please login again.';
        } else if (statusCode == 404) {
          errorMessage = 'Category not found.';
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
      throw Exception('Error fetching category: $e');
    }
  }

  /// Get a category by slug
  Future<Map<String, dynamic>> getCategoryBySlug(String slug) async {
    try {
      final response = await _dio.get('/categories/slug/$slug');

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to fetch category: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to fetch category.';
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data?['message'] ?? e.response!.statusMessage;
        
        if (statusCode == 401) {
          errorMessage = 'Unauthorized. Please login again.';
        } else if (statusCode == 404) {
          errorMessage = 'Category not found.';
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
      throw Exception('Error fetching category: $e');
    }
  }

  /// Get subcategories (children) of a category
  Future<List<Map<String, dynamic>>> getSubcategories(String parentId) async {
    try {
      final response = await _dio.get('/categories', queryParameters: {'parentId': parentId});

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        } else if (data is Map && data['data'] != null) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
        return [];
      } else {
        throw Exception('Failed to fetch subcategories: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to fetch subcategories.';
      
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
      throw Exception('Error fetching subcategories: $e');
    }
  }

  /// Create a new category
  Future<Map<String, dynamic>> createCategory({
    required String name,
    required String slug,
    String? parentId,
    String? icon,
    String? description,
    int? sortOrder,
    bool? isActive,
  }) async {
    try {
      final response = await _dio.post(
        '/categories',
        data: {
          'name': name,
          'slug': slug,
          if (parentId != null) 'parentId': parentId,
          if (icon != null) 'icon': icon,
          if (description != null) 'description': description,
          if (sortOrder != null) 'sortOrder': sortOrder,
          if (isActive != null) 'isActive': isActive,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to create category: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to create category.';
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data?['message'] ?? e.response!.statusMessage;
        
        if (statusCode == 401) {
          errorMessage = 'Unauthorized. Please login again.';
        } else if (statusCode == 409) {
          errorMessage = 'Category with this slug already exists.';
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
      throw Exception('Error creating category: $e');
    }
  }

  /// Ensure all required categories exist, creating them if they don't
  Future<void> ensureCategoriesExist() async {
    // Expected parent categories matching UI/UX
    const expectedCategories = [
      {'name': 'Events', 'slug': 'events', 'icon': 'event', 'sortOrder': 1},
      {'name': 'Dining', 'slug': 'dining', 'icon': 'restaurant', 'sortOrder': 2},
      {'name': 'Experiences', 'slug': 'experiences', 'icon': 'explore', 'sortOrder': 3},
      {'name': 'Nightlife', 'slug': 'nightlife', 'icon': 'local_bar', 'sortOrder': 4},
      {'name': 'Accommodation', 'slug': 'accommodation', 'icon': 'hotel', 'sortOrder': 5},
      {'name': 'Shopping', 'slug': 'shopping', 'icon': 'shopping_bag', 'sortOrder': 6},
      {'name': 'Attractions', 'slug': 'attractions', 'icon': 'attractions', 'sortOrder': 7},
      {'name': 'Sports', 'slug': 'sports', 'icon': 'sports_soccer', 'sortOrder': 8},
      {'name': 'National Parks', 'slug': 'national-parks', 'icon': 'landscape', 'sortOrder': 9},
      {'name': 'Museums', 'slug': 'museums', 'icon': 'museum', 'sortOrder': 10},
      {'name': 'Transport', 'slug': 'transport', 'icon': 'directions_car', 'sortOrder': 11},
      {'name': 'Hiking', 'slug': 'hiking', 'icon': 'terrain', 'sortOrder': 12},
      {'name': 'Services', 'slug': 'services', 'icon': 'build', 'sortOrder': 13},
    ];

    try {
      // Get all existing categories
      final existingCategories = await getCategories();
      final existingSlugs = existingCategories
          .where((cat) => cat['parentId'] == null)
          .map((cat) => cat['slug'] as String? ?? '')
          .toSet();

      // Create missing categories
      for (final category in expectedCategories) {
        final slug = category['slug'] as String;
        if (!existingSlugs.contains(slug)) {
          try {
            await createCategory(
              name: category['name'] as String,
              slug: slug,
              icon: category['icon'] as String?,
              sortOrder: category['sortOrder'] as int?,
              isActive: true,
            );
          } catch (e) {
            // Category might have been created by another request, ignore duplicate errors
            if (!e.toString().contains('already exists')) {
              // Log other errors but don't throw
              print('Warning: Failed to create category $slug: $e');
            }
          }
        }
      }
    } catch (e) {
      // Don't throw - just log the error
      print('Warning: Failed to ensure categories exist: $e');
    }
  }
}

