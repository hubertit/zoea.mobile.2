import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/place_card.dart';

class CategoryPlacesScreen extends ConsumerStatefulWidget {
  final String category;
  
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
  final Set<String> _favoritePlaces = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _getTabCount(), vsync: this);
  }

  int _getTabCount() {
    switch (widget.category.toLowerCase()) {
      case 'dining':
        return 4; // All, Restaurants, Cafes, Fast Food
      case 'experiences':
        return 5; // All, Adventure, Cultural, Nature, Water
      case 'nightlife':
        return 4; // All, Bars, Clubs, Lounges
      case 'accommodation':
        return 4; // All, Hotels, Hostels, Resorts
      case 'shopping':
        return 4; // All, Malls, Markets, Boutiques
      default:
        return 2; // All, Popular
    }
  }

  List<String> _getTabLabels() {
    switch (widget.category.toLowerCase()) {
      case 'dining':
        return ['All', 'Restaurants', 'Cafes', 'Fast Food'];
      case 'experiences':
        return ['All', 'Adventure', 'Cultural', 'Nature', 'Water'];
      case 'nightlife':
        return ['All', 'Bars', 'Clubs', 'Lounges'];
      case 'accommodation':
        return ['All', 'Hotels', 'Hostels', 'Resorts'];
      case 'shopping':
        return ['All', 'Malls', 'Markets', 'Boutiques'];
      default:
        return ['All', 'Popular'];
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          widget.category,
          style: AppTheme.headlineSmall.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/search?category=${widget.category.toLowerCase()}'),
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
          indicatorColor: AppTheme.primaryColor,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.secondaryTextColor,
          labelStyle: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w600),
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelPadding: const EdgeInsets.symmetric(horizontal: 16),
          tabs: _getTabLabels().map((label) => Tab(text: label)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _getTabLabels().map((label) => _buildPlacesList(label)).toList(),
      ),
    );
  }

  Widget _buildPlacesList(String subcategory) {
    final places = _getMockPlaces(subcategory);
    
    if (places.isEmpty) {
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
              'No ${widget.category.toLowerCase()} found',
              style: AppTheme.headlineSmall.copyWith(
                color: AppTheme.secondaryTextColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for new ${widget.category.toLowerCase()}',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.secondaryTextColor,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: places.length,
      itemBuilder: (context, index) {
        final place = places[index];
        return PlaceCard(
          name: place['name'],
          location: place['location'],
          image: place['image'],
          rating: place['rating'],
          reviews: place['reviews'],
          priceRange: place['priceRange'],
          category: place['category'],
          isFavorite: _favoritePlaces.contains(place['id']),
          onTap: () {
            context.push('/place/${place['id']}');
          },
          onFavorite: () {
            setState(() {
              if (_favoritePlaces.contains(place['id'])) {
                _favoritePlaces.remove(place['id']);
              } else {
                _favoritePlaces.add(place['id']);
              }
            });
          },
        );
      },
    );
  }

  List<Map<String, dynamic>> _getMockPlaces(String subcategory) {
    final allPlaces = _getAllMockPlaces();
    
    if (subcategory == 'All') {
      return allPlaces;
    }
    
    return allPlaces.where((place) => place['subcategory'] == subcategory).toList();
  }

  List<Map<String, dynamic>> _getAllMockPlaces() {
    switch (widget.category.toLowerCase()) {
      case 'dining':
        return _getDiningPlaces();
      case 'experiences':
        return _getExperiencePlaces();
      case 'nightlife':
        return _getNightlifePlaces();
      case 'accommodation':
        return _getAccommodationPlaces();
      case 'shopping':
        return _getShoppingPlaces();
      default:
        return _getGenericPlaces();
    }
  }

  List<Map<String, dynamic>> _getDiningPlaces() {
    return [
      {
        'id': 'dining_1',
        'name': 'The Hut Restaurant',
        'location': 'Kigali, Rwanda',
        'image': 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800',
        'rating': 4.5,
        'reviews': 234,
        'priceRange': '\$\$',
        'category': 'Dining',
        'subcategory': 'Restaurants',
      },
      {
        'id': 'dining_2',
        'name': 'Café de la Paix',
        'location': 'Kigali, Rwanda',
        'image': 'https://images.unsplash.com/photo-1554118811-1e0d58224f24?w=800',
        'rating': 4.3,
        'reviews': 189,
        'priceRange': '\$',
        'category': 'Dining',
        'subcategory': 'Cafes',
      },
      {
        'id': 'dining_3',
        'name': 'KFC Kigali',
        'location': 'Kigali, Rwanda',
        'image': 'https://images.unsplash.com/photo-1571091718767-18b5b1457add?w=800',
        'rating': 4.1,
        'reviews': 156,
        'priceRange': '\$',
        'category': 'Dining',
        'subcategory': 'Fast Food',
      },
    ];
  }

  List<Map<String, dynamic>> _getExperiencePlaces() {
    return [
      {
        'id': 'exp_1',
        'name': 'Gorilla Trekking',
        'location': 'Volcanoes National Park',
        'image': 'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=800',
        'rating': 4.9,
        'reviews': 1247,
        'priceRange': 'From \$1,500',
        'category': 'Experiences',
        'subcategory': 'Adventure',
      },
      {
        'id': 'exp_2',
        'name': 'Cultural Village Tour',
        'location': 'Kigali, Rwanda',
        'image': 'https://images.unsplash.com/photo-1541961017774-22349e4a1262?w=800',
        'rating': 4.6,
        'reviews': 456,
        'priceRange': 'From \$50',
        'category': 'Experiences',
        'subcategory': 'Cultural',
      },
    ];
  }

  List<Map<String, dynamic>> _getNightlifePlaces() {
    return [
      {
        'id': 'night_1',
        'name': 'Sky Lounge',
        'location': 'Kigali, Rwanda',
        'image': 'https://images.unsplash.com/photo-1572116469696-31de0f17cc34?w=800',
        'rating': 4.4,
        'reviews': 312,
        'priceRange': '\$\$',
        'category': 'Nightlife',
        'subcategory': 'Bars',
      },
      {
        'id': 'night_2',
        'name': 'Club Amahoro',
        'location': 'Kigali, Rwanda',
        'image': 'https://images.unsplash.com/photo-1571266028243-e68ba4a6b4e0?w=800',
        'rating': 4.2,
        'reviews': 278,
        'priceRange': '\$\$\$',
        'category': 'Nightlife',
        'subcategory': 'Clubs',
      },
    ];
  }

  List<Map<String, dynamic>> _getAccommodationPlaces() {
    return [
      {
        'id': 'acc_1',
        'name': 'Kigali Marriott Hotel',
        'location': 'Kigali, Rwanda',
        'image': 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800',
        'rating': 4.7,
        'reviews': 892,
        'priceRange': '\$\$\$\$',
        'category': 'Accommodation',
        'subcategory': 'Hotels',
      },
      {
        'id': 'acc_2',
        'name': 'Backpackers Hostel',
        'location': 'Kigali, Rwanda',
        'image': 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=800',
        'rating': 4.1,
        'reviews': 234,
        'priceRange': '\$',
        'category': 'Accommodation',
        'subcategory': 'Hostels',
      },
    ];
  }

  List<Map<String, dynamic>> _getShoppingPlaces() {
    return [
      {
        'id': 'shop_1',
        'name': 'Kigali City Mall',
        'location': 'Kigali, Rwanda',
        'image': 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=800',
        'rating': 4.3,
        'reviews': 567,
        'priceRange': '\$\$',
        'category': 'Shopping',
        'subcategory': 'Malls',
      },
      {
        'id': 'shop_2',
        'name': 'Kimisagara Market',
        'location': 'Kigali, Rwanda',
        'image': 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=800',
        'rating': 4.0,
        'reviews': 189,
        'priceRange': '\$',
        'category': 'Shopping',
        'subcategory': 'Markets',
      },
    ];
  }

  List<Map<String, dynamic>> _getGenericPlaces() {
    return [
      {
        'id': 'gen_1',
        'name': 'Popular Place 1',
        'location': 'Kigali, Rwanda',
        'image': 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=800',
        'rating': 4.5,
        'reviews': 123,
        'priceRange': '\$\$',
        'category': widget.category,
        'subcategory': 'Popular',
      },
    ];
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
                'Filter ${widget.category}',
                style: AppTheme.headlineSmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),

              // Rating Filter
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

              const SizedBox(height: 20),

              // Features Filter
              Text(
                'Features',
                style: AppTheme.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildFilterChip('Family Friendly', false),
                  _buildFilterChip('Parking', false),
                  _buildFilterChip('WiFi', false),
                  _buildFilterChip('Accessible', false),
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
                'Sort ${widget.category}',
                style: AppTheme.headlineSmall.copyWith(
                  fontWeight: FontWeight.w600,
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
