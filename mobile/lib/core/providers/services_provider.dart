import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/services_service.dart';
import '../models/service.dart';

final servicesServiceProvider = Provider<ServicesService>((ref) {
  return ServicesService();
});

/// Parameters for services query
class ServicesParams {
  final int? page;
  final int? limit;
  final String? listingId;
  final String? status;
  final String? search;
  final String? category;
  final double? minPrice;
  final double? maxPrice;
  final bool? isFeatured;
  final String? sortBy;

  const ServicesParams({
    this.page,
    this.limit,
    this.listingId,
    this.status,
    this.search,
    this.category,
    this.minPrice,
    this.maxPrice,
    this.isFeatured,
    this.sortBy,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServicesParams &&
          runtimeType == other.runtimeType &&
          page == other.page &&
          limit == other.limit &&
          listingId == other.listingId &&
          status == other.status &&
          search == other.search &&
          category == other.category &&
          minPrice == other.minPrice &&
          maxPrice == other.maxPrice &&
          isFeatured == other.isFeatured &&
          sortBy == other.sortBy;

  @override
  int get hashCode =>
      page.hashCode ^
      limit.hashCode ^
      listingId.hashCode ^
      status.hashCode ^
      search.hashCode ^
      category.hashCode ^
      minPrice.hashCode ^
      maxPrice.hashCode ^
      isFeatured.hashCode ^
      sortBy.hashCode;
}

/// Provider for all services with pagination
final servicesProvider = FutureProvider.family<Map<String, dynamic>, ServicesParams>((ref, params) async {
  final servicesService = ref.watch(servicesServiceProvider);
  return await servicesService.getServices(
    page: params.page,
    limit: params.limit,
    listingId: params.listingId,
    status: params.status,
    search: params.search,
    category: params.category,
    minPrice: params.minPrice,
    maxPrice: params.maxPrice,
    isFeatured: params.isFeatured,
    sortBy: params.sortBy,
  );
});

/// Provider for single service by ID
final serviceByIdProvider = FutureProvider.family<Service, String>((ref, serviceId) async {
  final servicesService = ref.watch(servicesServiceProvider);
  return await servicesService.getServiceById(serviceId);
});

