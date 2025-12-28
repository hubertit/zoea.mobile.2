import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/notifications_provider.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  bool _isMarkingAllAsRead = false;

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(
      notificationsProvider(
        const NotificationsParams(
          page: 1,
          limit: 100,
        ),
      ),
    );

    return Scaffold(
      backgroundColor: AppTheme.dividerColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left,
            color: AppTheme.primaryTextColor,
            size: 32,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Notifications',
          style: AppTheme.headlineMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _isMarkingAllAsRead ? null : _markAllAsRead,
            child: _isMarkingAllAsRead
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'Mark all read',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ),
        ],
      ),
      body: notificationsAsync.when(
        data: (response) {
          final notifications = (response['data'] as List<dynamic>?)
                  ?.map((n) => n as Map<String, dynamic>)
                  .toList() ??
              [];

          if (notifications.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(
                notificationsProvider(
                  const NotificationsParams(
                    page: 1,
                    limit: 100,
                  ),
                ),
              );
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _buildNotificationCard(context, notification);
              },
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: AppTheme.primaryColor,
          ),
        ),
        error: (error, stack) => _buildErrorState(error),
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, Map<String, dynamic> notification) {
    final isRead = notification['isRead'] as bool? ?? false;
    final title = notification['title'] as String? ?? 'Notification';
    final body = notification['body'] as String? ?? '';
    final createdAt = notification['createdAt'] as String?;
    final type = notification['type'] as String?;
    final actionUrl = notification['actionUrl'] as String?;
    final bookingId = notification['bookingId'] as String?;
    final eventId = notification['eventId'] as String?;
    final listingId = notification['listingId'] as String?;

    // Get icon based on notification type
    final icon = _getIconForType(type);
    
    // Format time
    final timeText = _formatTime(createdAt);

    // Determine action text and navigation
    String? actionText;
    VoidCallback? onActionTap;

    if (bookingId != null) {
      actionText = 'View Booking';
      onActionTap = () {
        context.push('/booking-confirmation/$bookingId');
      };
    } else if (eventId != null) {
      actionText = 'View Event';
      onActionTap = () {
        context.push('/events/$eventId');
      };
    } else if (listingId != null) {
      actionText = 'View Listing';
      onActionTap = () {
        context.push('/listings/$listingId');
      };
    } else if (actionUrl != null && actionUrl.isNotEmpty) {
      actionText = 'View Details';
      onActionTap = () {
        // Handle custom action URL
        _handleActionUrl(context, actionUrl);
      };
    }

    return GestureDetector(
      onTap: !isRead ? () => _markAsRead(notification['id'] as String) : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppTheme.backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: !isRead
              ? Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.2),
                  width: 1,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryTextColor.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon/Avatar
            Container(
              margin: const EdgeInsets.all(12),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isRead
                    ? AppTheme.dividerColor
                    : AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                color: isRead
                    ? AppTheme.secondaryTextColor
                    : AppTheme.primaryColor,
                size: 20,
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 12, top: 12, bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and time
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: AppTheme.bodyMedium.copyWith(
                              fontWeight: isRead
                                  ? FontWeight.w500
                                  : FontWeight.w600,
                              color: AppTheme.primaryTextColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          timeText,
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Message
                    Text(
                      body,
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.secondaryTextColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Action button (if applicable)
                    if (actionText != null && onActionTap != null) ...[
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: onActionTap,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          actionText,
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppTheme.dividerColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none,
              size: 48,
              color: AppTheme.secondaryTextColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Notifications',
            style: AppTheme.titleLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You don\'t have any notifications yet',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.secondaryTextColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.errorColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load notifications',
              style: AppTheme.titleLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString().replaceAll('Exception: ', ''),
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.secondaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(
                  notificationsProvider(
                    const NotificationsParams(
                      page: 1,
                      limit: 100,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _markAsRead(String notificationId) async {
    try {
      final notificationsService = ref.read(notificationsServiceProvider);
      await notificationsService.markAsRead(notificationId);

      if (!mounted) return;

      // Refresh notifications list
      ref.invalidate(
        notificationsProvider(
          const NotificationsParams(
            page: 1,
            limit: 100,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to mark notification as read: ${e.toString().replaceAll('Exception: ', '')}',
          ),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  Future<void> _markAllAsRead() async {
    setState(() {
      _isMarkingAllAsRead = true;
    });

    try {
      final notificationsService = ref.read(notificationsServiceProvider);
      await notificationsService.markAllAsRead();

      if (!mounted) return;

      // Refresh notifications list and unread count
      ref.invalidate(
        notificationsProvider(
          const NotificationsParams(
            page: 1,
            limit: 100,
          ),
        ),
      );
      ref.invalidate(unreadCountProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All notifications marked as read'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to mark all as read: ${e.toString().replaceAll('Exception: ', '')}',
          ),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isMarkingAllAsRead = false;
        });
      }
    }
  }

  IconData _getIconForType(String? type) {
    if (type == null) return Icons.notifications;
    
    switch (type.toLowerCase()) {
      case 'booking':
      case 'booking_confirmed':
      case 'booking_cancelled':
        return Icons.check_circle;
      case 'event':
      case 'event_reminder':
        return Icons.event;
      case 'payment':
      case 'payment_received':
        return Icons.payment;
      case 'review':
      case 'review_request':
        return Icons.star;
      case 'promotion':
      case 'offer':
      case 'discount':
        return Icons.local_offer;
      case 'system':
      case 'app_update':
        return Icons.system_update;
      case 'weather':
        return Icons.wb_sunny;
      default:
        return Icons.notifications;
    }
  }

  String _formatTime(String? dateString) {
    if (dateString == null) return 'Just now';
    
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes} min ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
      } else {
        return DateFormat('MMM dd, yyyy').format(date);
      }
    } catch (e) {
      return 'Recently';
    }
  }

  void _handleActionUrl(BuildContext context, String actionUrl) {
    // Handle different action URL patterns
    if (actionUrl.startsWith('/')) {
      // Internal route
      context.push(actionUrl);
    } else if (actionUrl.startsWith('http://') || actionUrl.startsWith('https://')) {
      // External URL - could use url_launcher here if needed
      // For now, just show a message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Opening: $actionUrl'),
          backgroundColor: AppTheme.primaryColor,
        ),
      );
    }
  }
}
