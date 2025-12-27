import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/place_card.dart';
import '../../../core/providers/categories_provider.dart';
import '../../../core/providers/listings_provider.dart';
import '../../../core/providers/favorites_provider.dart';

class CategoryPlacesScreen extends ConsumerStatefulWidget {
  final String category; // This is the slug
  
  const CategoryPlacesScreen({
    super.key,
    required this.category,
  });

  @override
  ConsumerState<CategoryPlacesScreen> createState() => _CategoryPlacesScreenState();
}

class _CategoryPlacesScreenState extends ConsumerState<CategoryPlacesScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentPage = 1;
  final int _pageSize = 20;
  String? _categoryId;
  String? _categoryName;
  bool _isAccommodation = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // All, Popular for now
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool _isAccommodationCategory(String? categoryName, String? categorySlug) {
    if (categoryName == null && categorySlug == null) return false;
    final name = (categoryName ?? '').toLowerCase();
    final slug = (categorySlug ?? widget.category).toLowerCase();
    return name.contains('hotel') || 
           name.contains('accommodation') || 
           slug.contains('hotel') || 
           slug.contains('accommodation');
  }

  @override
  Widget build(BuildContext context) {
    // Fetch category by slug
    final categoryAsync = ref.watch(categoryBySlugProvider(widget.category));

    return categoryAsync.when(
      data: (categoryData) {
        _categoryId = categoryData['id'] as String?;
        _categoryName = categoryData['name'] as String?;
        _isAccommodation = _isAccommodationCategory(_categoryName, widget.category);

        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            backgroundColor: AppTheme.backgroundColor,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.chevron_left, size: 32),
              onPressed: () => context.pop(),
              color: AppTheme.primaryTextColor,
            ),
            title: Text(
              _categoryName ?? widget.category,
              style: AppTheme.headlineSmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => context.push('/search?category=${widget.category}'),
              ),
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: _showFilterBottomSheet,
              ),
              IconButton(
                icon: const Icon(Icons.sort),
                onPressed: _showSortBottomSheet,
              ),
            ],
            bottom: _isAccommodation ? null : TabBar(
              controller: _tabController,
              indicatorColor: AppTheme.primaryColor,
              labelColor: AppTheme.primaryColor,
              unselectedLabelColor: AppTheme.secondaryTextColor,
              labelStyle: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w600),
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelPadding: const EdgeInsets.symmetric(horizontal: 16),
              tabs: const [
                Tab(text: 'All'),
                Tab(text: 'Popular'),
              ],
            ),
          ),
          body: _categoryId != null
              ? _buildListingsList()
              : const Center(
                  child: Text('Category not found'),
                ),
        );
      },
      loading: () => Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: AppTheme.backgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.chevron_left, size: 32),
            onPressed: () => context.pop(),
            color: AppTheme.primaryTextColor,
          ),
          title: Text(
            widget.category,
            style: AppTheme.headlineSmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: AppTheme.backgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.chevron_left, size: 32),
            onPressed: () => context.pop(),
            color: AppTheme.primaryTextColor,
          ),
          title: Text(
            widget.category,
            style: AppTheme.headlineSmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppTheme.secondaryTextColor,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load category',
                style: AppTheme.headlineSmall.copyWith(
                  color: AppTheme.secondaryTextColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.secondaryTextColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(categoryBySlugProvider(widget.category));
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListingsList() {
    if (_categoryId == null) {
      return const Center(child: Text('Category not found'));
    }

    final listingsAsync = ref.watch(
      listingsProvider(
        ListingsParams(
          page: _currentPage,
          limit: _pageSize,
          category: _categoryId,
        ),
      ),
    );

    return listingsAsync.when(
      data: (response) {
        final listings = response['data'] as List? ?? [];
        final meta = response['meta'] as Map<String, dynamic>?;
        final totalPages = meta?['totalPages'] ?? 1;

        if (listings.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.explore,
                  size: 64,
                  color: AppTheme.secondaryTextColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'No ${_categoryName?.toLowerCase() ?? widget.category} found',
                  style: AppTheme.headlineSmall.copyWith(
                    color: AppTheme.secondaryTextColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Check back later for new listings',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.secondaryTextColor,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(
              listingsProvider(
                ListingsParams(
                  page: _currentPage,
                  limit: _pageSize,
                  category: _categoryId,
                ),
              ),
            );
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: listings.length + (_currentPage < totalPages ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == listings.length) {
                // Load more indicator
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _currentPage++;
                        });
                      },
                      child: const Text('Load More'),
                    ),
                  ),
                );
              }

              final listing = listings[index] as Map<String, dynamic>;
              
              if (_isAccommodation) {
                return _buildAccommodationCard(listing);
              } else {
                return _buildRegularListingCard(listing);
              }
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.secondaryTextColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load listings',
              style: AppTheme.headlineSmall.copyWith(
                color: AppTheme.secondaryTextColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.secondaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(
                  listingsProvider(
                    ListingsParams(
                      page: _currentPage,
                      limit: _pageSize,
                      category: _categoryId,
                    ),
                  ),
                );
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegularListingCard(Map<String, dynamic> listing) {
    final listingId = listing['id'] as String? ?? '';
    final name = listing['name'] as String? ?? 'Unknown';
    
    // Extract image URL - images is a List of Maps with media objects
    String? imageUrl;
    if (listing['images'] != null && listing['images'] is List && (listing['images'] as List).isNotEmpty) {
      final firstImage = (listing['images'] as List).first;
      if (firstImage is Map && firstImage['media'] != null) {
        imageUrl = firstImage['media']['url'] ?? firstImage['media']['thumbnailUrl'];
      } else if (firstImage is String) {
        imageUrl = firstImage;
      }
    }
    
    // Extract address - address is directly on listing, city is an object
    final address = listing['address'] as String? ?? '';
    String cityName = '';
    final city = listing['city'];
    if (city is Map) {
      cityName = (city as Map<String, dynamic>)['name'] as String? ?? '';
    } else if (city is String) {
      cityName = city;
    }
    final locationText = address.isNotEmpty && cityName.isNotEmpty
        ? '$address, $cityName'
        : address.isNotEmpty
            ? address
            : cityName.isNotEmpty
                ? cityName
                : 'Location not available';
    
    // Extract rating
    final rating = listing['rating'] != null
        ? (listing['rating'] is String
            ? double.tryParse(listing['rating']) ?? 0.0
            : (listing['rating'] as num?)?.toDouble() ?? 0.0)
        : 0.0;
    // Backend returns _count.reviews, not reviewCount directly
    final reviewCount = (listing['_count'] as Map<String, dynamic>?)?['reviews'] as int? ?? 
                       listing['reviewCount'] as int? ?? 0;
    
    // Extract price - minPrice and currency are directly on listing
    final minPrice = listing['minPrice'] != null
        ? (listing['minPrice'] is String
            ? double.tryParse(listing['minPrice']) ?? 0.0
            : (listing['minPrice'] as num?)?.toDouble() ?? 0.0)
        : 0.0;
    final maxPrice = listing['maxPrice'] != null
        ? (listing['maxPrice'] is String
            ? double.tryParse(listing['maxPrice']) ?? 0.0
            : (listing['maxPrice'] as num?)?.toDouble() ?? 0.0)
        : 0.0;
    final currency = listing['currency'] as String? ?? 'RWF';
    final priceText = minPrice > 0 
        ? (maxPrice > minPrice ? '$currency ${minPrice.toStringAsFixed(0)} - ${maxPrice.toStringAsFixed(0)}' : '$currency ${minPrice.toStringAsFixed(0)}')
        : 'Price not available';

    // Check if favorited
    final isFavoritedAsync = ref.watch(isListingFavoritedProvider(listingId));

    return PlaceCard(
      name: name,
      location: locationText,
      image: imageUrl ?? '',
      rating: rating,
      reviews: reviewCount,
      priceRange: priceText,
      category: _categoryName ?? widget.category,
      isFavorite: isFavoritedAsync.when(
        data: (isFavorited) => isFavorited,
        loading: () => false,
        error: (_, __) => false,
      ),
      onTap: () {
        context.push('/listing/$listingId');
      },
      onFavorite: () async {
        final favoritesService = ref.read(favoritesServiceProvider);
        await favoritesService.toggleFavorite(listingId: listingId);
        
        ref.invalidate(isListingFavoritedProvider(listingId));
        ref.invalidate(favoritesProvider(const FavoritesParams(page: 1, limit: 100)));
      },
    );
  }

  Widget _buildAccommodationCard(Map<String, dynamic> listing) {
    final listingId = listing['id'] as String? ?? '';
    final name = listing['name'] as String? ?? 'Unknown';
    
    // Extract image URL - images is a List of Maps with media objects
    String? imageUrl;
    if (listing['images'] != null && listing['images'] is List && (listing['images'] as List).isNotEmpty) {
      final firstImage = (listing['images'] as List).first;
      if (firstImage is Map && firstImage['media'] != null) {
        imageUrl = firstImage['media']['url'] ?? firstImage['media']['thumbnailUrl'];
      } else if (firstImage is String) {
        imageUrl = firstImage;
      }
    }
    
    // Extract address - address is directly on listing, city is an object
    final address = listing['address'] as String? ?? '';
    String cityName = '';
    final city = listing['city'];
    if (city is Map) {
      cityName = (city as Map<String, dynamic>)['name'] as String? ?? '';
    } else if (city is String) {
      cityName = city;
    }
    final locationText = address.isNotEmpty && cityName.isNotEmpty
        ? '$address, $cityName'
        : address.isNotEmpty
            ? address
            : cityName.isNotEmpty
                ? cityName
                : 'Location not available';
    
    // Extract rating
    final rating = listing['rating'] != null
        ? (listing['rating'] is String
            ? double.tryParse(listing['rating']) ?? 0.0
            : (listing['rating'] as num?)?.toDouble() ?? 0.0)
        : 0.0;
    // Backend returns _count.reviews, not reviewCount directly
    final reviewCount = (listing['_count'] as Map<String, dynamic>?)?['reviews'] as int? ?? 
                       listing['reviewCount'] as int? ?? 0;
    
    // Extract price - minPrice and currency are directly on listing
    final minPrice = listing['minPrice'] != null
        ? (listing['minPrice'] is String
            ? double.tryParse(listing['minPrice']) ?? 0.0
            : (listing['minPrice'] as num?)?.toDouble() ?? 0.0)
        : 0.0;
    final currency = listing['currency'] as String? ?? 'RWF';
    
    // Extract amenities
    final amenities = listing['amenities'] as List? ?? [];

    // Check if favorited
    final isFavoritedAsync = ref.watch(isListingFavoritedProvider(listingId));

    return GestureDetector(
      onTap: () {
        context.push('/listing/$listingId');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with favorite button
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            height: 200,
                            color: Colors.grey[200],
                            child: const Center(child: CircularProgressIndicator()),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 200,
                            color: Colors.grey[200],
                            child: Icon(
                              Icons.image_not_supported,
                              color: Colors.grey[400],
                              size: 48,
                            ),
                          ),
                        )
                      : Container(
                          height: 200,
                          color: Colors.grey[200],
                          child: Icon(
                            Icons.image_not_supported,
                            color: Colors.grey[400],
                            size: 48,
                          ),
                        ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () async {
                      final favoritesService = ref.read(favoritesServiceProvider);
                      await favoritesService.toggleFavorite(listingId: listingId);
                      
                      ref.invalidate(isListingFavoritedProvider(listingId));
                      ref.invalidate(favoritesProvider(const FavoritesParams(page: 1, limit: 100)));
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: isFavoritedAsync.when(
                        data: (isFavorited) => Icon(
                          isFavorited ? Icons.favorite : Icons.favorite_border,
                          color: isFavorited ? Colors.red : Colors.white,
                          size: 20,
                        ),
                        loading: () => const Icon(
                          Icons.favorite_border,
                          color: Colors.white,
                          size: 20,
                        ),
                        error: (_, __) => const Icon(
                          Icons.favorite_border,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
                // Price badge
                if (minPrice > 0)
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$currency ${minPrice.toStringAsFixed(0)}',
                        style: AppTheme.bodySmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: AppTheme.headlineSmall.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            rating.toStringAsFixed(1),
                            style: AppTheme.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '($reviewCount)',
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: AppTheme.secondaryTextColor,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          locationText,
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.secondaryTextColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (amenities.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: amenities.take(4).map<Widget>((amenity) {
                        final amenityName = amenity is String ? amenity : amenity['name'] as String? ?? '';
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            amenityName,
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.primaryTextColor,
                              fontSize: 11,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter ${_categoryName ?? widget.category}',
                style: AppTheme.headlineSmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Minimum Rating',
                style: AppTheme.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildFilterChip('4.0+ Stars', false),
                  _buildFilterChip('4.5+ Stars', false),
                  _buildFilterChip('5.0 Stars', false),
                ],
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryColor,
                        side: BorderSide(color: AppTheme.primaryColor),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Clear All'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Apply Filters'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sort ${_categoryName ?? widget.category}',
                style: AppTheme.headlineSmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              _buildSortOption('Popular', true),
              _buildSortOption('Rating (High to Low)', false),
              _buildSortOption('Rating (Low to High)', false),
              _buildSortOption('Name (A to Z)', false),
              _buildSortOption('Name (Z to A)', false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        // Handle filter selection
      },
      selectedColor: AppTheme.primaryColor.withOpacity(0.2),
      checkmarkColor: AppTheme.primaryColor,
      labelStyle: AppTheme.bodySmall.copyWith(
        color: isSelected ? AppTheme.primaryColor : AppTheme.primaryTextColor,
      ),
    );
  }

  Widget _buildSortOption(String label, bool isSelected) {
    return ListTile(
      title: Text(
        label,
        style: AppTheme.bodyMedium,
      ),
      trailing: isSelected ? Icon(Icons.check, color: AppTheme.primaryColor) : null,
      onTap: () {
        Navigator.pop(context);
        // Handle sort selection
      },
    );
  }
}
