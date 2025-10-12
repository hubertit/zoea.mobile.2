import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.dividerColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left,
            color: AppTheme.primaryTextColor,
            size: 28,
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
            onPressed: () {
              // TODO: Mark all as read
            },
            child: Text(
              'Mark all read',
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _getMockNotifications().length,
        itemBuilder: (context, index) {
          final notification = _getMockNotifications()[index];
          return _buildNotificationCard(notification);
        },
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
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
              color: notification['isRead'] 
                  ? AppTheme.dividerColor 
                  : AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              notification['icon'],
              color: notification['isRead'] 
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
                          notification['title'],
                          style: AppTheme.bodyMedium.copyWith(
                            fontWeight: notification['isRead'] 
                                ? FontWeight.w500 
                                : FontWeight.w600,
                            color: notification['isRead'] 
                                ? AppTheme.primaryTextColor 
                                : AppTheme.primaryTextColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        notification['time'],
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  
                  // Message
                  Text(
                    notification['message'],
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.secondaryTextColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  // Action button (if applicable)
                  if (notification['action'] != null) ...[
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        // TODO: Handle action
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        notification['action'],
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
    );
  }

  List<Map<String, dynamic>> _getMockNotifications() {
    return [
      {
        'title': 'New Event Available',
        'message': 'Gorilla Trekking experience is now available for booking',
        'time': '2 min ago',
        'icon': Icons.event,
        'isRead': false,
        'action': 'View Event',
      },
      {
        'title': 'Booking Confirmed',
        'message': 'Your Cultural Village Tour booking has been confirmed for tomorrow',
        'time': '1 hour ago',
        'icon': Icons.check_circle,
        'isRead': false,
        'action': 'View Booking',
      },
      {
        'title': 'Special Offer',
        'message': 'Get 25% off on Lake Kivu Boat Trip - Limited time offer!',
        'time': '3 hours ago',
        'icon': Icons.local_offer,
        'isRead': true,
        'action': 'View Offer',
      },
      {
        'title': 'Weather Update',
        'message': 'Perfect weather conditions for your upcoming Volcanoes National Park visit',
        'time': '5 hours ago',
        'icon': Icons.wb_sunny,
        'isRead': true,
        'action': null,
      },
      {
        'title': 'Payment Received',
        'message': 'Payment of RWF 1,200 has been received for your booking',
        'time': '1 day ago',
        'icon': Icons.payment,
        'isRead': true,
        'action': 'View Receipt',
      },
      {
        'title': 'Review Request',
        'message': 'How was your experience at Kimisagara Restaurant?',
        'time': '2 days ago',
        'icon': Icons.star,
        'isRead': true,
        'action': 'Write Review',
      },
      {
        'title': 'App Update',
        'message': 'New features available! Check out the improved booking experience',
        'time': '3 days ago',
        'icon': Icons.system_update,
        'isRead': true,
        'action': 'Update Now',
      },
    ];
  }
}
