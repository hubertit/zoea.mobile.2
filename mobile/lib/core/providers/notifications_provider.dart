import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notifications_service.dart';

final notificationsServiceProvider = Provider<NotificationsService>((ref) {
  return NotificationsService();
});

/// Parameters for notifications query
class NotificationsParams {
  final int? page;
  final int? limit;
  final bool? unreadOnly;

  const NotificationsParams({
    this.page,
    this.limit,
    this.unreadOnly,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationsParams &&
          runtimeType == other.runtimeType &&
          page == other.page &&
          limit == other.limit &&
          unreadOnly == other.unreadOnly;

  @override
  int get hashCode =>
      page.hashCode ^
      limit.hashCode ^
      unreadOnly.hashCode;
}

/// Provider for user notifications with filters
final notificationsProvider = FutureProvider.family<Map<String, dynamic>, NotificationsParams>((ref, params) async {
  final notificationsService = ref.watch(notificationsServiceProvider);
  return await notificationsService.getNotifications(
    page: params.page,
    limit: params.limit,
    unreadOnly: params.unreadOnly,
  );
});

/// Provider for unread notification count
final unreadCountProvider = FutureProvider<int>((ref) async {
  final notificationsService = ref.watch(notificationsServiceProvider);
  return await notificationsService.getUnreadCount();
});

