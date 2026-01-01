import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/widgets/place_card.dart';
import '../../../core/providers/categories_provider.dart';
import '../../../core/providers/listings_provider.dart';
import '../../../core/providers/favorites_provider.dart';
import '../../../core/config/app_config.dart';

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
  TabController? _tabController;
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;
  int _currentPage = 1;
  final int _pageSize = 20;
  String? _categoryId;
  String? _categoryName;
  bool _isAccommodation = false;
  
  // Subcategories and navigation
  List<Map<String, dynamic>> _subcategories = [];
  String? _selectedCategoryId; // Currently selected category/subcategory ID for listings
  // ignore: unused_field
  int _selectedTabIndex = 0; // 0 = All, 1 = Popular, 2+ = subcategories (tracked for state management)
  String? _currentParentCategoryId; // Track which category's children we're showing
  bool _isInitializingTabs = false; // Prevent listener from firing during initialization
  
  // Filter state
  double? _minRating;
  double? _minPrice;
  double? _maxPrice;
  bool? _isFeatured;
  
  // Sort state
  String? _sortBy;
  
  bool get _hasActiveFilters => _minRating != null || _minPrice != null || _maxPrice != null || _isFeatured != null;

  @override
  void initState() {
    super.initState();
    // TabController will be initialized after we know the number of tabs
    
    // Shimmer animation controller
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // Start shimmer animation
    _shimmerController.repeat();
    
    // Shimmer animation
    _shimmerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  void _initializeTabs(List<Map<String, dynamic>>? children) {
    _isInitializingTabs = true;
    
    // Extract direct children only (not nested)
    _subcategories = (children ?? [])
        .where((child) => child['isActive'] != false)
        .toList();
    
    final tabCount = 2 + _subcategories.length; // All + Popular + subcategories
    
    // Dispose old controller if exists
    _tabController?.dispose();
    
    // Create new controller with correct number of tabs
    _tabController = TabController(length: tabCount, vsync: this);
    _tabController!.addListener(() {
      // Don't handle tab change during initialization
      if (!_isInitializingTabs && !_tabController!.indexIsChanging) {
        _handleTabChange(_tabController!.index);
      }
    });
    
    // Set initial selected category
    if (_selectedCategoryId == null) {
      _selectedCategoryId = _categoryId;
      _currentParentCategoryId = _categoryId;
    }
    
    _isInitializingTabs = false;
  }

  void _handleTabChange(int index) {
    if (!mounted || _tabController == null) return;
    
    setState(() {
      _selectedTabIndex = index;
      _currentPage = 1; // Reset to first page
      
      if (index == 0) {
        // "All" tab - show listings from current parent category
        _selectedCategoryId = _currentParentCategoryId ?? _categoryId;
        _sortBy = null; // Reset sort for "All"
      } else if (index == 1) {
        // "Popular" tab - show popular listings from current parent category
        _selectedCategoryId = _currentParentCategoryId ?? _categoryId;
        _sortBy = 'popular';
      } else {
        // Subcategory tab - show listings from selected subcategory
        final subcategoryIndex = index - 2;
        if (subcategoryIndex < _subcategories.length) {
          final subcategory = _subcategories[subcategoryIndex];
          final subcategoryId = subcategory['id'] as String?;
          final subcategoryChildren = subcategory['children'] as List?;
          
          // If this subcategory has children, update tabs to show them
          if (subcategoryChildren != null && subcategoryChildren.isNotEmpty) {
            // Prevent infinite loop: only update if we're not already showing these children
            if (_currentParentCategoryId != subcategoryId) {
              _currentParentCategoryId = subcategoryId;
              _isInitializingTabs = true;
              _initializeTabs(List<Map<String, dynamic>>.from(subcategoryChildren));
              // Reset to "All" tab when switching to subcategory with children
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && _tabController != null) {
                  _isInitializingTabs = true;
                  _tabController!.animateTo(0);
                  setState(() {
                    _selectedTabIndex = 0;
                    _selectedCategoryId = subcategoryId;
                    _sortBy = null;
                    _isInitializingTabs = false;
                  });
                }
              });
              return; // Exit early, will be updated in postFrameCallback
            }
          }
          
          // No children or already showing this category's children - just show its listings
          _selectedCategoryId = subcategoryId;
          _sortBy = null; // Reset sort when selecting subcategory
        }
      }
    });
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
        
        // Extract children from category data
        final children = categoryData['children'] as List?;
        
        // Initialize tabs if not already done or if category changed
        if (_tabController == null || _currentParentCategoryId != _categoryId) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _initializeTabs(children != null 
                  ? List<Map<String, dynamic>>.from(children)
                  : null);
            }
          });
        }

        return Scaffold(
          backgroundColor: context.grey50,
          appBar: AppBar(
            backgroundColor: context.backgroundColor,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.chevron_left, size: 32),
              onPressed: () => context.pop(),
              color: context.primaryTextColor,
            ),
            title: Text(
              _categoryName ?? widget.category,
              style: AppTheme.headlineSmall.copyWith(
                fontWeight: FontWeight.w600,
                color: context.primaryTextColor,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => context.push('/search?category=${widget.category}'),
              ),
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: _showFilterBottomSheet,
                  ),
                  if (_hasActiveFilters)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: context.primaryColorTheme,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.sort),
                    onPressed: _showSortBottomSheet,
                  ),
                  if (_sortBy != null && _sortBy != 'popular')
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: context.primaryColorTheme,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ],
            bottom: _isAccommodation || _tabController == null ? null : TabBar(
              controller: _tabController,
              indicatorColor: context.primaryColorTheme,
              labelColor: context.primaryColorTheme,
              unselectedLabelColor: context.secondaryTextColor,
              labelStyle: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w600),
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelPadding: const EdgeInsets.symmetric(horizontal: 16),
              tabs: [
                const Tab(text: 'All'),
                const Tab(text: 'Popular'),
                ..._subcategories.map((subcategory) {
                  final name = subcategory['name'] as String? ?? 'Unknown';
                  return Tab(text: name);
                }),
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
        backgroundColor: context.grey50,
        appBar: AppBar(
          backgroundColor: context.backgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.chevron_left, size: 32),
            onPressed: () => context.pop(),
            color: context.primaryTextColor,
          ),
          title: Text(
            widget.category,
            style: AppTheme.headlineSmall.copyWith(
              fontWeight: FontWeight.w600,
              color: context.primaryTextColor,
            ),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        backgroundColor: context.grey50,
        appBar: AppBar(
          backgroundColor: context.backgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.chevron_left, size: 32),
            onPressed: () => context.pop(),
            color: context.primaryTextColor,
          ),
          title: Text(
            widget.category,
            style: AppTheme.headlineSmall.copyWith(
              fontWeight: FontWeight.w600,
              color: context.primaryTextColor,
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: context.secondaryTextColor,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load category',
                style: AppTheme.headlineSmall.copyWith(
                  color: context.secondaryTextColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: AppTheme.bodyMedium.copyWith(
                  color: context.secondaryTextColor,
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

  // Getter for the category ID to use for listings
  String? get _categoryIdForListings => _selectedCategoryId ?? _categoryId;

  Widget _buildListingsList() {
    if (_categoryId == null) {
      return const Center(child: Text('Category not found'));
    }
    
    final listingsAsync = ref.watch(
      listingsProvider(
        ListingsParams(
          page: _currentPage,
          limit: _pageSize,
          category: _categoryIdForListings,
          rating: _minRating,
          minPrice: _minPrice,
          maxPrice: _maxPrice,
          isFeatured: _isFeatured,
          sortBy: _sortBy,
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
                  color: context.secondaryTextColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'No ${_categoryName?.toLowerCase() ?? widget.category} found',
                  style: AppTheme.headlineSmall.copyWith(
                    color: context.secondaryTextColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Check back later for new listings',
                  style: AppTheme.bodyMedium.copyWith(
                    color: context.secondaryTextColor,
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
                  rating: _minRating,
                  minPrice: _minPrice,
                  maxPrice: _maxPrice,
                  isFeatured: _isFeatured,
                  sortBy: _sortBy,
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
                          // Invalidate to fetch next page with current filters and sort
                          ref.invalidate(
                            listingsProvider(
                              ListingsParams(
                                page: _currentPage,
                                limit: _pageSize,
                                category: _categoryIdForListings,
                                rating: _minRating,
                                minPrice: _minPrice,
                                maxPrice: _maxPrice,
                                isFeatured: _isFeatured,
                                sortBy: _sortBy,
                              ),
                            ),
                          );
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
      loading: () => _buildSkeletonLoader(),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: context.secondaryTextColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load listings',
              style: AppTheme.headlineSmall.copyWith(
                color: context.secondaryTextColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: AppTheme.bodyMedium.copyWith(
                color: context.secondaryTextColor,
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
                      rating: _minRating,
                      minPrice: _minPrice,
                      maxPrice: _maxPrice,
                      isFeatured: _isFeatured,
                      sortBy: _sortBy,
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
        try {
          final favoritesService = ref.read(favoritesServiceProvider);
          final isFavorited = isFavoritedAsync.value ?? false;
          
          await favoritesService.toggleFavorite(listingId: listingId);
          
          ref.invalidate(isListingFavoritedProvider(listingId));
          ref.invalidate(favoritesProvider(const FavoritesParams(page: 1, limit: 100)));
          
          if (context.mounted) {
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
                            color: context.grey200,
                            child: const Center(child: CircularProgressIndicator()),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 200,
                            color: context.grey200,
                            child: Icon(
                              Icons.image_not_supported,
                              color: context.grey400,
                              size: 48,
                            ),
                          ),
                        )
                      : Container(
                          height: 200,
                          color: context.grey200,
                          child: Icon(
                            Icons.image_not_supported,
                            color: context.grey400,
                            size: 48,
                          ),
                        ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () async {
                      try {
                        final favoritesService = ref.read(favoritesServiceProvider);
                        final isFavorited = isFavoritedAsync.value ?? false;
                        
                        await favoritesService.toggleFavorite(listingId: listingId);
                        
                        ref.invalidate(isListingFavoritedProvider(listingId));
                        ref.invalidate(favoritesProvider(const FavoritesParams(page: 1, limit: 100)));
                        
                        if (context.mounted) {
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
                        color: context.primaryColorTheme,
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
                          const Icon(
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
                              color: context.secondaryTextColor,
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
                        color: context.secondaryTextColor,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          locationText,
                          style: AppTheme.bodySmall.copyWith(
                            color: context.secondaryTextColor,
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
                            color: context.grey100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            amenityName,
                            style: AppTheme.bodySmall.copyWith(
                              color: context.primaryTextColor,
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
    // Local state for bottom sheet
    double? tempMinRating = _minRating;
    double? tempMinPrice = _minPrice;
    double? tempMaxPrice = _maxPrice;
    bool? tempIsFeatured = _isFeatured;
    
    final minPriceController = TextEditingController(
      text: _minPrice != null ? _minPrice!.toStringAsFixed(0) : '',
    );
    final maxPriceController = TextEditingController(
      text: _maxPrice != null ? _maxPrice!.toStringAsFixed(0) : '',
    );
    
    showModalBottomSheet(
      context: context,
      backgroundColor: context.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filter ${_categoryName ?? widget.category}',
                      style: AppTheme.headlineSmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.primaryTextColor,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Minimum Rating
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
                    _buildRatingChip(
                      '4.0+ Stars',
                      4.0,
                      tempMinRating,
                      (value) {
                        setModalState(() {
                          tempMinRating = tempMinRating == value ? null : value;
                        });
                      },
                    ),
                    _buildRatingChip(
                      '4.5+ Stars',
                      4.5,
                      tempMinRating,
                      (value) {
                        setModalState(() {
                          tempMinRating = tempMinRating == value ? null : value;
                        });
                      },
                    ),
                    _buildRatingChip(
                      '5.0 Stars',
                      5.0,
                      tempMinRating,
                      (value) {
                        setModalState(() {
                          tempMinRating = tempMinRating == value ? null : value;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Price Range
                Text(
                  'Price Range',
                  style: AppTheme.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: minPriceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Min Price',
                          hintText: '0',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: context.grey300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: context.grey300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: context.primaryColorTheme),
                          ),
                          prefixText: 'RWF ',
                        ),
                        onChanged: (value) {
                          final price = double.tryParse(value);
                          setModalState(() {
                            tempMinPrice = price;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: maxPriceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Max Price',
                          hintText: 'No limit',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: context.grey300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: context.grey300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: context.primaryColorTheme),
                          ),
                          prefixText: 'RWF ',
                        ),
                        onChanged: (value) {
                          final price = double.tryParse(value);
                          setModalState(() {
                            tempMaxPrice = price;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Featured Only
                CheckboxListTile(
                  title: Text(
                    'Featured Only',
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                      color: context.primaryTextColor,
                    ),
                  ),
                  subtitle: Text(
                    'Show only featured listings',
                    style: AppTheme.bodySmall.copyWith(
                      color: context.secondaryTextColor,
                    ),
                  ),
                  value: tempIsFeatured == true,
                  onChanged: (bool? value) {
                    setModalState(() {
                      tempIsFeatured = (value == true) ? true : null;
                    });
                  },
                  activeColor: context.primaryColorTheme,
                  contentPadding: EdgeInsets.zero,
                ),
                
                // Action buttons
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setModalState(() {
                            tempMinRating = null;
                            tempMinPrice = null;
                            tempMaxPrice = null;
                            tempIsFeatured = null;
                            minPriceController.clear();
                            maxPriceController.clear();
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: context.primaryColorTheme,
                          side: BorderSide(color: context.primaryColorTheme),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Clear All'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _minRating = tempMinRating;
                            _minPrice = tempMinPrice;
                            _maxPrice = tempMaxPrice;
                            _isFeatured = tempIsFeatured;
                            _currentPage = 1; // Reset to first page
                          });
                          minPriceController.dispose();
                          maxPriceController.dispose();
                          Navigator.pop(context);
                          // Invalidate provider to refresh with new filters
                          ref.invalidate(
                            listingsProvider(
                              ListingsParams(
                                page: 1,
                                limit: _pageSize,
                                category: _categoryIdForListings,
                                rating: _minRating,
                                minPrice: _minPrice,
                                maxPrice: _maxPrice,
                                isFeatured: _isFeatured,
                                sortBy: _sortBy,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.primaryColorTheme,
                          foregroundColor: context.primaryTextColor,
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
      ),
    );
  }
  
  Widget _buildRatingChip(String label, double value, double? selectedValue, Function(double) onSelected) {
    final isSelected = selectedValue == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(value),
      selectedColor: AppTheme.primaryColor.withOpacity(0.2),
      checkmarkColor: AppTheme.primaryColor,
      labelStyle: AppTheme.bodySmall.copyWith(
        color: isSelected ? AppTheme.primaryColor : AppTheme.primaryTextColor,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  void _showSortBottomSheet() {
    // Local state for bottom sheet
    String? tempSortBy = _sortBy;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: context.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sort ${_categoryName ?? widget.category}',
                      style: AppTheme.headlineSmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Sort Options
                _buildSortOption('Popular', 'popular', tempSortBy, (value) {
                  setModalState(() {
                    tempSortBy = tempSortBy == value ? null : value;
                  });
                }),
                _buildSortOption('Rating (High to Low)', 'rating_desc', tempSortBy, (value) {
                  setModalState(() {
                    tempSortBy = tempSortBy == value ? null : value;
                  });
                }),
                _buildSortOption('Rating (Low to High)', 'rating_asc', tempSortBy, (value) {
                  setModalState(() {
                    tempSortBy = tempSortBy == value ? null : value;
                  });
                }),
                _buildSortOption('Price (Low to High)', 'price_asc', tempSortBy, (value) {
                  setModalState(() {
                    tempSortBy = tempSortBy == value ? null : value;
                  });
                }),
                _buildSortOption('Price (High to Low)', 'price_desc', tempSortBy, (value) {
                  setModalState(() {
                    tempSortBy = tempSortBy == value ? null : value;
                  });
                }),
                _buildSortOption('Name (A to Z)', 'name_asc', tempSortBy, (value) {
                  setModalState(() {
                    tempSortBy = tempSortBy == value ? null : value;
                  });
                }),
                _buildSortOption('Name (Z to A)', 'name_desc', tempSortBy, (value) {
                  setModalState(() {
                    tempSortBy = tempSortBy == value ? null : value;
                  });
                }),
                _buildSortOption('Newest First', 'createdAt_desc', tempSortBy, (value) {
                  setModalState(() {
                    tempSortBy = tempSortBy == value ? null : value;
                  });
                }),
                _buildSortOption('Oldest First', 'createdAt_asc', tempSortBy, (value) {
                  setModalState(() {
                    tempSortBy = tempSortBy == value ? null : value;
                  });
                }),
                
                // Action buttons
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setModalState(() {
                            tempSortBy = null;
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: context.primaryColorTheme,
                          side: BorderSide(color: context.primaryColorTheme),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Clear'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _sortBy = tempSortBy;
                            _currentPage = 1; // Reset to first page
                          });
                          Navigator.pop(context);
                          // Invalidate provider to refresh with new sort
                          ref.invalidate(
                            listingsProvider(
                              ListingsParams(
                                page: 1,
                                limit: _pageSize,
                                category: _categoryIdForListings,
                                rating: _minRating,
                                minPrice: _minPrice,
                                maxPrice: _maxPrice,
                                isFeatured: _isFeatured,
                                sortBy: _sortBy,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.primaryColorTheme,
                          foregroundColor: context.primaryTextColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Apply Sort'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildSortOption(String label, String value, String? selectedValue, Function(String) onSelected) {
    final isSelected = selectedValue == value;
    return ListTile(
      title: Text(
        label,
        style: AppTheme.bodyMedium.copyWith(
          color: context.primaryTextColor,
        ),
      ),
      trailing: isSelected ? const Icon(Icons.check, color: AppTheme.primaryColor) : null,
      onTap: () => onSelected(value),
      selected: isSelected,
      selectedTileColor: AppTheme.primaryColor.withOpacity(0.1),
    );
  }

  Widget _buildSkeletonLoader() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        if (_isAccommodation) {
          return _buildSkeletonAccommodationCard();
        } else {
          return _buildSkeletonRegularCard();
        }
      },
    );
  }

  Widget _buildSkeletonRegularCard() {
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
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image skeleton
              Stack(
                children: [
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: context.grey200,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
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
                  // Favorite button skeleton
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: context.isDarkMode ? Colors.white.withOpacity(0.2) : Colors.white.withOpacity(0.7),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
              // Content skeleton
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 20,
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
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 60,
                          height: 24,
                          decoration: BoxDecoration(
                            color: context.grey300,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: context.grey300,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Container(
                            height: 16,
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
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: context.grey300,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          width: 40,
                          height: 16,
                          decoration: BoxDecoration(
                            color: context.grey300,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 80,
                          height: 14,
                          decoration: BoxDecoration(
                            color: context.grey300,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: 60,
                          height: 16,
                          decoration: BoxDecoration(
                            color: context.grey300,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSkeletonAccommodationCard() {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: context.cardColor,
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
              // Image skeleton
              Stack(
                children: [
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: context.grey200,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
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
                  // Favorite button skeleton
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  // Price badge skeleton
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                      width: 70,
                      height: 28,
                      decoration: BoxDecoration(
                        color: context.grey300,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
              // Content skeleton
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 20,
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
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 50,
                          height: 16,
                          decoration: BoxDecoration(
                            color: context.grey300,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: context.grey300,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Container(
                            height: 16,
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
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Amenities skeleton
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(3, (index) {
                        return Container(
                          width: 60 + (index * 20),
                          height: 24,
                          decoration: BoxDecoration(
                            color: context.grey300,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
