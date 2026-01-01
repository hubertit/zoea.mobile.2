class Cart {
  final String id;
  final String? userId;
  final String? sessionId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<CartItem> items;

  Cart({
    required this.id,
    this.userId,
    this.sessionId,
    required this.createdAt,
    required this.updatedAt,
    this.items = const [],
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['id'] as String,
      userId: json['userId'] as String? ?? json['user_id'] as String?,
      sessionId: json['sessionId'] as String? ?? json['session_id'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String? ?? json['created_at'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String? ?? json['updated_at'] as String),
      items: json['items'] != null
          ? (json['items'] as List).map((i) => CartItem.fromJson(i as Map<String, dynamic>)).toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'sessionId': sessionId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'items': items.map((i) => i.toJson()).toList(),
    };
  }

  double get totalAmount => items.fold(0.0, (sum, item) => sum + item.totalPrice);
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
  bool get isEmpty => items.isEmpty;
}

class CartItem {
  final String id;
  final String cartId;
  final CartItemType itemType;
  final String? productId;
  final String? productVariantId;
  final String? serviceId;
  final String? menuItemId;
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

  CartItem({
    required this.id,
    required this.cartId,
    required this.itemType,
    this.productId,
    this.productVariantId,
    this.serviceId,
    this.menuItemId,
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
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as String,
      cartId: json['cartId'] as String? ?? json['cart_id'] as String,
      itemType: CartItemType.fromString(json['itemType'] as String? ?? json['item_type'] as String),
      productId: json['productId'] as String? ?? json['product_id'] as String?,
      productVariantId: json['productVariantId'] as String? ?? json['product_variant_id'] as String?,
      serviceId: json['serviceId'] as String? ?? json['service_id'] as String?,
      menuItemId: json['menuItemId'] as String? ?? json['menu_item_id'] as String?,
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cartId': cartId,
      'itemType': itemType.toString(),
      'productId': productId,
      'productVariantId': productVariantId,
      'serviceId': serviceId,
      'menuItemId': menuItemId,
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
    };
  }

  String get itemName {
    if (productVariant != null && product != null) {
      return '${product!['name']} - ${productVariant!['name']}';
    } else if (product != null) {
      return product!['name'] as String;
    } else if (service != null) {
      return service!['name'] as String;
    } else if (menuItem != null) {
      return menuItem!['name'] as String;
    }
    return 'Unknown Item';
  }

  String? get itemImage {
    if (productVariant != null && productVariant!['imageId'] != null) {
      return productVariant!['imageId'] as String?;
    } else if (product != null && product!['images'] != null && (product!['images'] as List).isNotEmpty) {
      return (product!['images'] as List).first as String?;
    } else if (service != null && service!['images'] != null && (service!['images'] as List).isNotEmpty) {
      return (service!['images'] as List).first as String?;
    } else if (menuItem != null && menuItem!['imageId'] != null) {
      return menuItem!['imageId'] as String?;
    }
    return null;
  }
}

enum CartItemType {
  product,
  service,
  menuItem;

  static CartItemType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'product':
        return CartItemType.product;
      case 'service':
        return CartItemType.service;
      case 'menu_item':
        return CartItemType.menuItem;
      default:
        return CartItemType.product;
    }
  }

  @override
  String toString() {
    switch (this) {
      case CartItemType.product:
        return 'product';
      case CartItemType.service:
        return 'service';
      case CartItemType.menuItem:
        return 'menu_item';
    }
  }
}

