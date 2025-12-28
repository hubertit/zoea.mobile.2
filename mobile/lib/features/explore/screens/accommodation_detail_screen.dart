import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/listings_provider.dart';
import '../../../core/providers/favorites_provider.dart';
import '../../../core/providers/reviews_provider.dart';
import '../../../core/config/app_config.dart';

class AccommodationDetailScreen extends ConsumerStatefulWidget {
  final String accommodationId;
  final DateTime? checkInDate;
  final DateTime? checkOutDate;
  final TimeOfDay? checkInTime;
  final int? guestCount;

  const AccommodationDetailScreen({
    super.key,
    required this.accommodationId,
    this.checkInDate,
    this.checkOutDate,
    this.checkInTime,
    this.guestCount,
  });

  @override
  ConsumerState<AccommodationDetailScreen> createState() => _AccommodationDetailScreenState();
}

class _AccommodationDetailScreenState extends ConsumerState<AccommodationDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  int _selectedImageIndex = 0;
  bool _isScrolled = false;
  Map<String, Map<String, dynamic>> _selectedRooms = {}; // roomType -> {roomType, quantity}

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this, initialIndex: 1); // Rooms tab is index 1
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.offset > 150 && !_isScrolled) {
      setState(() {
        _isScrolled = true;
      });
    } else if (_scrollController.offset <= 150 && _isScrolled) {
      setState(() {
        _isScrolled = false;
      });
    }
  }

  // Helper methods to extract data from API response
  List<String> _extractImages(Map<String, dynamic> listing) {
    final images = listing['images'] as List? ?? [];
    return images.map((img) {
      if (img is Map<String, dynamic>) {
        final media = img['media'] as Map<String, dynamic>?;
        return media?['url'] as String? ?? media?['thumbnailUrl'] as String? ?? '';
      }
      return img.toString();
    }).where((url) => url.isNotEmpty).toList();
  }

  String _extractLocation(Map<String, dynamic> listing) {
    final address = listing['address'] as String? ?? '';
    final city = listing['city'] as Map<String, dynamic>?;
    final cityName = city?['name'] as String? ?? '';
    final country = listing['country'] as Map<String, dynamic>?;
    final countryName = country?['name'] as String? ?? '';
    
    if (address.isNotEmpty) {
      return '$address${cityName.isNotEmpty ? ', $cityName' : ''}${countryName.isNotEmpty && cityName.isEmpty ? ', $countryName' : ''}';
    } else if (cityName.isNotEmpty) {
      return '$cityName${countryName.isNotEmpty ? ', $countryName' : ''}';
    } else if (countryName.isNotEmpty) {
      return countryName;
    }
    return 'Location not available';
  }

  double _extractRating(Map<String, dynamic> listing) {
    final rating = listing['rating'];
    if (rating == null) return 0.0;
    if (rating is String) return double.tryParse(rating) ?? 0.0;
    return (rating as num?)?.toDouble() ?? 0.0;
  }

  int _extractReviewCount(Map<String, dynamic> listing) {
    final count = listing['_count'] as Map<String, dynamic>?;
    return count?['reviews'] as int? ?? 0;
  }

  String _extractPrice(Map<String, dynamic> listing) {
    final minPrice = listing['minPrice'];
    
    if (minPrice == null) return 'Price not available';
    
    double minPriceValue = 0.0;
    if (minPrice is String) {
      minPriceValue = double.tryParse(minPrice) ?? 0.0;
    } else if (minPrice is num) {
      minPriceValue = minPrice.toDouble();
    }
    
    if (minPriceValue == 0.0) return 'Price not available';
    
    final maxPrice = listing['maxPrice'];
    if (maxPrice != null) {
      double maxPriceValue = 0.0;
      if (maxPrice is String) {
        maxPriceValue = double.tryParse(maxPrice) ?? 0.0;
      } else if (maxPrice is num) {
        maxPriceValue = maxPrice.toDouble();
      }
      if (maxPriceValue > minPriceValue) {
        return '${minPriceValue.toStringAsFixed(0)} - ${maxPriceValue.toStringAsFixed(0)}';
      }
    }
    
    return minPriceValue.toStringAsFixed(0);
  }

  List<String> _extractQuickAmenities(Map<String, dynamic> listing) {
    final amenities = listing['amenities'] as List? ?? [];
    return amenities.take(4).map((a) {
      if (a is Map<String, dynamic>) {
        final amenity = a['amenity'] as Map<String, dynamic>?;
        return amenity?['name'] as String? ?? '';
      }
      return '';
    }).where((name) => name.isNotEmpty).toList();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listingAsync = ref.watch(listingByIdProvider(widget.accommodationId));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: listingAsync.when(
        data: (listing) {
          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              _buildSliverAppBar(listing),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildAccommodationInfo(listing),
                    _buildTabBar(),
                    _buildTabContent(listing),
                  ],
                ),
              ),
            ],
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
                color: AppTheme.errorColor,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load accommodation',
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
                  ref.invalidate(listingByIdProvider(widget.accommodationId));
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: listingAsync.when(
        data: (listing) => _buildBottomBar(listing),
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildSliverAppBar(Map<String, dynamic> listing) {
    final images = _extractImages(listing);
    final listingId = listing['id'] as String? ?? widget.accommodationId;
    final isFavoritedAsync = ref.watch(isListingFavoritedProvider(listingId));

    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: _isScrolled ? AppTheme.backgroundColor : Colors.transparent,
      leading: Container(
        width: 36,
        height: 36,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(
            Icons.chevron_left,
            size: 20,
            color: Colors.white,
          ),
          padding: EdgeInsets.zero,
          alignment: Alignment.center,
        ),
      ),
      actions: const [], // Remove from app bar, will be positioned in flexibleSpace
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (images.isNotEmpty)
              PageView.builder(
                onPageChanged: (index) {
                  setState(() {
                    _selectedImageIndex = index;
                  });
                },
                itemCount: images.length,
                itemBuilder: (context, index) {
                  return Image.network(
                    images[index],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.grey[400],
                          size: 48,
                        ),
                      );
                    },
                  );
                },
              )
            else
              Container(
                color: Colors.grey[200],
                child: Icon(
                  Icons.image_not_supported,
                  color: Colors.grey[400],
                  size: 48,
                ),
              ),
            // Image indicators
            if (images.length > 1)
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    images.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _selectedImageIndex == index
                            ? Colors.white
                            : Colors.white.withOpacity(0.5),
                      ),
                    ),
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
                        _showReviewBottomSheet(listingId);
                      },
                    ),
                  ),
                  // Share button
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
                        Icons.share,
                        color: Colors.white,
                        size: 18,
                      ),
                      padding: EdgeInsets.zero,
                      onPressed: () async {
                        final listingAsync = ref.read(listingByIdProvider(widget.accommodationId));
                        listingAsync.whenData((listing) async {
                          final name = listing['name'] as String? ?? 'Accommodation';
                          final address = listing['address'] as String? ?? '';
                          final city = listing['city'] as Map<String, dynamic>?;
                          final cityName = city?['name'] as String? ?? '';
                          final location = address.isNotEmpty 
                              ? '$address${cityName.isNotEmpty ? ', $cityName' : ''}'
                              : cityName;
                          
                          final shareText = 'Check out $name${location.isNotEmpty ? ' in $location' : ''} on Zoea!';
                          final shareUrl = '${AppConfig.apiBaseUrl.replaceAll('/api', '')}/accommodation/${widget.accommodationId}';
                          
                          await Share.share('$shareText\n$shareUrl');
                        });
                      },
                    ),
                  ),
                  // Favorite button
                  Container(
                    width: 36,
                    height: 36,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: isFavoritedAsync.when(
                        data: (isFavorited) => Icon(
                          isFavorited ? Icons.favorite : Icons.favorite_border,
                          color: isFavorited ? Colors.red : Colors.white,
                          size: 18,
                        ),
                        loading: () => const Icon(
                          Icons.favorite_border,
                          color: Colors.white,
                          size: 18,
                        ),
                        error: (_, __) => const Icon(
                          Icons.favorite_border,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      padding: EdgeInsets.zero,
                      onPressed: () async {
                        try {
                          final favoritesService = ref.read(favoritesServiceProvider);
                          await favoritesService.toggleFavorite(listingId: listingId);
                          ref.invalidate(isListingFavoritedProvider(listingId));
                          ref.invalidate(favoritesProvider(const FavoritesParams(page: 1, limit: 100)));
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              AppTheme.successSnackBar(
                                message: isFavoritedAsync.value ?? false
                                    ? AppConfig.favoriteRemovedMessage
                                    : AppConfig.favoriteAddedMessage,
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              AppTheme.errorSnackBar(
                                message: e.toString().replaceFirst('Exception: ', ''),
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccommodationInfo(Map<String, dynamic> listing) {
    final name = listing['name'] as String? ?? 'Accommodation';
    final rating = _extractRating(listing);
    final reviewCount = _extractReviewCount(listing);
    final location = _extractLocation(listing);
    final quickAmenities = _extractQuickAmenities(listing);

    return Container(
      color: AppTheme.backgroundColor,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: AppTheme.headlineMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (rating > 0)
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      rating.toStringAsFixed(1),
                      style: AppTheme.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (reviewCount > 0)
                      Text(
                        ' ($reviewCount reviews)',
                        style: AppTheme.bodyMedium.copyWith(
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
                  location,
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.secondaryTextColor,
                  ),
                ),
              ),
            ],
          ),
          if (quickAmenities.isNotEmpty) ...[
            const SizedBox(height: 16),
            // Quick amenities
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: quickAmenities.map<Widget>((amenity) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    amenity,
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.primaryTextColor,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppTheme.backgroundColor,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        labelPadding: const EdgeInsets.symmetric(horizontal: 20),
        labelColor: AppTheme.primaryColor,
        unselectedLabelColor: AppTheme.secondaryTextColor,
        indicatorColor: AppTheme.primaryColor,
        indicatorWeight: 2,
        labelStyle: AppTheme.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
        ),
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Rooms'),
          Tab(text: 'Amenities'),
          Tab(text: 'Reviews'),
          Tab(text: 'Photos'),
        ],
      ),
    );
  }

  Widget _buildTabContent(Map<String, dynamic> accommodation) {
    return Container(
      height: 400,
      color: AppTheme.backgroundColor,
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(accommodation),
          _buildRoomsTab(accommodation),
          _buildAmenitiesTab(accommodation),
          _buildReviewsTab(accommodation),
          _buildPhotosTab(accommodation),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(Map<String, dynamic> accommodation) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About this place',
            style: AppTheme.headlineSmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            accommodation['description'],
            style: AppTheme.bodyMedium.copyWith(
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Check-in & Check-out',
            style: AppTheme.headlineSmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Check-in',
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '3:00 PM',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Check-out',
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '11:00 AM',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Booking Policies',
            style: AppTheme.headlineSmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildPolicyCard(
            icon: Icons.cancel_outlined,
            title: 'Cancellation',
            description: 'Free cancellation until 24 hours before check-in',
            color: AppTheme.successColor,
          ),
          const SizedBox(height: 12),
          _buildPolicyCard(
            icon: Icons.money_off,
            title: 'Refund Policy',
            description: 'Full refund if cancelled 24+ hours before check-in',
            color: AppTheme.primaryColor,
          ),
          const SizedBox(height: 12),
          _buildPolicyCard(
            icon: Icons.pets,
            title: 'Pet Policy',
            description: 'Pets allowed with additional fee of RWF 15,000 per night',
            color: AppTheme.secondaryTextColor,
          ),
          const SizedBox(height: 12),
          _buildPolicyCard(
            icon: Icons.smoking_rooms,
            title: 'Smoking Policy',
            description: 'Non-smoking property. Smoking allowed in designated areas only',
            color: AppTheme.errorColor,
          ),
          const SizedBox(height: 12),
          _buildPolicyCard(
            icon: Icons.child_care,
            title: 'Children Policy',
            description: 'Children of all ages welcome. Extra beds available on request',
            color: AppTheme.primaryColor,
          ),
          const SizedBox(height: 12),
          _buildPolicyCard(
            icon: Icons.credit_card,
            title: 'Payment Policy',
            description: 'Credit card required for booking. Payment due at check-in',
            color: AppTheme.secondaryTextColor,
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.secondaryTextColor,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomsTab(Map<String, dynamic> listing) {
    final roomTypes = listing['roomTypes'] as List? ?? [];
    
    return GestureDetector(
      onTap: () {
        // Scroll to top when tapping anywhere on the room types tab
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Available Rooms',
              style: AppTheme.headlineSmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            if (roomTypes.isNotEmpty) ...[
              ...roomTypes.map<Widget>((roomType) {
                // Convert API roomType structure to expected format
                final roomTypeData = roomType is Map<String, dynamic> ? roomType : <String, dynamic>{};
                final name = roomTypeData['name'] as String? ?? 'Room';
                final basePrice = roomTypeData['basePrice'];
                final priceValue = basePrice is String
                    ? double.tryParse(basePrice) ?? 0.0
                    : (basePrice as num?)?.toDouble() ?? 0.0;
                final maxOccupancy = roomTypeData['maxOccupancy'] as int? ?? 2;
                final totalRooms = roomTypeData['totalRooms'] as int? ?? 0;
                final bedType = roomTypeData['bedType'] as String? ?? '';
                final description = roomTypeData['description'] as String? ?? '';
                
                return _buildSelectableRoomTypeCard({
                  'type': name,
                  'price': priceValue.toStringAsFixed(0),
                  'available': totalRooms,
                  'maxGuests': maxOccupancy,
                  'amenities': description.isNotEmpty ? description : bedType,
                });
              }).toList(),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'No room types available',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.secondaryTextColor,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAmenitiesTab(Map<String, dynamic> listing) {
    final amenities = listing['amenities'] as List? ?? [];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Amenities',
            style: AppTheme.headlineSmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          if (amenities.isNotEmpty) ...[
            ...amenities.map<Widget>((item) {
              if (item is Map<String, dynamic>) {
                final amenity = item['amenity'] as Map<String, dynamic>?;
                if (amenity != null) {
                  final name = amenity['name'] as String? ?? 'Amenity';
                  final iconName = amenity['icon'] as String?;
                  final icon = _getAmenityIcon(iconName);
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Icon(
                          icon,
                          size: 20,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            name,
                            style: AppTheme.bodyMedium.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              }
              return const SizedBox.shrink();
            }).toList(),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  'No amenities listed',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.secondaryTextColor,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getAmenityIcon(String? iconName) {
    switch (iconName?.toLowerCase()) {
      case 'wifi':
        return Icons.wifi;
      case 'pool':
        return Icons.pool;
      case 'spa':
        return Icons.spa;
      case 'restaurant':
        return Icons.restaurant;
      case 'parking':
        return Icons.local_parking;
      case 'fitness center':
      case 'fitness':
        return Icons.fitness_center;
      case 'bar':
        return Icons.local_bar;
      case 'cafe':
        return Icons.coffee;
      case 'room service':
        return Icons.room_service;
      case 'air conditioning':
      case 'ac':
        return Icons.ac_unit;
      case 'tv':
        return Icons.tv;
      case 'minibar':
        return Icons.local_drink;
      case 'balcony':
        return Icons.balcony;
      case 'garden':
        return Icons.yard;
      case 'security':
        return Icons.security;
      case 'laundry':
        return Icons.local_laundry_service;
      case 'pet friendly':
      case 'pets':
        return Icons.pets;
      case 'wheelchair accessible':
      case 'accessible':
        return Icons.accessible;
      default:
        return Icons.star;
    }
  }

  Widget _buildReviewsTab(Map<String, dynamic> listing) {
    final listingId = listing['id'] as String? ?? widget.accommodationId;
    final reviewCount = _extractReviewCount(listing);
    final reviewsAsync = ref.watch(listingReviewsProvider(ListingReviewsParams(
      listingId: listingId,
      page: 1,
      limit: 20,
    )));

    return reviewsAsync.when(
      data: (reviewsData) {
        final reviews = reviewsData['data'] as List? ?? [];
        
        return Stack(
          children: [
            RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(listingReviewsProvider(ListingReviewsParams(
                  listingId: listingId,
                  page: 1,
                  limit: 20,
                )));
                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,
                  bottom: 100, // Space for FAB
                ),
                child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Reviews',
                    style: AppTheme.headlineSmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '$reviewCount reviews',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.secondaryTextColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (reviews.isEmpty) ...[
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
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
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            _showReviewBottomSheet(listingId);
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
                ),
              ] else ...[
                ...reviews.map<Widget>((review) {
                  if (review is Map<String, dynamic>) {
                    final user = review['user'] as Map<String, dynamic>?;
                    final userName = user?['firstName'] != null && user?['lastName'] != null
                        ? '${user!['firstName']} ${user['lastName']}'
                        : user?['email'] as String? ?? 'Anonymous';
                    final userImage = user?['profileImage'] as String?;
                    final rating = review['rating'] != null
                        ? (review['rating'] is String
                            ? double.tryParse(review['rating']) ?? 0.0
                            : (review['rating'] as num?)?.toDouble() ?? 0.0)
                        : 0.0;
                    final comment = review['comment'] as String? ?? '';
                    final createdAt = review['createdAt'] as String?;
                    final dateText = createdAt != null
                        ? _formatDate(createdAt)
                        : 'Recently';
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundImage: userImage != null
                                    ? NetworkImage(userImage)
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
                                    Row(
                                      children: [
                                        ...List.generate(5, (index) {
                                          return Icon(
                                            Icons.star,
                                            size: 16,
                                            color: index < rating.round()
                                                ? Colors.amber
                                                : Colors.grey[300],
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
                          if (comment.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(
                              comment,
                              style: AppTheme.bodyMedium.copyWith(
                                height: 1.4,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }).toList(),
              ],
            ],
          ),
        ),
            ),
            if (reviews.isNotEmpty)
              Positioned(
                bottom: 20,
                right: 20,
                child: FloatingActionButton.extended(
                  onPressed: () {
                    _showReviewBottomSheet(listingId);
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
      loading: () => const Center(child: Padding(
        padding: EdgeInsets.all(20),
        child: CircularProgressIndicator(),
      )),
      error: (error, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'Failed to load reviews: ${error.toString()}',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.errorColor,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inDays == 0) {
        return 'Today';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else if (difference.inDays < 30) {
        final weeks = (difference.inDays / 7).floor();
        return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
      } else if (difference.inDays < 365) {
        final months = (difference.inDays / 30).floor();
        return '$months ${months == 1 ? 'month' : 'months'} ago';
      } else {
        final years = (difference.inDays / 365).floor();
        return '$years ${years == 1 ? 'year' : 'years'} ago';
      }
    } catch (e) {
      return 'Recently';
    }
  }

  Widget _buildPhotosTab(Map<String, dynamic> listing) {
    final images = _extractImages(listing);
    
    if (images.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'No photos available',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.secondaryTextColor,
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
        childAspectRatio: 1.2,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            images[index],
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[200],
                child: Icon(
                  Icons.image_not_supported,
                  color: Colors.grey[400],
                  size: 32,
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildBottomBar(Map<String, dynamic> accommodation) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getTotalPrice(),
                  style: AppTheme.headlineSmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
                Text(
                  _getPriceDescription(),
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _selectedRooms.isNotEmpty ? () {
                final bookingData = {
                  'selectedRooms': _selectedRooms,
                  'checkInDate': widget.checkInDate,
                  'checkOutDate': widget.checkOutDate,
                  'checkInTime': widget.checkInTime,
                  'guestCount': widget.guestCount,
                };
                context.push('/accommodation/${widget.accommodationId}/book', extra: bookingData);
              } : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedRooms.isNotEmpty 
                    ? AppTheme.primaryColor 
                    : Colors.grey[300],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                'Book Now',
                style: AppTheme.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getAccommodationDetails(String id) {
    // Mock accommodation details
    return {
      'id': id,
      'name': 'Kigali Marriott Hotel',
      'location': 'Kacyiru, Kigali',
      'rating': 4.8,
      'reviews': 1247,
      'price': '120,000',
      'description': 'Experience luxury and comfort at the Kigali Marriott Hotel, located in the heart of Kigali\'s business district. Our hotel offers world-class amenities, exceptional service, and stunning views of the city.',
      'quickAmenities': ['WiFi', 'Pool', 'Spa', 'Restaurant'],
      'images': [
        'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800',
        'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=800',
        'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=800',
        'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=800',
      ],
      'amenities': [
        {'name': 'Free WiFi', 'icon': Icons.wifi},
        {'name': 'Swimming Pool', 'icon': Icons.pool},
        {'name': 'Spa & Wellness', 'icon': Icons.spa},
        {'name': 'Restaurant', 'icon': Icons.restaurant},
        {'name': 'Fitness Center', 'icon': Icons.fitness_center},
        {'name': 'Business Center', 'icon': Icons.business},
        {'name': 'Parking', 'icon': Icons.local_parking},
        {'name': 'Airport Shuttle', 'icon': Icons.airport_shuttle},
      ],
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
      'reviewList': [
        {
          'userName': 'John Doe',
          'userImage': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100',
          'rating': 5,
          'date': '2 days ago',
          'comment': 'Excellent hotel with great service and amenities. The staff was very helpful and the rooms were clean and comfortable.',
        },
        {
          'userName': 'Sarah Wilson',
          'userImage': 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=100',
          'rating': 4,
          'date': '1 week ago',
          'comment': 'Beautiful hotel with amazing views. The pool area is fantastic and the restaurant serves delicious food.',
        },
        {
          'userName': 'Michael Brown',
          'userImage': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100',
          'rating': 5,
          'date': '2 weeks ago',
          'comment': 'Perfect location for business travelers. The conference facilities are top-notch and the staff is very professional.',
        },
      ],
    };
  }

  Widget _buildSelectableRoomTypeCard(Map<String, dynamic> roomType) {
    final roomTypeKey = roomType['type'];
    final isSelected = _selectedRooms.containsKey(roomTypeKey);
    final quantity = _selectedRooms[roomTypeKey]?['quantity'] ?? 0;
    final maxAvailable = roomType['available'] as int;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppTheme.primaryColor : Colors.grey[200]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  roomType['type'],
                  style: AppTheme.headlineSmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'RWF ${roomType['price']}',
                  style: AppTheme.bodySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.bed,
                size: 16,
                color: AppTheme.secondaryTextColor,
              ),
              const SizedBox(width: 4),
              Text(
                '${roomType['maxGuests']} guests',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.secondaryTextColor,
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.hotel,
                size: 16,
                color: AppTheme.secondaryTextColor,
              ),
              const SizedBox(width: 4),
              Text(
                '${roomType['available']} available',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.secondaryTextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            roomType['amenities'],
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.secondaryTextColor,
            ),
          ),
          const SizedBox(height: 12),
          // Quantity selector
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Quantity:',
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: quantity > 0 ? () {
                            setState(() {
                              if (quantity > 1) {
                                _selectedRooms[roomTypeKey] = {
                                  'roomType': roomType,
                                  'quantity': quantity - 1,
                                };
                              } else {
                                _selectedRooms.remove(roomTypeKey);
                              }
                            });
                          } : null,
                          icon: Icon(
                            Icons.remove,
                            size: 16,
                            color: quantity > 0 ? AppTheme.primaryColor : Colors.grey[400],
                          ),
                          style: IconButton.styleFrom(
                            padding: const EdgeInsets.all(8),
                            minimumSize: const Size(32, 32),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Text(
                            quantity.toString(),
                            style: AppTheme.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: quantity < maxAvailable ? () {
                            setState(() {
                              _selectedRooms[roomTypeKey] = {
                                'roomType': roomType,
                                'quantity': quantity + 1,
                              };
                            });
                          } : null,
                          icon: Icon(
                            Icons.add,
                            size: 16,
                            color: quantity < maxAvailable ? AppTheme.primaryColor : Colors.grey[400],
                          ),
                          style: IconButton.styleFrom(
                            padding: const EdgeInsets.all(8),
                            minimumSize: const Size(32, 32),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (quantity > 0) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Total: RWF ${(int.parse(roomType['price'].replaceAll(',', '')) * quantity).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _getTotalPrice() {
    final accommodation = _getAccommodationDetails(widget.accommodationId);
    
    if (_selectedRooms.isEmpty) {
      return 'RWF ${accommodation['price']}';
    }
    
    int total = 0;
    for (var roomSelection in _selectedRooms.values) {
      final roomType = roomSelection['roomType'] as Map<String, dynamic>;
      final quantity = roomSelection['quantity'] as int;
      final price = int.parse(roomType['price'].toString().replaceAll(',', ''));
      total += price * quantity;
    }
    
    return 'RWF ${total.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  String _getPriceDescription() {
    if (_selectedRooms.isEmpty) {
      return 'per night';
    }
    
    int totalRooms = 0;
    for (var roomSelection in _selectedRooms.values) {
      totalRooms += roomSelection['quantity'] as int;
    }
    
    if (totalRooms == 1) {
      return '1 room - per night';
    } else {
      return '$totalRooms rooms - per night';
    }
  }

  void _showReviewBottomSheet(String listingId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ReviewBottomSheet(
        listingId: listingId,
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
        SnackBar(
          content: const Text('Thank you for your review!'),
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
