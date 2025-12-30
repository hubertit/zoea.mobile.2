



// @JsonSerializable()
class Listing {
  final String id;
  final String name;
  final String description;
  final String category;
  final ListingType type;
  final Location location;
  final List<String> images;
  final double rating;
  final int reviewCount;
  final PriceRange priceRange;
  final List<String> amenities;
  final List<String> tags;
  final bool isVerified;
  final bool isFeatured;
  final bool acceptsBookings;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? contactPhone;
  final String? contactEmail;
  final String? website;

  const Listing({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.type,
    required this.location,
    required this.images,
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.priceRange,
    this.amenities = const [],
    this.tags = const [],
    this.isVerified = false,
    this.isFeatured = false,
    this.acceptsBookings = false,
    required this.createdAt,
    required this.updatedAt,
    this.contactPhone,
    this.contactEmail,
    this.website,
  });

  // factory Listing.fromJson(Map<String, dynamic> json) => _$ListingFromJson(json);
  // Map<String, dynamic> toJson() => _$ListingToJson(this);
}

// @JsonSerializable()
class Location {
  final double latitude;
  final double longitude;
  final String address;
  final String city;
  final String country;
  final String? district;
  final String? sector;

  const Location({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.city,
    required this.country,
    this.district,
    this.sector,
  });

  // factory Location.fromJson(Map<String, dynamic> json) => _$LocationFromJson(json);
  // Map<String, dynamic> toJson() => _$LocationToJson(this);
}

// @JsonSerializable()
class PriceRange {
  final double minPrice;
  final double maxPrice;
  final String currency;
  final PriceUnit unit;

  const PriceRange({
    required this.minPrice,
    required this.maxPrice,
    required this.currency,
    required this.unit,
  });

  // factory PriceRange.fromJson(Map<String, dynamic> json) => _$PriceRangeFromJson(json);
  // Map<String, dynamic> toJson() => _$PriceRangeToJson(this);
}

enum ListingType {
  // @JsonValue('hotel')
  hotel,
  // @JsonValue('restaurant')
  restaurant,
  // @JsonValue('tour')
  tour,
  // @JsonValue('event')
  event,
  // @JsonValue('attraction')
  attraction,
}

enum PriceUnit {
  // @JsonValue('per_night')
  perNight,
  // @JsonValue('per_person')
  perPerson,
  // @JsonValue('per_meal')
  perMeal,
  // @JsonValue('per_tour')
  perTour,
  // @JsonValue('per_event')
  perEvent,
}
