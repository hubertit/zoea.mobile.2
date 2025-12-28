/// Listing model - Each business can have multiple listings
/// Listings are type-specific based on the business category
class Listing {
  final String id;
  final String businessId;
  final String name;
  final String description;
  final ListingType type;
  final List<String> images;
  final PriceRange priceRange;
  final List<String> amenities;
  final List<String> tags;
  final bool isActive;
  final bool isFeatured;
  final double rating;
  final int reviewCount;
  final int bookingsCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Type-specific fields
  final RoomDetails? roomDetails;       // For hotels
  final TableDetails? tableDetails;     // For restaurants
  final TourDetails? tourDetails;       // For tour operators
  final EventDetails? eventDetails;     // For event venues

  const Listing({
    required this.id,
    required this.businessId,
    required this.name,
    required this.description,
    required this.type,
    required this.images,
    required this.priceRange,
    this.amenities = const [],
    this.tags = const [],
    this.isActive = true,
    this.isFeatured = false,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.bookingsCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.roomDetails,
    this.tableDetails,
    this.tourDetails,
    this.eventDetails,
  });

  Listing copyWith({
    String? id,
    String? businessId,
    String? name,
    String? description,
    ListingType? type,
    List<String>? images,
    PriceRange? priceRange,
    List<String>? amenities,
    List<String>? tags,
    bool? isActive,
    bool? isFeatured,
    double? rating,
    int? reviewCount,
    int? bookingsCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    RoomDetails? roomDetails,
    TableDetails? tableDetails,
    TourDetails? tourDetails,
    EventDetails? eventDetails,
  }) {
    return Listing(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      images: images ?? this.images,
      priceRange: priceRange ?? this.priceRange,
      amenities: amenities ?? this.amenities,
      tags: tags ?? this.tags,
      isActive: isActive ?? this.isActive,
      isFeatured: isFeatured ?? this.isFeatured,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      bookingsCount: bookingsCount ?? this.bookingsCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      roomDetails: roomDetails ?? this.roomDetails,
      tableDetails: tableDetails ?? this.tableDetails,
      tourDetails: tourDetails ?? this.tourDetails,
      eventDetails: eventDetails ?? this.eventDetails,
    );
  }
}

/// Room details for hotel listings
class RoomDetails {
  final RoomType roomType;
  final int capacity;
  final int bedCount;
  final BedType bedType;
  final double size; // in sqm
  final bool hasBalcony;
  final bool hasView;
  final int totalRooms;
  final int availableRooms;

  const RoomDetails({
    required this.roomType,
    required this.capacity,
    this.bedCount = 1,
    this.bedType = BedType.double,
    this.size = 0,
    this.hasBalcony = false,
    this.hasView = false,
    this.totalRooms = 1,
    this.availableRooms = 1,
  });
}

enum RoomType {
  standard,
  deluxe,
  suite,
  executive,
  presidential,
  family,
  single,
  twin,
}

extension RoomTypeExtension on RoomType {
  String get displayName {
    switch (this) {
      case RoomType.standard:
        return 'Standard Room';
      case RoomType.deluxe:
        return 'Deluxe Room';
      case RoomType.suite:
        return 'Suite';
      case RoomType.executive:
        return 'Executive Room';
      case RoomType.presidential:
        return 'Presidential Suite';
      case RoomType.family:
        return 'Family Room';
      case RoomType.single:
        return 'Single Room';
      case RoomType.twin:
        return 'Twin Room';
    }
  }
}

enum BedType {
  single,
  double,
  queen,
  king,
  twin,
}

extension BedTypeExtension on BedType {
  String get displayName {
    switch (this) {
      case BedType.single:
        return 'Single Bed';
      case BedType.double:
        return 'Double Bed';
      case BedType.queen:
        return 'Queen Bed';
      case BedType.king:
        return 'King Bed';
      case BedType.twin:
        return 'Twin Beds';
    }
  }
}

/// Table details for restaurant listings
class TableDetails {
  final int capacity;
  final TableLocation location;
  final bool isPrivate;
  final int totalTables;
  final int availableTables;
  final List<String> availableTimeSlots;

  const TableDetails({
    required this.capacity,
    this.location = TableLocation.indoor,
    this.isPrivate = false,
    this.totalTables = 1,
    this.availableTables = 1,
    this.availableTimeSlots = const [],
  });
}

enum TableLocation {
  indoor,
  outdoor,
  terrace,
  rooftop,
  privateRoom,
  poolside,
}

extension TableLocationExtension on TableLocation {
  String get displayName {
    switch (this) {
      case TableLocation.indoor:
        return 'Indoor';
      case TableLocation.outdoor:
        return 'Outdoor';
      case TableLocation.terrace:
        return 'Terrace';
      case TableLocation.rooftop:
        return 'Rooftop';
      case TableLocation.privateRoom:
        return 'Private Room';
      case TableLocation.poolside:
        return 'Poolside';
    }
  }
}

/// Tour details for tour operator listings
class TourDetails {
  final String duration; // e.g., "3 hours", "Full day", "2 days"
  final TourDifficulty difficulty;
  final int minParticipants;
  final int maxParticipants;
  final List<String> included;
  final List<String> notIncluded;
  final List<String> itinerary;
  final String? pickupLocation;
  final String? meetingPoint;
  final List<DateTime> availableDates;

  const TourDetails({
    required this.duration,
    this.difficulty = TourDifficulty.easy,
    this.minParticipants = 1,
    this.maxParticipants = 20,
    this.included = const [],
    this.notIncluded = const [],
    this.itinerary = const [],
    this.pickupLocation,
    this.meetingPoint,
    this.availableDates = const [],
  });
}

enum TourDifficulty {
  easy,
  moderate,
  challenging,
  difficult,
}

extension TourDifficultyExtension on TourDifficulty {
  String get displayName {
    switch (this) {
      case TourDifficulty.easy:
        return 'Easy';
      case TourDifficulty.moderate:
        return 'Moderate';
      case TourDifficulty.challenging:
        return 'Challenging';
      case TourDifficulty.difficult:
        return 'Difficult';
    }
  }
}

/// Event details for event venue listings
class EventDetails {
  final DateTime eventDate;
  final DateTime? eventEndDate;
  final String? venue;
  final int totalCapacity;
  final int availableSpots;
  final List<TicketType> ticketTypes;
  final bool isRecurring;
  final String? recurringPattern;

  const EventDetails({
    required this.eventDate,
    this.eventEndDate,
    this.venue,
    this.totalCapacity = 100,
    this.availableSpots = 100,
    this.ticketTypes = const [],
    this.isRecurring = false,
    this.recurringPattern,
  });
}

class TicketType {
  final String name;
  final double price;
  final String currency;
  final int available;
  final String? description;

  const TicketType({
    required this.name,
    required this.price,
    required this.currency,
    this.available = 0,
    this.description,
  });
}

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
}

enum ListingType {
  room,        // Hotels
  table,       // Restaurants
  tour,        // Tour operators
  event,       // Event venues
  activity,    // Attractions
  package,     // Bundled offerings
}

extension ListingTypeExtension on ListingType {
  String get displayName {
    switch (this) {
      case ListingType.room:
        return 'Room';
      case ListingType.table:
        return 'Table';
      case ListingType.tour:
        return 'Tour';
      case ListingType.event:
        return 'Event';
      case ListingType.activity:
        return 'Activity';
      case ListingType.package:
        return 'Package';
    }
  }

  String get icon {
    switch (this) {
      case ListingType.room:
        return '🛏️';
      case ListingType.table:
        return '🍽️';
      case ListingType.tour:
        return '🗺️';
      case ListingType.event:
        return '🎫';
      case ListingType.activity:
        return '🎯';
      case ListingType.package:
        return '📦';
    }
  }
}

enum PriceUnit {
  perNight,
  perPerson,
  perTable,
  perTour,
  perTicket,
  perHour,
}

extension PriceUnitExtension on PriceUnit {
  String get displayName {
    switch (this) {
      case PriceUnit.perNight:
        return 'per night';
      case PriceUnit.perPerson:
        return 'per person';
      case PriceUnit.perTable:
        return 'per table';
      case PriceUnit.perTour:
        return 'per tour';
      case PriceUnit.perTicket:
        return 'per ticket';
      case PriceUnit.perHour:
        return 'per hour';
    }
  }
}
