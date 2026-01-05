import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/itinerary_service.dart';
import '../models/itinerary.dart';

final itineraryServiceProvider = Provider<ItineraryService>((ref) {
  return ItineraryService();
});

/// Provider for all user itineraries
final myItinerariesProvider = FutureProvider<List<Itinerary>>((ref) async {
  final itineraryService = ref.watch(itineraryServiceProvider);
  return await itineraryService.getMyItineraries(
    page: 1,
    limit: 50,
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

