import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/providers/events_provider.dart';
import '../../../core/models/event.dart';
import '../../../core/constants/assets.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _greetingController;
  late AnimationController _searchAnimationController;
  late AnimationController _shimmerController;
  late AnimationController _rewardsAnimationController;
  late Animation<double> _greetingFadeAnimation;
  late Animation<double> _searchFadeAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<Color?> _rewardsColorAnimation;
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
    _searchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Shimmer animation controller
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // Rewards animation controller
    _rewardsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000), // Slow animation
      vsync: this,
    );
    
    // Start shimmer animation
    _shimmerController.repeat();
    
    // Start rewards animation (slow loop)
    _rewardsAnimationController.repeat(reverse: true);
    
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
      parent: _searchAnimationController,
      curve: Curves.easeInOut,
    ));
    
    // Shimmer animation
    _shimmerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));
    
    // Rewards color animation (orange theme)
    _rewardsColorAnimation = ColorTween(
      begin: Colors.orange[300], // Light orange
      end: Colors.orange[700],   // Dark orange
    ).animate(CurvedAnimation(
      parent: _rewardsAnimationController,
      curve: Curves.easeInOut,
    ));
    
    
    _startAnimationSequence();
  }

  void _startAnimationSequence() {
    // Start greeting animation
    _greetingController.forward();
    
    // Hide greeting and show search after 1 minute
    Future.delayed(const Duration(seconds: 60), () {
      if (mounted) {
        setState(() {
          _showGreeting = false;
          _showSearch = true;
        });
        _searchAnimationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _greetingController.dispose();
    _searchAnimationController.dispose();
    _shimmerController.dispose();
    _rewardsAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        leadingWidth: 200,
        leading: Row(
          children: [
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.only(bottom: 10),
              child: Image.asset(
                AppAssets.logoDark,
                height: 30,
              ),
            ),
          ],
        ),
        actions: [
          // Search Icon
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              context.push('/search');
            },
          ),
          // Rewards/Referral Icon with Orange Animation
          AnimatedBuilder(
            animation: _rewardsColorAnimation,
            builder: (context, child) {
              return IconButton(
                icon: Icon(
                  Icons.card_giftcard,
                  color: _rewardsColorAnimation.value,
                ),
                onPressed: () {
                  context.push('/referrals');
                },
              );
            },
          ),
          // Notifications Icon with Badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  context.push('/notifications');
                },
              ),
              // Small badge for unread notifications
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
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
                          child: Column(
                            children: [
                              _buildHeader(),
                              const SizedBox(height: 8),
                            ],
                          ),
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
              const SizedBox(height: 8),
              _buildQuickInfoWidgets(),
              
              // Categories section (always visible)
              const SizedBox(height: 16),
              _buildCategoriesSection(),
              const SizedBox(height: 16),
              
              // Events section (always visible)
              _buildEventsSection(),
              const SizedBox(height: 16),
              
              // Recommend section (always visible)
              _buildRecommendSection(),
              const SizedBox(height: 16),
              
              // Near Me section (always visible)
              _buildNearMeSection(),
              const SizedBox(height: 16),
              
              // Specials section (always visible)
              _buildSpecialsSection(),
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
          _getTimeBasedGreeting(),
          style: AppTheme.bodyLarge.copyWith(
            color: AppTheme.secondaryTextColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _getFriendlyMessage(),
          style: AppTheme.headlineMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _getTimeBasedGreeting() {
    final hour = DateTime.now().hour;
    
    if (hour >= 5 && hour < 12) {
      return 'Good morning, Hubert';
    } else if (hour >= 12 && hour < 17) {
      return 'Good afternoon, Hubert';
    } else if (hour >= 17 && hour < 21) {
      return 'Good evening, Hubert';
    } else {
      return 'Good night, Hubert';
    }
  }

  String _getFriendlyMessage() {
    final hour = DateTime.now().hour;
    
    if (hour >= 5 && hour < 12) {
      return 'Ready to start your day?';
    } else if (hour >= 12 && hour < 17) {
      return 'How can we help you today?';
    } else if (hour >= 17 && hour < 21) {
      return 'What would you like to explore?';
    } else {
      return 'Planning for tomorrow?';
    }
  }

  Widget _buildQuickInfoWidgets() {
    return SizedBox(
      height: 80,
      child: ListView(
        scrollDirection: Axis.horizontal,
      children: [
        // Weather Widget
          SizedBox(
            width: 130,
          child: _buildWeatherWidget(),
        ),
          const SizedBox(width: 8),
        // Currency Widget
          SizedBox(
            width: 130,
          child: _buildCurrencyWidget(),
        ),
          const SizedBox(width: 8),
          // Quick Actions Widget
          SizedBox(
            width: 100,
            child: _buildQuickActionsWidget(),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherWidget() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Location
              Text(
                'Kigali',
            style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
              color: AppTheme.primaryTextColor,
              fontSize: 11,
                ),
          ),
          const SizedBox(height: 8),
          
          // Temperature and weather info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Temperature
              Flexible(
                child: Text(
                  '25°',
                  style: AppTheme.headlineMedium.copyWith(
                  fontWeight: FontWeight.w700,
                    color: AppTheme.primaryTextColor,
                    fontSize: 18,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
              // Weather icon and details
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                  // Rain probability
                  Column(
                    children: [
                  Icon(
                    Icons.water_drop,
                    color: Colors.grey[600],
                    size: 16,
              ),
              Text(
                        '10%',
                style: AppTheme.bodySmall.copyWith(
                          color: Colors.grey[600],
                          fontSize: 8,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  
                  // Main weather icon
                  Icon(
                    Icons.wb_sunny,
                    color: Colors.orange[600],
                    size: 24,
                  ),
                ],
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
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Currency pair and percentage
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Currency pair
              Flexible(
                child: Text(
                  'USD / RWF',
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryTextColor,
                    fontSize: 10.8,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
              // Percentage change
              Text(
                '-0.0080%',
                style: AppTheme.bodySmall.copyWith(
                  color: Colors.red[600],
                  fontSize: 7.2,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Bottom row: Exchange rate and trend icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Exchange rate
              Flexible(
                child: Text(
                  '1,444.33',
                  style: AppTheme.headlineMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryTextColor,
                    fontSize: 18.48,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
              // Trend icon
              Container(
                width: 19.2,
                height: 19.2,
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.red[600],
                  size: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsWidget() {
    return GestureDetector(
      onTap: () => _showQuickActionsBottomSheet(),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
              Text(
              'Quick Actions',
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryTextColor,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 4),
            
            // Interesting action icon
            Center(
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.bolt,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showQuickActionsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey[50],
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Title
            Text(
              'Quick Actions',
                style: AppTheme.headlineSmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            
            // Quick actions grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: [
                _buildQuickActionItem(
                  icon: Icons.emergency,
                  label: 'Emergency SOS',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Emergency SOS activated',
                          style: AppTheme.bodyMedium.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        backgroundColor: AppTheme.primaryColor,
                      ),
                    );
                  },
                ),
                _buildQuickActionItem(
                  icon: Icons.local_taxi,
                  label: 'Call Taxi',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Finding nearby taxis...',
                          style: AppTheme.bodyMedium.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        backgroundColor: AppTheme.primaryColor,
                      ),
                    );
                  },
                ),
                _buildQuickActionItem(
                  icon: Icons.atm,
                  label: 'Find ATM',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Finding nearby ATMs...',
                          style: AppTheme.bodyMedium.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        backgroundColor: AppTheme.primaryColor,
                      ),
                    );
                  },
                ),
                _buildQuickActionItem(
                  icon: Icons.tour,
                  label: 'Book Tour',
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/explore/experiences');
                  },
                ),
                _buildQuickActionItem(
                  icon: Icons.local_hospital,
                  label: 'Find Hospital',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Finding nearby hospitals...',
                          style: AppTheme.bodyMedium.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        backgroundColor: AppTheme.primaryColor,
                      ),
                    );
                  },
                ),
                      _buildQuickActionItem(
                        icon: Icons.security,
                        label: 'Police',
                        onTap: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Connecting to police...',
                                style: AppTheme.bodyMedium.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              backgroundColor: AppTheme.primaryColor,
                            ),
                          );
                        },
                      ),
                      _buildQuickActionItem(
                        icon: Icons.local_pharmacy,
                        label: 'Pharmacy',
                        onTap: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Finding nearby pharmacies...',
                                style: AppTheme.bodyMedium.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              backgroundColor: AppTheme.primaryColor,
                            ),
                          );
                        },
                      ),
                      _buildQuickActionItem(
                        icon: Icons.car_repair,
                        label: 'Roadside Assistance',
                        onTap: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Connecting to roadside assistance...',
                                style: AppTheme.bodyMedium.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              backgroundColor: AppTheme.primaryColor,
                            ),
                          );
                        },
                      ),
                      _buildQuickActionItem(
                        icon: Icons.airplane_ticket,
                        label: 'Flight Info',
                        onTap: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Checking flight information...',
                                style: AppTheme.bodyMedium.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              backgroundColor: AppTheme.primaryColor,
                            ),
                          );
                        },
                      ),
              ],
            ),
            
            // Add bottom padding for safe area
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey[200]!,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
              icon,
              color: AppTheme.primaryColor,
              size: 24,
            ),
            const SizedBox(height: 8),
                  Text(
              label,
                    style: AppTheme.bodySmall.copyWith(
                color: AppTheme.primaryTextColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 11,
                    ),
              textAlign: TextAlign.center,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Explore events, venues, experiences...',
          hintStyle: AppTheme.bodyMedium.copyWith(
            color: AppTheme.secondaryTextColor,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: AppTheme.secondaryTextColor,
            size: 20,
          ),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: AppTheme.dividerColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: AppTheme.dividerColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: AppTheme.dividerColor),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
        ),
        style: AppTheme.bodyMedium,
        onSubmitted: (value) {
          if (value.trim().isNotEmpty) {
            context.push('/search?q=${Uri.encodeComponent(value)}');
          }
        },
      ),
    );
  }

  Widget _buildCategoriesSection() {
    final categories = [
      {'icon': Icons.event, 'label': 'Events'},
      {'icon': Icons.restaurant, 'label': 'Dining'},
      {'icon': Icons.explore, 'label': 'Experiences'},
      {'icon': Icons.nightlife, 'label': 'Nightlife'},
      {'icon': Icons.hotel, 'label': 'Accommodation'},
      {'icon': Icons.shopping_bag, 'label': 'Shopping'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Categories',
              style: AppTheme.headlineMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () {
                _showCategoriesBottomSheet(context);
              },
              child: Text(
                'View More',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
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
        if (label == 'Events') {
          context.go('/events');
        } else if (label == 'Dining') {
          context.push('/dining');
        } else if (label == 'Experiences') {
          context.push('/experiences');
        } else if (label == 'Nightlife') {
          context.push('/nightlife');
        } else if (label == 'Accommodation') {
          context.push('/accommodation');
        } else if (label == 'Shopping') {
          context.push('/shopping');
        }
        // TODO: Navigate to other category screens
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
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

  Widget _buildEventsSection() {
    return Consumer(
      builder: (context, ref, child) {
        final eventsState = ref.watch(eventsProvider);
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Happening',
                  style: AppTheme.headlineMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    context.push('/events');
                  },
                  child: Text(
                    'View More',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (eventsState.isLoading)
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    return _buildSkeletonEventCard();
                  },
                ),
              )
            else if (eventsState.error != null)
              SizedBox(
                height: 120,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: AppTheme.errorColor,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Failed to load events',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.errorColor,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (eventsState.events.isEmpty)
              SizedBox(
                height: 120,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event_available,
                        color: AppTheme.secondaryTextColor,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
            Text(
                        'No events today',
                        style: AppTheme.bodySmall.copyWith(
                color: AppTheme.secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: eventsState.events.take(5).length,
                  itemBuilder: (context, index) {
                    final event = eventsState.events[index];
                    return _buildEventCardFromData(event);
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildSkeletonEventCard() {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[300],
      ),
      child: Stack(
        children: [
          // Skeleton shimmer effect
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _shimmerAnimation,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.grey[300]!,
                        Colors.grey[200]!,
                        Colors.grey[300]!,
                      ],
                      stops: [
                        0.0,
                        _shimmerAnimation.value,
                        1.0,
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Skeleton content
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 12,
                    width: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 10,
                    width: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCardFromData(Event event) {
    final eventDetails = event.event;
    final startDate = eventDetails.startDate;
    final timeFormat = DateFormat('HH:mm');
    final dateFormat = DateFormat('MMM dd');
    
    // Check if event is today
    final now = DateTime.now();
    final isToday = startDate.year == now.year && 
                   startDate.month == now.month && 
                   startDate.day == now.day;
    
    String timeText;
    if (isToday) {
      timeText = 'Today, ${timeFormat.format(startDate)}';
    } else {
      timeText = '${dateFormat.format(startDate)}, ${timeFormat.format(startDate)}';
    }
    
    return GestureDetector(
      onTap: () {
        context.go('/event/${event.id}', extra: event);
      },
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              // Event image
              Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: eventDetails.flyer,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.event,
                      color: Colors.grey,
                      size: 40,
                    ),
                  ),
                ),
              ),
              // Gradient overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
              ),
              // Event details
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        eventDetails.name,
                        style: AppTheme.bodyMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        eventDetails.locationName,
                        style: AppTheme.bodySmall.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        timeText,
                        style: AppTheme.labelSmall.copyWith(
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventCard({
    required String title,
    required String subtitle,
    required String time,
    required String imageUrl,
  }) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Event image
            Positioned.fill(
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.image,
                      color: Colors.grey,
                      size: 40,
                    ),
                  );
                },
              ),
            ),
            // Gradient overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
            ),
            // Event details
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTheme.bodySmall.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      time,
                      style: AppTheme.labelSmall.copyWith(
                        color: Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoriesBottomSheet(BuildContext context) {
    final allCategories = [
      {'icon': Icons.event, 'label': 'Events'},
      {'icon': Icons.restaurant, 'label': 'Dining'},
      {'icon': Icons.explore, 'label': 'Experiences'},
      {'icon': Icons.nightlife, 'label': 'Nightlife'},
      {'icon': Icons.hotel, 'label': 'Accommodation'},
      {'icon': Icons.shopping_bag, 'label': 'Shopping'},
      {'icon': Icons.sports_soccer, 'label': 'Sports'},
      {'icon': Icons.landscape, 'label': 'National Parks'},
      {'icon': Icons.museum, 'label': 'Museums'},
      {'icon': Icons.directions_car, 'label': 'Transport'},
      {'icon': Icons.terrain, 'label': 'Hiking'},
      {'icon': Icons.build, 'label': 'Services'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey[50], // Match quick actions background
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Title
            Text(
              'All Categories',
              style: AppTheme.headlineSmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            // Categories grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: allCategories.map((category) {
                return _buildBottomSheetCategoryCard(
                  icon: category['icon'] as IconData,
                  label: category['label'] as String,
                );
              }).toList(),
            ),
            
            // Add bottom padding for safe area
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSheetCategoryCard({
    required IconData icon,
    required String label,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        // TODO: Navigate to specific category
        // context.push('/category/${label.toLowerCase()}');
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, // Match quick actions white background
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey[200]!, // Match quick actions border
            width: 1,
          ),
          boxShadow: [ // Add shadow like quick actions
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: AppTheme.primaryColor, // Match quick actions icon color
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.primaryTextColor, // Match quick actions text color
                fontWeight: FontWeight.w500,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recommend',
              style: AppTheme.headlineMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () {
                context.push('/recommendations');
              },
              child: Text(
                'View More',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5, // Show 5 recommended items
            itemBuilder: (context, index) {
              return _buildRecommendCard(index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendCard(int index) {
    // Sample recommendation data with real images and IDs
    final recommendations = [
      {
        'id': '1',
        'title': 'Volcanoes National Park',
        'subtitle': 'Gorilla Trekking Experience',
        'image': 'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=400',
        'rating': 4.9,
        'category': 'Wildlife',
      },
      {
        'id': '2',
        'title': 'Nyungwe Forest',
        'subtitle': 'Canopy Walk Adventure',
        'image': 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=400',
        'rating': 4.8,
        'category': 'Nature',
      },
      {
        'id': '3',
        'title': 'Lake Kivu',
        'subtitle': 'Relaxing Boat Cruise',
        'image': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400',
        'rating': 4.7,
        'category': 'Water',
      },
      {
        'id': '4',
        'title': 'Kigali Genocide Memorial',
        'subtitle': 'Historical Tour',
        'image': 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400',
        'rating': 4.9,
        'category': 'History',
      },
      {
        'id': '5',
        'title': 'Akagera National Park',
        'subtitle': 'Safari Experience',
        'image': 'https://images.unsplash.com/photo-1516026672322-bc52d61a55d5?w=400',
        'rating': 4.6,
        'category': 'Wildlife',
      },
    ];

    final recommendation = recommendations[index % recommendations.length];

    return GestureDetector(
      onTap: () {
        context.push('/place/${recommendation['id']}');
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with real cover
            Container(
              height: 100,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                color: Colors.grey[200],
              ),
              child: Stack(
                children: [
                  // Real image
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.network(
                      recommendation['image'] as String,
                      width: double.infinity,
                      height: 100,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 100,
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 100,
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(Icons.image, color: Colors.grey),
                          ),
                        );
                      },
                    ),
                  ),
                  // Category badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        recommendation['category'] as String,
                        style: AppTheme.bodySmall.copyWith(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  // Rating
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 12,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            recommendation['rating'].toString(),
                            style: AppTheme.bodySmall.copyWith(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recommendation['title'] as String,
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    recommendation['subtitle'] as String,
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.secondaryTextColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        recommendation['category'] as String,
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // TODO: Add to favorites
                        },
                        child: Icon(
                          Icons.favorite_border,
                          color: AppTheme.secondaryTextColor,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNearMeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Near Me',
              style: AppTheme.headlineMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Navigate to map view
                context.push('/map');
              },
              child: Text(
                'View Map',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _getMockNearMePlaces().length,
          itemBuilder: (context, index) {
            final place = _getMockNearMePlaces()[index];
            return _buildNearMeCard(place);
          },
        ),
      ],
    );
  }

  Widget _buildNearMeCard(Map<String, dynamic> place) {
    return GestureDetector(
      onTap: () {
        context.push('/place/${place['id']}');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppTheme.backgroundColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
            child: CachedNetworkImage(
              imageUrl: place['image'],
              height: 80,
              width: 80,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 80,
                width: 80,
                color: AppTheme.dividerColor,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                height: 80,
                width: 80,
                color: AppTheme.dividerColor,
                child: const Icon(Icons.image_not_supported),
              ),
            ),
          ),
          
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    place['name'],
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  
                  // Distance and Category
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 12,
                        color: AppTheme.secondaryTextColor,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        place['distance'],
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.secondaryTextColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          place['category'],
                          style: AppTheme.labelSmall.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  List<Map<String, dynamic>> _getMockNearMePlaces() {
    return [
      {
        'id': 'near_me_1',
        'name': 'Kigali Convention Centre',
        'distance': '0.5 km',
        'category': 'Venue',
        'image': 'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=200',
      },
      {
        'id': 'near_me_2',
        'name': 'Kimisagara Market',
        'distance': '1.2 km',
        'category': 'Market',
        'image': 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=200',
      },
      {
        'id': 'near_me_3',
        'name': 'Kigali Genocide Memorial',
        'distance': '2.1 km',
        'category': 'Memorial',
        'image': 'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=200',
      },
      {
        'id': 'near_me_4',
        'name': 'Kimisagara Restaurant',
        'distance': '0.8 km',
        'category': 'Dining',
        'image': 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=200',
      },
      {
        'id': 'near_me_5',
        'name': 'Kigali City Tower',
        'distance': '1.5 km',
        'category': 'Shopping',
        'image': 'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=200',
      },
    ];
  }

  Widget _buildSpecialsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Special Offers',
              style: AppTheme.headlineMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () {
                context.push('/specials');
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
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _getMockSpecials().length,
          itemBuilder: (context, index) {
            final special = _getMockSpecials()[index];
            return _buildSpecialCard(special);
          },
        ),
      ],
    );
  }

  Widget _buildSpecialCard(Map<String, dynamic> special) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left content
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      special['badge'],
                      style: AppTheme.labelSmall.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Title
                  Text(
                    special['title'],
                    style: AppTheme.headlineSmall.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  
                  // Description
                  Text(
                    special['description'],
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.secondaryTextColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  
                  // Price and discount
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            special['originalPrice'],
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.secondaryTextColor,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            special['discountedPrice'],
                            style: AppTheme.titleMedium.copyWith(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.successColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          special['discount'],
                          style: AppTheme.labelSmall.copyWith(
                            color: AppTheme.successColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Right content - Image
          Expanded(
            flex: 1,
            child: Container(
              height: 140,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.horizontal(right: Radius.circular(16)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.horizontal(right: Radius.circular(16)),
                child: CachedNetworkImage(
                  imageUrl: special['image'],
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppTheme.dividerColor,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: AppTheme.dividerColor,
                    child: const Icon(Icons.image_not_supported),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getMockSpecials() {
    return [
      {
        'title': 'Gorilla Trekking',
        'description': 'Experience the majestic mountain gorillas in their natural habitat',
        'badge': 'LIMITED TIME',
        'originalPrice': 'RWF 1,500',
        'discountedPrice': 'RWF 1,200',
        'discount': '20% OFF',
        'image': 'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=200',
      },
      {
        'title': 'Cultural Village Tour',
        'description': 'Discover Rwanda\'s rich cultural heritage and traditions',
        'badge': 'POPULAR',
        'originalPrice': 'RWF 800',
        'discountedPrice': 'RWF 600',
        'discount': '25% OFF',
        'image': 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=200',
      },
      {
        'title': 'Lake Kivu Boat Trip',
        'description': 'Relax on a scenic boat trip across the beautiful Lake Kivu',
        'badge': 'NEW',
        'originalPrice': 'RWF 1,200',
        'discountedPrice': 'RWF 900',
        'discount': '25% OFF',
        'image': 'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=200',
      },
    ];
  }
}