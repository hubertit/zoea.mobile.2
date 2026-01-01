import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/widgets/place_card.dart';

class ShoppingScreen extends ConsumerStatefulWidget {
  const ShoppingScreen({super.key});

  @override
  ConsumerState<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends ConsumerState<ShoppingScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'All';
  String _selectedSort = 'Popular';
  final Set<String> _favoritePlaces = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
        centerTitle: false,
        leading: IconButton(
          onPressed: () => context.go('/explore'),
          icon: const Icon(Icons.chevron_left, size: 32),
          style: IconButton.styleFrom(
            foregroundColor: AppTheme.primaryTextColor,
          ),
        ),
        title: Text(
          'Shopping',
          style: AppTheme.headlineMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: context.primaryTextColor,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              context.push('/search?category=shopping');
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelPadding: const EdgeInsets.symmetric(horizontal: 20),
          labelColor: context.primaryColorTheme,
          unselectedLabelColor: context.secondaryTextColor,
          indicatorColor: context.primaryColorTheme,
          labelStyle: AppTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Malls'),
            Tab(text: 'Markets'),
            Tab(text: 'Boutiques'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildShoppingList('All'),
          _buildShoppingList('Malls'),
          _buildShoppingList('Markets'),
          _buildShoppingList('Boutiques'),
        ],
      ),
    );
  }

  Widget _buildShoppingList(String category) {
    final shoppingPlaces = _getMockShoppingPlaces(category);

    if (shoppingPlaces.isEmpty) {
      return _buildEmptyState(category);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: shoppingPlaces.length,
      itemBuilder: (context, index) {
        final place = shoppingPlaces[index];
        return PlaceCard(
          name: place['name'],
          location: place['location'],
          image: place['image'],
          rating: place['rating'],
          reviews: place['reviews'],
          priceRange: place['priceRange'],
          category: place['category'],
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
          isFavorite: _favoritePlaces.contains(place['id']),
        );
      },
    );
  }

  Widget _buildEmptyState(String category) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: context.secondaryTextColor,
            ),
            const SizedBox(height: 16),
            Text(
              'No $category found',
              style: AppTheme.headlineSmall.copyWith(
                color: context.secondaryTextColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters or check back later',
              style: AppTheme.bodyMedium.copyWith(
                color: context.secondaryTextColor,
              ),
              textAlign: TextAlign.center,
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
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter by',
              style: AppTheme.headlineSmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            _buildFilterOption('All', 'All'),
            _buildFilterOption('Malls', 'Malls'),
            _buildFilterOption('Markets', 'Markets'),
            _buildFilterOption('Boutiques', 'Boutiques'),
            const SizedBox(height: 20),
            Text(
              'Sort by',
              style: AppTheme.headlineSmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            _buildSortOption('Popular', 'Popular'),
            _buildSortOption('Rating', 'Rating'),
            _buildSortOption('Distance', 'Distance'),
            _buildSortOption('Price', 'Price'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(String value, String label) {
    return RadioListTile<String>(
      title: Text(label),
      value: value,
      groupValue: _selectedFilter,
      onChanged: (value) {
        setState(() {
          _selectedFilter = value!;
        });
        Navigator.pop(context);
      },
      activeColor: AppTheme.primaryColor,
    );
  }

  Widget _buildSortOption(String value, String label) {
    return RadioListTile<String>(
      title: Text(label),
      value: value,
      groupValue: _selectedSort,
      onChanged: (value) {
        setState(() {
          _selectedSort = value!;
        });
        Navigator.pop(context);
      },
      activeColor: AppTheme.primaryColor,
    );
  }

  List<Map<String, dynamic>> _getMockShoppingPlaces(String category) {
    final allPlaces = [
      {
        'id': 'shop_1',
        'name': 'Kigali City Tower',
        'location': 'Kigali, Rwanda',
        'image': 'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=500',
        'rating': 4.3,
        'reviews': 456,
        'priceRange': 'Shopping',
        'category': 'Mall',
        'type': 'Malls',
      },
      {
        'id': 'shop_2',
        'name': 'Kimisagara Market',
        'location': 'Kimisagara, Kigali',
        'image': 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=500',
        'rating': 4.2,
        'reviews': 89,
        'priceRange': 'Market',
        'category': 'Market',
        'type': 'Markets',
      },
      {
        'id': 'shop_3',
        'name': 'Rwanda Fashion House',
        'location': 'Nyarutarama, Kigali',
        'image': 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=500',
        'rating': 4.6,
        'reviews': 123,
        'priceRange': 'Boutique',
        'category': 'Boutique',
        'type': 'Boutiques',
      },
      {
        'id': 'shop_4',
        'name': 'Kigali Heights Mall',
        'location': 'Kigali Heights, Rwanda',
        'image': 'https://images.unsplash.com/photo-1555529902-1c0a6a2b5b5b?w=500',
        'rating': 4.4,
        'reviews': 234,
        'priceRange': 'Mall',
        'category': 'Mall',
        'type': 'Malls',
      },
      {
        'id': 'shop_5',
        'name': 'Nyabugogo Market',
        'location': 'Nyabugogo, Kigali',
        'image': 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=500',
        'rating': 4.1,
        'reviews': 156,
        'priceRange': 'Market',
        'category': 'Market',
        'type': 'Markets',
      },
      {
        'id': 'shop_6',
        'name': 'Rwanda Crafts Boutique',
        'location': 'Kacyiru, Kigali',
        'image': 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=500',
        'rating': 4.7,
        'reviews': 78,
        'priceRange': 'Boutique',
        'category': 'Boutique',
        'type': 'Boutiques',
      },
      {
        'id': 'shop_7',
        'name': 'Kigali Convention Centre Shops',
        'location': 'Kigali, Rwanda',
        'image': 'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=500',
        'rating': 4.0,
        'reviews': 67,
        'priceRange': 'Mall',
        'category': 'Mall',
        'type': 'Malls',
      },
      {
        'id': 'shop_8',
        'name': 'Kimironko Market',
        'location': 'Kimironko, Kigali',
        'image': 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=500',
        'rating': 4.3,
        'reviews': 98,
        'priceRange': 'Market',
        'category': 'Market',
        'type': 'Markets',
      },
    ];

    if (category == 'All') {
      return allPlaces;
    }

    return allPlaces.where((place) => place['type'] == category).toList();
  }
}
