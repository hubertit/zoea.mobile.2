import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/place_card.dart';
import '../../../core/providers/categories_provider.dart';
import '../../../core/providers/listings_provider.dart';
import '../../../core/providers/favorites_provider.dart';
import '../../../core/config/app_config.dart';

class DiningScreen extends ConsumerStatefulWidget {
  const DiningScreen({super.key});

  @override
  ConsumerState<DiningScreen> createState() => _DiningScreenState();
}

class _DiningScreenState extends ConsumerState<DiningScreen>
    with TickerProviderStateMixin {
  TabController? _tabController;
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;
  
  // Category and subcategories
  String? _diningCategoryId;
  String? _diningCategoryName;
  List<Map<String, dynamic>> _subcategories = [];
  String? _selectedCategoryId; // Currently selected category/subcategory ID for listings
  // ignore: unused_field
  int _selectedTabIndex = 0; // 0 = All, 1+ = subcategories (tracked for state management)
  
  // Pagination
  int _currentPage = 1;
  final int _pageSize = 20;
  
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
    
    // Shimmer animation controller
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _shimmerController.repeat();
    
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
    // Extract direct children only (not nested)
    _subcategories = (children ?? [])
        .where((child) => child['isActive'] != false)
        .toList();
    
    final tabCount = 1 + _subcategories.length; // All + subcategories
    
    // Dispose old controller if exists
    _tabController?.dispose();
    
    // Create new controller with correct number of tabs
    _tabController = TabController(length: tabCount, vsync: this);
    _tabController!.addListener(() {
      if (!_tabController!.indexIsChanging) {
        _handleTabChange(_tabController!.index);
      }
    });
    
    // Set initial selected category
    _selectedCategoryId ??= _diningCategoryId;
  }

  void _handleTabChange(int index) {
    if (!mounted || _tabController == null) return;
    
    setState(() {
      _selectedTabIndex = index;
      _currentPage = 1; // Reset to first page
      
      if (index == 0) {
        // "All" tab - show listings from dining category
        _selectedCategoryId = _diningCategoryId;
        _sortBy = null; // Reset sort for "All"
      } else {
        // Subcategory tab - show listings from selected subcategory
        final subcategoryIndex = index - 1;
        if (subcategoryIndex < _subcategories.length) {
          final subcategory = _subcategories[subcategoryIndex];
          _selectedCategoryId = subcategory['id'] as String?;
          _sortBy = null; // Reset sort when selecting subcategory
        }
      }
    });
  }

  // Getter for the category ID to use for listings
  String? get _categoryIdForListings => _selectedCategoryId ?? _diningCategoryId;

  @override
  Widget build(BuildContext context) {
    // Fetch dining category by slug
    final categoryAsync = ref.watch(categoryBySlugProvider('dining'));

    return categoryAsync.when(
      data: (categoryData) {
        _diningCategoryId = categoryData['id'] as String?;
        _diningCategoryName = categoryData['name'] as String?;
        
        // Extract children from category data
        final children = categoryData['children'] as List?;
        
        // Initialize tabs if not already done
        if (_tabController == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _initializeTabs(children != null 
                  ? List<Map<String, dynamic>>.from(children)
                  : null);
            }
          });
        }

        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            backgroundColor: AppTheme.backgroundColor,
            elevation: 0,
            centerTitle: false,
            leading: IconButton(
              onPressed: () => context.go('/explore'),
              icon: const Icon(Icons.chevron_left, size: 32),
              style: IconButton.styleFrom(
                foregroundColor: AppTheme.primaryTextColor,
              ),
            ),
            title: Text(
              _diningCategoryName ?? 'Dining',
              style: AppTheme.headlineMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => context.push('/search?category=dining'),
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
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryColor,
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
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ],
            bottom: _tabController == null ? null : TabBar(
              controller: _tabController,
              indicatorColor: AppTheme.primaryColor,
              labelColor: AppTheme.primaryColor,
              unselectedLabelColor: AppTheme.secondaryTextColor,
              labelStyle: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w600),
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelPadding: const EdgeInsets.symmetric(horizontal: 16),
              tabs: [
                const Tab(text: 'All'),
                ..._subcategories.map((subcategory) {
                  final name = subcategory['name'] as String? ?? 'Unknown';
                  return Tab(text: name);
                }),
              ],
            ),
          ),
          body: _diningCategoryId != null
              ? _buildDiningList()
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
            onPressed: () => context.go('/explore'),
            icon: const Icon(Icons.chevron_left, size: 32),
            style: IconButton.styleFrom(
              foregroundColor: AppTheme.primaryTextColor,
            ),
          ),
          title: Text(
            'Dining',
            style: AppTheme.headlineMedium.copyWith(
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
            onPressed: () => context.go('/explore'),
            icon: const Icon(Icons.chevron_left, size: 32),
            style: IconButton.styleFrom(
              foregroundColor: AppTheme.primaryTextColor,
            ),
          ),
          title: Text(
            'Dining',
            style: AppTheme.headlineMedium.copyWith(
              fontWeight: FontWeight.w600,
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
                color: AppTheme.secondaryTextColor,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load dining category',
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
                  ref.invalidate(categoryBySlugProvider('dining'));
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDiningList() {
    if (_categoryIdForListings == null) {
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
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () async {
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
              return _buildListingCard(listing);
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
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListingCard(Map<String, dynamic> listing) {
    final listingId = listing['id'] as String? ?? '';
    final name = listing['name'] as String? ?? 'Unknown';
    
    // Extract image URL
    String? imageUrl;
    if (listing['images'] != null && listing['images'] is List && (listing['images'] as List).isNotEmpty) {
      final firstImage = (listing['images'] as List).first;
      if (firstImage is Map && firstImage['media'] != null) {
        imageUrl = firstImage['media']['url'] ?? firstImage['media']['thumbnailUrl'];
      } else if (firstImage is String) {
        imageUrl = firstImage;
      }
    }
    
    // Extract address
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
    final reviewCount = (listing['_count'] as Map<String, dynamic>?)?['reviews'] as int? ?? 
                       listing['reviewCount'] as int? ?? 0;
    
    // Extract price
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

    // Get category name
    final category = listing['category'] as Map<String, dynamic>?;
    final categoryName = category?['name'] as String? ?? 'Dining';

    // Check if favorited
    final isFavoritedAsync = ref.watch(isListingFavoritedProvider(listingId));

    return PlaceCard(
      name: name,
      location: locationText,
      image: imageUrl ?? '',
      rating: rating,
      reviews: reviewCount,
      priceRange: priceText,
      category: categoryName,
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant,
            size: 80,
            color: AppTheme.secondaryTextColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No dining options found',
            style: AppTheme.headlineSmall.copyWith(
              color: AppTheme.secondaryTextColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for new dining options',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.secondaryTextColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _shimmerAnimation,
          builder: (context, child) {
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image skeleton
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.grey[200]!,
                          Colors.grey[100]!,
                          Colors.grey[200]!,
                        ],
                        stops: [
                          0.0,
                          _shimmerAnimation.value,
                          1.0,
                        ],
                      ),
                    ),
                  ),
                  // Content skeleton
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 20,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
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
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 16,
                          width: 150,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
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
      backgroundColor: AppTheme.backgroundColor,
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
                      'Filter Dining',
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
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppTheme.primaryColor),
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
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppTheme.primaryColor),
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
                    ),
                  ),
                  subtitle: Text(
                    'Show only featured listings',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.secondaryTextColor,
                    ),
                  ),
                  value: tempIsFeatured == true,
                  onChanged: (bool? value) {
                    setModalState(() {
                      tempIsFeatured = (value == true) ? true : null;
                    });
                  },
                  activeColor: AppTheme.primaryColor,
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
                          foregroundColor: AppTheme.primaryColor,
                          side: const BorderSide(color: AppTheme.primaryColor),
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
      backgroundColor: AppTheme.backgroundColor,
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
                      'Sort Dining',
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
                          foregroundColor: AppTheme.primaryColor,
                          side: const BorderSide(color: AppTheme.primaryColor),
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
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
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
        style: AppTheme.bodyMedium,
      ),
      trailing: isSelected ? const Icon(Icons.check, color: AppTheme.primaryColor) : null,
      onTap: () => onSelected(value),
      selected: isSelected,
      selectedTileColor: AppTheme.primaryColor.withOpacity(0.1),
    );
  }
}
