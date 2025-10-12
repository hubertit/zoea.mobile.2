import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/place_card.dart';
import 'place_detail_screen.dart';

class DiningScreen extends ConsumerStatefulWidget {
  const DiningScreen({super.key});

  @override
  ConsumerState<DiningScreen> createState() => _DiningScreenState();
}

class _DiningScreenState extends ConsumerState<DiningScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'All';
  String _selectedSort = 'Popular';
  Set<String> _favoritePlaces = {};

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
          'Dining',
          style: AppTheme.headlineMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
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
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.secondaryTextColor,
          indicatorColor: AppTheme.primaryColor,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Restaurants'),
            Tab(text: 'Cafes'),
            Tab(text: 'Fast Food'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDiningList('All'),
          _buildDiningList('Restaurants'),
          _buildDiningList('Cafes'),
          _buildDiningList('Fast Food'),
        ],
      ),
    );
  }

  Widget _buildDiningList(String category) {
    final diningPlaces = _getMockDiningPlaces(category);

    if (diningPlaces.isEmpty) {
      return _buildEmptyState(category);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: diningPlaces.length,
      itemBuilder: (context, index) {
        final place = diningPlaces[index];
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
            'No $category found',
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

  List<Map<String, dynamic>> _getMockDiningPlaces(String category) {
    final allPlaces = [
      {
        'id': '1',
        'name': 'The Hut Restaurant',
        'location': 'Kigali, Rwanda',
        'image': 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=500',
        'rating': 4.5,
        'reviews': 128,
        'priceRange': '\$\$',
        'category': 'Restaurant',
        'type': 'Restaurants',
      },
      {
        'id': '2',
        'name': 'Bourbon Coffee',
        'location': 'Kigali Heights, Rwanda',
        'image': 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=500',
        'rating': 4.2,
        'reviews': 95,
        'priceRange': '\$',
        'category': 'Cafe',
        'type': 'Cafes',
      },
      {
        'id': '3',
        'name': 'KFC Kigali',
        'location': 'Kigali City Center',
        'image': 'https://images.unsplash.com/photo-1571091718767-18b5b1457add?w=500',
        'rating': 4.0,
        'reviews': 67,
        'priceRange': '\$',
        'category': 'Fast Food',
        'type': 'Fast Food',
      },
      {
        'id': '4',
        'name': 'Sole Luna Restaurant',
        'location': 'Kimisagara, Kigali',
        'image': 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=500',
        'rating': 4.7,
        'reviews': 203,
        'priceRange': '\$\$\$',
        'category': 'Restaurant',
        'type': 'Restaurants',
      },
      {
        'id': '5',
        'name': 'Café Neo',
        'location': 'Nyarutarama, Kigali',
        'image': 'https://images.unsplash.com/photo-1554118811-1e0d58224f24?w=500',
        'rating': 4.3,
        'reviews': 89,
        'priceRange': '\$\$',
        'category': 'Cafe',
        'type': 'Cafes',
      },
      {
        'id': '6',
        'name': 'Pizza Inn',
        'location': 'Kacyiru, Kigali',
        'image': 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=500',
        'rating': 4.1,
        'reviews': 156,
        'priceRange': '\$\$',
        'category': 'Fast Food',
        'type': 'Fast Food',
      },
    ];

    if (category == 'All') {
      return allPlaces;
    }

    return allPlaces.where((place) => place['type'] == category).toList();
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
            const SizedBox(height: 16),
            _buildFilterOption('All', 'All'),
            _buildFilterOption('Restaurants', 'Restaurants'),
            _buildFilterOption('Cafes', 'Cafes'),
            _buildFilterOption('Fast Food', 'Fast Food'),
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
        activeColor: AppTheme.primaryColor,
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
              'Sort by',
              style: AppTheme.headlineSmall.copyWith(
                fontWeight: FontWeight.w600,
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
        activeColor: AppTheme.primaryColor,
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
