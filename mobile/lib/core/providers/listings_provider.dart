import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/listings_service.dart';

final listingsServiceProvider = Provider<ListingsService>((ref) {
  return ListingsService();
});

/// Parameters for listings query
class ListingsParams {
  final int? page;
  final int? limit;
  final String? type;
  final String? category;
  final String? city;
  final String? search;
  final double? minPrice;
  final double? maxPrice;
  final String? sortBy;

  const ListingsParams({
    this.page,
    this.limit,
    this.type,
    this.category,
    this.city,
    this.search,
    this.minPrice,
    this.maxPrice,
    this.sortBy,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListingsParams &&
          runtimeType == other.runtimeType &&
          page == other.page &&
          limit == other.limit &&
          type == other.type &&
          category == other.category &&
          city == other.city &&
          search == other.search &&
          minPrice == other.minPrice &&
          maxPrice == other.maxPrice &&
          sortBy == other.sortBy;

  @override
  int get hashCode =>
      page.hashCode ^
      limit.hashCode ^
      type.hashCode ^
      category.hashCode ^
      city.hashCode ^
      search.hashCode ^
      minPrice.hashCode ^
      maxPrice.hashCode ^
      sortBy.hashCode;
}

/// Provider for all listings with pagination
final listingsProvider = FutureProvider.family<Map<String, dynamic>, ListingsParams>((ref, params) async {
  final listingsService = ref.watch(listingsServiceProvider);
  return await listingsService.getListings(
    page: params.page,
    limit: params.limit,
    type: params.type,
    category: params.category,
    city: params.city,
    search: params.search,
    minPrice: params.minPrice,
    maxPrice: params.maxPrice,
    sortBy: params.sortBy,
  );
});

/// Provider for featured listings
final featuredListingsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final listingsService = ref.watch(listingsServiceProvider);
  return await listingsService.getFeaturedListings();
});

/// Parameters for nearby listings query
class NearbyListingsParams {
  final double latitude;
  final double longitude;
  final double? radiusKm;
  final int? limit;
  final String? type;

  const NearbyListingsParams({
    required this.latitude,
    required this.longitude,
    this.radiusKm,
    this.limit,
    this.type,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NearbyListingsParams &&
          runtimeType == other.runtimeType &&
          latitude == other.latitude &&
          longitude == other.longitude &&
          radiusKm == other.radiusKm &&
          limit == other.limit &&
          type == other.type;

  @override
  int get hashCode =>
      latitude.hashCode ^
      longitude.hashCode ^
      radiusKm.hashCode ^
      limit.hashCode ^
      type.hashCode;
}

/// Provider for nearby listings
final nearbyListingsProvider = FutureProvider.family<List<Map<String, dynamic>>, NearbyListingsParams>((ref, params) async {
  final listingsService = ref.watch(listingsServiceProvider);
  return await listingsService.getNearbyListings(
    latitude: params.latitude,
    longitude: params.longitude,
    radiusKm: params.radiusKm ?? 10.0,
    limit: params.limit,
    type: params.type,
  );
});

/// Parameters for listings by type query
class ListingsByTypeParams {
  final String type;
  final int? page;
  final int? limit;
  final String? category;
  final String? city;
  final String? search;

  const ListingsByTypeParams({
    required this.type,
    this.page,
    this.limit,
    this.category,
    this.city,
    this.search,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListingsByTypeParams &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          page == other.page &&
          limit == other.limit &&
          category == other.category &&
          city == other.city &&
          search == other.search;

  @override
  int get hashCode =>
      type.hashCode ^
      page.hashCode ^
      limit.hashCode ^
      category.hashCode ^
      city.hashCode ^
      search.hashCode;
}

/// Provider for listings by type
final listingsByTypeProvider = FutureProvider.family<Map<String, dynamic>, ListingsByTypeParams>((ref, params) async {
  final listingsService = ref.watch(listingsServiceProvider);
  return await listingsService.getListingsByType(
    type: params.type,
    page: params.page,
    limit: params.limit,
    category: params.category,
    city: params.city,
    search: params.search,
  );
});

/// Provider for single listing by ID
final listingByIdProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, id) async {
  final listingsService = ref.watch(listingsServiceProvider);
  return await listingsService.getListingById(id);
});

/// Provider for single listing by slug
final listingBySlugProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, slug) async {
  final listingsService = ref.watch(listingsServiceProvider);
  return await listingsService.getListingBySlug(slug);
});

/// Provider for merchant listings
final merchantListingsProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, merchantId) async {
  final listingsService = ref.watch(listingsServiceProvider);
  return await listingsService.getListingsByMerchant(merchantId);
});

