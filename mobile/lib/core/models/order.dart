import 'cart.dart';

class Order {
  final String id;
  final String orderNumber;
  final String? userId;
  final String listingId;
  final String merchantId;
  final OrderType orderType;
  final double subtotal;
  final double taxAmount;
  final double shippingAmount;
  final double discountAmount;
  final double totalAmount;
  final String currency;
  final FulfillmentType fulfillmentType;
  final Map<String, dynamic>? deliveryAddress;
  final String? pickupLocation;
  final DateTime? deliveryDate;
  final String? deliveryTimeSlot;
  final String customerName;
  final String? customerEmail;
  final String customerPhone;
  final String? customerNotes;
  final OrderStatus status;
  final FulfillmentStatus fulfillmentStatus;
  final String paymentStatus;
  final String? internalNotes;
  final DateTime? confirmedAt;
  final DateTime? shippedAt;
  final DateTime? deliveredAt;
  final DateTime? cancelledAt;
  final String? cancelledBy;
  final String? cancellationReason;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<OrderItem> items;
  final Map<String, dynamic>? listing;
  final Map<String, dynamic>? merchant;

  Order({
    required this.id,
    required this.orderNumber,
    this.userId,
    required this.listingId,
    required this.merchantId,
    required this.orderType,
    required this.subtotal,
    required this.taxAmount,
    required this.shippingAmount,
    required this.discountAmount,
    required this.totalAmount,
    this.currency = 'RWF',
    required this.fulfillmentType,
    this.deliveryAddress,
    this.pickupLocation,
    this.deliveryDate,
    this.deliveryTimeSlot,
    required this.customerName,
    this.customerEmail,
    required this.customerPhone,
    this.customerNotes,
    this.status = OrderStatus.pending,
    this.fulfillmentStatus = FulfillmentStatus.pending,
    this.paymentStatus = 'pending',
    this.internalNotes,
    this.confirmedAt,
    this.shippedAt,
    this.deliveredAt,
    this.cancelledAt,
    this.cancelledBy,
    this.cancellationReason,
    required this.createdAt,
    required this.updatedAt,
    this.items = const [],
    this.listing,
    this.merchant,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      orderNumber: json['orderNumber'] as String? ?? json['order_number'] as String,
      userId: json['userId'] as String? ?? json['user_id'] as String?,
      listingId: json['listingId'] as String? ?? json['listing_id'] as String,
      merchantId: json['merchantId'] as String? ?? json['merchant_id'] as String,
      orderType: OrderType.fromString(json['orderType'] as String? ?? json['order_type'] as String? ?? 'mixed'),
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      taxAmount: (json['taxAmount'] ?? json['tax_amount'] ?? 0).toDouble(),
      shippingAmount: (json['shippingAmount'] ?? json['shipping_amount'] ?? 0).toDouble(),
      discountAmount: (json['discountAmount'] ?? json['discount_amount'] ?? 0).toDouble(),
      totalAmount: (json['totalAmount'] ?? json['total_amount'] ?? 0).toDouble(),
      currency: json['currency'] as String? ?? 'RWF',
      fulfillmentType: FulfillmentType.fromString(json['fulfillmentType'] as String? ?? json['fulfillment_type'] as String),
      deliveryAddress: json['deliveryAddress'] as Map<String, dynamic>? ?? json['delivery_address'] as Map<String, dynamic>?,
      pickupLocation: json['pickupLocation'] as String? ?? json['pickup_location'] as String?,
      deliveryDate: json['deliveryDate'] != null || json['delivery_date'] != null
          ? DateTime.parse((json['deliveryDate'] ?? json['delivery_date']) as String)
          : null,
      deliveryTimeSlot: json['deliveryTimeSlot'] as String? ?? json['delivery_time_slot'] as String?,
      customerName: json['customerName'] as String? ?? json['customer_name'] as String,
      customerEmail: json['customerEmail'] as String? ?? json['customer_email'] as String?,
      customerPhone: json['customerPhone'] as String? ?? json['customer_phone'] as String,
      customerNotes: json['customerNotes'] as String? ?? json['customer_notes'] as String?,
      status: OrderStatus.fromString(json['status'] as String? ?? 'pending'),
      fulfillmentStatus: FulfillmentStatus.fromString(json['fulfillmentStatus'] as String? ?? json['fulfillment_status'] as String? ?? 'pending'),
      paymentStatus: json['paymentStatus'] as String? ?? json['payment_status'] as String? ?? 'pending',
      internalNotes: json['internalNotes'] as String? ?? json['internal_notes'] as String?,
      confirmedAt: json['confirmedAt'] != null || json['confirmed_at'] != null
          ? DateTime.parse((json['confirmedAt'] ?? json['confirmed_at']) as String)
          : null,
      shippedAt: json['shippedAt'] != null || json['shipped_at'] != null
          ? DateTime.parse((json['shippedAt'] ?? json['shipped_at']) as String)
          : null,
      deliveredAt: json['deliveredAt'] != null || json['delivered_at'] != null
          ? DateTime.parse((json['deliveredAt'] ?? json['delivered_at']) as String)
          : null,
      cancelledAt: json['cancelledAt'] != null || json['cancelled_at'] != null
          ? DateTime.parse((json['cancelledAt'] ?? json['cancelled_at']) as String)
          : null,
      cancelledBy: json['cancelledBy'] as String? ?? json['cancelled_by'] as String?,
      cancellationReason: json['cancellationReason'] as String? ?? json['cancellation_reason'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String? ?? json['created_at'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String? ?? json['updated_at'] as String),
      items: json['items'] != null
          ? (json['items'] as List).map((i) => OrderItem.fromJson(i as Map<String, dynamic>)).toList()
          : const [],
      listing: json['listing'] as Map<String, dynamic>?,
      merchant: json['merchant'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderNumber': orderNumber,
      'userId': userId,
      'listingId': listingId,
      'merchantId': merchantId,
      'orderType': orderType.toString(),
      'subtotal': subtotal,
      'taxAmount': taxAmount,
      'shippingAmount': shippingAmount,
      'discountAmount': discountAmount,
      'totalAmount': totalAmount,
      'currency': currency,
      'fulfillmentType': fulfillmentType.toString(),
      'deliveryAddress': deliveryAddress,
      'pickupLocation': pickupLocation,
      'deliveryDate': deliveryDate?.toIso8601String(),
      'deliveryTimeSlot': deliveryTimeSlot,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'customerPhone': customerPhone,
      'customerNotes': customerNotes,
      'status': status.toString(),
      'fulfillmentStatus': fulfillmentStatus.toString(),
      'paymentStatus': paymentStatus,
      'internalNotes': internalNotes,
      'confirmedAt': confirmedAt?.toIso8601String(),
      'shippedAt': shippedAt?.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
      'cancelledAt': cancelledAt?.toIso8601String(),
      'cancelledBy': cancelledBy,
      'cancellationReason': cancellationReason,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'items': items.map((i) => i.toJson()).toList(),
      'listing': listing,
      'merchant': merchant,
    };
  }

  bool get canBeCancelled => !['delivered', 'cancelled', 'refunded'].contains(status.toString());
}

class OrderItem {
  final String id;
  final String orderId;
  final CartItemType itemType;
  final String? productId;
  final String? productVariantId;
  final String? serviceId;
  final String? menuItemId;
  final String itemName;
  final String? itemSku;
  final String? itemImageId;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String currency;
  final Map<String, dynamic>? customization;
  final DateTime? serviceBookingDate;
  final String? serviceBookingTime;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? product;
  final Map<String, dynamic>? productVariant;
  final Map<String, dynamic>? service;
  final Map<String, dynamic>? menuItem;
  final Map<String, dynamic>? serviceBooking;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.itemType,
    this.productId,
    this.productVariantId,
    this.serviceId,
    this.menuItemId,
    required this.itemName,
    this.itemSku,
    this.itemImageId,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.currency = 'RWF',
    this.customization,
    this.serviceBookingDate,
    this.serviceBookingTime,
    required this.createdAt,
    required this.updatedAt,
    this.product,
    this.productVariant,
    this.service,
    this.menuItem,
    this.serviceBooking,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as String,
      orderId: json['orderId'] as String? ?? json['order_id'] as String,
      itemType: CartItemType.fromString(json['itemType'] as String? ?? json['item_type'] as String),
      productId: json['productId'] as String? ?? json['product_id'] as String?,
      productVariantId: json['productVariantId'] as String? ?? json['product_variant_id'] as String?,
      serviceId: json['serviceId'] as String? ?? json['service_id'] as String?,
      menuItemId: json['menuItemId'] as String? ?? json['menu_item_id'] as String?,
      itemName: json['itemName'] as String? ?? json['item_name'] as String,
      itemSku: json['itemSku'] as String? ?? json['item_sku'] as String?,
      itemImageId: json['itemImageId'] as String? ?? json['item_image_id'] as String?,
      quantity: json['quantity'] as int? ?? 1,
      unitPrice: (json['unitPrice'] ?? json['unit_price'] ?? 0).toDouble(),
      totalPrice: (json['totalPrice'] ?? json['total_price'] ?? 0).toDouble(),
      currency: json['currency'] as String? ?? 'RWF',
      customization: json['customization'] as Map<String, dynamic>?,
      serviceBookingDate: json['serviceBookingDate'] != null || json['service_booking_date'] != null
          ? DateTime.parse((json['serviceBookingDate'] ?? json['service_booking_date']) as String)
          : null,
      serviceBookingTime: json['serviceBookingTime'] as String? ?? json['service_booking_time'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String? ?? json['created_at'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String? ?? json['updated_at'] as String),
      product: json['product'] as Map<String, dynamic>?,
      productVariant: json['productVariant'] as Map<String, dynamic>? ?? json['product_variant'] as Map<String, dynamic>?,
      service: json['service'] as Map<String, dynamic>?,
      menuItem: json['menuItem'] as Map<String, dynamic>? ?? json['menu_item'] as Map<String, dynamic>?,
      serviceBooking: json['serviceBooking'] as Map<String, dynamic>? ?? json['service_booking'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'itemType': itemType.toString(),
      'productId': productId,
      'productVariantId': productVariantId,
      'serviceId': serviceId,
      'menuItemId': menuItemId,
      'itemName': itemName,
      'itemSku': itemSku,
      'itemImageId': itemImageId,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
      'currency': currency,
      'customization': customization,
      'serviceBookingDate': serviceBookingDate?.toIso8601String(),
      'serviceBookingTime': serviceBookingTime,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'product': product,
      'productVariant': productVariant,
      'service': service,
      'menuItem': menuItem,
      'serviceBooking': serviceBooking,
    };
  }
}

enum OrderType {
  product,
  service,
  menuItem,
  mixed;

  static OrderType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'product':
        return OrderType.product;
      case 'service':
        return OrderType.service;
      case 'menu_item':
        return OrderType.menuItem;
      case 'mixed':
        return OrderType.mixed;
      default:
        return OrderType.mixed;
    }
  }

  @override
  String toString() {
    switch (this) {
      case OrderType.product:
        return 'product';
      case OrderType.service:
        return 'service';
      case OrderType.menuItem:
        return 'menu_item';
      case OrderType.mixed:
        return 'mixed';
    }
  }
}

enum FulfillmentType {
  delivery,
  pickup,
  dineIn;

  static FulfillmentType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'delivery':
        return FulfillmentType.delivery;
      case 'pickup':
        return FulfillmentType.pickup;
      case 'dine_in':
        return FulfillmentType.dineIn;
      default:
        return FulfillmentType.delivery;
    }
  }

  @override
  String toString() {
    switch (this) {
      case FulfillmentType.delivery:
        return 'delivery';
      case FulfillmentType.pickup:
        return 'pickup';
      case FulfillmentType.dineIn:
        return 'dine_in';
    }
  }
}

enum OrderStatus {
  pending,
  confirmed,
  processing,
  readyForPickup,
  shipped,
  outForDelivery,
  delivered,
  cancelled,
  refunded;

  static OrderStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return OrderStatus.pending;
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'processing':
        return OrderStatus.processing;
      case 'ready_for_pickup':
        return OrderStatus.readyForPickup;
      case 'shipped':
        return OrderStatus.shipped;
      case 'out_for_delivery':
        return OrderStatus.outForDelivery;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      case 'refunded':
        return OrderStatus.refunded;
      default:
        return OrderStatus.pending;
    }
  }

  @override
  String toString() {
    switch (this) {
      case OrderStatus.pending:
        return 'pending';
      case OrderStatus.confirmed:
        return 'confirmed';
      case OrderStatus.processing:
        return 'processing';
      case OrderStatus.readyForPickup:
        return 'ready_for_pickup';
      case OrderStatus.shipped:
        return 'shipped';
      case OrderStatus.outForDelivery:
        return 'out_for_delivery';
      case OrderStatus.delivered:
        return 'delivered';
      case OrderStatus.cancelled:
        return 'cancelled';
      case OrderStatus.refunded:
        return 'refunded';
    }
  }
}

enum FulfillmentStatus {
  pending,
  preparing,
  ready,
  inTransit,
  completed,
  cancelled;

  static FulfillmentStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return FulfillmentStatus.pending;
      case 'preparing':
        return FulfillmentStatus.preparing;
      case 'ready':
        return FulfillmentStatus.ready;
      case 'in_transit':
        return FulfillmentStatus.inTransit;
      case 'completed':
        return FulfillmentStatus.completed;
      case 'cancelled':
        return FulfillmentStatus.cancelled;
      default:
        return FulfillmentStatus.pending;
    }
  }

  @override
  String toString() {
    switch (this) {
      case FulfillmentStatus.pending:
        return 'pending';
      case FulfillmentStatus.preparing:
        return 'preparing';
      case FulfillmentStatus.ready:
        return 'ready';
      case FulfillmentStatus.inTransit:
        return 'in_transit';
      case FulfillmentStatus.completed:
        return 'completed';
      case FulfillmentStatus.cancelled:
        return 'cancelled';
    }
  }
}

