/// Itinerary Item Type
enum ItineraryItemType {
  listing,
  event,
  tour,
  custom,
}

/// Itinerary Item Model
class ItineraryItem {
  final String? id;
  final String itineraryId;
  final ItineraryItemType type;
  final String? listingId;
  final String? eventId;
  final String? tourId;
  final String? customName;
  final String? customDescription;
  final String? customLocation;
  final DateTime startTime;
  final DateTime? endTime;
  final int? durationMinutes;
  final int order;
  final String? notes;
  final Map<String, dynamic>? metadata;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ItineraryItem({
    this.id,
    required this.itineraryId,
    required this.type,
    this.listingId,
    this.eventId,
    this.tourId,
    this.customName,
    this.customDescription,
    this.customLocation,
    required this.startTime,
    this.endTime,
    this.durationMinutes,
    required this.order,
    this.notes,
    this.metadata,
    this.createdAt,
    this.updatedAt,
  });

  factory ItineraryItem.fromJson(Map<String, dynamic> json) {
    return ItineraryItem(
      id: json['id'] as String?,
      itineraryId: json['itineraryId'] as String,
      type: _parseItemType(json['type'] as String? ?? 'custom'),
      listingId: json['listingId'] as String?,
      eventId: json['eventId'] as String?,
      tourId: json['tourId'] as String?,
      customName: json['customName'] as String?,
      customDescription: json['customDescription'] as String?,
      customLocation: json['customLocation'] as String?,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime'] as String) : null,
      durationMinutes: json['durationMinutes'] as int?,
      order: json['order'] as int? ?? 0,
      notes: json['notes'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'itineraryId': itineraryId,
      'type': _itemTypeToString(type),
      if (listingId != null) 'listingId': listingId,
      if (eventId != null) 'eventId': eventId,
      if (tourId != null) 'tourId': tourId,
      if (customName != null) 'customName': customName,
      if (customDescription != null) 'customDescription': customDescription,
      if (customLocation != null) 'customLocation': customLocation,
      'startTime': startTime.toIso8601String(),
      if (endTime != null) 'endTime': endTime!.toIso8601String(),
      if (durationMinutes != null) 'durationMinutes': durationMinutes,
      'order': order,
      if (notes != null) 'notes': notes,
      if (metadata != null) 'metadata': metadata,
    };
  }

  static ItineraryItemType _parseItemType(String type) {
    switch (type.toLowerCase()) {
      case 'listing':
        return ItineraryItemType.listing;
      case 'event':
        return ItineraryItemType.event;
      case 'tour':
        return ItineraryItemType.tour;
      default:
        return ItineraryItemType.custom;
    }
  }

  static String _itemTypeToString(ItineraryItemType type) {
    switch (type) {
      case ItineraryItemType.listing:
        return 'listing';
      case ItineraryItemType.event:
        return 'event';
      case ItineraryItemType.tour:
        return 'tour';
      case ItineraryItemType.custom:
        return 'custom';
    }
  }

  ItineraryItem copyWith({
    String? id,
    String? itineraryId,
    ItineraryItemType? type,
    String? listingId,
    String? eventId,
    String? tourId,
    String? customName,
    String? customDescription,
    String? customLocation,
    DateTime? startTime,
    DateTime? endTime,
    int? durationMinutes,
    int? order,
    String? notes,
    Map<String, dynamic>? metadata,
  }) {
    return ItineraryItem(
      id: id ?? this.id,
      itineraryId: itineraryId ?? this.itineraryId,
      type: type ?? this.type,
      listingId: listingId ?? this.listingId,
      eventId: eventId ?? this.eventId,
      tourId: tourId ?? this.tourId,
      customName: customName ?? this.customName,
      customDescription: customDescription ?? this.customDescription,
      customLocation: customLocation ?? this.customLocation,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      order: order ?? this.order,
      notes: notes ?? this.notes,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

/// Itinerary Model
class Itinerary {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final DateTime startDate;
  final DateTime endDate;
  final String? location;
  final String? cityId;
  final String? countryId;
  final bool isPublic;
  final bool isShared;
  final String? shareToken;
  final List<ItineraryItem> items;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  Itinerary({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.startDate,
    required this.endDate,
    this.location,
    this.cityId,
    this.countryId,
    this.isPublic = false,
    this.isShared = false,
    this.shareToken,
    this.items = const [],
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Itinerary.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? [];
    final items = itemsJson.map((item) => ItineraryItem.fromJson(item as Map<String, dynamic>)).toList();
    
    return Itinerary(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      location: json['location'] as String?,
      cityId: json['cityId'] as String?,
      countryId: json['countryId'] as String?,
      isPublic: json['isPublic'] as bool? ?? false,
      isShared: (json['shareToken'] as String?) != null,
      shareToken: json['shareToken'] as String?,
      items: items,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      if (description != null) 'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      if (location != null) 'location': location,
      if (cityId != null) 'cityId': cityId,
      if (countryId != null) 'countryId': countryId,
      'isPublic': isPublic,
      'isShared': isShared,
      if (shareToken != null) 'shareToken': shareToken,
      'items': items.map((item) => item.toJson()).toList(),
      if (metadata != null) 'metadata': metadata,
    };
  }

  Itinerary copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    String? location,
    String? cityId,
    String? countryId,
    bool? isPublic,
    bool? isShared,
    String? shareToken,
    List<ItineraryItem>? items,
    Map<String, dynamic>? metadata,
  }) {
    return Itinerary(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      location: location ?? this.location,
      cityId: cityId ?? this.cityId,
      countryId: countryId ?? this.countryId,
      isPublic: isPublic ?? this.isPublic,
      isShared: isShared ?? this.isShared,
      shareToken: shareToken ?? this.shareToken,
      items: items ?? this.items,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Get the number of days in the itinerary
  int get daysCount {
    return endDate.difference(startDate).inDays + 1;
  }

  /// Get sorted items by order
  List<ItineraryItem> get sortedItems {
    final sorted = List<ItineraryItem>.from(items);
    sorted.sort((a, b) => a.order.compareTo(b.order));
    return sorted;
  }
}

