import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/order.dart';

class OrdersService {
  final Dio _dio = AppConfig.dioInstance();
  static const String _sessionIdKey = 'cart_session_id';

  /// Get authenticated Dio instance (optional auth for orders)
  Future<Dio> _getDio({bool requireAuth = false}) async {
    if (requireAuth) {
      return AppConfig.authenticatedDioInstance();
    }
    // For orders, we use optional auth - try to get token but don't fail if not available
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
      sessionId = '${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecondsSinceEpoch}';
      await prefs.setString(_sessionIdKey, sessionId);
    }
    
    return sessionId;
  }

  /// Get all orders
  Future<Map<String, dynamic>> getOrders({
    int? page,
    int? limit,
    String? listingId,
    String? status,
    String? fulfillmentType,
    String? orderNumber,
  }) async {
    try {
      final dio = await _getDio();
      final queryParams = <String, dynamic>{};
      
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;
      if (listingId != null) queryParams['listingId'] = listingId;
      if (status != null) queryParams['status'] = status;
      if (fulfillmentType != null) queryParams['fulfillmentType'] = fulfillmentType;
      if (orderNumber != null) queryParams['orderNumber'] = orderNumber;

      final response = await dio.get(
        AppConfig.ordersEndpoint,
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to fetch orders: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to fetch orders.';
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data?['message'] ?? e.response!.statusMessage;
        
        if (statusCode == 401) {
          errorMessage = 'Unauthorized. Please login again.';
        } else if (statusCode == 403) {
          errorMessage = 'You do not have permission to view these orders.';
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
      throw Exception('Error fetching orders: $e');
    }
  }

  /// Get order by ID
  Future<Order> getOrderById(String id) async {
    try {
      final dio = await _getDio();
      final response = await dio.get('${AppConfig.ordersEndpoint}/$id');

      if (response.statusCode == 200) {
        return Order.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to fetch order: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to fetch order.';
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data?['message'] ?? e.response!.statusMessage;
        
        if (statusCode == 401) {
          errorMessage = 'Unauthorized. Please login again.';
        } else if (statusCode == 403) {
          errorMessage = 'You do not have permission to view this order.';
        } else if (statusCode == 404) {
          errorMessage = 'Order not found.';
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
      throw Exception('Error fetching order: $e');
    }
  }

  /// Create order from cart
  Future<Order> createOrder({
    required String listingId,
    required FulfillmentType fulfillmentType,
    Map<String, dynamic>? deliveryAddress,
    String? pickupLocation,
    DateTime? deliveryDate,
    String? deliveryTimeSlot,
    required String customerName,
    String? customerEmail,
    required String customerPhone,
    String? customerNotes,
    double? taxAmount,
    double? shippingAmount,
    double? discountAmount,
  }) async {
    try {
      final dio = await _getDio();
      final sessionId = await _getSessionId();
      
      final data = <String, dynamic>{
        'listingId': listingId,
        'fulfillmentType': fulfillmentType.toString(),
        'customerName': customerName,
        'customerPhone': customerPhone,
      };

      if (deliveryAddress != null) data['deliveryAddress'] = deliveryAddress;
      if (pickupLocation != null) data['pickupLocation'] = pickupLocation;
      if (deliveryDate != null) {
        data['deliveryDate'] = deliveryDate.toIso8601String().split('T')[0];
      }
      if (deliveryTimeSlot != null) data['deliveryTimeSlot'] = deliveryTimeSlot;
      if (customerEmail != null) data['customerEmail'] = customerEmail;
      if (customerNotes != null) data['customerNotes'] = customerNotes;
      if (taxAmount != null) data['taxAmount'] = taxAmount;
      if (shippingAmount != null) data['shippingAmount'] = shippingAmount;
      if (discountAmount != null) data['discountAmount'] = discountAmount;

      final response = await dio.post(
        AppConfig.ordersEndpoint,
        data: data,
        options: Options(
          headers: {'X-Session-Id': sessionId},
        ),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Order.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to create order: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to create order.';
      
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
            errorMessage = message ?? 'Invalid order data. Please check your input.';
          }
        } else if (statusCode == 404) {
          errorMessage = 'Listing not found or cart is empty.';
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
      throw Exception('Error creating order: $e');
    }
  }

  /// Cancel order
  Future<Order> cancelOrder({
    required String id,
    required String cancellationReason,
  }) async {
    try {
      final dio = await _getDio();
      final response = await dio.put(
        '${AppConfig.ordersEndpoint}/$id/cancel',
        data: {'cancellationReason': cancellationReason},
      );

      if (response.statusCode == 200) {
        return Order.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to cancel order: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to cancel order.';
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data?['message'] ?? e.response!.statusMessage;
        
        if (statusCode == 400) {
          final errorData = e.response!.data;
          if (errorData is Map && errorData['message'] != null) {
            errorMessage = errorData['message'].toString();
          } else {
            errorMessage = message ?? 'Order cannot be cancelled.';
          }
        } else if (statusCode == 401) {
          errorMessage = 'Unauthorized. Please login again.';
        } else if (statusCode == 403) {
          errorMessage = 'You do not have permission to cancel this order.';
        } else if (statusCode == 404) {
          errorMessage = 'Order not found.';
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
      throw Exception('Error cancelling order: $e');
    }
  }
}

