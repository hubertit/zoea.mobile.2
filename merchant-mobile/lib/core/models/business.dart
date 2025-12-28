/// Business model - A merchant can own multiple businesses
class Business {
  final String id;
  final String ownerId;
  final String name;
  final String description;
  final BusinessCategory category;
  final String? logo;
  final String? coverImage;
  final BusinessLocation location;
  final BusinessContact contact;
  final bool isVerified;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int listingsCount;
  final double rating;
  final int reviewCount;

  const Business({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.description,
    required this.category,
    this.logo,
    this.coverImage,
    required this.location,
    required this.contact,
    this.isVerified = false,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.listingsCount = 0,
    this.rating = 0.0,
    this.reviewCount = 0,
  });

  Business copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? description,
    BusinessCategory? category,
    String? logo,
    String? coverImage,
    BusinessLocation? location,
    BusinessContact? contact,
    bool? isVerified,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? listingsCount,
    double? rating,
    int? reviewCount,
  }) {
    return Business(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      logo: logo ?? this.logo,
      coverImage: coverImage ?? this.coverImage,
      location: location ?? this.location,
      contact: contact ?? this.contact,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      listingsCount: listingsCount ?? this.listingsCount,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
    );
  }
}

class BusinessLocation {
  final double latitude;
  final double longitude;
  final String address;
  final String city;
  final String country;
  final String? district;
  final String? sector;

  const BusinessLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.city,
    required this.country,
    this.district,
    this.sector,
  });
}

class BusinessContact {
  final String? phone;
  final String? email;
  final String? website;
  final String? whatsapp;

  const BusinessContact({
    this.phone,
    this.email,
    this.website,
    this.whatsapp,
  });
}

enum BusinessCategory {
  hotel,
  restaurant,
  tourOperator,
  eventVenue,
  attraction,
  transportation,
  other,
}

extension BusinessCategoryExtension on BusinessCategory {
  String get displayName {
    switch (this) {
      case BusinessCategory.hotel:
        return 'Hotel & Accommodation';
      case BusinessCategory.restaurant:
        return 'Restaurant & Dining';
      case BusinessCategory.tourOperator:
        return 'Tour Operator';
      case BusinessCategory.eventVenue:
        return 'Event Venue';
      case BusinessCategory.attraction:
        return 'Attraction';
      case BusinessCategory.transportation:
        return 'Transportation';
      case BusinessCategory.other:
        return 'Other';
    }
  }

  String get icon {
    switch (this) {
      case BusinessCategory.hotel:
        return '🏨';
      case BusinessCategory.restaurant:
        return '🍽️';
      case BusinessCategory.tourOperator:
        return '🗺️';
      case BusinessCategory.eventVenue:
        return '🎪';
      case BusinessCategory.attraction:
        return '🎢';
      case BusinessCategory.transportation:
        return '🚐';
      case BusinessCategory.other:
        return '📦';
    }
  }
}

