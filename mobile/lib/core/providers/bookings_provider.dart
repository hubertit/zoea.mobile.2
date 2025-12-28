import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/bookings_service.dart';

final bookingsServiceProvider = Provider<BookingsService>((ref) {
  return BookingsService();
});

/// Parameters for bookings query
class BookingsParams {
  final int? page;
  final int? limit;
  final String? status;
  final String? type;

  const BookingsParams({
    this.page,
    this.limit,
    this.status,
    this.type,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookingsParams &&
          runtimeType == other.runtimeType &&
          page == other.page &&
          limit == other.limit &&
          status == other.status &&
          type == other.type;

  @override
  int get hashCode =>
      page.hashCode ^
      limit.hashCode ^
      status.hashCode ^
      type.hashCode;
}

/// Provider for user bookings with filters
final bookingsProvider = FutureProvider.family<Map<String, dynamic>, BookingsParams>((ref, params) async {
  final bookingsService = ref.watch(bookingsServiceProvider);
  return await bookingsService.getBookings(
    page: params.page,
    limit: params.limit,
    status: params.status,
    type: params.type,
  );
});

/// Provider for upcoming bookings
final upcomingBookingsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final bookingsService = ref.watch(bookingsServiceProvider);
  return await bookingsService.getUpcomingBookings(limit: 100);
});

/// Provider for a single booking by ID
final bookingByIdProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, bookingId) async {
  final bookingsService = ref.watch(bookingsServiceProvider);
  return await bookingsService.getBooking(bookingId);
});

