import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/search_service.dart';

final searchServiceProvider = Provider<SearchService>((ref) {
  return SearchService();
});

/// Search parameters class for stable comparison
class SearchParams {
  final String query;
  final String? category;
  final String? type;
  final String? city;
  final double? latitude;
  final double? longitude;
  final double? radiusKm;

  const SearchParams({
    required this.query,
    this.category,
    this.type,
    this.city,
    this.latitude,
    this.longitude,
    this.radiusKm,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchParams &&
          runtimeType == other.runtimeType &&
          query == other.query &&
          category == other.category &&
          type == other.type &&
          city == other.city &&
          latitude == other.latitude &&
          longitude == other.longitude &&
          radiusKm == other.radiusKm;

  @override
  int get hashCode =>
      query.hashCode ^
      category.hashCode ^
      type.hashCode ^
      city.hashCode ^
      latitude.hashCode ^
      longitude.hashCode ^
      radiusKm.hashCode;
}

/// Provider for global search (listings, events, tours)
/// Using a custom class for stable parameter comparison
final searchProvider = FutureProvider.family<Map<String, dynamic>, SearchParams>((ref, params) async {
  final searchService = ref.watch(searchServiceProvider);
  return await searchService.search(
    query: params.query,
    category: params.category,
    type: params.type,
    city: params.city,
    latitude: params.latitude,
    longitude: params.longitude,
    radiusKm: params.radiusKm,
  );
});

/// Provider for searching listings only
final searchListingsProvider = FutureProvider.family<List<Map<String, dynamic>>, Map<String, dynamic>>((ref, params) async {
  final searchService = ref.watch(searchServiceProvider);
  return await searchService.searchListings(
    query: params['query'] as String,
    category: params['category'] as String?,
    type: params['type'] as String?,
    city: params['city'] as String?,
    latitude: params['latitude'] as double?,
    longitude: params['longitude'] as double?,
    radiusKm: params['radiusKm'] as double?,
  );
});

/// Provider for searching events only
final searchEventsProvider = FutureProvider.family<List<Map<String, dynamic>>, Map<String, dynamic>>((ref, params) async {
  final searchService = ref.watch(searchServiceProvider);
  return await searchService.searchEvents(
    query: params['query'] as String,
    category: params['category'] as String?,
    city: params['city'] as String?,
    latitude: params['latitude'] as double?,
    longitude: params['longitude'] as double?,
    radiusKm: params['radiusKm'] as double?,
  );
});

/// Provider for searching tours only
final searchToursProvider = FutureProvider.family<List<Map<String, dynamic>>, Map<String, dynamic>>((ref, params) async {
  final searchService = ref.watch(searchServiceProvider);
  return await searchService.searchTours(
    query: params['query'] as String,
    category: params['category'] as String?,
    city: params['city'] as String?,
    latitude: params['latitude'] as double?,
    longitude: params['longitude'] as double?,
    radiusKm: params['radiusKm'] as double?,
  );
});

/// Provider for user's search history
final searchHistoryProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final searchService = ref.watch(searchServiceProvider);
  return await searchService.getSearchHistory(limit: 10);
});

/// Provider for trending searches
final trendingSearchesProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final searchService = ref.watch(searchServiceProvider);
  return await searchService.getTrendingSearches();
});

