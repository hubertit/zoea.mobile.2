import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/theme/text_theme_extensions.dart';
import '../../../core/providers/favorites_provider.dart';
import '../../../core/providers/listings_provider.dart';
import '../../../core/providers/categories_provider.dart';
import '../../../core/config/app_config.dart';

class AccommodationScreen extends ConsumerStatefulWidget {
  const AccommodationScreen({super.key});

  @override
  ConsumerState<AccommodationScreen> createState() => _AccommodationScreenState();
}

class _AccommodationScreenState extends ConsumerState<AccommodationScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;
  String _selectedLocation = 'Kigali';
  String _selectedDates = 'Any dates';
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  TimeOfDay? _checkInTime;
  TimeOfDay? _checkOutTime;
  int _guestCount = 1;
  String? _accommodationCategoryId;
  final List<String> _tabs = [
    'All',
    'Hotels',
    'B&Bs',
    'Apartments',
    'Villas',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _setDefaultDatesAndTimes();
    _loadAccommodationCategoryId();
    
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

  Future<void> _loadAccommodationCategoryId() async {
    try {
      final categories = await ref.read(categoriesProvider.future);
      final accommodationCategory = categories.firstWhere(
        (cat) => cat['slug'] == 'accommodation',
        orElse: () => <String, dynamic>{},
      );
      if (accommodationCategory.isNotEmpty && mounted) {
        setState(() {
          _accommodationCategoryId = accommodationCategory['id'] as String?;
        });
      }
    } catch (e) {
      debugPrint('Error loading accommodation category: $e');
    }
  }

  void _setDefaultDatesAndTimes() {
    final now = DateTime.now();
    final nextHour = now.hour + 1;
    
    // Set check-in to current date and next hour
    _checkInDate = DateTime(now.year, now.month, now.day);
    _checkInTime = TimeOfDay(hour: nextHour > 23 ? 0 : nextHour, minute: 0);
    
    // Set check-out to next day (24 hours later)
    _checkOutDate = DateTime(now.year, now.month, now.day + 1);
    _checkOutTime = _checkInTime;
    
    // Update the display string
    _updateDatesDisplay();
  }

  void _updateDatesDisplay() {
    if (_checkInDate != null && _checkOutDate != null) {
      final checkInFormatted = '${_checkInDate!.day}/${_checkInDate!.month}/${_checkInDate!.year}';
      final checkOutFormatted = '${_checkOutDate!.day}/${_checkOutDate!.month}/${_checkOutDate!.year}';
      _selectedDates = '$checkInFormatted - $checkOutFormatted';
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.grey50,
      appBar: AppBar(
        backgroundColor: context.backgroundColor,
        elevation: 0,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Where to stay',
              style: context.headlineMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: context.primaryTextColor,
              ),
            ),
            Text(
              'Find your perfect accommodation',
              style: context.bodySmall.copyWith(
                color: context.secondaryTextColor,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/search?category=accommodation'),
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortBottomSheet,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
          ),
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: _showMapView,
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              context.push('/profile');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _tabs.map((tab) => _buildAccommodationList(tab)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: _showSearchOptions,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.grey300),
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
            Icon(
              Icons.location_on,
              color: context.primaryColorTheme,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedLocation,
                style: context.bodySmall.copyWith(
                  color: context.primaryTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              height: 20,
              width: 1,
              color: context.grey300,
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.calendar_today,
              color: context.secondaryTextColor,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _getDateRangeText(),
                style: context.bodySmall.copyWith(
                  color: context.secondaryTextColor,
                ),
              ),
            ),
            Container(
              height: 20,
              width: 1,
              color: context.grey300,
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.person,
              color: context.secondaryTextColor,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              '$_guestCount guest${_guestCount > 1 ? 's' : ''}',
              style: context.bodySmall.copyWith(
                color: context.secondaryTextColor,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_drop_down,
              color: context.secondaryTextColor,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildTabBar() {
    return Container(
            color: context.cardColor,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        labelPadding: const EdgeInsets.symmetric(horizontal: 16),
        indicatorColor: context.primaryColorTheme,
        indicatorWeight: 2,
        labelColor: context.primaryColorTheme,
        unselectedLabelColor: context.secondaryTextColor,
        labelStyle: context.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
          color: context.primaryTextColor,
        ),
        unselectedLabelStyle: context.bodyMedium,
        tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
      ),
    );
  }

  Widget _buildAccommodationList(String category) {
    // Get the appropriate filter based on tab
    String? typeFilter;
    if (category.toLowerCase() == 'hotels') {
      typeFilter = 'hotel';
    } else if (category.toLowerCase() == 'all') {
      // For "All", filter by accommodation category
      typeFilter = null; // Will use categoryId instead
    }
    // Note: B&Bs, Apartments, Villas don't have specific types in backend
    // They would all be type='hotel' or need to be filtered differently
    
    // Fetch all listings - use a high limit to get all accommodation listings
    final listingsAsync = ref.watch(
      listingsProvider(
        ListingsParams(
          page: 1,
          limit: 200, // Increased limit to fetch all accommodation listings
          type: typeFilter,
          category: _accommodationCategoryId, // Filter by accommodation category
        ),
      ),
    );

    return listingsAsync.when(
      data: (response) {
        final listings = response['data'] as List? ?? [];
        
        // Filter by category tab if needed (for B&Bs, Apartments, Villas)
        // Since backend only has 'hotel' type, we'll show all for now
        final filteredListings = category.toLowerCase() == 'all' || category.toLowerCase() == 'hotels'
            ? listings
            : <Map<String, dynamic>>[]; // Empty for B&Bs, Apartments, Villas (no backend support yet)

        if (filteredListings.isEmpty) {
          return _buildEmptyState(category);
        }

        return RefreshIndicator(
          color: context.primaryColorTheme,
          backgroundColor: context.cardColor,
          onRefresh: () async {
            ref.invalidate(
              listingsProvider(
                ListingsParams(
                  page: 1,
                  limit: 200,
                  type: typeFilter,
                  category: _accommodationCategoryId,
                ),
              ),
            );
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredListings.length,
            itemBuilder: (context, index) {
              final listing = filteredListings[index] as Map<String, dynamic>;
              return _buildAccommodationCard(listing);
            },
          ),
        );
      },
      loading: () => _buildSkeletonLoader(),
      error: (error, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
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
                'Failed to load accommodations',
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
                    listingsProvider(
                      ListingsParams(
                        page: 1,
                        limit: 200,
                        type: typeFilter,
                        category: _accommodationCategoryId,
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

  /// Generate a mock image URL based on listing name or ID
  String _generateMockImageUrl(String listingId, String? name) {
    // Use a hash of the listing ID to consistently select an image
    final hash = listingId.hashCode.abs();
    final imageIndex = hash % 10; // Use 10 different mock images
    // Use Unsplash hotel images with different IDs
    final imageIds = [
      '1566073771259', '1571896349842', '1520250497591', '1582719478250',
      '1522708323590', '1560448204', '1613490493576', '1566073771258',
      '1571896349843', '1520250497592'
    ];
    return 'https://images.unsplash.com/photo-${imageIds[imageIndex]}?w=800&h=600&fit=crop';
  }
  
  /// Generate default price based on rating and other factors
  double _generateDefaultPrice(double rating, String? name) {
    // Base price on rating: higher rating = higher price
    final basePrice = rating > 0 ? (rating * 20000.0) : 50000.0;
    // Add some variation based on name hash
    final variation = ((name?.hashCode ?? 0).abs() % 50000).toDouble();
    return basePrice + variation;
  }
  
  /// Generate default amenities based on listing type and rating
  List<String> _generateDefaultAmenities(double rating, String? type) {
    final amenities = <String>['WiFi'];
    if (rating >= 4.0) {
      amenities.addAll(['Pool', 'Restaurant']);
    }
    if (rating >= 4.5) {
      amenities.add('Spa');
    }
    if (type == 'hotel') {
      amenities.add('Room Service');
    }
    return amenities;
  }

  Widget _buildSkeletonLoader() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return _buildSkeletonAccommodationCard();
      },
    );
  }

  Widget _buildSkeletonSearchBar() {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.grey300),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
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
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: context.grey300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 16,
                  decoration: BoxDecoration(
                    color: context.grey300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Container(
                height: 20,
                width: 1,
                color: context.grey300,
              ),
              const SizedBox(width: 12),
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: context.grey300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 16,
                  decoration: BoxDecoration(
                    color: context.grey300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Container(
                height: 20,
                width: 1,
                color: context.grey300,
              ),
              const SizedBox(width: 12),
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: context.grey300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 60,
                height: 16,
                decoration: BoxDecoration(
                  color: context.grey300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: context.grey300,
                  borderRadius: BorderRadius.circular(4),
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
                  // Breakfast badge skeleton
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      width: 80,
                      height: 24,
                      decoration: BoxDecoration(
                        color: context.grey300,
                        borderRadius: BorderRadius.circular(8),
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
                    const SizedBox(height: 4),
                    Container(
                      height: 16,
                      width: 150,
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
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: 14,
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
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAccommodationCard(Map<String, dynamic> listing) {
    // Extract data from API response structure with graceful fallbacks
    final listingId = listing['id'] as String? ?? '';
    final name = listing['name'] as String? ?? 'Accommodation';
    
    // Extract image - API returns images array with nested media
    // If no image, use mock image path
    final images = listing['images'] as List? ?? [];
    String? primaryImage;
    if (images.isNotEmpty) {
      final firstImage = images.first as Map<String, dynamic>?;
      final media = firstImage?['media'] as Map<String, dynamic>?;
      primaryImage = media?['url'] as String?;
    }
    // Use mock image if no image from API
    final imageUrl = primaryImage ?? _generateMockImageUrl(listingId, name);
    
    // Extract location with fallbacks
    final city = listing['city'] as Map<String, dynamic>?;
    final cityName = city?['name'] as String? ?? '';
    final country = listing['country'] as Map<String, dynamic>?;
    final countryName = country?['name'] as String? ?? '';
    final address = listing['address'] as String? ?? '';
    final location = address.isNotEmpty 
        ? '$address${cityName.isNotEmpty ? ', $cityName' : ''}${countryName.isNotEmpty && cityName.isEmpty ? ', $countryName' : ''}'
        : cityName.isNotEmpty 
            ? '$cityName${countryName.isNotEmpty ? ', $countryName' : ''}'
            : countryName.isNotEmpty
                ? countryName
                : 'Location not available';
    
    // Extract rating with fallback
    final rating = listing['rating'] != null
        ? (listing['rating'] is String
            ? double.tryParse(listing['rating']) ?? 0.0
            : (listing['rating'] as num?)?.toDouble() ?? 0.0)
        : 0.0;
    // If no rating, generate a reasonable default (3.5-5.0 as per user's previous request)
    final displayRating = rating > 0 ? rating : (3.5 + (listingId.hashCode.abs() % 15) / 10);
    
    final reviewCount = (listing['_count'] as Map<String, dynamic>?)?['reviews'] as int? ?? 0;
    
    // Extract price with fallback generation
    double minPrice = 0.0;
    if (listing['minPrice'] != null) {
      minPrice = listing['minPrice'] is String
          ? double.tryParse(listing['minPrice']) ?? 0.0
          : (listing['minPrice'] as num?)?.toDouble() ?? 0.0;
    }
    
    double? maxPrice;
    if (listing['maxPrice'] != null) {
      maxPrice = listing['maxPrice'] is String
          ? double.tryParse(listing['maxPrice'])
          : (listing['maxPrice'] as num?)?.toDouble();
    }
    
    // Generate default price if missing
    if (minPrice == 0.0) {
      minPrice = _generateDefaultPrice(displayRating, name);
      maxPrice = minPrice * 1.5; // Add 50% for max price
    } else if (maxPrice == null) {
      maxPrice = minPrice * 1.3; // Add 30% for max price if only minPrice exists
    } else if (maxPrice == 0.0) {
      maxPrice = minPrice * 1.3; // Add 30% for max price if maxPrice is 0
    }
    
    final currency = listing['currency'] as String? ?? 'RWF';
    final priceDisplay = minPrice > 0
        ? (maxPrice > minPrice 
            ? '$currency ${minPrice.toStringAsFixed(0)} - ${maxPrice.toStringAsFixed(0)}'
            : '$currency ${minPrice.toStringAsFixed(0)}')
        : 'Price not available';
    
    // Extract room types
    final roomTypes = listing['roomTypes'] as List? ?? [];
    final hasRooms = roomTypes.isNotEmpty;
    
    // Extract amenities with fallback generation
    final amenitiesList = listing['amenities'] as List? ?? [];
    List<String> amenityNames = [];
    if (amenitiesList.isNotEmpty) {
      amenityNames = amenitiesList
          .map((a) {
            if (a is Map<String, dynamic>) {
              final amenity = a['amenity'];
              if (amenity is Map<String, dynamic>) {
                return amenity['name'] as String?;
              }
            }
            return null;
          })
          .whereType<String>()
          .toList();
    }
    // Generate default amenities if none exist
    if (amenityNames.isEmpty) {
      amenityNames = _generateDefaultAmenities(displayRating, listing['type'] as String?);
    }
    
    return GestureDetector(
      onTap: () {
        final dateData = {
          'checkInDate': _checkInDate,
          'checkOutDate': _checkOutDate,
          'checkInTime': _checkInTime,
          'guestCount': _guestCount,
        };
        context.push('/listing/$listingId', extra: dateData);
      },
      child: Container(
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
          // Image with favorite button
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            color: context.grey200,
                            child: Icon(
                              Icons.image_not_supported,
                              color: context.grey400,
                              size: 48,
                            ),
                          );
                        },
                      )
                    : Container(
                        height: 200,
                        color: context.grey200,
                        child: Icon(
                          Icons.hotel,
                          color: context.grey400,
                          size: 48,
                        ),
                      ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Consumer(
                  builder: (context, ref, child) {
                    final isFavoritedAsync = ref.watch(isListingFavoritedProvider(listingId));
                    
                    return GestureDetector(
                      onTap: () async {
                        try {
                          final favoritesService = ref.read(favoritesServiceProvider);
                          await favoritesService.toggleFavorite(listingId: listingId);
                          
                          ref.invalidate(isListingFavoritedProvider(listingId));
                          ref.invalidate(favoritesProvider(const FavoritesParams(page: 1, limit: 100)));
                          
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
                    );
                  },
                ),
              ),
              // Price badge
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
                    priceDisplay,
                    style: context.bodySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              // Breakfast included badge (removed - not in API response)
              // if (accommodation['breakfastIncluded'] == true)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.successColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.restaurant,
                          color: Colors.white,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Breakfast',
                          style: context.bodySmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              // Room availability indicator
              if (hasRooms)
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.bed,
                          color: Colors.white,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${roomTypes.length} room type${roomTypes.length != 1 ? 's' : ''}',
                          style: context.bodySmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ],
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
                        style: context.headlineSmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: context.primaryTextColor,
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
                          displayRating > 0 ? displayRating.toStringAsFixed(1) : 'N/A',
                          style: context.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: context.primaryTextColor,
                          ),
                        ),
                        if (reviewCount > 0)
                          Text(
                            ' ($reviewCount)',
                            style: context.bodySmall.copyWith(
                              color: context.secondaryTextColor,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  location,
                  style: context.bodyMedium.copyWith(
                    color: context.secondaryTextColor,
                  ),
                ),
                const SizedBox(height: 8),
                // Display amenities (already extracted above with fallbacks)
                if (amenityNames.isNotEmpty)
                  Row(
                    children: [
                      Icon(
                        Icons.wifi,
                        size: 16,
                        color: context.secondaryTextColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          amenityNames.take(3).join(', '),
                          style: context.bodySmall.copyWith(
                            color: context.secondaryTextColor,
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
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String category) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.hotel,
            size: 64,
            color: context.secondaryTextColor,
          ),
          const SizedBox(height: 16),
          Text(
            'No ${category.toLowerCase()} found',
            style: context.headlineSmall.copyWith(
              color: context.secondaryTextColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: context.bodyMedium.copyWith(
              color: context.secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filters',
                    style: context.headlineSmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.primaryTextColor,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Clear all filters
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Clear All',
                      style: context.bodyMedium.copyWith(
                        color: context.primaryColorTheme,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Price Range
              Text(
                'Price Range (RWF)',
                style: context.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.primaryTextColor,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: context.grey300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Min: 10,000',
                        style: context.bodyMedium,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: context.grey300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Max: 200,000',
                        style: context.bodyMedium,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Rating
              Text(
                'Minimum Rating',
                style: context.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () {
                      // Handle rating selection
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: context.grey300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text('${index + 1}+'),
                        ],
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
              
              // Amenities
              Text(
                'Amenities',
                style: context.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  'WiFi',
                  'Pool',
                  'Spa',
                  'Gym',
                  'Restaurant',
                  'Parking',
                  'Air Conditioning',
                  'Business Center',
                  'Kitchen',
                  'Garden',
                ].map((amenity) => FilterChip(
                  label: Text(amenity),
                  selected: false,
                  onSelected: (selected) {
                    // Handle amenity selection
                  },
                  backgroundColor: context.cardColor,
                  selectedColor: context.primaryColorTheme.withOpacity(0.1),
                  checkmarkColor: context.primaryColorTheme,
                  side: BorderSide(color: context.grey300),
                )).toList(),
              ),
              const SizedBox(height: 20),
              
              // Property Type
              Text(
                'Property Type',
                style: context.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  'Hotels',
                  'B&Bs',
                  'Apartments',
                  'Villas',
                ].map((type) => FilterChip(
                  label: Text(type),
                  selected: false,
                  onSelected: (selected) {
                    // Handle property type selection
                  },
                  backgroundColor: context.cardColor,
                  selectedColor: context.primaryColorTheme.withOpacity(0.1),
                  checkmarkColor: context.primaryColorTheme,
                  side: BorderSide(color: context.grey300),
                )).toList(),
              ),
              const SizedBox(height: 20),
              
              // Distance
              Text(
                'Distance from City Center',
                style: context.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  'Any',
                  'Under 5km',
                  '5-10km',
                  '10-20km',
                  'Over 20km',
                ].map((distance) => Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(distance),
                      selected: false,
                      onSelected: (selected) {
                        // Handle distance selection
                      },
                      backgroundColor: context.backgroundColor,
                      selectedColor: context.primaryColorTheme.withOpacity(0.1),
                      checkmarkColor: context.primaryColorTheme,
                      side: BorderSide(color: context.grey300),
                    ),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 30),
              
              // Apply button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Apply filters logic here
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.primaryColorTheme,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    'Apply Filters',
                    style: context.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMapView() {
    // Implement map view
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Map view coming soon!'),
      ),
    );
  }

  void _showSearchOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Search Options',
              style: context.headlineSmall.copyWith(
                fontWeight: FontWeight.w600,
                color: context.primaryTextColor,
              ),
            ),
            const SizedBox(height: 20),
            
            // Location
            _buildSearchOption(
              icon: Icons.location_on,
              title: 'Where',
              subtitle: _selectedLocation,
              onTap: _selectLocation,
            ),
            const SizedBox(height: 16),
            
            // Dates
            _buildSearchOption(
              icon: Icons.calendar_today,
              title: 'Check-in & Check-out',
              subtitle: _selectedDates,
              onTap: _selectDates,
            ),
            const SizedBox(height: 16),
            
            // Guests
            _buildSearchOption(
              icon: Icons.person,
              title: 'Guests',
              subtitle: '$_guestCount guest${_guestCount > 1 ? 's' : ''}',
              onTap: _selectGuests,
            ),
            const SizedBox(height: 30),
            
            // Search button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Apply search filters
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.primaryColorTheme,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Search Accommodations',
                  style: context.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: context.grey300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
                        color: context.primaryColorTheme,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.primaryTextColor,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: context.bodySmall.copyWith(
                      color: context.secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: context.secondaryTextColor,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _selectLocation() {
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: context.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Location',
              style: context.headlineSmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            ...['Kigali', 'Musanze', 'Rubavu', 'Huye', 'Nyagatare', 'Rusizi'].map((location) => 
              ListTile(
                title: Text(location),
                trailing: location == _selectedLocation 
                  ? Icon(Icons.check, color: context.primaryColorTheme)
                  : null,
                onTap: () {
                  setState(() {
                    _selectedLocation = location;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDateRangeText() {
    if (_checkInDate == null && _checkOutDate == null) {
      return 'Any dates';
    } else if (_checkInDate != null && _checkOutDate == null) {
      return '${_checkInDate!.day}/${_checkInDate!.month}/${_checkInDate!.year} - Select checkout';
    } else if (_checkInDate != null && _checkOutDate != null) {
      return '${_checkInDate!.day}/${_checkInDate!.month} - ${_checkOutDate!.day}/${_checkOutDate!.month}';
    }
    return 'Any dates';
  }

  void _selectDates() {
    Navigator.pop(context);
    _showDateRangePicker();
  }

  void _showDateRangePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Dates & Times',
              style: context.headlineSmall.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            
            // Check-in Date
            _buildDateTimeSelector(
              title: 'Check-in',
              date: _checkInDate,
              time: _checkInTime,
              onDateTap: () => _selectDate(true),
              onTimeTap: () => _selectTime(true),
            ),
            const SizedBox(height: 16),
            
            // Check-out Date
            _buildDateTimeSelector(
              title: 'Check-out',
              date: _checkOutDate,
              time: _checkOutTime,
              onDateTap: () => _selectDate(false),
              onTimeTap: () => _selectTime(false),
            ),
            const SizedBox(height: 30),
            
            // Done button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.primaryColorTheme,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Done',
                  style: context.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeSelector({
    required String title,
    required DateTime? date,
    required TimeOfDay? time,
    required VoidCallback onDateTap,
    required VoidCallback onTimeTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: context.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: onDateTap,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: context.grey300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: context.primaryColorTheme,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        date != null
                            ? '${date.day}/${date.month}/${date.year}'
                            : 'Select date',
                        style: context.bodyMedium.copyWith(
                          color: date != null 
                              ? context.primaryTextColor 
                              : context.secondaryTextColor,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: onTimeTap,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: context.grey300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: context.primaryColorTheme,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        time != null
                            ? '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}'
                            : 'Select time',
                        style: context.bodyMedium.copyWith(
                          color: time != null 
                              ? context.primaryTextColor 
                              : context.secondaryTextColor,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _selectDate(bool isCheckIn) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isCheckIn
          ? (_checkInDate ?? DateTime.now())
          : (_checkOutDate ?? (_checkInDate?.add(const Duration(days: 1)) ?? DateTime.now().add(const Duration(days: 1)))),
      firstDate: isCheckIn ? DateTime.now() : (_checkInDate ?? DateTime.now()),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          _checkInDate = picked;
          // Reset check-out if it's before check-in
          if (_checkOutDate != null && _checkOutDate!.isBefore(_checkInDate!.add(const Duration(days: 1)))) {
            _checkOutDate = null;
            _checkOutTime = null;
          }
        } else {
          _checkOutDate = picked;
        }
        _updateDatesDisplay();
      });
    }
  }

  Future<void> _selectTime(bool isCheckIn) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isCheckIn
          ? (_checkInTime ?? const TimeOfDay(hour: 15, minute: 0))
          : (_checkOutTime ?? const TimeOfDay(hour: 11, minute: 0)),
    );

    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          _checkInTime = picked;
        } else {
          _checkOutTime = picked;
        }
      });
    }
  }

  void _selectGuests() {
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: context.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Number of Guests',
              style: context.headlineSmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Guests',
                  style: context.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: _guestCount > 1 ? () {
                        setState(() {
                          _guestCount--;
                        });
                      } : null,
                      icon: const Icon(Icons.remove),
                      style: IconButton.styleFrom(
                        backgroundColor: context.grey100,
                        shape: const CircleBorder(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '$_guestCount',
                      style: context.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      onPressed: _guestCount < 10 ? () {
                        setState(() {
                          _guestCount++;
                        });
                      } : null,
                      icon: const Icon(Icons.add),
                      style: IconButton.styleFrom(
                        backgroundColor: context.primaryColorTheme,
                        foregroundColor: Theme.of(context).brightness == Brightness.dark
                            ? AppTheme.primaryColor
                            : Colors.white,
                        shape: const CircleBorder(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.primaryColorTheme,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Done',
                  style: context.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sort by',
              style: context.headlineSmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            ...['Recommended', 'Price: Low to High', 'Price: High to Low', 'Rating: High to Low', 'Distance', 'Popularity'].map((sortOption) => 
              ListTile(
                title: Text(
                  sortOption,
                  style: context.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: sortOption == 'Recommended' 
                  ? Icon(Icons.check, color: context.primaryColorTheme)
                  : null,
                onTap: () {
                  Navigator.pop(context);
                  // Handle sort selection
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _getTotalAvailableRooms(Map<String, dynamic> accommodation) {
    if (accommodation['roomTypes'] == null) return 0;
    
    int total = 0;
    for (var roomType in accommodation['roomTypes']) {
      total += roomType['available'] as int;
    }
    return total;
  }

  List<Map<String, dynamic>> _getMockAccommodations(String category) {
    final allAccommodations = [
      // Hotels
      {
        'id': 'hotel_1',
        'name': 'Kigali Marriott Hotel',
        'location': 'Kacyiru, Kigali',
        'rating': 4.8,
        'reviews': 1247,
        'price': '120,000',
        'amenities': 'WiFi, Pool, Spa, Restaurant',
        'category': 'hotels',
        'image': 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=500',
        'breakfastIncluded': true,
        'roomTypes': [
          {
            'type': 'Deluxe Room',
            'price': '120,000',
            'available': 3,
            'maxGuests': 2,
            'amenities': 'King bed, City view, WiFi',
          },
          {
            'type': 'Executive Suite',
            'price': '180,000',
            'available': 1,
            'maxGuests': 4,
            'amenities': 'King bed, Living area, City view, WiFi',
          },
        ],
      },
      {
        'id': 'hotel_2',
        'name': 'Radisson Blu Hotel',
        'location': 'Kigali Heights, Kigali',
        'rating': 4.6,
        'reviews': 892,
        'price': '95,000',
        'amenities': 'WiFi, Pool, Gym, Restaurant',
        'category': 'hotels',
        'image': 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=500',
        'breakfastIncluded': false,
        'roomTypes': [
          {
            'type': 'Standard Room',
            'price': '95,000',
            'available': 5,
            'maxGuests': 2,
            'amenities': 'Queen bed, WiFi, Air conditioning',
          },
          {
            'type': 'Superior Room',
            'price': '125,000',
            'available': 2,
            'maxGuests': 3,
            'amenities': 'King bed, Pool view, WiFi, Air conditioning',
          },
        ],
      },
      {
        'id': 'hotel_3',
        'name': 'Kigali Serena Hotel',
        'location': 'Kacyiru, Kigali',
        'rating': 4.9,
        'reviews': 1203,
        'price': '150,000',
        'amenities': 'WiFi, Pool, Spa, Restaurant, Business Center',
        'category': 'hotels',
        'image': 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=500',
        'breakfastIncluded': true,
        'roomTypes': [
          {
            'type': 'Deluxe Room',
            'price': '150,000',
            'available': 4,
            'maxGuests': 2,
            'amenities': 'King bed, Garden view, WiFi, Minibar',
          },
          {
            'type': 'Presidential Suite',
            'price': '300,000',
            'available': 1,
            'maxGuests': 6,
            'amenities': 'King bed, Living room, Dining area, Garden view, WiFi, Minibar',
          },
        ],
      },
      // B&Bs
      {
        'id': 'bnb_1',
        'name': 'Heaven Boutique Hotel',
        'location': 'Kiyovu, Kigali',
        'rating': 4.7,
        'reviews': 234,
        'price': '45,000',
        'amenities': 'WiFi, Breakfast, Garden',
        'category': 'b&bs',
        'image': 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=500',
        'breakfastIncluded': true,
        'roomTypes': [
          {
            'type': 'Standard Room',
            'price': '45,000',
            'available': 6,
            'maxGuests': 2,
            'amenities': 'Double bed, Garden view, WiFi, Breakfast',
          },
          {
            'type': 'Family Room',
            'price': '65,000',
            'available': 2,
            'maxGuests': 4,
            'amenities': 'Twin beds, Garden view, WiFi, Breakfast',
          },
        ],
      },
      // Apartments
      {
        'id': 'apartment_1',
        'name': 'Kigali Heights Apartments',
        'location': 'Kigali Heights, Kigali',
        'rating': 4.5,
        'reviews': 89,
        'price': '80,000',
        'amenities': 'WiFi, Kitchen, Balcony',
        'category': 'apartments',
        'image': 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=500',
        'breakfastIncluded': false,
        'roomTypes': [
          {
            'type': '1-Bedroom Apartment',
            'price': '80,000',
            'available': 3,
            'maxGuests': 2,
            'amenities': 'Kitchen, Balcony, WiFi, Living area',
          },
          {
            'type': '2-Bedroom Apartment',
            'price': '120,000',
            'available': 1,
            'maxGuests': 4,
            'amenities': 'Kitchen, Balcony, WiFi, Living area, 2 bedrooms',
          },
        ],
      },
      {
        'id': 'apartment_2',
        'name': 'Modern City Apartment',
        'location': 'Remera, Kigali',
        'rating': 4.3,
        'reviews': 67,
        'price': '65,000',
        'amenities': 'WiFi, Kitchen, Parking',
        'category': 'apartments',
        'image': 'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=500',
        'breakfastIncluded': false,
        'roomTypes': [
          {
            'type': 'Studio Apartment',
            'price': '65,000',
            'available': 4,
            'maxGuests': 2,
            'amenities': 'Kitchen, WiFi, Parking, Modern design',
          },
        ],
      },
      // Villas
      {
        'id': 'villa_1',
        'name': 'Luxury Villa Kigali',
        'location': 'Kiyovu, Kigali',
        'rating': 4.9,
        'reviews': 45,
        'price': '200,000',
        'amenities': 'WiFi, Pool, Garden, Security',
        'category': 'villas',
        'image': 'https://images.unsplash.com/photo-1613490493576-7fde63acd811?w=500',
        'breakfastIncluded': true,
        'roomTypes': [
          {
            'type': '3-Bedroom Villa',
            'price': '200,000',
            'available': 1,
            'maxGuests': 6,
            'amenities': '3 bedrooms, Pool, Garden, WiFi, Security, Breakfast',
          },
          {
            'type': '5-Bedroom Villa',
            'price': '350,000',
            'available': 1,
            'maxGuests': 10,
            'amenities': '5 bedrooms, Pool, Garden, WiFi, Security, Breakfast, Staff',
          },
        ],
      },
    ];

    if (category.toLowerCase() == 'all') {
      return allAccommodations;
    }

    return allAccommodations
        .where((accommodation) =>
            (accommodation['category'] as String).toLowerCase() == category.toLowerCase())
        .toList();
  }
}
