class Product {
  final String id;
  final String listingId;
  final String name;
  final String slug;
  final String? description;
  final String? shortDescription;
  final double basePrice;
  final double? compareAtPrice;
  final String currency;
  final double? costPrice;
  final String? sku;
  final bool trackInventory;
  final int inventoryQuantity;
  final int lowStockThreshold;
  final bool allowBackorders;
  final double? weight;
  final Map<String, dynamic>? dimensions;
  final String? category;
  final List<String> tags;
  final bool hasVariants;
  final Map<String, dynamic>? variantOptions;
  final ProductStatus status;
  final bool isFeatured;
  final List<String> images;
  final int viewCount;
  final int orderCount;
  final double rating;
  final int reviewCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final List<ProductVariant>? variants;
  final Map<String, dynamic>? listing;

  Product({
    required this.id,
    required this.listingId,
    required this.name,
    required this.slug,
    this.description,
    this.shortDescription,
    required this.basePrice,
    this.compareAtPrice,
    this.currency = 'RWF',
    this.costPrice,
    this.sku,
    this.trackInventory = true,
    this.inventoryQuantity = 0,
    this.lowStockThreshold = 5,
    this.allowBackorders = false,
    this.weight,
    this.dimensions,
    this.category,
    this.tags = const [],
    this.hasVariants = false,
    this.variantOptions,
    this.status = ProductStatus.draft,
    this.isFeatured = false,
    this.images = const [],
    this.viewCount = 0,
    this.orderCount = 0,
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.variants,
    this.listing,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      listingId: json['listingId'] as String? ?? json['listing_id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      shortDescription: json['shortDescription'] as String? ?? json['short_description'] as String?,
      basePrice: (json['basePrice'] ?? json['base_price'] ?? 0).toDouble(),
      compareAtPrice: json['compareAtPrice'] != null || json['compare_at_price'] != null
          ? ((json['compareAtPrice'] ?? json['compare_at_price']) as num).toDouble()
          : null,
      currency: json['currency'] as String? ?? 'RWF',
      costPrice: json['costPrice'] != null || json['cost_price'] != null
          ? ((json['costPrice'] ?? json['cost_price']) as num).toDouble()
          : null,
      sku: json['sku'] as String?,
      trackInventory: json['trackInventory'] as bool? ?? json['track_inventory'] as bool? ?? true,
      inventoryQuantity: json['inventoryQuantity'] as int? ?? json['inventory_quantity'] as int? ?? 0,
      lowStockThreshold: json['lowStockThreshold'] as int? ?? json['low_stock_threshold'] as int? ?? 5,
      allowBackorders: json['allowBackorders'] as bool? ?? json['allow_backorders'] as bool? ?? false,
      weight: json['weight'] != null ? (json['weight'] as num).toDouble() : null,
      dimensions: json['dimensions'] as Map<String, dynamic>?,
      category: json['category'] as String?,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : const [],
      hasVariants: json['hasVariants'] as bool? ?? json['has_variants'] as bool? ?? false,
      variantOptions: json['variantOptions'] as Map<String, dynamic>? ?? json['variant_options'] as Map<String, dynamic>?,
      status: ProductStatus.fromString(json['status'] as String? ?? 'draft'),
      isFeatured: json['isFeatured'] as bool? ?? json['is_featured'] as bool? ?? false,
      images: json['images'] != null ? List<String>.from(json['images']) : const [],
      viewCount: json['viewCount'] as int? ?? json['view_count'] as int? ?? 0,
      orderCount: json['orderCount'] as int? ?? json['order_count'] as int? ?? 0,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : 0.0,
      reviewCount: json['reviewCount'] as int? ?? json['review_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String? ?? json['created_at'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String? ?? json['updated_at'] as String),
      deletedAt: json['deletedAt'] != null || json['deleted_at'] != null
          ? DateTime.parse((json['deletedAt'] ?? json['deleted_at']) as String)
          : null,
      variants: json['variants'] != null
          ? (json['variants'] as List).map((v) => ProductVariant.fromJson(v as Map<String, dynamic>)).toList()
          : null,
      listing: json['listing'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'listingId': listingId,
      'name': name,
      'slug': slug,
      'description': description,
      'shortDescription': shortDescription,
      'basePrice': basePrice,
      'compareAtPrice': compareAtPrice,
      'currency': currency,
      'costPrice': costPrice,
      'sku': sku,
      'trackInventory': trackInventory,
      'inventoryQuantity': inventoryQuantity,
      'lowStockThreshold': lowStockThreshold,
      'allowBackorders': allowBackorders,
      'weight': weight,
      'dimensions': dimensions,
      'category': category,
      'tags': tags,
      'hasVariants': hasVariants,
      'variantOptions': variantOptions,
      'status': status.toString(),
      'isFeatured': isFeatured,
      'images': images,
      'viewCount': viewCount,
      'orderCount': orderCount,
      'rating': rating,
      'reviewCount': reviewCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
      'variants': variants?.map((v) => v.toJson()).toList(),
      'listing': listing,
    };
  }

  bool get isAvailable => status == ProductStatus.active && (!trackInventory || inventoryQuantity > 0);
  bool get isLowStock => trackInventory && inventoryQuantity <= lowStockThreshold && inventoryQuantity > 0;
  bool get isOutOfStock => trackInventory && inventoryQuantity <= 0 && !allowBackorders;
  double? get discountPercent => compareAtPrice != null && compareAtPrice! > basePrice
      ? ((compareAtPrice! - basePrice) / compareAtPrice! * 100)
      : null;
}

class ProductVariant {
  final String id;
  final String productId;
  final String name;
  final String? sku;
  final double? price;
  final double? compareAtPrice;
  final Map<String, dynamic> attributes;
  final int inventoryQuantity;
  final bool trackInventory;
  final String? imageId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductVariant({
    required this.id,
    required this.productId,
    required this.name,
    this.sku,
    this.price,
    this.compareAtPrice,
    required this.attributes,
    this.inventoryQuantity = 0,
    this.trackInventory = true,
    this.imageId,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['id'] as String,
      productId: json['productId'] as String? ?? json['product_id'] as String,
      name: json['name'] as String,
      sku: json['sku'] as String?,
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      compareAtPrice: json['compareAtPrice'] != null || json['compare_at_price'] != null
          ? ((json['compareAtPrice'] ?? json['compare_at_price']) as num).toDouble()
          : null,
      attributes: json['attributes'] as Map<String, dynamic>,
      inventoryQuantity: json['inventoryQuantity'] as int? ?? json['inventory_quantity'] as int? ?? 0,
      trackInventory: json['trackInventory'] as bool? ?? json['track_inventory'] as bool? ?? true,
      imageId: json['imageId'] as String? ?? json['image_id'] as String?,
      isActive: json['isActive'] as bool? ?? json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String? ?? json['created_at'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String? ?? json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'name': name,
      'sku': sku,
      'price': price,
      'compareAtPrice': compareAtPrice,
      'attributes': attributes,
      'inventoryQuantity': inventoryQuantity,
      'trackInventory': trackInventory,
      'imageId': imageId,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  bool get isAvailable => isActive && (!trackInventory || inventoryQuantity > 0);
}

enum ProductStatus {
  draft,
  active,
  inactive,
  outOfStock;

  static ProductStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'draft':
        return ProductStatus.draft;
      case 'active':
        return ProductStatus.active;
      case 'inactive':
        return ProductStatus.inactive;
      case 'out_of_stock':
        return ProductStatus.outOfStock;
      default:
        return ProductStatus.draft;
    }
  }

  @override
  String toString() {
    switch (this) {
      case ProductStatus.draft:
        return 'draft';
      case ProductStatus.active:
        return 'active';
      case ProductStatus.inactive:
        return 'inactive';
      case ProductStatus.outOfStock:
        return 'out_of_stock';
    }
  }
}

