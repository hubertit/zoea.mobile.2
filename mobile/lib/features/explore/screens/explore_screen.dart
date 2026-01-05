import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/theme/text_theme_extensions.dart';
import '../../../core/widgets/fade_in_image.dart' show FadeInNetworkImage;
import '../../../core/providers/events_provider.dart';
import '../../../core/providers/listings_provider.dart';
import '../../../core/providers/categories_provider.dart';
import '../../../core/providers/favorites_provider.dart';
import '../../../core/providers/tours_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/providers/country_provider.dart';
import '../../../core/models/event.dart';
import '../../../core/constants/assets.dart';
import '../../../core/config/app_config.dart';
import '../../user_data_collection/utils/prompt_helper.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen>
    with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  late AnimationController _rewardsAnimationController;
  late Animation<double> _shimmerAnimation;
  late Animation<Color?> _rewardsColorAnimation;

  // Responsive width helper - similar to Bootstrap columns
  double _getResponsiveWidth({
    required BuildContext context,
    double xs = 1.0,  // Extra small (< 576px) - fraction of screen width
    double? sm,        // Small (≥ 576px)
    double? md,        // Medium (≥ 768px)
    double? lg,        // Large (≥ 992px)
    double? xl,        // Extra large (≥ 1200px)
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = MediaQuery.of(context).padding.left + MediaQuery.of(context).padding.right;
    final availableWidth = screenWidth - padding - 40; // Account for screen padding and widget padding
    
    // Use the largest breakpoint that fits
    if (xl != null && screenWidth >= 1200) {
      return availableWidth * xl;
    } else if (lg != null && screenWidth >= 992) {
      return availableWidth * lg;
    } else if (md != null && screenWidth >= 768) {
      return availableWidth * md;
    } else if (sm != null && screenWidth >= 576) {
      return availableWidth * sm;
    } else {
      return availableWidth * xs;
    }
  }

  @override
  void initState() {
    super.initState();
    
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

    // Check and show progressive prompt based on session count (after first frame)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          PromptHelper.checkAndShowPromptBasedOnSessions(context, ref);
        }
      });
    });
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _rewardsAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: context.grey50,
      appBar: AppBar(
        backgroundColor: context.surfaceColor,
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
                isDarkMode ? AppAssets.logoWhite : AppAssets.logoDark,
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
          // Rewards/Referral Icon with Orange Animation - Shows menu
          AnimatedBuilder(
            animation: _rewardsColorAnimation,
            builder: (context, child) {
              return IconButton(
                icon: Icon(
                  Icons.card_giftcard,
                  color: _rewardsColorAnimation.value,
                ),
                onPressed: () {
                  _showGiftBoxMenu(context);
                },
              );
            },
          ),
          // Profile Icon
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              context.push('/profile');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: context.primaryColorTheme,
          backgroundColor: context.cardColor,
          onRefresh: () async {
            // Refresh all data on explore screen
            ref.invalidate(categoriesProvider);
            ref.invalidate(eventsProvider);
            ref.invalidate(listingsProvider);
            // Wait a bit for providers to refresh
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(), // Enable pull-to-refresh even when content fits
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                
                // Tour Packages section (always visible)
                _buildTourPackagesSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildQuickInfoWidgets() {
    return SizedBox(
      height: 80,
      child: Row(
        children: [
          // Weather Widget - takes proportional space
          Expanded(
            flex: 3, // 3 parts
            child: _buildWeatherWidget(),
          ),
          const SizedBox(width: 8),
          // Currency Widget - takes proportional space
          Expanded(
            flex: 3, // 3 parts
            child: _buildCurrencyWidget(),
          ),
          const SizedBox(width: 8),
          // Quick Actions Widget - takes proportional space
          Expanded(
            flex: 2, // 2 parts (slightly smaller)
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
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: context.isDarkMode 
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
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
            style: context.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
              color: context.primaryTextColor,
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
                  style: context.headlineMedium.copyWith(
                  fontWeight: FontWeight.w700,
                    color: context.primaryTextColor,
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
                    color: context.grey600,
                    size: 16,
              ),
              Text(
                        '10%',
                style: context.bodySmall.copyWith(
                          color: context.grey600,
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
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: context.isDarkMode 
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
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
                  style: context.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.primaryTextColor,
                    fontSize: 10.8,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
              // Percentage change
              Text(
                '-0.0080%',
                style: context.bodySmall.copyWith(
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
                  style: context.headlineMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: context.primaryTextColor,
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
                  color: context.isDarkMode 
                      ? Colors.red[900]!.withOpacity(0.3)
                      : Colors.red[100],
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
          color: context.cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: context.isDarkMode 
                  ? Colors.black.withOpacity(0.3)
                  : Colors.black.withOpacity(0.05),
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
              style: context.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: context.primaryTextColor,
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
                  color: context.primaryColorTheme.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: context.primaryColorTheme.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.bolt,
                  color: context.primaryColorTheme,
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
      backgroundColor: context.grey50,
      builder: (context) => Container(
        padding: const EdgeInsets.all(12),
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
                  color: context.grey300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Title
            Text(
              'Quick Actions',
                style: context.headlineSmall.copyWith(
                fontWeight: FontWeight.w600,
                color: context.primaryTextColor,
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
              childAspectRatio: 1.625, // Reduced height by 20% (was 1.3)
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
                          style: context.bodyMedium.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        backgroundColor: context.primaryColorTheme,
                      ),
                    );
                  },
                ),
                _buildQuickActionItem(
                  icon: Icons.local_taxi,
                  label: 'Call Taxi',
                  onTap: () async {
                    Navigator.pop(context);
                    final Uri phoneUri = Uri(scheme: 'tel', path: '1010');
                    if (await canLaunchUrl(phoneUri)) {
                      await launchUrl(phoneUri);
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          AppTheme.errorSnackBar(
                            message: 'Unable to make phone call',
                          ),
                        );
                      }
                    }
                  },
                ),
                _buildQuickActionItem(
                  icon: Icons.tour,
                  label: 'Book Tour',
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/tour-packages');
                  },
                ),
                _buildQuickActionItem(
                  icon: Icons.sim_card,
                  label: 'eSim',
                  onTap: () {
                    Navigator.pop(context);
                    // Open eSim deeplink in webview
                    context.push(
                      '/webview?url=${Uri.encodeComponent('https://amadeus-api.optionizr.com/api/esim/deeplink?site=P02XP02X')}&title=${Uri.encodeComponent('eSim')}',
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
                                style: context.bodyMedium.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              backgroundColor: context.primaryColorTheme,
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
                                style: context.bodyMedium.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              backgroundColor: context.primaryColorTheme,
                            ),
                          );
                        },
                      ),
                      _buildQuickActionItem(
                        icon: Icons.airplane_ticket,
                        label: 'Flight Info',
                        onTap: () {
                          Navigator.pop(context);
                          // Open RwandAir website in webview
                          context.push(
                            '/webview?url=${Uri.encodeComponent('https://www.rwandair.com/')}&title=${Uri.encodeComponent('RwandAir')}',
                          );
                        },
                      ),
                      _buildQuickActionItem(
                        icon: Icons.admin_panel_settings, // Placeholder icon - will be replaced with Irembo logo
                        label: 'Irembo',
                        isCustomIcon: true, // Flag to indicate custom icon/logo
                        onTap: () {
                          Navigator.pop(context);
                          // Open Irembo website in webview
                          context.push(
                            '/webview?url=${Uri.encodeComponent('https://irembo.gov.rw/')}&title=${Uri.encodeComponent('Irembo')}',
                          );
                        },
                      ),
                      _buildQuickActionItem(
                        icon: Icons.tour, // Placeholder icon - will be replaced with Visit Rwanda logo
                        label: 'Visit Rwanda',
                        isCustomIcon: true, // Flag to indicate custom icon/logo
                        onTap: () {
                          Navigator.pop(context);
                          // Open Visit Rwanda website in webview
                          context.push(
                            '/webview?url=${Uri.encodeComponent('https://visitrwanda.com/')}&title=${Uri.encodeComponent('Visit Rwanda')}',
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
    bool isCustomIcon = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: context.grey200,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Use custom logo for Irembo
            if (isCustomIcon && label == 'Irembo')
              SvgPicture.asset(
                'assets/images/irembo_logo.svg',
                width: 16,
                height: 16,
                colorFilter: ColorFilter.mode(
                  context.primaryColorTheme,
                  BlendMode.srcIn,
                ),
                placeholderBuilder: (context) => Icon(
                  icon,
                  color: context.primaryColorTheme,
                  size: 22,
                ),
              )
            // Use custom logo for Visit Rwanda
            else if (isCustomIcon && label == 'Visit Rwanda')
              ColorFiltered(
                colorFilter: ColorFilter.mode(
                  context.primaryColorTheme,
                  BlendMode.srcIn,
                ),
                child: Image.asset(
                  'assets/images/visit-rwanda.png',
                  width: 44,
                  height: 44,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    icon,
                    color: context.primaryColorTheme,
                    size: 22,
                  ),
                ),
              )
            else
              Icon(
                icon,
                color: context.primaryColorTheme,
                size: 22, // Match category card icon size
              ),
            // No spacing for Visit Rwanda and Irembo (they don't have text labels)
            if (label != 'Visit Rwanda' && label != 'Irembo') const SizedBox(height: 6),
            // Hide text label for Visit Rwanda and Irembo (logos already contain names)
            if (label != 'Visit Rwanda' && label != 'Irembo')
              Text(
                label,
                style: context.bodySmall.copyWith(
                  color: context.primaryTextColor,
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


  Widget _buildCategoriesSection() {
    final categoriesAsync = ref.watch(categoriesProvider);

    // If we have previous data, show it while silently refreshing
    if (categoriesAsync.hasValue && categoriesAsync.value != null) {
      final categories = categoriesAsync.value!;
      // Filter only active categories and sort by sortOrder
      final activeCategories = categories
          .where((cat) => cat['isActive'] == true)
          .toList()
        ..sort((a, b) => (a['sortOrder'] as int? ?? 0).compareTo(b['sortOrder'] as int? ?? 0));

      if (activeCategories.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Categories',
                style: context.headlineMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.primaryTextColor,
                ),
              ),
              TextButton(
                onPressed: () {
                  _showCategoriesBottomSheet(context);
                },
                child: Text(
                  'View More',
                  style: context.bodySmall.copyWith(
                    color: context.primaryColorTheme,
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
              childAspectRatio: 1.3,
            ),
            itemCount: activeCategories.length > 6 ? 6 : activeCategories.length,
            itemBuilder: (context, index) {
              final category = activeCategories[index];
              return _buildCategoryCardFromApi(category);
            },
          ),
        ],
      );
    }

    // Only show loading state if we don't have previous data
    return categoriesAsync.when(
      data: (categories) {
        // Filter only active categories and sort by sortOrder
        final activeCategories = categories
            .where((cat) => cat['isActive'] == true)
            .toList()
          ..sort((a, b) => (a['sortOrder'] as int? ?? 0).compareTo(b['sortOrder'] as int? ?? 0));

        if (activeCategories.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Categories',
                  style: context.headlineMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.primaryTextColor,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _showCategoriesBottomSheet(context);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: context.primaryColorTheme,
                  ),
                  child: const Text(
                    'View More',
                    style: TextStyle(
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
                childAspectRatio: 1.3,
              ),
              itemCount: activeCategories.length > 6 ? 6 : activeCategories.length,
              itemBuilder: (context, index) {
                final category = activeCategories[index];
                return _buildCategoryCardFromApi(category);
              },
            ),
          ],
        );
      },
      loading: () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Categories',
            style: context.headlineMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: context.primaryTextColor,
            ),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.3,
            ),
            itemCount: 6,
            itemBuilder: (context, index) {
              return _buildSkeletonCategoryCard();
            },
          ),
        ],
      ),
      error: (error, stack) => const SizedBox.shrink(), // Hide on error
    );
  }

  IconData _getIconForCategory(String? iconName) {
    // Map icon names from API to Flutter icons
    switch (iconName?.toLowerCase()) {
      case 'hotel':
        return Icons.hotel;
      case 'restaurant':
        return Icons.restaurant;
      case 'local_bar':
      case 'nightlife':
        return Icons.nightlife;
      case 'explore':
      case 'tours':
        return Icons.explore;
      case 'event':
      case 'events':
        return Icons.event;
      case 'shopping_bag':
      case 'shopping':
        return Icons.shopping_bag;
      case 'attractions':
        return Icons.attractions;
      default:
        return Icons.category;
    }
  }

  Widget _buildCategoryCardFromApi(Map<String, dynamic> category) {
    final name = category['name'] as String? ?? 'Category';
    final slug = category['slug'] as String? ?? '';
    final iconName = category['icon'] as String?;
    final icon = _getIconForCategory(iconName);

    return GestureDetector(
      onTap: () {
        // Navigate to Stay tab if Accommodation category
        if (slug == 'accommodation' || name.toLowerCase() == 'accommodation') {
          context.go('/accommodation');
        } 
        // Navigate to Events screen if Events category
        else if (slug == 'events' || name.toLowerCase() == 'events') {
          context.go('/events');
        } 
        else if (slug.isNotEmpty) {
          context.push('/category/$slug');
        } else {
          context.push('/category/${name.toLowerCase().replaceAll(' ', '-')}');
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: context.grey200,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: context.primaryColorTheme,
              size: 22,
            ),
            const SizedBox(height: 6),
            Text(
              name,
              style: context.bodySmall.copyWith(
                fontWeight: FontWeight.w500,
                color: context.primaryTextColor,
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

  Widget _buildSkeletonCategoryCard() {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: context.grey200,
              width: 1,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                context.grey200,
                context.grey100,
                context.grey200,
              ],
              stops: [
                0.0,
                _shimmerAnimation.value,
                1.0,
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Skeleton icon
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: context.grey300,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 8),
              // Skeleton text
              Container(
                width: 60,
                height: 12,
                decoration: BoxDecoration(
                  color: context.grey300,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryCard({
    required IconData icon,
    required String label,
  }) {
    return GestureDetector(
      onTap: () {
        context.push('/category/${label.toLowerCase()}');
      },
      child: Container(
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: context.grey200,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: context.primaryColorTheme,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: context.bodySmall.copyWith(
                fontWeight: FontWeight.w500,
                color: context.primaryTextColor,
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
                  style: context.headlineMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.primaryTextColor,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    context.push('/events');
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: context.primaryColorTheme,
                  ),
                  child: const Text(
                    'View More',
                    style: TextStyle(
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
                        color: context.errorColor,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Failed to load events',
                        style: context.bodySmall.copyWith(
                          color: context.errorColor,
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
                        color: context.secondaryTextColor,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
            Text(
                        'No events today',
                        style: context.bodySmall.copyWith(
                color: context.secondaryTextColor,
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
      width: 200, // Fixed width for horizontal scrolling
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: context.grey300,
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
                        context.grey300,
                        context.grey200,
                        context.grey300,
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
                      color: context.grey400,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 12,
                    width: 80,
                    decoration: BoxDecoration(
                      color: context.grey400,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 10,
                    width: 60,
                    decoration: BoxDecoration(
                      color: context.grey400,
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
        width: 200, // Fixed width for horizontal scrolling
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
                child: FadeInNetworkImage(
                  imageUrl: eventDetails.flyer,
                  fit: BoxFit.cover,
                  placeholderColor: context.grey300,
                  errorWidget: Container(
                    color: context.grey300,
                    child: Icon(
                      Icons.event,
                      color: context.grey400,
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
                        style: context.bodySmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        timeText,
                        style: context.labelSmall.copyWith(
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
      width: 200, // Fixed width for horizontal scrolling
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
                    color: context.grey300,
                    child: Icon(
                      Icons.image,
                      color: context.grey400,
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
                      style: context.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: context.bodySmall.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      time,
                      style: context.labelSmall.copyWith(
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
    // Ensure categories exist before showing the bottom sheet
    final categoriesService = ref.read(categoriesServiceProvider);
    categoriesService.ensureCategoriesExist().catchError((e) {
      // Silently handle errors - categories might already exist
      debugPrint('Note: Category registration check: $e');
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.grey50, // Match quick actions background
      builder: (context) => Container(
        padding: const EdgeInsets.all(12),
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
                  color: context.grey300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Title
            Text(
              'All Categories',
              style: context.headlineSmall.copyWith(
                fontWeight: FontWeight.w600,
                color: context.primaryTextColor,
              ),
            ),
            const SizedBox(height: 20),
            // Categories grid
            Consumer(
              builder: (context, ref, child) {
                final categoriesAsync = ref.watch(categoriesProvider);
                
                // If we have previous data, show it while silently refreshing
                if (categoriesAsync.hasValue && categoriesAsync.value != null) {
                  final categories = categoriesAsync.value!;
                  // Filter to only show parent categories (no parentId)
                  final parentCategories = categories
                      .where((cat) => 
                          cat['isActive'] == true && 
                          (cat['parentId'] == null || cat['parentId'] == ''))
                      .toList()
                    ..sort((a, b) => (a['sortOrder'] as int? ?? 0).compareTo(b['sortOrder'] as int? ?? 0));
                  
                  if (parentCategories.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          'No categories available',
                          style: context.bodyMedium.copyWith(
                            color: context.secondaryTextColor,
                          ),
                        ),
                      ),
                    );
                  }
                  
                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.4,
                    children: parentCategories.map((category) {
                      return _buildBottomSheetCategoryCardFromApi(category);
                    }).toList(),
                  );
                }
                
                // Only show loading state if we don't have previous data
                return categoriesAsync.when(
                  data: (categories) {
                    // Filter to only show parent categories (no parentId)
                    final parentCategories = categories
                        .where((cat) => 
                            cat['isActive'] == true && 
                            (cat['parentId'] == null || cat['parentId'] == ''))
                        .toList()
                      ..sort((a, b) => (a['sortOrder'] as int? ?? 0).compareTo(b['sortOrder'] as int? ?? 0));
                    
                    if (parentCategories.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                            'No categories available',
                            style: context.bodyMedium.copyWith(
                              color: context.secondaryTextColor,
                            ),
                          ),
                        ),
                      );
                    }
                    
                    return GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.4,
                      children: parentCategories.map((category) {
                        return _buildBottomSheetCategoryCardFromApi(category);
                      }).toList(),
                    );
                  },
                  loading: () => Center(child: CircularProgressIndicator(color: context.primaryColorTheme)),
                  error: (error, stack) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Failed to load categories',
                            style: context.bodyMedium.copyWith(
                              color: context.errorColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              ref.invalidate(categoriesProvider);
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: context.primaryColorTheme,
                            ),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            
            // Add bottom padding for safe area
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSheetCategoryCardFromApi(Map<String, dynamic> category) {
    final name = category['name'] as String? ?? 'Category';
    final slug = category['slug'] as String? ?? '';
    final iconName = category['icon'] as String?;
    final icon = _getIconForCategory(iconName);

    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        // Navigate to Stay tab if Accommodation category
        if (slug == 'accommodation' || name.toLowerCase() == 'accommodation') {
          context.go('/accommodation');
        } 
        // Navigate to Events screen if Events category
        else if (slug == 'events' || name.toLowerCase() == 'events') {
          context.go('/events');
        } 
        else if (slug.isNotEmpty) {
          context.push('/category/$slug');
        } else {
          context.push('/category/${name.toLowerCase().replaceAll(' ', '-')}');
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: context.grey200,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: context.primaryColorTheme,
              size: 22,
            ),
            const SizedBox(height: 6),
            Text(
              name,
              style: context.bodySmall.copyWith(
                color: context.primaryTextColor,
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

  Widget _buildBottomSheetCategoryCard({
    required IconData icon,
    required String label,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        context.push('/category/${label.toLowerCase()}');
      },
      child: Container(
        decoration: BoxDecoration(
          color: context.cardColor, // Match quick actions background
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: context.grey200, // Match quick actions border
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: context.primaryColorTheme, // Match quick actions icon color
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: context.bodySmall.copyWith(
                color: context.primaryTextColor, // Match quick actions text color
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
    return Consumer(
      builder: (context, ref, child) {
        final selectedCountry = ref.watch(selectedCountryProvider).value;
        // Try with country filter first, if empty, fallback to all featured listings
        final featuredAsync = ref.watch(featuredListingsProvider(selectedCountry?.id));
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recommended',
                  style: context.headlineMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.primaryTextColor,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    context.push('/recommendations');
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: context.primaryColorTheme,
                  ),
                  child: const Text(
                    'View More',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: featuredAsync.when(
                data: (listings) {
                  if (listings.isEmpty) {
                    // If no listings for selected country, try without country filter
                    final allFeaturedAsync = ref.watch(featuredListingsProvider(null));
                    return allFeaturedAsync.when(
                      data: (allListings) {
                        if (allListings.isEmpty) {
                          return Center(
                            child: Text(
                              'No featured listings available',
                              style: context.bodyMedium.copyWith(
                                color: context.secondaryTextColor,
                              ),
                            ),
                          );
                        }
                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: allListings.length > 5 ? 5 : allListings.length,
                          itemBuilder: (context, index) {
                            return _buildRecommendCardFromData(allListings[index]);
                          },
                        );
                      },
                      loading: () => ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 3,
                        itemBuilder: (context, index) {
                          return _buildSkeletonRecommendCard();
                        },
                      ),
                      error: (error, stack) => Center(
                        child: Text(
                          'No featured listings',
                          style: context.bodyMedium.copyWith(
                            color: context.secondaryTextColor,
                          ),
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: listings.length > 5 ? 5 : listings.length,
                    itemBuilder: (context, index) {
                      return _buildRecommendCardFromData(listings[index]);
                    },
                  );
                },
                loading: () => ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    return _buildSkeletonRecommendCard();
                  },
                ),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: context.errorColor,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Failed to load recommendations',
                        style: context.bodyMedium.copyWith(
                          color: context.errorColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          error.toString(),
                          style: context.bodySmall.copyWith(
                            color: context.secondaryTextColor,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton.icon(
                        onPressed: () {
                          ref.invalidate(featuredListingsProvider(selectedCountry?.id));
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                        style: TextButton.styleFrom(
                          foregroundColor: context.primaryColorTheme,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecommendCardFromData(Map<String, dynamic> listing) {
    // Extract image URL
    String? imageUrl;
    if (listing['images'] != null && listing['images'] is List && (listing['images'] as List).isNotEmpty) {
      final firstImage = (listing['images'] as List).first;
      if (firstImage is Map && firstImage['media'] != null) {
        imageUrl = firstImage['media']['url'] ?? firstImage['media']['thumbnailUrl'];
      }
    }

    // Extract data
    final name = listing['name'] ?? 'Unknown';
    final address = listing['address'] ?? listing['city']?['name'] ?? '';
    final rating = listing['rating'] != null 
        ? (listing['rating'] is String 
            ? double.tryParse(listing['rating']) 
            : listing['rating']?.toDouble())
        : 0.0;
    final category = listing['category']?['name'] ?? listing['type'] ?? 'Place';
    final id = listing['id'] ?? '';

    return GestureDetector(
      onTap: () {
        context.push('/listing/$id');
      },
      child: Container(
        width: 160, // Fixed width for horizontal scrolling
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: context.cardColor,
          boxShadow: [
            BoxShadow(
              color: context.isDarkMode 
                  ? Colors.black.withOpacity(0.3)
                  : Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Container(
              height: 100,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                color: context.grey200,
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: imageUrl != null
                        ? FadeInNetworkImage(
                            imageUrl: imageUrl,
                            width: double.infinity,
                            height: 100,
                            fit: BoxFit.cover,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                            errorWidget: Container(
                              height: 100,
                              color: context.grey200,
                              child: Icon(Icons.image, color: context.secondaryTextColor),
                            ),
                          )
                        : Container(
                            height: 100,
                            color: context.grey200,
                            child: Icon(Icons.image, color: context.secondaryTextColor),
                          ),
                  ),
                  // Category badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: context.primaryColorTheme,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        category,
                        style: context.bodySmall.copyWith(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  // Rating
                  if (rating > 0)
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
                              rating.toStringAsFixed(1),
                              style: context.bodySmall.copyWith(
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
                    name,
                    style: context.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.primaryTextColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  if (address.isNotEmpty)
                    Text(
                      address,
                      style: context.bodySmall.copyWith(
                        color: context.secondaryTextColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          category,
                          style: context.bodySmall.copyWith(
                            color: context.primaryColorTheme,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Consumer(
                        builder: (context, ref, child) {
                          final isFavoritedAsync = ref.watch(isListingFavoritedProvider(id));
                          
                          return GestureDetector(
                            onTap: () async {
                              try {
                                final favoritesService = ref.read(favoritesServiceProvider);
                                await favoritesService.toggleFavorite(listingId: id);
                                
                                ref.invalidate(isListingFavoritedProvider(id));
                                ref.invalidate(favoritesProvider(const FavoritesParams(page: 1, limit: 20)));
                                
                                if (context.mounted) {
                                  final isFavorited = isFavoritedAsync.value ?? false;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    AppTheme.successSnackBar(
                                      message: isFavorited 
                                          ? AppConfig.favoriteRemovedMessage 
                                          : AppConfig.favoriteAddedMessage,
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    AppTheme.errorSnackBar(
                                      message: 'Failed to update favorite: ${e.toString().replaceFirst('Exception: ', '')}',
                                    ),
                                  );
                                }
                              }
                            },
                            child: isFavoritedAsync.when(
                              data: (isFavorited) => Icon(
                                isFavorited ? Icons.favorite : Icons.favorite_border,
                                color: isFavorited ? Colors.red : context.secondaryTextColor,
                                size: 16,
                              ),
                              loading: () => Icon(
                                Icons.favorite_border,
                                color: context.secondaryTextColor,
                                size: 16,
                              ),
                              error: (_, __) => Icon(
                                Icons.favorite_border,
                                color: context.secondaryTextColor,
                                size: 16,
                              ),
                            ),
                          );
                        },
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

  Widget _buildSkeletonRecommendCard() {
    return Container(
      width: 160, // Fixed width for horizontal scrolling
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: context.grey300,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 100,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              color: context.grey300,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 16,
                  width: 120,
                  decoration: BoxDecoration(
                    color: context.grey400,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 12,
                  width: 80,
                  decoration: BoxDecoration(
                    color: context.grey400,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNearMeSection() {
    return Consumer(
      builder: (context, ref, child) {
        // Use random listings for now until geolocation is implemented
        final nearbyAsync = ref.watch(randomListingsProvider(5));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Near Me',
                  style: context.headlineMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.primaryTextColor,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    context.push('/map');
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: context.primaryColorTheme,
                  ),
                  child: const Text(
                    'View Map',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            nearbyAsync.when(
              data: (listings) {
                if (listings.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        'No listings available',
                        style: context.bodyMedium.copyWith(
                          color: context.secondaryTextColor,
                        ),
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: listings.length,
                  itemBuilder: (context, index) {
                    return _buildNearMeCardFromData(listings[index]);
                  },
                );
              },
              loading: () => ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 3,
                itemBuilder: (context, index) {
                  return _buildSkeletonNearMeCard();
                },
              ),
              error: (error, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    'Failed to load listings',
                    style: context.bodySmall.copyWith(
                      color: context.errorColor,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNearMeCardFromData(Map<String, dynamic> listing) {
    // Extract image URL
    String? imageUrl;
    if (listing['images'] != null && listing['images'] is List && (listing['images'] as List).isNotEmpty) {
      final firstImage = (listing['images'] as List).first;
      if (firstImage is Map && firstImage['media'] != null) {
        imageUrl = firstImage['media']['url'] ?? firstImage['media']['thumbnailUrl'];
      }
    }

    // Extract data
    final name = listing['name'] ?? 'Unknown';
    final address = listing['address'] ?? listing['city']?['name'] ?? '';
    final category = listing['category']?['name'] ?? listing['type'] ?? 'Place';
    final id = listing['id'] ?? '';

    return GestureDetector(
      onTap: () {
        context.push('/listing/$id');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: context.backgroundColor,
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
              child: imageUrl != null
                  ? FadeInNetworkImage(
                      imageUrl: imageUrl,
                      height: 80,
                      width: 80,
                      fit: BoxFit.cover,
                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                      errorWidget: Container(
                        height: 80,
                        width: 80,
                        color: context.dividerColor,
                        child: const Icon(Icons.image_not_supported),
                      ),
                    )
                  : Container(
                      height: 80,
                      width: 80,
                      color: context.dividerColor,
                      child: const Icon(Icons.image_not_supported),
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
                      name,
                      style: context.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.primaryTextColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    
                    // Address and Category
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 12,
                          color: context.secondaryTextColor,
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            address,
                            style: context.bodySmall.copyWith(
                              color: context.secondaryTextColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: context.primaryColorTheme.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            category,
                            style: context.labelSmall.copyWith(
                              color: context.primaryColorTheme,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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

  Widget _buildSkeletonNearMeCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: context.grey300,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            height: 80,
            width: 80,
            color: context.grey400,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    width: 150,
                    decoration: BoxDecoration(
                      color: context.grey400,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 12,
                    width: 100,
                    decoration: BoxDecoration(
                      color: context.grey400,
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

  Widget _buildTourPackagesSection() {
    return Consumer(
      builder: (context, ref, child) {
        final toursAsync = ref.watch(toursProvider(const ToursParams(
          page: 1,
          limit: 5, // Show only 5 tours on explore screen
          status: 'active',
        )));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tour Packages',
                  style: context.headlineMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.primaryTextColor,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    context.push('/tour-packages');
                  },
                  child: Text(
                    'View All',
                    style: context.bodySmall.copyWith(
                      color: context.primaryColorTheme,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            toursAsync.when(
              loading: () => ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 3,
                itemBuilder: (context, index) {
                  return _buildTourCardSkeleton();
                },
              ),
              error: (error, stack) => Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.errorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: context.errorColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Failed to load tours',
                        style: context.bodyMedium.copyWith(
                          color: context.errorColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              data: (response) {
                final tours = (response['data'] as List?)?.cast<Map<String, dynamic>>() ?? [];
                
                if (tours.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: context.dividerColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.tour_outlined, color: context.secondaryTextColor),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'No tour packages available',
                            style: context.bodyMedium.copyWith(
                              color: context.secondaryTextColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: tours.length,
                  itemBuilder: (context, index) {
                    final tour = tours[index];
                    return _buildTourCard(tour);
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildTourCard(Map<String, dynamic> tour) {
    final String title = tour['name'] ?? 'Untitled Tour';
    final String description = tour['description'] ?? '';
    
    // Parse price safely
    double? priceFrom;
    try {
      final priceValue = tour['pricePerPerson'];
      if (priceValue != null) {
        if (priceValue is num) {
          priceFrom = priceValue.toDouble();
        } else if (priceValue is String) {
          priceFrom = double.tryParse(priceValue);
        }
      }
    } catch (e) {
      priceFrom = null;
    }
    
    final String? coverImageUrl = tour['images']?[0]?['media']?['url'];
    final String? difficulty = tour['difficultyLevel'];
    
    // Parse duration safely - handle both String and num types
    int? duration;
    final durationDaysValue = tour['durationDays'];
    final durationHoursValue = tour['durationHours'];
    
    if (durationDaysValue != null) {
      if (durationDaysValue is num) {
        duration = durationDaysValue.toInt();
      } else if (durationDaysValue is String) {
        duration = int.tryParse(durationDaysValue);
      }
    } else if (durationHoursValue != null) {
      if (durationHoursValue is num) {
        duration = durationHoursValue.toInt();
      } else if (durationHoursValue is String) {
        duration = int.tryParse(durationHoursValue);
      }
    }
    
    final String? durationType = tour['durationDays'] != null ? 'day' : (tour['durationHours'] != null ? 'hour' : null);
    final bool isFeatured = tour['isFeatured'] ?? false;

    // Determine badge
    String badge = 'TOUR';
    if (isFeatured) {
      badge = 'FEATURED';
    } else if (difficulty != null) {
      badge = difficulty.toUpperCase();
    }

    // Format price
    final formatter = NumberFormat('#,###', 'en_US');
    String priceText = 'From RWF ${priceFrom != null ? formatter.format(priceFrom) : '---'}';

    // Format duration
    String durationText = '';
    if (duration != null && durationType != null) {
      durationText = '$duration ${durationType}${duration > 1 ? 's' : ''}';
    }

    return GestureDetector(
      onTap: () {
        final slug = tour['slug'];
        if (slug != null) {
          context.push('/tour/$slug');
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: context.isDarkMode 
                  ? Colors.black.withOpacity(0.3)
                  : Colors.black.withOpacity(0.05),
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
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: context.primaryColorTheme.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        badge,
                        style: context.labelSmall.copyWith(
                          color: context.primaryColorTheme,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Title
                    Text(
                      title,
                      style: context.headlineSmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: context.primaryTextColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    
                    // Description
                    Text(
                      description,
                      style: context.bodyMedium.copyWith(
                        color: context.secondaryTextColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    
                    // Duration (if available)
                    if (durationText.isNotEmpty) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.schedule_outlined,
                            size: 14,
                            color: context.secondaryTextColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            durationText,
                            style: context.bodySmall.copyWith(
                              color: context.secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                    
                    // Price
                    Text(
                      priceText,
                      style: context.titleMedium.copyWith(
                        color: context.primaryColorTheme,
                        fontWeight: FontWeight.w700,
                      ),
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
                  child: coverImageUrl != null
                      ? FadeInNetworkImage(
                          imageUrl: coverImageUrl,
                          fit: BoxFit.cover,
                          placeholderColor: context.dividerColor,
                          errorWidget: Container(
                            color: context.dividerColor,
                            child: Icon(
                              Icons.tour_outlined,
                              color: context.secondaryTextColor,
                            ),
                          ),
                        )
                      : Container(
                          color: context.dividerColor,
                          child: Icon(
                            Icons.tour_outlined,
                            color: context.secondaryTextColor,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTourCardSkeleton() {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: context.isDarkMode 
                    ? Colors.black.withOpacity(0.3)
                    : Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Left content skeleton
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge skeleton
                      Container(
                        height: 20,
                        width: 60,
                        decoration: BoxDecoration(
                          color: context.grey300,
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              context.grey300,
                              context.grey200,
                              context.grey300,
                            ],
                            stops: [
                              0.0,
                              _shimmerAnimation.value,
                              1.0,
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Title skeleton
                      Container(
                        height: 18,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: context.grey300,
                          borderRadius: BorderRadius.circular(4),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              context.grey300,
                              context.grey200,
                              context.grey300,
                            ],
                            stops: [
                              0.0,
                              _shimmerAnimation.value,
                              1.0,
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 18,
                        width: 200,
                        decoration: BoxDecoration(
                          color: context.grey300,
                          borderRadius: BorderRadius.circular(4),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              context.grey300,
                              context.grey200,
                              context.grey300,
                            ],
                            stops: [
                              0.0,
                              _shimmerAnimation.value,
                              1.0,
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Description skeleton
                      Container(
                        height: 14,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: context.grey200,
                          borderRadius: BorderRadius.circular(4),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              context.grey200,
                              context.grey100,
                              context.grey200,
                            ],
                            stops: [
                              0.0,
                              _shimmerAnimation.value,
                              1.0,
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 14,
                        width: 150,
                        decoration: BoxDecoration(
                          color: context.grey200,
                          borderRadius: BorderRadius.circular(4),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              context.grey200,
                              context.grey100,
                              context.grey200,
                            ],
                            stops: [
                              0.0,
                              _shimmerAnimation.value,
                              1.0,
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Duration skeleton
                      Row(
                        children: [
                          Container(
                            height: 14,
                            width: 14,
                            decoration: BoxDecoration(
                              color: context.grey200,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            height: 12,
                            width: 60,
                            decoration: BoxDecoration(
                              color: context.grey200,
                              borderRadius: BorderRadius.circular(4),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  context.grey200,
                                  context.grey100,
                                  context.grey200,
                                ],
                                stops: [
                                  0.0,
                                  _shimmerAnimation.value,
                                  1.0,
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      // Price skeleton
                      Container(
                        height: 20,
                        width: 120,
                        decoration: BoxDecoration(
                          color: context.grey300,
                          borderRadius: BorderRadius.circular(4),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              context.grey300,
                              context.grey200,
                              context.grey300,
                            ],
                            stops: [
                              0.0,
                              _shimmerAnimation.value,
                              1.0,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Right content - Image skeleton
              Expanded(
                flex: 1,
                child: Container(
                  height: 140,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.horizontal(right: Radius.circular(16)),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        context.grey300,
                        context.grey200,
                        context.grey300,
                      ],
                      stops: [
                        0.0,
                        _shimmerAnimation.value,
                        1.0,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Keep old specials section commented out for now
  /*
  Widget _buildSpecialsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Special Offers',
              style: context.headlineMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: context.primaryTextColor,
              ),
            ),
            TextButton(
              onPressed: () {
                context.push('/specials');
              },
              child: Text(
                'View All',
                style: context.bodySmall.copyWith(
                  color: context.primaryColorTheme,
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
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: context.isDarkMode 
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
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
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: context.primaryColorTheme.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      special['badge'],
                      style: context.labelSmall.copyWith(
                        color: context.primaryColorTheme,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Title
                  Text(
                    special['title'],
                    style: context.headlineSmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: context.primaryTextColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  
                  // Description
                  Text(
                    special['description'],
                    style: context.bodyMedium.copyWith(
                      color: context.secondaryTextColor,
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
                            style: context.bodySmall.copyWith(
                              color: context.secondaryTextColor,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            special['discountedPrice'],
                            style: context.titleMedium.copyWith(
                              color: context.primaryColorTheme,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: context.successColor.withOpacity(0.1), // Success color is intentional
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          special['discount'],
                          style: context.labelSmall.copyWith(
                            color: context.successColor, // Success color is intentional
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
                child: FadeInNetworkImage(
                  imageUrl: special['image'],
                  fit: BoxFit.cover,
                  placeholderColor: context.dividerColor,
                  errorWidget: Container(
                    color: context.dividerColor,
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
  */

  void _showGiftBoxMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: context.secondaryTextColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Menu items
            _buildGiftBoxMenuItem(
              context: context,
              icon: Icons.card_giftcard,
              title: 'Refer & Earn',
              subtitle: 'Invite friends and earn rewards',
              onTap: () {
                Navigator.pop(context);
                context.push('/referrals');
              },
            ),
            const Divider(height: 1),
            _buildGiftBoxMenuItem(
              context: context,
              icon: Icons.route,
              title: 'Itinerary Planning',
              subtitle: 'Plan and share your trip',
              onTap: () {
                Navigator.pop(context);
                context.push('/itineraries');
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildGiftBoxMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: context.primaryColorTheme.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: context.primaryColorTheme,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: context.titleMedium.copyWith(
          fontWeight: FontWeight.w600,
          color: context.primaryTextColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: context.bodySmall.copyWith(
          color: context.secondaryTextColor,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: context.secondaryTextColor,
      ),
      onTap: onTap,
    );
  }
}