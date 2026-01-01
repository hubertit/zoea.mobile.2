import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/orders_service.dart';

final ordersServiceProvider = Provider<OrdersService>((ref) {
  return OrdersService();
});

/// Parameters for orders query
class OrdersParams {
  final int? page;
  final int? limit;
  final String? listingId;
  final String? status;
  final String? fulfillmentType;
  final String? orderNumber;

  const OrdersParams({
    this.page,
    this.limit,
    this.listingId,
    this.status,
    this.fulfillmentType,
    this.orderNumber,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrdersParams &&
          runtimeType == other.runtimeType &&
          page == other.page &&
          limit == other.limit &&
          listingId == other.listingId &&
          status == other.status &&
          fulfillmentType == other.fulfillmentType &&
          orderNumber == other.orderNumber;

  @override
  int get hashCode =>
      page.hashCode ^
      limit.hashCode ^
      listingId.hashCode ^
      status.hashCode ^
      fulfillmentType.hashCode ^
      orderNumber.hashCode;
}

/// Provider for all orders with pagination
final ordersProvider = FutureProvider.family<Map<String, dynamic>, OrdersParams>((ref, params) async {
  final ordersService = ref.watch(ordersServiceProvider);
  return await ordersService.getOrders(
    page: params.page,
    limit: params.limit,
    listingId: params.listingId,
    status: params.status,
    fulfillmentType: params.fulfillmentType,
    orderNumber: params.orderNumber,
  );
});

/// Provider for single order by ID
final orderByIdProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, orderId) async {
  final ordersService = ref.watch(ordersServiceProvider);
  final order = await ordersService.getOrderById(orderId);
  return order.toJson();
});

