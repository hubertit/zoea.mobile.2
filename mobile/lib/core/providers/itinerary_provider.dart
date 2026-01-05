import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/itinerary_service.dart';
import '../models/itinerary.dart';

final itineraryServiceProvider = Provider<ItineraryService>((ref) {
  return ItineraryService();
});

/// Parameters for itineraries query
class ItinerariesParams {
  final int? page;
  final int? limit;
  final String? search;
  final DateTime? startDate;
  final DateTime? endDate;

  const ItinerariesParams({
    this.page,
    this.limit,
    this.search,
    this.startDate,
    this.endDate,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItinerariesParams &&
          runtimeType == other.runtimeType &&
          page == other.page &&
          limit == other.limit &&
          search == other.search &&
          startDate == other.startDate &&
          endDate == other.endDate;

  @override
  int get hashCode =>
      page.hashCode ^
      limit.hashCode ^
      search.hashCode ^
      startDate.hashCode ^
      endDate.hashCode;
}

/// Provider for all user itineraries with pagination
final itinerariesProvider = FutureProvider.family<Map<String, dynamic>, ItinerariesParams>((ref, params) async {
  final itineraryService = ref.watch(itineraryServiceProvider);
  return await itineraryService.getItineraries(
    page: params.page,
    limit: params.limit,
    search: params.search,
    startDate: params.startDate,
    endDate: params.endDate,
  );
});

/// Provider for single itinerary by ID
final itineraryByIdProvider = FutureProvider.family<Itinerary, String>((ref, itineraryId) async {
  final itineraryService = ref.watch(itineraryServiceProvider);
  return await itineraryService.getItineraryById(itineraryId);
});

/// Provider for shared itinerary by token
final sharedItineraryProvider = FutureProvider.family<Itinerary, String>((ref, shareToken) async {
  final itineraryService = ref.watch(itineraryServiceProvider);
  return await itineraryService.getSharedItinerary(shareToken);
});

