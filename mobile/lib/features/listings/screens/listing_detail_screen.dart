import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/config/app_config.dart';
import '../../../core/providers/listings_provider.dart';
import '../../../core/providers/favorites_provider.dart';
import '../../../core/providers/reviews_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/widgets/fade_in_image.dart' show FadeInNetworkImage;

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
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
      backgroundColor: Colors.grey[50],
      body: listingAsync.when(
        data: (listing) => _buildContent(listing),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(error),
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
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
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.errorColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load listing',
              style: AppTheme.headlineSmall.copyWith(
                color: AppTheme.errorColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString().replaceFirst('Exception: ', ''),
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.secondaryTextColor,
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

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
      controller: _scrollController,
      slivers: [
        // App Bar with Image
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          backgroundColor: _isScrolled ? Colors.white : AppTheme.backgroundColor,
          leading: IconButton(
            icon: Icon(
              Icons.chevron_left,
              color: _isScrolled ? AppTheme.primaryTextColor : Colors.white,
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
                          color: Colors.grey[200],
                          child: const Icon(Icons.place, size: 100),
                        ),
                      )
                    : Container(
                        color: Colors.grey[200],
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
                                color: isFavorited ? Colors.red : Colors.white,
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
                          icon: const Icon(
                            Icons.rate_review,
                            color: Colors.white,
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
                              icon: const Icon(
                                Icons.share,
                                color: Colors.white,
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
            color: Colors.grey[50],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Listing Info
                Container(
                  color: AppTheme.backgroundColor,
                  padding: const EdgeInsets.all(20),
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
                                    style: AppTheme.headlineMedium.copyWith(
                                      fontWeight: FontWeight.w600,
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
                                      color: Colors.blue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.verified,
                                          size: 14,
                                          color: Colors.blue[700],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Verified',
                                          style: AppTheme.bodySmall.copyWith(
                                            color: Colors.blue[700],
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
                          const Icon(
                            Icons.location_on,
                            size: 18,
                            color: AppTheme.secondaryTextColor,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              address,
                              style: AppTheme.bodyLarge.copyWith(
                                color: AppTheme.secondaryTextColor,
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
                              style: AppTheme.bodyLarge.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '($reviewCount reviews)',
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppTheme.secondaryTextColor,
                              ),
                            ),
                          ],
                          const Spacer(),
                          if (minPrice != null)
                            Text(
                              '$currency ${minPrice.toString()}${maxPrice != null ? ' - ${maxPrice.toString()}' : ''}',
                              style: AppTheme.bodyLarge.copyWith(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Tabs
                Container(
                  color: AppTheme.backgroundColor,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: AppTheme.primaryColor,
                    unselectedLabelColor: AppTheme.secondaryTextColor,
                    indicatorColor: AppTheme.primaryColor,
                    tabs: const [
                      Tab(text: 'Overview'),
                      Tab(text: 'Amenities'),
                      Tab(text: 'Reviews'),
                      Tab(text: 'Photos'),
                    ],
                  ),
                ),
                // Tab Content
                Container(
                  height: 400,
                  color: AppTheme.backgroundColor,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOverviewTab(listing, description, operatingHours),
                      _buildAmenitiesTab(amenities),
                      _buildReviewsTab(listing['id'] ?? widget.listingId),
                      _buildPhotosTab(images),
                    ],
                  ),
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // About/Description Section
          if (displayDescription.isNotEmpty) ...[
            Text(
              'About',
              style: AppTheme.headlineSmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              displayDescription,
              style: AppTheme.bodyMedium.copyWith(
                height: 1.6,
                color: AppTheme.secondaryTextColor,
              ),
            ),
            const SizedBox(height: 24),
          ],
          
          // Location Section
          Text(
            'Location',
            style: AppTheme.headlineSmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.location_on,
                size: 20,
                color: AppTheme.secondaryTextColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  locationText,
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.secondaryTextColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (operatingHours != null) ...[
            Text(
              'Opening Hours',
              style: AppTheme.headlineSmall.copyWith(
                fontWeight: FontWeight.w600,
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
                      child: Text(
                        day[0].toUpperCase() + day.substring(1),
                        style: AppTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      isClosed ? 'Closed' : '$open - $close',
                      style: AppTheme.bodyMedium.copyWith(
                        color: isClosed
                            ? AppTheme.errorColor
                            : AppTheme.secondaryTextColor,
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
              style: AppTheme.headlineSmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            if (contactPhone != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    const Icon(
                      Icons.phone,
                      size: 20,
                      color: AppTheme.secondaryTextColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        contactPhone,
                        style: AppTheme.bodyMedium,
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
                    const Icon(
                      Icons.email,
                      size: 20,
                      color: AppTheme.secondaryTextColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        contactEmail,
                        style: AppTheme.bodyMedium,
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
                    const Icon(
                      Icons.language,
                      size: 20,
                      color: AppTheme.secondaryTextColor,
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
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.primaryColor,
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
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.hotel_outlined,
                size: 64,
                color: AppTheme.secondaryTextColor,
              ),
              const SizedBox(height: 16),
              Text(
                'No amenities listed',
                style: AppTheme.headlineSmall.copyWith(
                  color: AppTheme.secondaryTextColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Amenities information will be available soon',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.secondaryTextColor,
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
      padding: const EdgeInsets.all(20),
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
                      style: AppTheme.headlineSmall.copyWith(
                        fontWeight: FontWeight.w600,
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
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            getIconForName(iconName),
            size: 20,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (description != null && description.isNotEmpty)
                  Text(
                    description,
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.secondaryTextColor,
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
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.rate_review_outlined,
                    size: 64,
                    color: AppTheme.secondaryTextColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No reviews yet',
                    style: AppTheme.headlineSmall.copyWith(
                      color: AppTheme.secondaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Be the first to review this place!',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.secondaryTextColor,
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
                icon: const Icon(Icons.edit, color: Colors.white),
                label: const Text(
                  'Write Review',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
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
                'Failed to load reviews',
                style: AppTheme.headlineSmall.copyWith(
                  color: AppTheme.errorColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString().replaceFirst('Exception: ', ''),
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.secondaryTextColor,
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
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[200]!,
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
                        style: AppTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
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
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
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
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.secondaryTextColor,
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
              style: AppTheme.titleSmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (content.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              content,
              style: AppTheme.bodyMedium.copyWith(
                height: 1.4,
              ),
            ),
          ],
          if (helpfulCount > 0) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.thumb_up_outlined,
                  size: 16,
                  color: AppTheme.secondaryTextColor,
                ),
                const SizedBox(width: 4),
                Text(
                  '$helpfulCount helpful',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.secondaryTextColor,
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
                          color: AppTheme.dividerColor,
                          child: const Icon(Icons.image_not_supported),
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

  Widget _buildPhotosTab(List images) {
    if (images.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'No photos available',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(20),
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
                    color: Colors.grey[200],
                    child: const Icon(Icons.image),
                  ),
                )
              : Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.image),
                ),
        );
      },
    );
  }

  Widget _buildBottomBar(Map<String, dynamic> listing, String? contactPhone) {
    final listingType = listing['type']?.toString().toLowerCase() ?? '';

    return Container(
      color: AppTheme.backgroundColor,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (listingType == 'restaurant' || listingType == 'hotel') ...[
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // Navigate to appropriate booking screen based on listing type
                  if (listingType == 'restaurant') {
                    // Extract data for dining booking
                    final images = listing['images'] as List? ?? [];
                    final primaryImage = images.isNotEmpty && images[0]['media'] != null
                        ? images[0]['media']['url']
                        : null;
                    final name = listing['name'] ?? 'Restaurant';
                    final address = listing['address'] ?? '';
                    final city = listing['city'] as Map<String, dynamic>?;
                    final cityName = city?['name'] as String? ?? '';
                    final location = address.isNotEmpty 
                        ? '$address${cityName.isNotEmpty ? ', $cityName' : ''}'
                        : cityName.isNotEmpty ? cityName : 'Location not available';
                    final rating = listing['rating'] != null
                        ? (listing['rating'] is String
                            ? double.tryParse(listing['rating'])
                            : listing['rating']?.toDouble())
                        : 0.0;
                    final minPrice = listing['minPrice'];
                    final maxPrice = listing['maxPrice'];
                    final currency = listing['currency'] ?? 'RWF';
                    String priceRange = 'Price not available';
                    if (minPrice != null) {
                      final min = minPrice is String ? double.tryParse(minPrice) : minPrice?.toDouble();
                      final max = maxPrice != null 
                          ? (maxPrice is String ? double.tryParse(maxPrice) : maxPrice?.toDouble())
                          : null;
                      if (min != null) {
                        priceRange = max != null && max > min
                            ? '$currency ${min.toStringAsFixed(0)} - ${max.toStringAsFixed(0)}'
                            : '$currency ${min.toStringAsFixed(0)}';
                      }
                    }
                    
                    // Navigate to dining booking screen
                    context.push('/dining-booking', extra: {
                      'placeId': widget.listingId,
                      'placeName': name,
                      'placeLocation': location,
                      'placeImage': primaryImage ?? '',
                      'placeRating': rating ?? 0.0,
                      'priceRange': priceRange,
                    });
                  } else if (listingType == 'hotel') {
                    // Navigate to accommodation booking screen
                    context.push('/accommodation/${widget.listingId}/book');
                  }
                },
                icon: const Icon(Icons.calendar_today, size: 18),
                label: const Text('Book Now'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                  backgroundColor: AppTheme.backgroundColor,
                  side: const BorderSide(color: AppTheme.primaryColor),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
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
                foregroundColor: Colors.white,
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
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
      decoration: const BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Title
          Text(
            'Write a Review',
            style: AppTheme.headlineMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          
          // Rating selection
          Text(
            'How was your experience?',
            style: AppTheme.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
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
                        ? Colors.amber 
                        : Colors.grey[400],
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
            style: AppTheme.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          
          TextField(
            controller: _reviewController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Share your thoughts about this place...',
              hintStyle: AppTheme.bodyMedium.copyWith(
                color: AppTheme.secondaryTextColor,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.primaryColor),
              ),
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
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Submit Review',
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
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
          const SnackBar(
            content: Text('Please write a review before submitting'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
      return;
    }

    // Validate that at least one ID is provided
    if (widget.listingId == null && widget.eventId == null && widget.tourId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to submit review. Missing listing, event, or tour information.'),
            backgroundColor: AppTheme.errorColor,
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
        const SnackBar(
          content: Text('Thank you for your review!'),
          backgroundColor: AppTheme.successColor,
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
