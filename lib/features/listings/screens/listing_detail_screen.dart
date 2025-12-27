import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/config/app_config.dart';
import '../../../core/providers/listings_provider.dart';
import '../../../core/providers/favorites_provider.dart';
import '../../../core/providers/reviews_provider.dart';

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
            Icon(
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
            onPressed: () => context.pop(),
          ),
          actions: [
            Consumer(
              builder: (context, ref, child) {
                final isFavoritedAsync = ref.watch(isListingFavoritedProvider(widget.listingId));
                final isFavorited = isFavoritedAsync.value ?? false;

                return IconButton(
                  icon: Icon(
                    isFavorited ? Icons.favorite : Icons.favorite_border,
                    color: _isScrolled ? AppTheme.primaryTextColor : Colors.white,
                  ),
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
                );
              },
            ),
            IconButton(
              icon: Icon(
                Icons.share,
                color: _isScrolled ? AppTheme.primaryTextColor : Colors.white,
              ),
              onPressed: () {
                // TODO: Implement share functionality
              },
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                primaryImage != null
                    ? CachedNetworkImage(
                        imageUrl: primaryImage,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
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
                          Icon(
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
                            Icon(
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (description.isNotEmpty) ...[
            Text(
              'About',
              style: AppTheme.headlineSmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: AppTheme.bodyMedium.copyWith(
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),
          ],
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
          if (listing['contactPhone'] != null || listing['website'] != null) ...[
            const SizedBox(height: 24),
            Text(
              'Contact Information',
              style: AppTheme.headlineSmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            if (listing['contactPhone'] != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.phone,
                      size: 18,
                      color: AppTheme.secondaryTextColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      listing['contactPhone'],
                      style: AppTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            if (listing['website'] != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.language,
                      size: 18,
                      color: AppTheme.secondaryTextColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      listing['website'],
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildAmenitiesTab(List amenities) {
    if (amenities.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'No amenities listed',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: amenities.map<Widget>((amenity) {
          final amenityName = amenity is Map
              ? (amenity['name'] ?? amenity['id'] ?? '')
              : amenity.toString();

          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              amenityName,
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }).toList(),
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
                  Icon(
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
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
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
            padding: const EdgeInsets.all(20),
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              final review = reviews[index] as Map<String, dynamic>;
              return _buildReviewCard(review);
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
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
                Icon(
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
                      child: CachedNetworkImage(
                        imageUrl: imageUrl is String ? imageUrl : imageUrl['url'] ?? '',
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 80,
                          height: 80,
                          color: AppTheme.dividerColor,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
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
              ? CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
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
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          if (listingType == 'restaurant' || listingType == 'hotel') ...[
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // Navigate to booking screen
                  context.push('/booking/${widget.listingId}');
                },
                icon: const Icon(Icons.calendar_today, size: 18),
                label: const Text('Book Now'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                  backgroundColor: AppTheme.backgroundColor,
                  side: const BorderSide(color: AppTheme.primaryColor),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: ElevatedButton.icon(
              onPressed: contactPhone != null
                  ? () {
                      // TODO: Implement phone call
                    }
                  : null,
              icon: const Icon(Icons.phone, size: 18),
              label: const Text('Contact'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
