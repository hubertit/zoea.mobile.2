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
  late AnimationController _searchController_anim;
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
    _searchController_anim = AnimationController(
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
      parent: _searchController_anim,
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
        _searchController_anim.forward();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _greetingController.dispose();
    _searchController_anim.dispose();
    _shimmerController.dispose();
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
              
              // Events section (always visible)
              _buildEventsSection(),
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
          // TODO: Navigate to search results
        },
      ),
    );
  }

  Widget _buildCategoriesSection() {
    final categories = [
      {'icon': Icons.event, 'label': 'Events'},
      {'icon': Icons.restaurant, 'label': 'Dining'},
      {'icon': Icons.explore, 'label': 'Experiences'},
      {'icon': Icons.sports_soccer, 'label': 'Sports'},
      {'icon': Icons.nightlife, 'label': 'Nightlife'},
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
            const SizedBox(height: 16),
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
      {'icon': Icons.sports_soccer, 'label': 'Sports'},
      {'icon': Icons.nightlife, 'label': 'Nightlife'},
      {'icon': Icons.shopping_bag, 'label': 'Shopping'},
      {'icon': Icons.landscape, 'label': 'National Parks'},
      {'icon': Icons.museum, 'label': 'Museums'},
      {'icon': Icons.hotel, 'label': 'Accommodation'},
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
}