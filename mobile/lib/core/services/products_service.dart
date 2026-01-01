import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../models/product.dart';

class ProductsService {
  final Dio _dio = AppConfig.dioInstance();

  /// Get authenticated Dio instance for authenticated endpoints
  Future<Dio> _getDio() async {
    return AppConfig.authenticatedDioInstance();
  }

  /// Get all products with filters and sorting
  /// Returns paginated response: {data: [...], meta: {total, page, limit, totalPages}}
  /// sortBy options: 'popular', 'name_asc', 'name_desc', 'price_asc', 'price_desc', 'createdAt_desc', 'createdAt_asc'
  Future<Map<String, dynamic>> getProducts({
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
        AppConfig.productsEndpoint,
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to fetch products: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to fetch products.';
      
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
      throw Exception('Error fetching products: $e');
    }
  }

  /// Get products by listing
  Future<Map<String, dynamic>> getProductsByListing({
    required String listingId,
    int? page,
    int? limit,
    String? status,
    String? search,
    String? category,
    String? sortBy,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;
      if (status != null) queryParams['status'] = status;
      if (search != null) queryParams['search'] = search;
      if (category != null) queryParams['category'] = category;
      if (sortBy != null && sortBy.isNotEmpty) queryParams['sortBy'] = sortBy;

      final response = await _dio.get(
        '${AppConfig.productsEndpoint}/listing/$listingId',
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to fetch products: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to fetch products.';
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data?['message'] ?? e.response!.statusMessage;
        
        if (statusCode == 401) {
          errorMessage = 'Unauthorized. Please login again.';
        } else if (statusCode == 404) {
          errorMessage = 'Listing not found.';
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
      throw Exception('Error fetching products: $e');
    }
  }

  /// Get product by ID
  Future<Product> getProductById(String id) async {
    try {
      final response = await _dio.get('${AppConfig.productsEndpoint}/$id');

      if (response.statusCode == 200) {
        return Product.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to fetch product: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to fetch product.';
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data?['message'] ?? e.response!.statusMessage;
        
        if (statusCode == 401) {
          errorMessage = 'Unauthorized. Please login again.';
        } else if (statusCode == 404) {
          errorMessage = 'Product not found.';
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
      throw Exception('Error fetching product: $e');
    }
  }

  /// Create product (requires authentication)
  Future<Product> createProduct(Map<String, dynamic> data) async {
    try {
      final dio = await _getDio();
      final response = await dio.post(
        AppConfig.productsEndpoint,
        data: data,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Product.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to create product: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to create product.';
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data?['message'] ?? e.response!.statusMessage;
        
        if (statusCode == 400) {
          final errorData = e.response!.data;
          if (errorData is Map && errorData['message'] != null) {
            if (errorData['message'] is List) {
              errorMessage = (errorData['message'] as List).join(', ');
            } else {
              errorMessage = errorData['message'].toString();
            }
          } else {
            errorMessage = message ?? 'Invalid product data. Please check your input.';
          }
        } else if (statusCode == 401) {
          errorMessage = 'Unauthorized. Please login again.';
        } else if (statusCode == 403) {
          errorMessage = 'You do not have permission to create products for this listing.';
        } else if (statusCode == 404) {
          errorMessage = 'Listing not found.';
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
      throw Exception('Error creating product: $e');
    }
  }

  /// Update product (requires authentication)
  Future<Product> updateProduct(String id, Map<String, dynamic> data) async {
    try {
      final dio = await _getDio();
      final response = await dio.put(
        '${AppConfig.productsEndpoint}/$id',
        data: data,
      );

      if (response.statusCode == 200) {
        return Product.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to update product: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to update product.';
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data?['message'] ?? e.response!.statusMessage;
        
        if (statusCode == 400) {
          final errorData = e.response!.data;
          if (errorData is Map && errorData['message'] != null) {
            if (errorData['message'] is List) {
              errorMessage = (errorData['message'] as List).join(', ');
            } else {
              errorMessage = errorData['message'].toString();
            }
          } else {
            errorMessage = message ?? 'Invalid product data. Please check your input.';
          }
        } else if (statusCode == 401) {
          errorMessage = 'Unauthorized. Please login again.';
        } else if (statusCode == 403) {
          errorMessage = 'You do not have permission to update this product.';
        } else if (statusCode == 404) {
          errorMessage = 'Product not found.';
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
      throw Exception('Error updating product: $e');
    }
  }

  /// Delete product (requires authentication)
  Future<void> deleteProduct(String id) async {
    try {
      final dio = await _getDio();
      final response = await dio.delete('${AppConfig.productsEndpoint}/$id');

      if (response.statusCode != 200) {
        throw Exception('Failed to delete product: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to delete product.';
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data?['message'] ?? e.response!.statusMessage;
        
        if (statusCode == 401) {
          errorMessage = 'Unauthorized. Please login again.';
        } else if (statusCode == 403) {
          errorMessage = 'You do not have permission to delete this product.';
        } else if (statusCode == 404) {
          errorMessage = 'Product not found.';
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
      throw Exception('Error deleting product: $e');
    }
  }

  /// Create product variant (requires authentication)
  Future<ProductVariant> createVariant(String productId, Map<String, dynamic> data) async {
    try {
      final dio = await _getDio();
      final response = await dio.post(
        '${AppConfig.productsEndpoint}/$productId/variants',
        data: data,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return ProductVariant.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to create variant: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to create variant.';
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data?['message'] ?? e.response!.statusMessage;
        
        if (statusCode == 400) {
          final errorData = e.response!.data;
          if (errorData is Map && errorData['message'] != null) {
            errorMessage = errorData['message'].toString();
          } else {
            errorMessage = message ?? 'Invalid variant data. Please check your input.';
          }
        } else if (statusCode == 401) {
          errorMessage = 'Unauthorized. Please login again.';
        } else if (statusCode == 403) {
          errorMessage = 'You do not have permission to create variants for this product.';
        } else if (statusCode == 404) {
          errorMessage = 'Product not found.';
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
      throw Exception('Error creating variant: $e');
    }
  }

  /// Update product variant (requires authentication)
  Future<ProductVariant> updateVariant(String variantId, Map<String, dynamic> data) async {
    try {
      final dio = await _getDio();
      final response = await dio.put(
        '${AppConfig.productsEndpoint}/variants/$variantId',
        data: data,
      );

      if (response.statusCode == 200) {
        return ProductVariant.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to update variant: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to update variant.';
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data?['message'] ?? e.response!.statusMessage;
        
        if (statusCode == 400) {
          final errorData = e.response!.data;
          if (errorData is Map && errorData['message'] != null) {
            errorMessage = errorData['message'].toString();
          } else {
            errorMessage = message ?? 'Invalid variant data. Please check your input.';
          }
        } else if (statusCode == 401) {
          errorMessage = 'Unauthorized. Please login again.';
        } else if (statusCode == 403) {
          errorMessage = 'You do not have permission to update this variant.';
        } else if (statusCode == 404) {
          errorMessage = 'Variant not found.';
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
      throw Exception('Error updating variant: $e');
    }
  }

  /// Delete product variant (requires authentication)
  Future<void> deleteVariant(String variantId) async {
    try {
      final dio = await _getDio();
      final response = await dio.delete('${AppConfig.productsEndpoint}/variants/$variantId');

      if (response.statusCode != 200) {
        throw Exception('Failed to delete variant: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to delete variant.';
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data?['message'] ?? e.response!.statusMessage;
        
        if (statusCode == 401) {
          errorMessage = 'Unauthorized. Please login again.';
        } else if (statusCode == 403) {
          errorMessage = 'You do not have permission to delete this variant.';
        } else if (statusCode == 404) {
          errorMessage = 'Variant not found.';
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
      throw Exception('Error deleting variant: $e');
    }
  }
}

