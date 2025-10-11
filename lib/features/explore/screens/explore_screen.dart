import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _greetingController;
  late AnimationController _searchController_anim;
  late Animation<double> _greetingFadeAnimation;
  late Animation<double> _searchFadeAnimation;
  bool _showGreeting = true;
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    
    // Greeting animation controller
    _greetingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // Search animation controller
    _searchController_anim = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    
    // Greeting fade animation
    _greetingFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _greetingController,
      curve: Curves.easeInOut,
    ));
    
    // Search fade animation
    _searchFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _searchController_anim,
      curve: Curves.easeInOut,
    ));
    
    
    _startAnimationSequence();
  }

  void _startAnimationSequence() {
    // Start greeting animation
    _greetingController.forward();
    
    // Hide greeting and show search after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _showGreeting = false;
          _showSearch = true;
        });
        _searchController_anim.forward();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _greetingController.dispose();
    _searchController_anim.dispose();
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
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Animated Header with greeting
              AnimatedBuilder(
                animation: _greetingFadeAnimation,
                builder: (context, child) {
                  return _showGreeting
                      ? Opacity(
                          opacity: _greetingFadeAnimation.value,
                          child: _buildHeader(),
                        )
                      : const SizedBox.shrink();
                },
              ),
              
              // Animated Search bar
              AnimatedBuilder(
                animation: _searchFadeAnimation,
                builder: (context, child) {
                  return _showSearch
                      ? Opacity(
                          opacity: _searchFadeAnimation.value,
                          child: Column(
                            children: [
                              const SizedBox(height: 8),
                              _buildSearchBar(),
                            ],
                          ),
                        )
                      : const SizedBox.shrink();
                },
              ),
              
              // Weather and Currency Widgets (always visible)
              const SizedBox(height: 16),
              _buildQuickInfoWidgets(),
              
              // Categories section (always visible)
              const SizedBox(height: 32),
              _buildCategoriesSection(),
              const SizedBox(height: 32),
              
              // Notifications section (always visible)
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
          style: AppTheme.headlineMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickInfoWidgets() {
    return Row(
      children: [
        // Weather Widget
        Expanded(
          child: _buildWeatherWidget(),
        ),
        const SizedBox(width: 12),
        // Currency Widget
        Expanded(
          child: _buildCurrencyWidget(),
        ),
      ],
    );
  }

  Widget _buildWeatherWidget() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Column(
        children: [
          // First row: Icon + Location
          Row(
            children: [
              Icon(
                Icons.wb_sunny,
                color: Colors.orange[600],
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                'Kigali',
                style: AppTheme.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[800],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Second row: Temperature + Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '24°C',
                style: AppTheme.headlineSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.blue[900],
                ),
              ),
              Text(
                'Sunny',
                style: AppTheme.bodySmall.copyWith(
                  color: Colors.blue[700],
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyWidget() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.green[100]!),
      ),
      child: Column(
        children: [
          // First row: Icon + Currency Pair
          Row(
            children: [
              Icon(
                Icons.attach_money,
                color: Colors.green[600],
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                'USD/RWF',
                style: AppTheme.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.green[800],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Second row: Rate + Trend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '3,250',
                style: AppTheme.headlineSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.green[900],
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.trending_up,
                    color: Colors.green[600],
                    size: 14,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    '+0.5%',
                    style: AppTheme.bodySmall.copyWith(
                      color: Colors.green[700],
                      fontWeight: FontWeight.w500,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
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
          hintText: 'Explore events, venues, experiences...',
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