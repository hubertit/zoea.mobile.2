import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Zoea',
            style: TextStyle(
              fontSize: 31,
              fontWeight: FontWeight.w800,
              color: AppTheme.primaryColor,
              letterSpacing: -0.5,
            ),
          ),
        ),
        actions: [
          // Rewards/Referral Icon
          IconButton(
            icon: const Icon(Icons.card_giftcard),
            onPressed: () {
              context.push('/referrals');
            },
          ),
          // Search Icon
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Navigate to search screen
            },
          ),
          // Notifications Icon with Badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  // TODO: Navigate to notifications screen
                },
              ),
              // Badge for unread notifications
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: const Text(
                    '3',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with greeting
              _buildHeader(),
              const SizedBox(height: 24),
              
              // Search bar
              _buildSearchBar(),
              const SizedBox(height: 32),
              
              // Categories section
              _buildCategoriesSection(),
              const SizedBox(height: 32),
              
              // Notifications section
              _buildNotificationsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Good morning',
          style: AppTheme.bodyLarge.copyWith(
            color: AppTheme.secondaryTextColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'What would you like to explore?',
          style: AppTheme.displayMedium.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search events, venues, experiences...',
          hintStyle: AppTheme.bodyMedium.copyWith(
            color: Colors.grey[500],
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.grey[500],
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        style: AppTheme.bodyMedium,
        onSubmitted: (value) {
          // TODO: Navigate to search results
        },
      ),
    );
  }

  Widget _buildCategoriesSection() {
    final categories = [
      {'icon': Icons.event, 'label': 'Events'},
      {'icon': Icons.restaurant, 'label': 'Dining'},
      {'icon': Icons.music_note, 'label': 'Music'},
      {'icon': Icons.sports_soccer, 'label': 'Sports'},
      {'icon': Icons.local_movies, 'label': 'Movies'},
      {'icon': Icons.shopping_bag, 'label': 'Shopping'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categories',
          style: AppTheme.headlineMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return _buildCategoryCard(
              icon: category['icon'] as IconData,
              label: category['label'] as String,
            );
          },
        ),
      ],
    );
  }

  Widget _buildCategoryCard({
    required IconData icon,
    required String label,
  }) {
    return GestureDetector(
      onTap: () {
        // TODO: Navigate to category screen
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: AppTheme.primaryTextColor,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTheme.bodySmall.copyWith(
                fontWeight: FontWeight.w500,
                color: AppTheme.primaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsSection() {
    final notifications = [
      {
        'title': 'New Event Alert',
        'subtitle': 'Summer Music Festival tickets are now available',
        'time': '2 hours ago',
        'isUnread': true,
      },
      {
        'title': 'Booking Confirmed',
        'subtitle': 'Your reservation at The Grand Hotel is confirmed',
        'time': '1 day ago',
        'isUnread': false,
      },
      {
        'title': 'Special Offer',
        'subtitle': 'Get 20% off on all dining experiences this weekend',
        'time': '2 days ago',
        'isUnread': false,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Important Updates',
              style: AppTheme.headlineMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Navigate to all notifications
              },
              child: Text(
                'View All',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...notifications.map((notification) => _buildNotificationCard(
          title: notification['title'] as String,
          subtitle: notification['subtitle'] as String,
          time: notification['time'] as String,
          isUnread: notification['isUnread'] as bool,
        )),
      ],
    );
  }

  Widget _buildNotificationCard({
    required String title,
    required String subtitle,
    required String time,
    required bool isUnread,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnread ? AppTheme.primaryColor.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUnread 
              ? AppTheme.primaryColor.withOpacity(0.2)
              : Colors.grey[200]!,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isUnread ? AppTheme.primaryColor : Colors.transparent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: isUnread ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.secondaryTextColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: AppTheme.labelSmall.copyWith(
                    color: AppTheme.secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}