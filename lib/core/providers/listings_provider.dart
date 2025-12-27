import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/listings_service.dart';

final listingsServiceProvider = Provider<ListingsService>((ref) {
  return ListingsService();
});

/// Provider for all listings with pagination
final listingsProvider = FutureProvider.family<Map<String, dynamic>, Map<String, dynamic>>((ref, filters) async {
  final listingsService = ref.watch(listingsServiceProvider);
  return await listingsService.getListings(
    page: filters['page'] as int?,
    limit: filters['limit'] as int?,
    type: filters['type'] as String?,
    category: filters['category'] as String?,
    city: filters['city'] as String?,
    search: filters['search'] as String?,
    minPrice: filters['minPrice'] as double?,
    maxPrice: filters['maxPrice'] as double?,
    sortBy: filters['sortBy'] as String?,
  );
});

/// Provider for featured listings
final featuredListingsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final listingsService = ref.watch(listingsServiceProvider);
  return await listingsService.getFeaturedListings();
});

/// Provider for nearby listings
final nearbyListingsProvider = FutureProvider.family<List<Map<String, dynamic>>, Map<String, dynamic>>((ref, params) async {
  final listingsService = ref.watch(listingsServiceProvider);
  return await listingsService.getNearbyListings(
    latitude: params['latitude'] as double,
    longitude: params['longitude'] as double,
    radiusKm: params['radiusKm'] as double? ?? 10.0,
    limit: params['limit'] as int?,
    type: params['type'] as String?,
  );
});

/// Provider for listings by type
final listingsByTypeProvider = FutureProvider.family<Map<String, dynamic>, Map<String, dynamic>>((ref, filters) async {
  final listingsService = ref.watch(listingsServiceProvider);
  return await listingsService.getListingsByType(
    type: filters['type'] as String,
    page: filters['page'] as int?,
    limit: filters['limit'] as int?,
    category: filters['category'] as String?,
    city: filters['city'] as String?,
    search: filters['search'] as String?,
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

