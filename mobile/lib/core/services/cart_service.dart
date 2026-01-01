import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/cart.dart';

class CartService {
  final Dio _dio = AppConfig.dioInstance();
  static const String _sessionIdKey = 'cart_session_id';

  /// Get authenticated Dio instance (optional auth for cart)
  Future<Dio> _getDio({bool requireAuth = false}) async {
    if (requireAuth) {
      return AppConfig.authenticatedDioInstance();
    }
    // For cart, we use optional auth - try to get token but don't fail if not available
    try {
      return await AppConfig.authenticatedDioInstance();
    } catch (e) {
      return _dio;
    }
  }

  /// Get or generate session ID for guest users
  Future<String> _getSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    String? sessionId = prefs.getString(_sessionIdKey);
    
    if (sessionId == null || sessionId.isEmpty) {
      // Generate a UUID-like session ID
      sessionId = '${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecondsSinceEpoch}';
      await prefs.setString(_sessionIdKey, sessionId);
    }
    
    return sessionId;
  }

  /// Get cart (works for both authenticated and guest users)
  Future<Cart> getCart() async {
    try {
      final dio = await _getDio();
      final sessionId = await _getSessionId();
      
      final response = await dio.get(
        AppConfig.cartEndpoint,
        options: Options(
          headers: {'X-Session-Id': sessionId},
        ),
      );

      if (response.statusCode == 200) {
        return Cart.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to fetch cart: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to fetch cart.';
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data?['message'] ?? e.response!.statusMessage;
        
        if (statusCode == 400) {
          errorMessage = 'Cart error. Please try again.';
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
      throw Exception('Error fetching cart: $e');
    }
  }

  /// Add item to cart
  Future<CartItem> addToCart({
    required CartItemType itemType,
    String? productId,
    String? productVariantId,
    String? serviceId,
    String? menuItemId,
    required int quantity,
    Map<String, dynamic>? customization,
    DateTime? serviceBookingDate,
    String? serviceBookingTime,
  }) async {
    try {
      final dio = await _getDio();
      final sessionId = await _getSessionId();
      
      final data = <String, dynamic>{
        'itemType': itemType.toString(),
        'quantity': quantity,
      };

      if (productId != null) data['productId'] = productId;
      if (productVariantId != null) data['productVariantId'] = productVariantId;
      if (serviceId != null) data['serviceId'] = serviceId;
      if (menuItemId != null) data['menuItemId'] = menuItemId;
      if (customization != null) data['customization'] = customization;
      if (serviceBookingDate != null) {
        data['serviceBookingDate'] = serviceBookingDate.toIso8601String();
      }
      if (serviceBookingTime != null) data['serviceBookingTime'] = serviceBookingTime;

      final response = await dio.post(
        '${AppConfig.cartEndpoint}/items',
        data: data,
        options: Options(
          headers: {'X-Session-Id': sessionId},
        ),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return CartItem.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to add item to cart: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to add item to cart.';
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data?['message'] ?? e.response!.statusMessage;
        
        if (statusCode == 400) {
          final errorData = e.response!.data;
          if (errorData is Map && errorData['message'] != null) {
            errorMessage = errorData['message'].toString();
          } else {
            errorMessage = message ?? 'Invalid item data. Please check your input.';
          }
        } else if (statusCode == 404) {
          errorMessage = 'Item not found.';
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
      throw Exception('Error adding item to cart: $e');
    }
  }

  /// Update cart item
  Future<CartItem> updateCartItem({
    required String itemId,
    required int quantity,
    Map<String, dynamic>? customization,
    DateTime? serviceBookingDate,
    String? serviceBookingTime,
  }) async {
    try {
      final dio = await _getDio();
      final sessionId = await _getSessionId();
      
      final data = <String, dynamic>{
        'quantity': quantity,
      };

      if (customization != null) data['customization'] = customization;
      if (serviceBookingDate != null) {
        data['serviceBookingDate'] = serviceBookingDate.toIso8601String();
      }
      if (serviceBookingTime != null) data['serviceBookingTime'] = serviceBookingTime;

      final response = await dio.put(
        '${AppConfig.cartEndpoint}/items/$itemId',
        data: data,
        options: Options(
          headers: {'X-Session-Id': sessionId},
        ),
      );

      if (response.statusCode == 200) {
        return CartItem.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to update cart item: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to update cart item.';
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data?['message'] ?? e.response!.statusMessage;
        
        if (statusCode == 400) {
          errorMessage = 'Cart item does not belong to your cart.';
        } else if (statusCode == 404) {
          errorMessage = 'Cart item not found.';
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
      throw Exception('Error updating cart item: $e');
    }
  }

  /// Remove item from cart
  Future<void> removeCartItem(String itemId) async {
    try {
      final dio = await _getDio();
      final sessionId = await _getSessionId();
      
      final response = await dio.delete(
        '${AppConfig.cartEndpoint}/items/$itemId',
        options: Options(
          headers: {'X-Session-Id': sessionId},
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to remove cart item: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to remove cart item.';
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data?['message'] ?? e.response!.statusMessage;
        
        if (statusCode == 400) {
          errorMessage = 'Cart item does not belong to your cart.';
        } else if (statusCode == 404) {
          errorMessage = 'Cart item not found.';
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
      throw Exception('Error removing cart item: $e');
    }
  }

  /// Clear cart
  Future<void> clearCart() async {
    try {
      final dio = await _getDio();
      final sessionId = await _getSessionId();
      
      final response = await dio.delete(
        AppConfig.cartEndpoint,
        options: Options(
          headers: {'X-Session-Id': sessionId},
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to clear cart: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to clear cart.';
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data?['message'] ?? e.response!.statusMessage;
        
        if (statusCode == 400) {
          errorMessage = 'Cart error. Please try again.';
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
      throw Exception('Error clearing cart: $e');
    }
  }
}

