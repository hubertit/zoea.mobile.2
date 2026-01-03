import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/theme/text_theme_extensions.dart';
import '../../../core/config/app_config.dart';
import '../../../core/providers/listings_provider.dart';
import '../../../core/providers/favorites_provider.dart';
import '../../../core/providers/reviews_provider.dart';
import '../../../core/providers/products_provider.dart' show productsByListingProvider, ProductsParams;
import '../../../core/providers/services_provider.dart' show servicesProvider, ServicesParams;
import '../../../core/providers/menus_provider.dart' show menusByListingProvider;
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/widgets/fade_in_image.dart' show FadeInNetworkImage;

/// Helper class to hold shop tabs data
class _ShopTabsData {
  final List<Tab> tabs;
  final List<Widget> children;

  _ShopTabsData({required this.tabs, required this.children});
}

class ListingDetailScreen extends ConsumerStatefulWidget {
  final String listingId;

  const ListingDetailScreen({
    super.key,
    required this.listingId,
  });

  @override
  ConsumerState<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends ConsumerState<ListingDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  bool _isScrolled = false;
  int _previousTabCount = 4;

  @override
  void initState() {
    super.initState();
    // Initial tab count (will be updated when listing data loads)
    _tabController = TabController(length: 4, vsync: this);
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _updateTabController(int tabCount) {
    if (_previousTabCount != tabCount) {
      _previousTabCount = tabCount;
      _tabController.dispose();
      _tabController = TabController(length: tabCount, vsync: this);
    }
  }

  void _onScroll() {
    if (_scrollController.offset > 200 && !_isScrolled) {
      setState(() {
        _isScrolled = true;
      });
    } else if (_scrollController.offset <= 200 && _isScrolled) {
      setState(() {
        _isScrolled = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listingAsync = ref.watch(listingByIdProvider(widget.listingId));

    return Scaffold(
      backgroundColor: context.grey50,
      body: listingAsync.when(
        data: (listing) => _buildContent(listing),
        loading: () => Center(child: CircularProgressIndicator(color: context.primaryColorTheme)),
        error: (error, stack) => _buildErrorState(error),
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Scaffold(
      backgroundColor: context.grey50,
      appBar: AppBar(
        backgroundColor: context.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 32),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: context.errorColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load listing',
              style: context.headlineSmall.copyWith(
                color: context.errorColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString().replaceFirst('Exception: ', ''),
              style: context.bodyMedium.copyWith(
                color: context.secondaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(listingByIdProvider(widget.listingId));
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(Map<String, dynamic> listing) {
    // Extract images
    final images = listing['images'] as List? ?? [];
    final primaryImage = images.isNotEmpty && images[0]['media'] != null
        ? images[0]['media']['url']
        : null;

    // Extract basic info
    final name = listing['name'] ?? 'Unknown';
    final description = listing['description'] ?? listing['shortDescription'] ?? '';
    final address = listing['address'] ?? listing['city']?['name'] ?? 'Kigali, Rwanda';
    final rating = listing['rating'] != null
        ? (listing['rating'] is String
            ? double.tryParse(listing['rating'])
            : listing['rating']?.toDouble())
        : 0.0;
    final reviewCount = listing['reviewCount'] ?? listing['_count']?['reviews'] ?? 0;
    final minPrice = listing['minPrice'];
    final maxPrice = listing['maxPrice'];
    final currency = listing['currency'] ?? 'RWF';
    final isVerified = listing['isVerified'] == true;
    final contactPhone = listing['contactPhone'];
    final operatingHours = listing['operatingHours'] as Map<String, dynamic>?;
    final amenities = listing['amenities'] as List? ?? [];
    final isShopEnabled = listing['isShopEnabled'] == true;

    return Scaffold(
      backgroundColor: context.grey50,
      body: CustomScrollView(
      controller: _scrollController,
      slivers: [
        // App Bar with Image
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          backgroundColor: _isScrolled ? context.backgroundColor : context.backgroundColor,
          leading: IconButton(
            icon: Icon(
              Icons.chevron_left,
              color: _isScrolled ? context.primaryTextColor : Colors.white,
              size: 32,
            ),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/explore');
              }
            },
          ),
          actions: const [], // Buttons moved to flexibleSpace
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                primaryImage != null
                    ? FadeInNetworkImage(
                        imageUrl: primaryImage,
                        fit: BoxFit.cover,
                        errorWidget: Container(
                          color: context.grey200,
                          child: const Icon(Icons.place, size: 100),
                        ),
                      )
                    : Container(
                        color: context.grey200,
                        child: const Icon(Icons.place, size: 100),
                      ),
                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.3),
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
                // Action buttons at top right
                Positioned(
                  top: 50,
                  right: 16,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Favorite button
                      Consumer(
                        builder: (context, ref, child) {
                          final isFavoritedAsync = ref.watch(isListingFavoritedProvider(widget.listingId));
                          final isFavorited = isFavoritedAsync.value ?? false;

                          return Container(
                            width: 36,
                            height: 36,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: Icon(
                                isFavorited ? Icons.favorite : Icons.favorite_border,
                                color: isFavorited ? context.errorColor : Colors.white, // White on dark overlay is intentional
                                size: 18,
                              ),
                              padding: EdgeInsets.zero,
                              onPressed: () async {
                                try {
                                  final favoritesService = ref.read(favoritesServiceProvider);
                                  
                                  // Use toggleFavorite for add/remove in one call
                                  await favoritesService.toggleFavorite(listingId: widget.listingId);
                                  
                                  // Invalidate to refresh
                                  ref.invalidate(isListingFavoritedProvider(widget.listingId));
                                  ref.invalidate(favoritesProvider(const FavoritesParams(page: 1, limit: 20)));
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      AppTheme.successSnackBar(
                                        message: isFavorited 
                                            ? AppConfig.favoriteRemovedMessage 
                                            : AppConfig.favoriteAddedMessage,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      AppTheme.errorSnackBar(
                                        message: 'Failed to update favorite: ${e.toString().replaceFirst('Exception: ', '')}',
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                          );
                        },
                      ),
                      // Review button
                      Container(
                        width: 36,
                        height: 36,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.rate_review,
                            color: Colors.white, // White on dark overlay is intentional
                            size: 18,
                          ),
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            _showReviewBottomSheet();
                          },
                        ),
                      ),
                      // Share button
                      Consumer(
                        builder: (context, ref, child) {
                          return Container(
                            width: 36,
                            height: 36,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.share,
                                color: Colors.white, // White on dark overlay is intentional
                                size: 18,
                              ),
                              padding: EdgeInsets.zero,
                              onPressed: () async {
                                final listingAsync = ref.read(listingByIdProvider(widget.listingId));
                                listingAsync.whenData((listing) async {
                                  final name = listing['name'] as String? ?? 'Listing';
                                  final address = listing['address'] as String? ?? '';
                                  final city = listing['city'] as Map<String, dynamic>?;
                                  final cityName = city?['name'] as String? ?? '';
                                  final location = address.isNotEmpty 
                                      ? '$address${cityName.isNotEmpty ? ', $cityName' : ''}'
                                      : cityName;
                                  
                                  final shareText = 'Check out $name${location.isNotEmpty ? ' in $location' : ''} on Zoea!';
                                  final shareUrl = '${AppConfig.apiBaseUrl.replaceAll('/api', '')}/listings/${widget.listingId}';
                                  
                                  await SharePlus.instance.share(ShareParams(text: '$shareText\n$shareUrl'));
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Content
        SliverToBoxAdapter(
          child: Container(
            color: context.grey50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Listing Info
                Container(
                  color: context.cardColor,
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    name,
                                    style: context.headlineMedium.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: context.primaryTextColor,
                                    ),
                                  ),
                                ),
                                if (isVerified) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: context.primaryColorTheme.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.verified,
                                          size: 14,
                                          color: context.primaryColorTheme,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Verified',
                                          style: context.bodySmall.copyWith(
                                            color: context.primaryColorTheme,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 18,
                            color: context.secondaryTextColor,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              address,
                              style: context.bodyLarge.copyWith(
                                color: context.secondaryTextColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          if (rating > 0) ...[
                            const Icon(
                              Icons.star,
                              size: 18,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              rating.toStringAsFixed(1),
                              style: context.bodyLarge.copyWith(
                                fontWeight: FontWeight.w600,
                                color: context.primaryTextColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '($reviewCount reviews)',
                              style: context.bodyMedium.copyWith(
                                color: context.secondaryTextColor,
                              ),
                            ),
                          ],
                          const Spacer(),
                          if (minPrice != null)
                            Text(
                              '$currency ${minPrice.toString()}${maxPrice != null ? ' - ${maxPrice.toString()}' : ''}',
                              style: context.bodyLarge.copyWith(
                                color: context.primaryColorTheme,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Tabs - dynamically built based on available shop content
                Builder(
                  builder: (context) {
                    final shopTabs = _buildShopTabs(context, isShopEnabled);
                    final allTabs = [
                      const Tab(text: 'Overview'),
                      ...shopTabs.tabs,
                      const Tab(text: 'Reviews'),
                      const Tab(text: 'Photos'),
                      const Tab(text: 'Amenities'),
                    ];
                    
                    // Update tab controller with correct count
                    _updateTabController(allTabs.length);
                    
                    return Container(
                      color: context.cardColor,
                      child: TabBar(
                        controller: _tabController,
                        labelColor: context.primaryColorTheme,
                        unselectedLabelColor: context.secondaryTextColor,
                        indicatorColor: context.primaryColorTheme,
                        isScrollable: allTabs.length > 4, // Make scrollable if we have many tabs
                        tabs: allTabs,
                      ),
                    );
                  },
                ),
                // Tab Content - dynamically built based on available shop content
                Builder(
                  builder: (context) {
                    final shopTabs = _buildShopTabs(context, isShopEnabled);
                    final allChildren = [
                      _buildOverviewTab(listing, description, operatingHours),
                      ...shopTabs.children,
                      _buildReviewsTab(listing['id'] ?? widget.listingId),
                      _buildPhotosTab(images),
                      _buildAmenitiesTab(amenities),
                    ];
                    
                    return Container(
                      height: 400,
                      color: context.backgroundColor,
                      child: TabBarView(
                        controller: _tabController,
                        children: allChildren,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
      ),
      bottomNavigationBar: _buildBottomBar(listing, contactPhone),
    );
  }

  Widget _buildOverviewTab(
    Map<String, dynamic> listing,
    String description,
    Map<String, dynamic>? operatingHours,
  ) {
    // Extract location details
    final address = listing['address'] as String? ?? '';
    final city = listing['city'] as Map<String, dynamic>?;
    final cityName = city?['name'] as String? ?? '';
    final country = listing['country'] as Map<String, dynamic>?;
    final countryName = country?['name'] as String? ?? '';
    final locationText = address.isNotEmpty
        ? '$address${cityName.isNotEmpty ? ', $cityName' : ''}${countryName.isNotEmpty && cityName.isEmpty ? ', $countryName' : ''}'
        : cityName.isNotEmpty
            ? '$cityName${countryName.isNotEmpty ? ', $countryName' : ''}'
            : countryName.isNotEmpty
                ? countryName
                : 'Location not available';
    
    // Extract contact info
    final contactPhone = listing['contactPhone'] as String?;
    final contactEmail = listing['contactEmail'] as String?;
    final website = listing['website'] as String?;
    
    // Extract category and type
    final category = listing['category'] as Map<String, dynamic>?;
    final categoryName = category?['name'] as String?;
    final listingType = listing['type'] as String?;
    
    // Generate description if missing
    final displayDescription = description.isNotEmpty
        ? description
        : categoryName != null
            ? 'Experience ${categoryName.toLowerCase()}${listingType != null ? ' - $listingType' : ''} in ${cityName.isNotEmpty ? cityName : countryName.isNotEmpty ? countryName : 'Rwanda'}.'
            : '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // About/Description Section
          if (displayDescription.isNotEmpty) ...[
            Text(
              'About',
              style: context.headlineSmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              displayDescription,
              style: context.bodyMedium.copyWith(
                height: 1.6,
                color: context.secondaryTextColor,
              ),
            ),
            const SizedBox(height: 24),
          ],
          
          // Location Section
          Text(
            'Location',
            style: context.headlineSmall.copyWith(
              fontWeight: FontWeight.w600,
              color: context.primaryTextColor,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.location_on,
                size: 20,
                color: context.secondaryTextColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  locationText,
                  style: context.bodyMedium.copyWith(
                    color: context.secondaryTextColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (operatingHours != null) ...[
            Text(
              'Opening Hours',
              style: context.headlineSmall.copyWith(
                fontWeight: FontWeight.w600,
                color: context.primaryTextColor,
              ),
            ),
            const SizedBox(height: 12),
            ...operatingHours.entries.map<Widget>((entry) {
              final day = entry.key;
              final hours = entry.value as Map<String, dynamic>?;
              final isClosed = hours?['closed'] == true;
              final open = hours?['open'] ?? '';
              final close = hours?['close'] ?? '';

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 100,
                      child:                       Text(
                        day[0].toUpperCase() + day.substring(1),
                        style: context.bodyMedium.copyWith(
                          fontWeight: FontWeight.w500,
                          color: context.primaryTextColor,
                        ),
                      ),
                    ),
                    Text(
                      isClosed ? 'Closed' : '$open - $close',
                      style: context.bodyMedium.copyWith(
                        color: isClosed
                            ? context.errorColor
                            : context.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
          // Contact Information Section
          if (contactPhone != null || contactEmail != null || website != null) ...[
            Text(
              'Contact Information',
              style: context.headlineSmall.copyWith(
                fontWeight: FontWeight.w600,
                color: context.primaryTextColor,
              ),
            ),
            const SizedBox(height: 12),
            if (contactPhone != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.phone,
                      size: 20,
                      color: context.secondaryTextColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        contactPhone,
                        style: context.bodyMedium.copyWith(
                          color: context.primaryTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (contactEmail != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.email,
                      size: 20,
                      color: context.secondaryTextColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        contactEmail,
                        style: context.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            if (website != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.language,
                      size: 20,
                      color: context.secondaryTextColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final uri = Uri.parse(website);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                AppTheme.errorSnackBar(
                                  message: 'Could not open website: $website',
                                ),
                              );
                            }
                          }
                        },
                        child: Text(
                          website,
                          style: context.bodyMedium.copyWith(
                            color: context.primaryColorTheme,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }

  Widget _buildAmenitiesTab(List amenities) {
    // Extract amenity data from nested structure
    final amenityList = amenities
        .map((item) {
          if (item is Map<String, dynamic>) {
            // API returns: { listingId, amenityId, amenity: { id, name, icon, description, category } }
            final amenity = item['amenity'] as Map<String, dynamic>?;
            if (amenity != null) {
              return {
                'name': amenity['name'] as String? ?? '',
                'icon': amenity['icon'] as String?,
                'description': amenity['description'] as String?,
                'category': amenity['category'] as String?,
              };
            }
            // Fallback: try direct access (for backward compatibility)
            if (item['name'] != null) {
              return {
                'name': item['name'] as String? ?? '',
                'icon': item['icon'] as String?,
                'description': item['description'] as String?,
                'category': item['category'] as String?,
              };
            }
          }
          return null;
        })
        .whereType<Map<String, dynamic>>()
        .where((a) => a['name'] != null && (a['name'] as String).isNotEmpty)
        .toList();

    if (amenityList.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.hotel_outlined,
                size: 64,
                color: context.secondaryTextColor,
              ),
              const SizedBox(height: 16),
              Text(
                'No amenities listed',
                style: context.headlineSmall.copyWith(
                  color: context.secondaryTextColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Amenities information will be available soon',
                style: context.bodyMedium.copyWith(
                  color: context.secondaryTextColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Group amenities by category if available
    final Map<String, List<Map<String, dynamic>>> groupedAmenities = {};
    for (final amenity in amenityList) {
      final category = amenity['category'] as String? ?? 'general';
      if (!groupedAmenities.containsKey(category)) {
        groupedAmenities[category] = [];
      }
      groupedAmenities[category]!.add(amenity);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Show all amenities in a grid if no categories, or grouped by category
          if (groupedAmenities.length == 1)
            // Single category - show as grid
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: amenityList.map<Widget>((amenity) {
                return _buildAmenityChip(amenity);
              }).toList(),
            )
          else
            // Multiple categories - show grouped
            ...groupedAmenities.entries.map<Widget>((entry) {
              final category = entry.key;
              final categoryAmenities = entry.value;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category[0].toUpperCase() + category.substring(1),
                      style: context.headlineSmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.primaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: categoryAmenities.map<Widget>((amenity) {
                        return _buildAmenityChip(amenity);
                      }).toList(),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildAmenityChip(Map<String, dynamic> amenity) {
    final name = amenity['name'] as String? ?? '';
    final iconName = amenity['icon'] as String?;
    final description = amenity['description'] as String?;
    
    // Map icon names to Material icons
    IconData getIconForName(String? iconName) {
      if (iconName == null) return Icons.star;
      
      switch (iconName.toLowerCase()) {
        case 'wifi':
        case 'wi-fi':
          return Icons.wifi;
        case 'pool':
          return Icons.pool;
        case 'spa':
          return Icons.spa;
        case 'restaurant':
        case 'dining':
          return Icons.restaurant;
        case 'fitness':
        case 'gym':
          return Icons.fitness_center;
        case 'parking':
          return Icons.local_parking;
        case 'business':
          return Icons.business;
        case 'airport':
        case 'shuttle':
          return Icons.airport_shuttle;
        case 'room':
        case 'service':
          return Icons.room_service;
        case 'bar':
          return Icons.local_bar;
        case 'breakfast':
          return Icons.free_breakfast;
        default:
          return Icons.star;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: context.primaryColorTheme.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.primaryColorTheme.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            getIconForName(iconName),
            size: 20,
            color: context.primaryColorTheme,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: context.bodyMedium.copyWith(
                    color: context.primaryColorTheme,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (description != null && description.isNotEmpty)
                  Text(
                    description,
                    style: context.bodySmall.copyWith(
                      color: context.secondaryTextColor,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsTab(String listingId) {
    final reviewsAsync = ref.watch(
      listingReviewsProvider(
        ListingReviewsParams(
          listingId: listingId,
          page: 1,
          limit: 20,
          sortBy: 'newest',
        ),
      ),
    );

    return reviewsAsync.when(
      data: (response) {
        final reviews = response['data'] as List? ?? [];

        if (reviews.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.rate_review_outlined,
                    size: 64,
                    color: context.secondaryTextColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No reviews yet',
                    style: context.headlineSmall.copyWith(
                      color: context.secondaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Be the first to review this place!',
                    style: context.bodyMedium.copyWith(
                      color: context.secondaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      _showReviewBottomSheet();
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Write Review'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Stack(
          children: [
            RefreshIndicator(
              color: context.primaryColorTheme,
              backgroundColor: context.cardColor,
              onRefresh: () async {
                ref.invalidate(
                  listingReviewsProvider(
                    ListingReviewsParams(
                      listingId: listingId,
                      page: 1,
                      limit: 20,
                      sortBy: 'newest',
                    ),
                  ),
                );
              },
              child: ListView.builder(
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,
                  bottom: 100, // Space for FAB
                ),
                itemCount: reviews.length,
                itemBuilder: (context, index) {
                  final review = reviews[index] as Map<String, dynamic>;
                  return _buildReviewCard(review);
                },
              ),
            ),
            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton.extended(
                onPressed: () {
                  _showReviewBottomSheet();
                },
              backgroundColor: AppTheme.primaryColor,
              icon: Icon(Icons.edit, color: Colors.white),
                label: Text(
                  'Write Review',
                  style: TextStyle(color: context.primaryTextColor),
                ),
              ),
            ),
          ],
        );
      },
      loading: () => Center(child: CircularProgressIndicator(color: context.primaryColorTheme)),
      error: (error, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: context.errorColor,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load reviews',
                style: context.headlineSmall.copyWith(
                  color: context.errorColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString().replaceFirst('Exception: ', ''),
                style: context.bodyMedium.copyWith(
                  color: context.secondaryTextColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(
                    listingReviewsProvider(
                      ListingReviewsParams(
                        listingId: listingId,
                        page: 1,
                        limit: 20,
                        sortBy: 'newest',
                      ),
                    ),
                  );
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    final user = review['user'] as Map<String, dynamic>?;
    final userName = user?['fullName'] ?? user?['name'] ?? 'Anonymous';
    final userImageId = user?['profileImageId'];
    final userImage = userImageId != null ? 'https://zoea.africa/catalog/users/$userImageId' : null;
    final rating = review['rating'] as int? ?? 0;
    final content = review['content'] ?? review['comment'] ?? review['text'] ?? '';
    final title = review['title'] as String?;
    final createdAt = review['createdAt'] as String?;
    final helpfulCount = review['helpfulCount'] as int? ?? 0;
    
    String dateText = 'Recently';
    if (createdAt != null) {
      try {
        final date = DateTime.parse(createdAt);
        final now = DateTime.now();
        final difference = now.difference(date);
        
        if (difference.inDays == 0) {
          dateText = 'Today';
        } else if (difference.inDays == 1) {
          dateText = 'Yesterday';
        } else if (difference.inDays < 7) {
          dateText = '${difference.inDays} days ago';
        } else if (difference.inDays < 30) {
          final weeks = (difference.inDays / 7).floor();
          dateText = weeks == 1 ? '1 week ago' : '$weeks weeks ago';
        } else {
          dateText = '${date.day}/${date.month}/${date.year}';
        }
      } catch (e) {
        dateText = 'Recently';
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.grey200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // User Avatar
              CircleAvatar(
                radius: 24,
                backgroundImage: userImage != null
                    ? CachedNetworkImageProvider(userImage)
                    : null,
                child: userImage == null
                    ? Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : 'A',
                        style: context.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: context.primaryTextColor,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: context.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.primaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        ...List.generate(5, (i) {
                          return Icon(
                            i < rating ? Icons.star : Icons.star_border,
                            size: 16,
                            color: Colors.amber,
                          );
                        }),
                        const SizedBox(width: 8),
                        Text(
                          dateText,
                          style: context.bodySmall.copyWith(
                            color: context.secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (title != null && title.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              title,
              style: context.titleSmall.copyWith(
                fontWeight: FontWeight.w600,
                color: context.primaryTextColor,
              ),
            ),
          ],
          if (content.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              content,
              style: context.bodyMedium.copyWith(
                height: 1.4,
                color: context.primaryTextColor,
              ),
            ),
          ],
          if (helpfulCount > 0) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.thumb_up_outlined,
                  size: 16,
                  color: context.secondaryTextColor,
                ),
                const SizedBox(width: 4),
                Text(
                  '$helpfulCount helpful',
                  style: context.bodySmall.copyWith(
                    color: context.secondaryTextColor,
                  ),
                ),
              ],
            ),
          ],
          // Review images if any
          if (review['images'] != null && (review['images'] as List).isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: (review['images'] as List).length,
                itemBuilder: (context, index) {
                  final imageUrl = (review['images'] as List)[index];
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: FadeInNetworkImage(
                        imageUrl: imageUrl is String ? imageUrl : imageUrl['url'] ?? '',
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        borderRadius: BorderRadius.circular(8),
                        errorWidget: Container(
                          width: 80,
                          height: 80,
                          color: context.dividerColor,
                          child: Icon(
                            Icons.image_not_supported,
                            color: context.secondaryTextColor,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProductsTab(String listingId) {
    return Column(
      children: [
        Expanded(
          child: ref.watch(productsByListingProvider(ProductsParams(
            listingId: listingId,
            status: 'active',
            limit: 20,
          ))).when(
            data: (data) {
              final products = (data['data'] as List? ?? [])
                  .map((p) => p as Map<String, dynamic>)
                  .toList();
              
              if (products.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined,
                        size: 48,
                        color: context.secondaryTextColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No products available',
                        style: context.bodyLarge.copyWith(
                          color: context.secondaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          context.push('/products?listingId=$listingId');
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: context.primaryColorTheme,
                        ),
                        child: const Text('View All Products'),
                      ),
                    ],
                  ),
                );
              }
              
              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: context.grey100,
                      child: Icon(
                        Icons.shopping_bag,
                        color: context.secondaryTextColor,
                      ),
                    ),
                    title: Text(
                      product['name'] as String? ?? 'Unknown',
                      style: context.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.primaryTextColor,
                      ),
                    ),
                    subtitle: Text(
                      '${AppConfig.currencySymbol} ${((product['basePrice'] ?? product['base_price'] ?? 0) as num).toDouble().toStringAsFixed(0)}',
                      style: context.bodySmall.copyWith(
                        color: context.primaryColorTheme,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: context.secondaryTextColor,
                    ),
                    onTap: () {
                      context.push('/product/${product['id']}');
                    },
                  );
                },
              );
            },
            loading: () => Center(child: CircularProgressIndicator(color: context.primaryColorTheme)),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: context.errorColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load products',
                    style: context.bodyMedium.copyWith(
                      color: context.errorColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      ref.invalidate(productsByListingProvider(ProductsParams(
                        listingId: listingId,
                        status: 'active',
                        limit: 20,
                      )));
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
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                context.push('/products?listingId=$listingId');
              },
              child: const Text('View All Products'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServicesTab(String listingId) {
    return Column(
      children: [
        Expanded(
          child: ref.watch(servicesProvider(ServicesParams(
            listingId: listingId,
            status: 'active',
            limit: 20,
          ))).when(
            data: (data) {
              final services = (data['data'] as List? ?? [])
                  .map((s) => s as Map<String, dynamic>)
                  .toList();
              
              if (services.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.room_service_outlined,
                        size: 48,
                        color: context.secondaryTextColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No services available',
                        style: context.bodyLarge.copyWith(
                          color: context.secondaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          context.push('/services?listingId=$listingId');
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: context.primaryColorTheme,
                        ),
                        child: const Text('View All Services'),
                      ),
                    ],
                  ),
                );
              }
              
              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: services.length,
                itemBuilder: (context, index) {
                  final service = services[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: context.grey100,
                      child: Icon(
                        Icons.room_service,
                        color: context.secondaryTextColor,
                      ),
                    ),
                    title: Text(
                      service['name'] as String? ?? 'Unknown',
                      style: context.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.primaryTextColor,
                      ),
                    ),
                    subtitle: Text(
                      '${AppConfig.currencySymbol} ${((service['basePrice'] ?? service['base_price'] ?? 0) as num).toDouble().toStringAsFixed(0)}',
                      style: context.bodySmall.copyWith(
                        color: context.primaryColorTheme,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: context.secondaryTextColor,
                    ),
                    onTap: () {
                      context.push('/service/${service['id']}');
                    },
                  );
                },
              );
            },
            loading: () => Center(child: CircularProgressIndicator(color: context.primaryColorTheme)),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: context.errorColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load services',
                    style: context.bodyMedium.copyWith(
                      color: context.errorColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      ref.invalidate(servicesProvider(ServicesParams(
                        listingId: listingId,
                        status: 'active',
                        limit: 20,
                      )));
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
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                context.push('/services?listingId=$listingId');
              },
              child: const Text('View All Services'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuTab(String listingId) {
    return ref.watch(menusByListingProvider(listingId)).when(
      data: (menus) {
        if (menus.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.restaurant_menu_outlined,
                  size: 48,
                  color: context.secondaryTextColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'No menu available',
                  style: context.bodyLarge.copyWith(
                    color: context.secondaryTextColor,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    context.push('/menus/$listingId');
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: context.primaryColorTheme,
                  ),
                  child: const Text('View Menu'),
                ),
              ],
            ),
          );
        }
        
        // If only one menu, show it inline, otherwise show menu selector
        if (menus.length == 1) {
          final menu = menus.first;
          final items = menu.items ?? [];
          
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.restaurant_menu_outlined,
                    size: 48,
                    color: context.secondaryTextColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Menu is empty',
                    style: context.bodyLarge.copyWith(
                      color: context.secondaryTextColor,
                    ),
                  ),
                ],
              ),
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: context.grey100,
                  child: Icon(
                    Icons.restaurant,
                    color: context.secondaryTextColor,
                  ),
                ),
                title: Text(
                  item.name,
                  style: context.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.primaryTextColor,
                  ),
                ),
                subtitle: Text(
                  '${AppConfig.currencySymbol} ${item.price.toStringAsFixed(0)}',
                  style: context.bodySmall.copyWith(
                    color: context.primaryColorTheme,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right,
                  color: context.secondaryTextColor,
                ),
                onTap: () {
                  // Navigate to full menu screen
                  context.push('/menus/$listingId');
                },
              );
            },
          );
        }
        
        // Multiple menus - show menu selector
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.restaurant_menu,
                size: 48,
                color: context.secondaryTextColor,
              ),
              const SizedBox(height: 16),
              Text(
                '${menus.length} menus available',
                style: context.bodyLarge.copyWith(
                  color: context.primaryTextColor,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  context.push('/menus/$listingId');
                },
                child: const Text('View Menus'),
              ),
            ],
          ),
        );
      },
      loading: () => Center(child: CircularProgressIndicator(color: context.primaryColorTheme)),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: context.errorColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load menu',
              style: context.bodyMedium.copyWith(
                color: context.errorColor,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                ref.invalidate(menusByListingProvider(listingId));
              },
              style: TextButton.styleFrom(
                foregroundColor: context.primaryColorTheme,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotosTab(List images) {
    if (images.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            'No photos available',
            style: TextStyle(
              fontSize: 16,
              color: context.secondaryTextColor,
            ),
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        final image = images[index];
        final imageUrl = image['media']?['url'] ?? image['media']?['thumbnailUrl'];

        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: imageUrl != null
              ? FadeInNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  borderRadius: BorderRadius.circular(12),
                  errorWidget: Container(
                    color: context.grey200,
                    child: Icon(
                      Icons.image,
                      color: context.secondaryTextColor,
                    ),
                  ),
                )
              : Container(
                  color: context.grey200,
                  child: Icon(
                    Icons.image,
                    color: context.secondaryTextColor,
                  ),
                ),
        );
      },
    );
  }

  /// Build shop tabs dynamically based on what's available
  _ShopTabsData _buildShopTabs(BuildContext context, bool isShopEnabled) {
    if (!isShopEnabled) {
      return _ShopTabsData(tabs: [], children: []);
    }

    final tabs = <Tab>[];
    final children = <Widget>[];

    // Check if products exist
    final productsAsync = ref.watch(productsByListingProvider(ProductsParams(
      listingId: widget.listingId,
      status: 'active',
      limit: 1,
    )));
    
    final hasProducts = productsAsync.maybeWhen(
      data: (data) {
        final products = (data['data'] as List? ?? []);
        return products.isNotEmpty;
      },
      orElse: () => false,
    );

    // Check if services exist
    final servicesAsync = ref.watch(servicesProvider(ServicesParams(
      listingId: widget.listingId,
      status: 'active',
      limit: 1,
    )));
    
    final hasServices = servicesAsync.maybeWhen(
      data: (data) {
        final services = (data['data'] as List? ?? []);
        return services.isNotEmpty;
      },
      orElse: () => false,
    );

    // Check if menus exist
    final menusAsync = ref.watch(menusByListingProvider(widget.listingId));
    
    final hasMenus = menusAsync.maybeWhen(
      data: (menus) => menus.isNotEmpty,
      orElse: () => false,
    );

    // Add tabs and children in priority order: Products, Services, Menu
    if (hasProducts) {
      tabs.add(const Tab(text: 'Products'));
      children.add(_buildProductsTab(widget.listingId));
    }

    if (hasServices) {
      tabs.add(const Tab(text: 'Services'));
      children.add(_buildServicesTab(widget.listingId));
    }

    if (hasMenus) {
      tabs.add(const Tab(text: 'Menu'));
      children.add(_buildMenuTab(widget.listingId));
    }

    return _ShopTabsData(tabs: tabs, children: children);
  }

  Widget _buildBottomBar(Map<String, dynamic> listing, String? contactPhone) {
    final listingType = listing['type']?.toString().toLowerCase() ?? '';
    // Get acceptsBookings from listing data (defaults to false if not set)
    final acceptsBookings = (listing['acceptsBookings'] as bool?) ?? false;
    final category = listing['category'] as Map<String, dynamic>?;
    final categorySlug = category?['slug'] as String? ?? '';
    final categoryName = category?['name'] as String? ?? '';
    
    // Check if it's a dining-related category (dining, restaurants, cafe, fastfood)
    final isDiningCategory = categorySlug.toLowerCase().contains('dining') ||
        categorySlug.toLowerCase().contains('restaurant') ||
        categorySlug.toLowerCase().contains('cafe') ||
        categorySlug.toLowerCase().contains('fastfood') ||
        categoryName.toLowerCase().contains('dining') ||
        categoryName.toLowerCase().contains('restaurant') ||
        categoryName.toLowerCase().contains('cafe') ||
        categoryName.toLowerCase().contains('fast food');

    // Determine which buttons to show
    final showBookingButtons = acceptsBookings && (listingType == 'restaurant' || listingType == 'hotel' || isDiningCategory);
    
    return Container(
      color: context.backgroundColor,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (showBookingButtons) ...[
            // Book Now button
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // Navigate to booking screen which will route to appropriate booking flow
                  context.push('/booking/${widget.listingId}');
                },
                icon: const Icon(Icons.calendar_today, size: 18),
                label: const Text('Book Now'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.primaryColorTheme,
                  backgroundColor: context.backgroundColor,
                  side: BorderSide(color: context.primaryColorTheme),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Order Now button - deep links to Vuba Vuba app
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  // Deep link to Vuba Vuba app
                  // Try to get merchant slug from listing, fallback to listing slug or name
                  final merchant = listing['merchant'] as Map<String, dynamic>?;
                  final merchantSlug = merchant?['slug'] as String?;
                  final listingSlug = listing['slug'] as String?;
                  final listingName = listing['name'] as String?;
                  
                  // Use merchant slug if available, otherwise use listing slug, or generate from name
                  String merchantIdentifier = merchantSlug ?? 
                      listingSlug ?? 
                      (listingName?.toLowerCase().replaceAll(' ', '-').replaceAll(RegExp(r'[^a-z0-9-]'), '') ?? 'meze-fresh');
                  
                  // Ensure we have a valid merchant identifier
                  if (merchantIdentifier.isEmpty) {
                    merchantIdentifier = 'meze-fresh'; // Fallback for testing
                  }
                  
                  // Try deep link first (custom scheme)
                  final deepLinkUrl = 'vubavuba://merchant/$merchantIdentifier';
                  final universalLinkUrl = 'https://www.vv.rw/merchant/$merchantIdentifier';
                  
                  debugPrint('Order Now: Trying deep link: $deepLinkUrl');
                  
                  try {
                    // First, try custom scheme deep link
                    final deepLinkUri = Uri.parse(deepLinkUrl);
                    if (await canLaunchUrl(deepLinkUri)) {
                      final launched = await launchUrl(
                        deepLinkUri,
                        mode: LaunchMode.externalApplication,
                      );
                      if (launched) {
                        debugPrint('Order Now: Successfully opened Vuba Vuba app via deep link');
                        return;
                      }
                    }
                  } catch (e) {
                    debugPrint('Order Now: Deep link failed: $e');
                  }
                  
                  // If deep link fails, try universal link
                  try {
                    debugPrint('Order Now: Trying universal link: $universalLinkUrl');
                    final universalUri = Uri.parse(universalLinkUrl);
                    if (await canLaunchUrl(universalUri)) {
                      // Try to launch as external app (will open Vuba Vuba if installed)
                      final launched = await launchUrl(
                        universalUri,
                        mode: LaunchMode.externalApplication,
                      );
                      if (launched) {
                        debugPrint('Order Now: Successfully opened via universal link');
                        return;
                      }
                    }
                  } catch (e) {
                    debugPrint('Order Now: Universal link failed: $e');
                  }
                  
                  // Fallback to webview if app is not installed
                  debugPrint('Order Now: Falling back to webview: $universalLinkUrl');
                  if (context.mounted) {
                    context.push(
                      Uri(
                        path: '/webview',
                        queryParameters: {
                          'url': universalLinkUrl,
                          'title': listingName ?? 'Vuba Vuba',
                        },
                      ).toString(),
                    );
                  }
                },
                icon: const Icon(Icons.shopping_cart, size: 18),
                label: const Text('Order Now'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF038f44), // Vuba Vuba brand color (intentional)
                  backgroundColor: context.backgroundColor,
                  side: const BorderSide(color: Color(0xFF038f44)), // Vuba Vuba brand color (intentional)
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          // Contact button
          Expanded(
            child: ElevatedButton.icon(
              onPressed: contactPhone != null
                  ? () async {
                      final uri = Uri.parse('tel:$contactPhone');
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            AppTheme.errorSnackBar(
                              message: 'Could not make phone call to $contactPhone',
                            ),
                          );
                        }
                      }
                    }
                  : null,
              icon: const Icon(Icons.phone, size: 18),
              label: const Text('Contact'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showReviewBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ReviewBottomSheet(
        listingId: widget.listingId,
      ),
    );
  }
}

class _ReviewBottomSheet extends ConsumerStatefulWidget {
  final String? listingId;
  final String? eventId;
  final String? tourId;

  const _ReviewBottomSheet({
    this.listingId,
    this.eventId,
    this.tourId,
  });

  @override
  ConsumerState<_ReviewBottomSheet> createState() => _ReviewBottomSheetState();
}

class _ReviewBottomSheetState extends ConsumerState<_ReviewBottomSheet> {
  int _selectedRating = 5;
  final TextEditingController _reviewController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
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
            'Write a Review',
            style: context.headlineMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: context.primaryTextColor,
            ),
          ),
          const SizedBox(height: 20),
          
          // Rating selection
          Text(
            'How was your experience?',
            style: context.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
              color: context.primaryTextColor,
            ),
          ),
          const SizedBox(height: 12),
          
          Row(
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedRating = index + 1;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: Icon(
                    index < _selectedRating ? Icons.star : Icons.star_border,
                    color: index < _selectedRating 
                        ? Colors.amber // Amber for stars is intentional
                        : context.grey400,
                    size: 32,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),
          
          // Review text field
          Text(
            'Tell us about your experience',
            style: context.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
              color: context.primaryTextColor,
            ),
          ),
          const SizedBox(height: 12),
          
          TextField(
            controller: _reviewController,
            maxLines: 4,
            style: context.bodyMedium.copyWith(
              color: context.primaryTextColor,
            ),
            decoration: InputDecoration(
              hintText: 'Share your thoughts about this place...',
              hintStyle: context.bodyMedium.copyWith(
                color: context.secondaryTextColor,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: context.grey300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: context.grey300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: context.primaryColorTheme),
              ),
              filled: true,
              fillColor: context.cardColor,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 24),
          
          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitReview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isSubmitting
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(context.primaryTextColor),
                      ),
                    )
                  : Text(
                      'Submit Review',
                      style: context.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.primaryTextColor,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitReview() async {
    if (_reviewController.text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
            content: Text('Please write a review before submitting'),
            backgroundColor: context.errorColor,
          ),
        );
      }
      return;
    }

    // Validate that at least one ID is provided
    if (widget.listingId == null && widget.eventId == null && widget.tourId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
            content: Text('Unable to submit review. Missing listing, event, or tour information.'),
            backgroundColor: context.errorColor,
          ),
        );
      }
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final reviewsService = ref.read(reviewsServiceProvider);
      
      await reviewsService.createReview(
        listingId: widget.listingId,
        eventId: widget.eventId,
        tourId: widget.tourId,
        rating: _selectedRating,
        content: _reviewController.text.trim(),
      );

      if (!mounted) return;

      // Invalidate reviews providers to refresh the list
      if (widget.listingId != null) {
        ref.invalidate(listingReviewsProvider(
          ListingReviewsParams(listingId: widget.listingId!),
        ));
      } else if (widget.eventId != null) {
        ref.invalidate(eventReviewsProvider(
          EventReviewsParams(eventId: widget.eventId!),
        ));
      }
      
      // Also invalidate general reviews provider
      ref.invalidate(reviewsProvider(
        ReviewsParams(
          listingId: widget.listingId,
          eventId: widget.eventId,
        ),
      ));

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
          content: Text('Thank you for your review!'),
          backgroundColor: context.successColor,
        ),
      );

      // Close bottom sheet
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceAll('Exception: ', ''),
          ),
          backgroundColor: AppTheme.errorColor,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
}
