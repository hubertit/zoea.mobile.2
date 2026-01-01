class Service {
  final String id;
  final String listingId;
  final String name;
  final String slug;
  final String? description;
  final String? shortDescription;
  final double basePrice;
  final String currency;
  final ServicePriceUnit priceUnit;
  final int? durationMinutes;
  final bool requiresBooking;
  final int advanceBookingDays;
  final int maxConcurrentBookings;
  final Map<String, dynamic>? availabilitySchedule;
  final bool isAvailable;
  final String? category;
  final List<String> tags;
  final List<String> images;
  final ServiceStatus status;
  final bool isFeatured;
  final int bookingCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final Map<String, dynamic>? listing;

  Service({
    required this.id,
    required this.listingId,
    required this.name,
    required this.slug,
    this.description,
    this.shortDescription,
    required this.basePrice,
    this.currency = 'RWF',
    this.priceUnit = ServicePriceUnit.fixed,
    this.durationMinutes,
    this.requiresBooking = true,
    this.advanceBookingDays = 7,
    this.maxConcurrentBookings = 1,
    this.availabilitySchedule,
    this.isAvailable = true,
    this.category,
    this.tags = const [],
    this.images = const [],
    this.status = ServiceStatus.active,
    this.isFeatured = false,
    this.bookingCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.listing,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] as String,
      listingId: json['listingId'] as String? ?? json['listing_id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      shortDescription: json['shortDescription'] as String? ?? json['short_description'] as String?,
      basePrice: (json['basePrice'] ?? json['base_price'] ?? 0).toDouble(),
      currency: json['currency'] as String? ?? 'RWF',
      priceUnit: ServicePriceUnit.fromString(json['priceUnit'] as String? ?? json['price_unit'] as String? ?? 'fixed'),
      durationMinutes: json['durationMinutes'] as int? ?? json['duration_minutes'] as int?,
      requiresBooking: json['requiresBooking'] as bool? ?? json['requires_booking'] as bool? ?? true,
      advanceBookingDays: json['advanceBookingDays'] as int? ?? json['advance_booking_days'] as int? ?? 7,
      maxConcurrentBookings: json['maxConcurrentBookings'] as int? ?? json['max_concurrent_bookings'] as int? ?? 1,
      availabilitySchedule: json['availabilitySchedule'] as Map<String, dynamic>? ?? json['availability_schedule'] as Map<String, dynamic>?,
      isAvailable: json['isAvailable'] as bool? ?? json['is_available'] as bool? ?? true,
      category: json['category'] as String?,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : const [],
      images: json['images'] != null ? List<String>.from(json['images']) : const [],
      status: ServiceStatus.fromString(json['status'] as String? ?? 'active'),
      isFeatured: json['isFeatured'] as bool? ?? json['is_featured'] as bool? ?? false,
      bookingCount: json['bookingCount'] as int? ?? json['booking_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String? ?? json['created_at'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String? ?? json['updated_at'] as String),
      deletedAt: json['deletedAt'] != null || json['deleted_at'] != null
          ? DateTime.parse((json['deletedAt'] ?? json['deleted_at']) as String)
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
      'currency': currency,
      'priceUnit': priceUnit.toString(),
      'durationMinutes': durationMinutes,
      'requiresBooking': requiresBooking,
      'advanceBookingDays': advanceBookingDays,
      'maxConcurrentBookings': maxConcurrentBookings,
      'availabilitySchedule': availabilitySchedule,
      'isAvailable': isAvailable,
      'category': category,
      'tags': tags,
      'images': images,
      'status': status.toString(),
      'isFeatured': isFeatured,
      'bookingCount': bookingCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
      'listing': listing,
    };
  }
}

enum ServicePriceUnit {
  fixed,
  perHour,
  perSession,
  perPerson;

  static ServicePriceUnit fromString(String value) {
    switch (value.toLowerCase()) {
      case 'fixed':
        return ServicePriceUnit.fixed;
      case 'per_hour':
        return ServicePriceUnit.perHour;
      case 'per_session':
        return ServicePriceUnit.perSession;
      case 'per_person':
        return ServicePriceUnit.perPerson;
      default:
        return ServicePriceUnit.fixed;
    }
  }

  @override
  String toString() {
    switch (this) {
      case ServicePriceUnit.fixed:
        return 'fixed';
      case ServicePriceUnit.perHour:
        return 'per_hour';
      case ServicePriceUnit.perSession:
        return 'per_session';
      case ServicePriceUnit.perPerson:
        return 'per_person';
    }
  }
}

enum ServiceStatus {
  active,
  inactive,
  unavailable;

  static ServiceStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'active':
        return ServiceStatus.active;
      case 'inactive':
        return ServiceStatus.inactive;
      case 'unavailable':
        return ServiceStatus.unavailable;
      default:
        return ServiceStatus.active;
    }
  }

  @override
  String toString() {
    switch (this) {
      case ServiceStatus.active:
        return 'active';
      case ServiceStatus.inactive:
        return 'inactive';
      case ServiceStatus.unavailable:
        return 'unavailable';
    }
  }
}

class ServiceBooking {
  final String id;
  final String? userId;
  final String serviceId;
  final String listingId;
  final String? orderId;
  final String? orderItemId;
  final DateTime bookingDate;
  final String bookingTime;
  final int? durationMinutes;
  final String customerName;
  final String? customerEmail;
  final String customerPhone;
  final ServiceBookingStatus status;
  final String? specialRequests;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? service;
  final Map<String, dynamic>? listing;

  ServiceBooking({
    required this.id,
    this.userId,
    required this.serviceId,
    required this.listingId,
    this.orderId,
    this.orderItemId,
    required this.bookingDate,
    required this.bookingTime,
    this.durationMinutes,
    required this.customerName,
    this.customerEmail,
    required this.customerPhone,
    this.status = ServiceBookingStatus.pending,
    this.specialRequests,
    required this.createdAt,
    required this.updatedAt,
    this.service,
    this.listing,
  });

  factory ServiceBooking.fromJson(Map<String, dynamic> json) {
    return ServiceBooking(
      id: json['id'] as String,
      userId: json['userId'] as String? ?? json['user_id'] as String?,
      serviceId: json['serviceId'] as String? ?? json['service_id'] as String,
      listingId: json['listingId'] as String? ?? json['listing_id'] as String,
      orderId: json['orderId'] as String? ?? json['order_id'] as String?,
      orderItemId: json['orderItemId'] as String? ?? json['order_item_id'] as String?,
      bookingDate: DateTime.parse(json['bookingDate'] as String? ?? json['booking_date'] as String),
      bookingTime: json['bookingTime'] as String? ?? json['booking_time'] as String,
      durationMinutes: json['durationMinutes'] as int? ?? json['duration_minutes'] as int?,
      customerName: json['customerName'] as String? ?? json['customer_name'] as String,
      customerEmail: json['customerEmail'] as String? ?? json['customer_email'] as String?,
      customerPhone: json['customerPhone'] as String? ?? json['customer_phone'] as String,
      status: ServiceBookingStatus.fromString(json['status'] as String? ?? 'pending'),
      specialRequests: json['specialRequests'] as String? ?? json['special_requests'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String? ?? json['created_at'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String? ?? json['updated_at'] as String),
      service: json['service'] as Map<String, dynamic>?,
      listing: json['listing'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'serviceId': serviceId,
      'listingId': listingId,
      'orderId': orderId,
      'orderItemId': orderItemId,
      'bookingDate': bookingDate.toIso8601String().split('T')[0],
      'bookingTime': bookingTime,
      'durationMinutes': durationMinutes,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'customerPhone': customerPhone,
      'status': status.toString(),
      'specialRequests': specialRequests,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'service': service,
      'listing': listing,
    };
  }
}

enum ServiceBookingStatus {
  pending,
  confirmed,
  completed,
  cancelled,
  noShow;

  static ServiceBookingStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return ServiceBookingStatus.pending;
      case 'confirmed':
        return ServiceBookingStatus.confirmed;
      case 'completed':
        return ServiceBookingStatus.completed;
      case 'cancelled':
        return ServiceBookingStatus.cancelled;
      case 'no_show':
        return ServiceBookingStatus.noShow;
      default:
        return ServiceBookingStatus.pending;
    }
  }

  @override
  String toString() {
    switch (this) {
      case ServiceBookingStatus.pending:
        return 'pending';
      case ServiceBookingStatus.confirmed:
        return 'confirmed';
      case ServiceBookingStatus.completed:
        return 'completed';
      case ServiceBookingStatus.cancelled:
        return 'cancelled';
      case ServiceBookingStatus.noShow:
        return 'no_show';
    }
  }
}

