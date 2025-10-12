import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/providers/events_provider.dart';
import '../../../core/models/event.dart';

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
  late Animation<double> _greetingFadeAnimation;
  late Animation<double> _searchFadeAnimation;
  late Animation<double> _shimmerAnimation;
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
    
    // Start shimmer animation
    _shimmerController.repeat();
    
    
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
          // Search Icon
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              context.push('/search');
            },
          ),
          // Rewards/Referral Icon
          IconButton(
            icon: const Icon(Icons.card_giftcard),
            onPressed: () {
              context.push('/referrals');
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
              const SizedBox(height: 8),
              _buildQuickInfoWidgets(),
              
              // Categories section (always visible)
              const SizedBox(height: 16),
              _buildCategoriesSection(),
              const SizedBox(height: 16),
              
              // Events section (always visible)
              _buildEventsSection(),
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
          'Good morning, Hubert',
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
                  'Happening Now',
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
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.backgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'All Categories',
                    style: AppTheme.titleLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.dividerColor,
                      foregroundColor: AppTheme.primaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
            // Categories grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1,
                ),
                itemCount: allCategories.length,
                itemBuilder: (context, index) {
                  final category = allCategories[index];
                  return _buildBottomSheetCategoryCard(
                    icon: category['icon'] as IconData,
                    label: category['label'] as String,
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.dividerColor,
          borderRadius: BorderRadius.circular(12),
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
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
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
    return Container(
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
    );
  }

  List<Map<String, dynamic>> _getMockNearMePlaces() {
    return [
      {
        'name': 'Kigali Convention Centre',
        'distance': '0.5 km',
        'category': 'Venue',
        'image': 'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=200',
      },
      {
        'name': 'Kimisagara Market',
        'distance': '1.2 km',
        'category': 'Market',
        'image': 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=200',
      },
      {
        'name': 'Kigali Genocide Memorial',
        'distance': '2.1 km',
        'category': 'Memorial',
        'image': 'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=200',
      },
      {
        'name': 'Kimisagara Restaurant',
        'distance': '0.8 km',
        'category': 'Dining',
        'image': 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=200',
      },
      {
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