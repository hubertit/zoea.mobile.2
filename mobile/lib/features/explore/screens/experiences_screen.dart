import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/theme/text_theme_extensions.dart';
import '../../../core/widgets/place_card.dart';
import '../../../core/providers/tours_provider.dart';
import '../../../core/providers/favorites_provider.dart';

class ExperiencesScreen extends ConsumerStatefulWidget {
  const ExperiencesScreen({super.key});

  @override
  ConsumerState<ExperiencesScreen> createState() => _ExperiencesScreenState();
}

class _ExperiencesScreenState extends ConsumerState<ExperiencesScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'All';
  String _selectedSort = 'Popular';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
        leading: IconButton(
          onPressed: () => context.go('/explore'),
          icon: const Icon(Icons.chevron_left, size: 32),
          style: IconButton.styleFrom(
            foregroundColor: context.primaryTextColor,
          ),
        ),
        title: Text(
          'Experiences',
          style: context.headlineMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: context.primaryTextColor,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/search?category=experiences'),
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
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: context.primaryColorTheme,
          labelColor: context.primaryColorTheme,
          unselectedLabelColor: context.secondaryTextColor,
          labelStyle: context.bodySmall.copyWith(fontWeight: FontWeight.w600),
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelPadding: const EdgeInsets.symmetric(horizontal: 16),
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Tours'),
            Tab(text: 'Adventures'),
            Tab(text: 'Cultural'),
            Tab(text: 'Operators'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildExperiencesList('All'),
          _buildExperiencesList('Tours'),
          _buildExperiencesList('Adventures'),
          _buildExperiencesList('Cultural'),
          _buildTourOperatorsList(),
        ],
      ),
    );
  }

  Widget _buildExperiencesList(String category) {
    // Map category to tour type for filtering
    String? typeFilter;
    if (category == 'Tours') {
      typeFilter = null; // Show all tours
    } else if (category == 'Adventures') {
      typeFilter = 'adventure';
    } else if (category == 'Cultural') {
      typeFilter = 'cultural';
    }

    final toursAsync = ref.watch(
      toursProvider(
        ToursParams(
          page: 1,
          limit: 100,
          status: 'active',
          type: category == 'All' ? null : typeFilter,
          search: null,
        ),
      ),
    );

    return toursAsync.when(
      data: (response) {
        final tours = (response['data'] as List?)?.cast<Map<String, dynamic>>() ?? [];

        if (tours.isEmpty) {
          return _buildEmptyState(category);
        }

        return RefreshIndicator(
          color: context.primaryColorTheme,
          backgroundColor: context.cardColor,
          onRefresh: () async {
            ref.invalidate(
              toursProvider(
                ToursParams(
                  page: 1,
                  limit: 100,
                  status: 'active',
                  type: category == 'All' ? null : typeFilter,
                  search: null,
                ),
              ),
            );
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tours.length,
            itemBuilder: (context, index) {
              final tour = tours[index];
              return _buildExperienceCard(tour);
            },
          ),
        );
      },
      loading: () => Center(
        child: CircularProgressIndicator(
          color: context.primaryColorTheme,
        ),
      ),
      error: (error, stack) => Center(
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
              'Failed to load experiences',
              style: context.titleMedium.copyWith(
                color: context.errorColor,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                ref.invalidate(
                  toursProvider(
                    ToursParams(
                      page: 1,
                      limit: 100,
                      status: 'active',
                      type: category == 'All' ? null : typeFilter,
                      search: null,
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

  Widget _buildExperienceCard(Map<String, dynamic> tour) {
    final id = tour['id'] as String? ?? '';
    final name = tour['name'] as String? ?? 'Unknown';
    final startLocationName = tour['startLocationName'] as String? ?? '';
    final city = tour['city'] as Map<String, dynamic>?;
    final cityName = city?['name'] as String? ?? '';
    final location = startLocationName.isNotEmpty 
        ? '$startLocationName${cityName.isNotEmpty ? ', $cityName' : ''}'
        : cityName.isNotEmpty ? cityName : 'Location not available';
    
    final images = tour['images'] as List? ?? [];
    String? imageUrl;
    if (images.isNotEmpty && images[0] != null) {
      if (images[0] is Map) {
        final imageMap = images[0] as Map<String, dynamic>;
        imageUrl = imageMap['media']?['url'] as String?;
      } else {
        imageUrl = images[0] as String?;
      }
    }
    
    final rating = (tour['rating'] as num?)?.toDouble() ?? 0.0;
    final reviewCount = (tour['reviewCount'] as num?)?.toInt() ?? 
                       (tour['review_count'] as num?)?.toInt() ?? 0;
    
    final pricePerPerson = tour['pricePerPerson'] as num?;
    final currency = tour['currency'] as String? ?? 'USD';
    final priceRange = pricePerPerson != null
        ? '$currency ${pricePerPerson.toDouble().toStringAsFixed(0)}/person'
        : 'Price not available';
    
    final category = tour['category'] as Map<String, dynamic>?;
    final categoryName = category?['name'] as String? ?? 'Tour';
    final tourType = tour['type'] as String? ?? 'Tour';

    // Check if favorite (tours use tourId, not listingId)
    final favoritesAsync = ref.watch(favoritesProvider(const FavoritesParams(page: 1, limit: 1000)));
    final isFavorite = favoritesAsync.maybeWhen(
      data: (favoritesData) {
        final favorites = (favoritesData['data'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        return favorites.any((fav) => fav['tourId'] == id || fav['tour_id'] == id);
      },
      orElse: () => false,
    );

    return PlaceCard(
      name: name,
      location: location,
      image: imageUrl ?? '',
      rating: rating,
      reviews: reviewCount,
      priceRange: priceRange,
      category: categoryName.isNotEmpty ? categoryName : tourType,
      onTap: () {
        // Navigate to tour detail - we'll need to create a tour detail screen
        // For now, navigate to tour booking with tour info
        context.push('/tour-booking', extra: {
          'tourId': id,
          'tourName': name,
          'tourLocation': location,
          'tourImage': imageUrl ?? '',
          'tourRating': rating,
        });
      },
      onFavorite: () async {
        // Toggle favorite for tour
        final favoritesService = ref.read(favoritesServiceProvider);
        if (isFavorite) {
          await favoritesService.removeFromFavorites(tourId: id);
        } else {
          await favoritesService.addTourToFavorites(id);
        }
        ref.invalidate(favoritesProvider(const FavoritesParams(page: 1, limit: 1000)));
      },
      isFavorite: isFavorite,
    );
  }

  Widget _buildTourOperatorsList() {
    // Fetch tours and group by operator
    // In the future, this could fetch from a dedicated tour operators endpoint
    final toursAsync = ref.watch(
      toursProvider(
        ToursParams(
          page: 1,
          limit: 100,
          status: 'active',
        ),
      ),
    );

    return toursAsync.when(
      data: (response) {
        final tours = (response['data'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        
        // Group tours by operator
        final operatorMap = <String, Map<String, dynamic>>{};
        for (final tour in tours) {
          final operator = tour['operator'] as Map<String, dynamic>?;
          if (operator != null) {
            final operatorId = operator['id'] as String? ?? '';
            if (operatorId.isNotEmpty && !operatorMap.containsKey(operatorId)) {
              operatorMap[operatorId] = {
                'id': operatorId,
                'name': operator['companyName'] as String? ?? 'Unknown Operator',
                'rating': operator['averageRating'] as num? ?? 0.0,
                'tours': <Map<String, dynamic>>[],
              };
            }
            if (operatorMap.containsKey(operatorId)) {
              (operatorMap[operatorId]!['tours'] as List).add(tour);
            }
          }
        }
        
        final operators = operatorMap.values.toList();

        if (operators.isEmpty) {
          return _buildEmptyState('Operators');
        }

        return RefreshIndicator(
          color: context.primaryColorTheme,
          backgroundColor: context.cardColor,
          onRefresh: () async {
            ref.invalidate(
              toursProvider(
                ToursParams(
                  page: 1,
                  limit: 100,
                  status: 'active',
                ),
              ),
            );
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: operators.length,
            itemBuilder: (context, index) {
              final operator = operators[index];
              return _buildTourOperatorCard(operator);
            },
          ),
        );
      },
      loading: () => Center(
        child: CircularProgressIndicator(
          color: context.primaryColorTheme,
        ),
      ),
      error: (error, stack) => Center(
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
              'Failed to load operators',
              style: context.titleMedium.copyWith(
                color: context.errorColor,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                ref.invalidate(
                  toursProvider(
                    ToursParams(
                      page: 1,
                      limit: 100,
                      status: 'active',
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

  Widget _buildTourOperatorCard(Map<String, dynamic> operator) {
    final name = operator['name'] as String? ?? 'Unknown Operator';
    final rating = (operator['rating'] as num?)?.toDouble() ?? 0.0;
    final tours = operator['tours'] as List<Map<String, dynamic>>? ?? [];
    
    // Get location from first tour
    String location = 'Location not available';
    String? imageUrl;
    String priceRange = 'Price not available';
    String? phone;
    String? description;
    
    if (tours.isNotEmpty) {
      final firstTour = tours[0];
      final city = firstTour['city'] as Map<String, dynamic>?;
      final cityName = city?['name'] as String? ?? '';
      final startLocationName = firstTour['startLocationName'] as String? ?? '';
      location = startLocationName.isNotEmpty 
          ? '$startLocationName${cityName.isNotEmpty ? ', $cityName' : ''}'
          : cityName.isNotEmpty ? cityName : 'Location not available';
      
      final images = firstTour['images'] as List? ?? [];
      if (images.isNotEmpty && images[0] != null) {
        if (images[0] is Map) {
          final imageMap = images[0] as Map<String, dynamic>;
          imageUrl = imageMap['media']?['url'] as String?;
        } else {
          imageUrl = images[0] as String?;
        }
      }
      
      final pricePerPerson = firstTour['pricePerPerson'] as num?;
      final currency = firstTour['currency'] as String? ?? 'USD';
      if (pricePerPerson != null) {
        priceRange = 'Starting from $currency ${pricePerPerson.toDouble().toStringAsFixed(0)}';
      }
      
      final operatorData = firstTour['operator'] as Map<String, dynamic>?;
      phone = operatorData?['contactPhone'] as String?;
      description = firstTour['description'] as String? ?? firstTour['shortDescription'] as String?;
    }
    
    final reviewCount = tours.length; // Use tour count as a proxy

    return GestureDetector(
      onTap: () {
        // Navigate to operator detail or first tour
        if (tours.isNotEmpty) {
          final firstTour = tours[0];
          final tourId = firstTour['id'] as String? ?? '';
          context.push('/tour-booking', extra: {
            'tourId': tourId,
            'tourName': firstTour['name'] as String? ?? 'Tour',
            'tourLocation': location,
            'tourImage': imageUrl ?? '',
            'tourRating': (firstTour['rating'] as num?)?.toDouble() ?? 0.0,
          });
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
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: imageUrl != null && imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            height: 200,
                            color: context.grey200,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: context.primaryColorTheme,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 200,
                            color: context.grey200,
                            child: Icon(
                              Icons.business,
                              size: 50,
                              color: context.secondaryTextColor,
                            ),
                          ),
                        )
                      : Container(
                          height: 200,
                          color: context.grey200,
                          child: Icon(
                            Icons.business,
                            size: 50,
                            color: context.secondaryTextColor,
                          ),
                        ),
                ),
              ],
            ),
            // Business details
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: context.headlineSmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.primaryTextColor,
                    ),
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
                          location,
                          style: context.bodyMedium.copyWith(
                            color: context.secondaryTextColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 16,
                        color: Colors.amber[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        rating.toStringAsFixed(1),
                        style: context.bodyMedium.copyWith(
                          fontWeight: FontWeight.w500,
                          color: context.primaryTextColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '($reviewCount reviews)',
                        style: context.bodySmall.copyWith(
                          color: context.secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                  if (description != null && description.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      description.length > 100 
                          ? '${description.substring(0, 100)}...'
                          : description,
                      style: context.bodySmall.copyWith(
                        color: context.secondaryTextColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Starting from',
                            style: context.bodySmall.copyWith(
                              color: context.secondaryTextColor,
                            ),
                          ),
                          Text(
                            priceRange,
                            style: context.bodyLarge.copyWith(
                              color: context.primaryColorTheme,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      if (phone != null && phone.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Contact',
                              style: context.bodySmall.copyWith(
                                color: context.secondaryTextColor,
                              ),
                            ),
                            Text(
                              phone,
                              style: context.bodyMedium.copyWith(
                                fontWeight: FontWeight.w500,
                                color: context.primaryTextColor,
                              ),
                            ),
                          ],
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
            Icons.explore,
            size: 80,
            color: context.secondaryTextColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No $category found',
            style: context.headlineSmall.copyWith(
              color: context.secondaryTextColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for new experiences',
            style: context.bodyMedium.copyWith(
              color: context.secondaryTextColor,
            ),
            textAlign: TextAlign.center,
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
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter by',
              style: context.headlineSmall.copyWith(
                fontWeight: FontWeight.w600,
                color: context.primaryTextColor,
              ),
            ),
            const SizedBox(height: 16),
            _buildFilterOption('All', 'All'),
            _buildFilterOption('Tours', 'Tours'),
            _buildFilterOption('Adventures', 'Adventures'),
            _buildFilterOption('Cultural', 'Cultural'),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(String label, String value) {
    return ListTile(
      title: Text(label),
      leading: Radio<String>(
        value: value,
        groupValue: _selectedFilter,
        onChanged: (value) {
          setState(() {
            _selectedFilter = value!;
          });
          Navigator.pop(context);
        },
        activeColor: context.primaryColorTheme,
      ),
      onTap: () {
        setState(() {
          _selectedFilter = value;
        });
        Navigator.pop(context);
      },
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
                color: context.primaryTextColor,
              ),
            ),
            const SizedBox(height: 16),
            _buildSortOption('Popular', 'Popular'),
            _buildSortOption('Rating', 'Rating'),
            _buildSortOption('Distance', 'Distance'),
            _buildSortOption('Price', 'Price'),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String label, String value) {
    return ListTile(
      title: Text(label),
      leading: Radio<String>(
        value: value,
        groupValue: _selectedSort,
        onChanged: (value) {
          setState(() {
            _selectedSort = value!;
          });
          Navigator.pop(context);
        },
        activeColor: context.primaryColorTheme,
      ),
      onTap: () {
        setState(() {
          _selectedSort = value;
        });
        Navigator.pop(context);
      },
    );
  }
}
