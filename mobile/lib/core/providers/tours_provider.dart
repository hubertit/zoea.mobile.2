import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/tours_service.dart';

final toursServiceProvider = Provider<ToursService>((ref) {
  return ToursService();
});

/// Parameters for tours query
class ToursParams {
  final int? page;
  final int? limit;
  final String? status;
  final String? cityId;
  final String? countryId;
  final String? categoryId;
  final String? type;
  final String? difficulty;
  final double? minPrice;
  final double? maxPrice;
  final String? search;

  const ToursParams({
    this.page,
    this.limit,
    this.status,
    this.cityId,
    this.countryId,
    this.categoryId,
    this.type,
    this.difficulty,
    this.minPrice,
    this.maxPrice,
    this.search,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToursParams &&
          runtimeType == other.runtimeType &&
          page == other.page &&
          limit == other.limit &&
          status == other.status &&
          cityId == other.cityId &&
          countryId == other.countryId &&
          categoryId == other.categoryId &&
          type == other.type &&
          difficulty == other.difficulty &&
          minPrice == other.minPrice &&
          maxPrice == other.maxPrice &&
          search == other.search;

  @override
  int get hashCode =>
      page.hashCode ^
      limit.hashCode ^
      status.hashCode ^
      cityId.hashCode ^
      countryId.hashCode ^
      categoryId.hashCode ^
      type.hashCode ^
      difficulty.hashCode ^
      minPrice.hashCode ^
      maxPrice.hashCode ^
      search.hashCode;
}

/// Provider for all tours with pagination
final toursProvider = FutureProvider.family<Map<String, dynamic>, ToursParams>((ref, params) async {
  final toursService = ref.watch(toursServiceProvider);
  return await toursService.getTours(
    page: params.page,
    limit: params.limit,
    status: params.status,
    cityId: params.cityId,
    countryId: params.countryId,
    categoryId: params.categoryId,
    type: params.type,
    difficulty: params.difficulty,
    minPrice: params.minPrice,
    maxPrice: params.maxPrice,
    search: params.search,
  );
});

/// Provider for single tour by ID
final tourByIdProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, tourId) async {
  final toursService = ref.watch(toursServiceProvider);
  return await toursService.getTourById(tourId);
});

/// Provider for single tour by slug
final tourBySlugProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, slug) async {
  final toursService = ref.watch(toursServiceProvider);
  return await toursService.getTourBySlug(slug);
});

/// Provider for tour schedules
final tourSchedulesProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, tourId) async {
  final toursService = ref.watch(toursServiceProvider);
  return await toursService.getTourSchedules(tourId);
});

/// Provider for featured tours
final featuredToursProvider = FutureProvider.family<List<Map<String, dynamic>>, int>((ref, limit) async {
  final toursService = ref.watch(toursServiceProvider);
  return await toursService.getFeaturedTours(limit: limit);
});

