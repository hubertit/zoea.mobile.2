import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/favorites_service.dart';

final favoritesServiceProvider = Provider<FavoritesService>((ref) {
  return FavoritesService();
});

/// Parameters for favorites query
class FavoritesParams {
  final int? page;
  final int? limit;

  const FavoritesParams({
    this.page,
    this.limit,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoritesParams &&
          runtimeType == other.runtimeType &&
          page == other.page &&
          limit == other.limit;

  @override
  int get hashCode => page.hashCode ^ limit.hashCode;
}

/// Provider for all user favorites with pagination
final favoritesProvider = FutureProvider.family<Map<String, dynamic>, FavoritesParams>((ref, params) async {
  final favoritesService = ref.watch(favoritesServiceProvider);
  return await favoritesService.getFavorites(
    page: params.page,
    limit: params.limit,
  );
});

/// Provider for checking if a listing is favorited
final isListingFavoritedProvider = FutureProvider.family<bool, String>((ref, listingId) async {
  final favoritesService = ref.watch(favoritesServiceProvider);
  return await favoritesService.checkIfListingFavorited(listingId);
});

/// Provider for checking if an event is favorited
final isEventFavoritedProvider = FutureProvider.family<bool, String>((ref, eventId) async {
  final favoritesService = ref.watch(favoritesServiceProvider);
  return await favoritesService.checkIfEventFavorited(eventId);
});

/// Provider for checking if a tour is favorited
final isTourFavoritedProvider = FutureProvider.family<bool, String>((ref, tourId) async {
  final favoritesService = ref.watch(favoritesServiceProvider);
  return await favoritesService.checkIfTourFavorited(tourId);
});

