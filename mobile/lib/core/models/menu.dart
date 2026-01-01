class Menu {
  final String id;
  final String listingId;
  final String name;
  final String? description;
  final List<String> availableDays;
  final String? startTime;
  final String? endTime;
  final bool isActive;
  final bool isDefault;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final List<MenuItem>? items;
  final Map<String, dynamic>? listing;

  Menu({
    required this.id,
    required this.listingId,
    required this.name,
    this.description,
    this.availableDays = const [],
    this.startTime,
    this.endTime,
    this.isActive = true,
    this.isDefault = false,
    this.sortOrder = 0,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.items,
    this.listing,
  });

  factory Menu.fromJson(Map<String, dynamic> json) {
    return Menu(
      id: json['id'] as String,
      listingId: json['listingId'] as String? ?? json['listing_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      availableDays: json['availableDays'] != null 
          ? List<String>.from(json['availableDays'])
          : json['available_days'] != null
              ? List<String>.from(json['available_days'])
              : const [],
      startTime: json['startTime'] as String? ?? json['start_time'] as String?,
      endTime: json['endTime'] as String? ?? json['end_time'] as String?,
      isActive: json['isActive'] as bool? ?? json['is_active'] as bool? ?? true,
      isDefault: json['isDefault'] as bool? ?? json['is_default'] as bool? ?? false,
      sortOrder: json['sortOrder'] as int? ?? json['sort_order'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String? ?? json['created_at'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String? ?? json['updated_at'] as String),
      deletedAt: json['deletedAt'] != null || json['deleted_at'] != null
          ? DateTime.parse((json['deletedAt'] ?? json['deleted_at']) as String)
          : null,
      items: json['items'] != null
          ? (json['items'] as List).map((i) => MenuItem.fromJson(i as Map<String, dynamic>)).toList()
          : null,
      listing: json['listing'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'listingId': listingId,
      'name': name,
      'description': description,
      'availableDays': availableDays,
      'startTime': startTime,
      'endTime': endTime,
      'isActive': isActive,
      'isDefault': isDefault,
      'sortOrder': sortOrder,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
      'items': items?.map((i) => i.toJson()).toList(),
      'listing': listing,
    };
  }
}

class MenuItem {
  final String id;
  final String menuId;
  final String? categoryId;
  final String name;
  final String? description;
  final double price;
  final String currency;
  final double? compareAtPrice;
  final List<String> dietaryTags;
  final List<String> allergens;
  final String? spiceLevel;
  final bool isAvailable;
  final bool isPopular;
  final bool isChefSpecial;
  final bool allowCustomization;
  final Map<String, dynamic>? customizationOptions;
  final String? imageId;
  final int? estimatedPrepTime;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  final MenuCategory? category;

  MenuItem({
    required this.id,
    required this.menuId,
    this.categoryId,
    required this.name,
    this.description,
    required this.price,
    this.currency = 'RWF',
    this.compareAtPrice,
    this.dietaryTags = const [],
    this.allergens = const [],
    this.spiceLevel,
    this.isAvailable = true,
    this.isPopular = false,
    this.isChefSpecial = false,
    this.allowCustomization = false,
    this.customizationOptions,
    this.imageId,
    this.estimatedPrepTime,
    this.sortOrder = 0,
    required this.createdAt,
    required this.updatedAt,
    this.category,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'] as String,
      menuId: json['menuId'] as String? ?? json['menu_id'] as String,
      categoryId: json['categoryId'] as String? ?? json['category_id'] as String?,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: (json['price'] ?? 0).toDouble(),
      currency: json['currency'] as String? ?? 'RWF',
      compareAtPrice: json['compareAtPrice'] != null || json['compare_at_price'] != null
          ? ((json['compareAtPrice'] ?? json['compare_at_price']) as num).toDouble()
          : null,
      dietaryTags: json['dietaryTags'] != null 
          ? List<String>.from(json['dietaryTags'])
          : json['dietary_tags'] != null
              ? List<String>.from(json['dietary_tags'])
              : const [],
      allergens: json['allergens'] != null ? List<String>.from(json['allergens']) : const [],
      spiceLevel: json['spiceLevel'] as String? ?? json['spice_level'] as String?,
      isAvailable: json['isAvailable'] as bool? ?? json['is_available'] as bool? ?? true,
      isPopular: json['isPopular'] as bool? ?? json['is_popular'] as bool? ?? false,
      isChefSpecial: json['isChefSpecial'] as bool? ?? json['is_chef_special'] as bool? ?? false,
      allowCustomization: json['allowCustomization'] as bool? ?? json['allow_customization'] as bool? ?? false,
      customizationOptions: json['customizationOptions'] as Map<String, dynamic>? ?? json['customization_options'] as Map<String, dynamic>?,
      imageId: json['imageId'] as String? ?? json['image_id'] as String?,
      estimatedPrepTime: json['estimatedPrepTime'] as int? ?? json['estimated_prep_time'] as int?,
      sortOrder: json['sortOrder'] as int? ?? json['sort_order'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String? ?? json['created_at'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String? ?? json['updated_at'] as String),
      category: json['category'] != null
          ? MenuCategory.fromJson(json['category'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'menuId': menuId,
      'categoryId': categoryId,
      'name': name,
      'description': description,
      'price': price,
      'currency': currency,
      'compareAtPrice': compareAtPrice,
      'dietaryTags': dietaryTags,
      'allergens': allergens,
      'spiceLevel': spiceLevel,
      'isAvailable': isAvailable,
      'isPopular': isPopular,
      'isChefSpecial': isChefSpecial,
      'allowCustomization': allowCustomization,
      'customizationOptions': customizationOptions,
      'imageId': imageId,
      'estimatedPrepTime': estimatedPrepTime,
      'sortOrder': sortOrder,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'category': category?.toJson(),
    };
  }

  double? get discountPercent => compareAtPrice != null && compareAtPrice! > price
      ? ((compareAtPrice! - price) / compareAtPrice! * 100)
      : null;
}

class MenuCategory {
  final String id;
  final String name;
  final String? description;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  MenuCategory({
    required this.id,
    required this.name,
    this.description,
    this.sortOrder = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MenuCategory.fromJson(Map<String, dynamic> json) {
    return MenuCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      sortOrder: json['sortOrder'] as int? ?? json['sort_order'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String? ?? json['created_at'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String? ?? json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'sortOrder': sortOrder,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

