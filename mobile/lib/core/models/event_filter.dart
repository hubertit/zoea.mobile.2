import 'package:flutter/material.dart';

class EventFilter {
  final String? category;
  final String? location;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? minPrice;
  final int? maxPrice;
  final String? searchQuery;
  final bool? isFree;
  final bool? isVerified;

  const EventFilter({
    this.category,
    this.location,
    this.startDate,
    this.endDate,
    this.minPrice,
    this.maxPrice,
    this.searchQuery,
    this.isFree,
    this.isVerified,
  });

  EventFilter copyWith({
    String? category,
    String? location,
    DateTime? startDate,
    DateTime? endDate,
    int? minPrice,
    int? maxPrice,
    String? searchQuery,
    bool? isFree,
    bool? isVerified,
  }) {
    return EventFilter(
      category: category ?? this.category,
      location: location ?? this.location,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      searchQuery: searchQuery ?? this.searchQuery,
      isFree: isFree ?? this.isFree,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  bool get hasActiveFilters {
    return category != null ||
        location != null ||
        startDate != null ||
        endDate != null ||
        minPrice != null ||
        maxPrice != null ||
        searchQuery != null ||
        isFree != null ||
        isVerified != null;
  }

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};
    
    if (category != null) params['category'] = category;
    if (location != null) params['location'] = location;
    if (startDate != null) params['startDate'] = startDate!.toIso8601String();
    if (endDate != null) params['endDate'] = endDate!.toIso8601String();
    if (minPrice != null) params['minPrice'] = minPrice;
    if (maxPrice != null) params['maxPrice'] = maxPrice;
    if (searchQuery != null && searchQuery!.isNotEmpty) params['search'] = searchQuery;
    if (isFree != null && isFree!) params['isFree'] = true;
    if (isVerified != null && isVerified!) params['isVerified'] = true;
    
    return params;
  }

}

class EventCategory {
  final String id;
  final String name;
  final String icon;
  final Color color;

  const EventCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  static const List<EventCategory> categories = [
    EventCategory(
      id: 'music',
      name: 'Music',
      icon: '🎵',
      color: Color(0xFF6366F1),
    ),
    EventCategory(
      id: 'sports',
      name: 'Sports & Wellness',
      icon: '⚽',
      color: Color(0xFF10B981),
    ),
    EventCategory(
      id: 'food',
      name: 'Food & Drinks',
      icon: '🍽️',
      color: Color(0xFFF59E0B),
    ),
    EventCategory(
      id: 'arts',
      name: 'Arts & Culture',
      icon: '🎨',
      color: Color(0xFF8B5CF6),
    ),
    EventCategory(
      id: 'conferences',
      name: 'Conferences',
      icon: '💼',
      color: Color(0xFF6B7280),
    ),
    EventCategory(
      id: 'performance',
      name: 'Performance',
      icon: '🎭',
      color: Color(0xFFEC4899),
    ),
  ];
}

class PriceRange {
  final int min;
  final int max;
  final String label;

  const PriceRange({
    required this.min,
    required this.max,
    required this.label,
  });

  static const List<PriceRange> ranges = [
    PriceRange(min: 0, max: 0, label: 'Free'),
    PriceRange(min: 0, max: 5000, label: 'Under 5K RWF'),
    PriceRange(min: 5000, max: 15000, label: '5K - 15K RWF'),
    PriceRange(min: 15000, max: 50000, label: '15K - 50K RWF'),
    PriceRange(min: 50000, max: 100000, label: '50K - 100K RWF'),
    PriceRange(min: 100000, max: 999999, label: '100K+ RWF'),
  ];
}
