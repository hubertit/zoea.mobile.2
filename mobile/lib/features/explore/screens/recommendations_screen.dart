import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/theme/text_theme_extensions.dart';
import '../../../core/widgets/place_card.dart';
import '../../../core/providers/listings_provider.dart';
import '../../../core/providers/country_provider.dart';

class RecommendationsScreen extends ConsumerStatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  ConsumerState<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends ConsumerState<RecommendationsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final Set<String> _favoritePlaces = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        backgroundColor: context.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 32),
          onPressed: () => context.pop(),
          color: context.primaryTextColor,
        ),
        title: Text(
          'Recommendations',
          style: context.headlineSmall.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/search?category=recommendations'),
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
            Tab(text: 'Wildlife'),
            Tab(text: 'Nature'),
            Tab(text: 'History'),
            Tab(text: 'Water'),
            Tab(text: 'Adventure'),
            Tab(text: 'Culture'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRecommendationsList('All'),
          _buildRecommendationsList('Wildlife'),
          _buildRecommendationsList('Nature'),
          _buildRecommendationsList('History'),
          _buildRecommendationsList('Water'),
          _buildRecommendationsList('Adventure'),
          _buildRecommendationsList('Culture'),
        ],
      ),
    );
  }

  Widget _buildRecommendationsList(String category) {
    final selectedCountry = ref.watch(selectedCountryProvider).value;
    final featuredAsync = ref.watch(featuredListingsProvider(selectedCountry?.id));
    
    return featuredAsync.when(
      data: (listings) {
        // Filter by category if not "All"
        List<Map<String, dynamic>> filteredListings = listings;
        if (category != 'All') {
          filteredListings = listings.where((listing) {
            final categoryName = listing['category']?['name'] as String? ?? '';
            // Map category names to match tab categories
            final categoryMap = {
              'Wildlife': ['Wildlife', 'Safari', 'Animal'],
              'Nature': ['Nature', 'Forest', 'Park', 'Mountain'],
              'History': ['History', 'Memorial', 'Museum', 'Heritage'],
              'Water': ['Water', 'Lake', 'Beach', 'River'],
              'Adventure': ['Adventure', 'Hiking', 'Trekking', 'Outdoor'],
              'Culture': ['Culture', 'Art', 'Arts', 'Cultural'],
            };
            final matchingCategories = categoryMap[category] ?? [category];
            return matchingCategories.any((cat) => 
              categoryName.toLowerCase().contains(cat.toLowerCase())
            );
          }).toList();
        }
        
        if (filteredListings.isEmpty) {
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
                  'No recommendations found',
                  style: context.headlineSmall.copyWith(
                    color: context.secondaryTextColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Check back later for new recommendations',
                  style: context.bodyMedium.copyWith(
                    color: context.secondaryTextColor,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: context.primaryColorTheme,
          backgroundColor: context.cardColor,
          onRefresh: () async {
            ref.invalidate(featuredListingsProvider(selectedCountry?.id));
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: filteredListings.length,
            itemBuilder: (context, index) {
              final listing = filteredListings[index];
              return _buildPlaceCardFromListing(listing);
            },
          ),
        );
      },
      loading: () => ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: 5,
        itemBuilder: (context, index) {
          return _buildSkeletonCard();
        },
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
              'Failed to load recommendations',
              style: context.headlineSmall.copyWith(
                color: context.errorColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: context.bodySmall.copyWith(
                color: context.secondaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(featuredListingsProvider(selectedCountry?.id));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primaryColorTheme,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPlaceCardFromListing(Map<String, dynamic> listing) {
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
    
    // Extract location
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
    
    // Extract review count
    final reviewCount = (listing['_count'] as Map<String, dynamic>?)?['reviews'] as int? ?? 
                       listing['reviewCount'] as int? ?? 0;
    
    // Extract price range
    final minPrice = listing['minPrice'] != null
        ? (listing['minPrice'] is String
            ? double.tryParse(listing['minPrice'])
            : (listing['minPrice'] as num?)?.toDouble())
        : null;
    final currency = listing['currency'] as String? ?? 'RWF';
    final priceRange = minPrice != null
        ? 'From ${_formatPrice(minPrice, currency)}'
        : 'Price not available';
    
    // Extract category
    final category = listing['category']?['name'] as String? ?? 
                    listing['type'] as String? ?? 
                    'Place';
    
    // Extract ID
    final id = listing['id'] as String? ?? '';
    
    return PlaceCard(
      name: listing['name'] as String? ?? 'Unknown',
      location: locationText,
      image: imageUrl ?? 'https://via.placeholder.com/400x300',
      rating: rating,
      reviews: reviewCount,
      priceRange: priceRange,
      category: category,
      isFavorite: _favoritePlaces.contains(id),
      onTap: () {
        context.push('/listing/$id');
      },
      onFavorite: () {
        setState(() {
          if (_favoritePlaces.contains(id)) {
            _favoritePlaces.remove(id);
          } else {
            _favoritePlaces.add(id);
          }
        });
      },
    );
  }
  
  String _formatPrice(double price, String currency) {
    if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(price % 1000 == 0 ? 0 : 1)}K $currency';
    }
    return '${price.toStringAsFixed(price % 1 == 0 ? 0 : 2)} $currency';
  }
  
  Widget _buildSkeletonCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: context.grey200,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 20,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: context.grey200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 16,
                  width: 150,
                  decoration: BoxDecoration(
                    color: context.grey200,
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


  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter Recommendations',
                style: context.headlineSmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.primaryTextColor,
                ),
              ),
              const SizedBox(height: 20),
              
              // Rating Filter
              Text(
                'Minimum Rating',
                style: context.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.primaryTextColor,
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
              
              const SizedBox(height: 20),
              
              // Features Filter
              Text(
                'Features',
                style: context.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.primaryTextColor,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildFilterChip('Family Friendly', false),
                  _buildFilterChip('Photography', false),
                  _buildFilterChip('Guided Tours', false),
                  _buildFilterChip('Accessible', false),
                  _buildFilterChip('Parking', false),
                  _buildFilterChip('Restrooms', false),
                ],
              ),
              
              const SizedBox(height: 30),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
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
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.primaryColorTheme,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
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
      backgroundColor: context.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sort Recommendations',
                style: context.headlineSmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.primaryTextColor,
                ),
              ),
              const SizedBox(height: 20),
              
              _buildSortOption('Popular', true),
              _buildSortOption('Rating (High to Low)', false),
              _buildSortOption('Rating (Low to High)', false),
              _buildSortOption('Distance (Near to Far)', false),
              _buildSortOption('Distance (Far to Near)', false),
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
      selectedColor: context.primaryColorTheme.withOpacity(0.2),
      checkmarkColor: context.primaryColorTheme,
      labelStyle: context.bodySmall.copyWith(
        color: isSelected ? context.primaryColorTheme : context.primaryTextColor,
      ),
    );
  }

  Widget _buildSortOption(String label, bool isSelected) {
    return ListTile(
      title: Text(
        label,
        style: context.bodyMedium.copyWith(
          color: context.primaryTextColor,
        ),
      ),
      trailing: isSelected ? Icon(Icons.check, color: context.primaryColorTheme) : null,
      onTap: () {
        Navigator.pop(context);
        // Handle sort selection
      },
    );
  }
}
