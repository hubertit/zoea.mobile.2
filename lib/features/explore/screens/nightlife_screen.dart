import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/place_card.dart';

class NightlifeScreen extends ConsumerStatefulWidget {
  const NightlifeScreen({super.key});

  @override
  ConsumerState<NightlifeScreen> createState() => _NightlifeScreenState();
}

class _NightlifeScreenState extends ConsumerState<NightlifeScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
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
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 32),
          onPressed: () => context.pop(),
          color: AppTheme.primaryTextColor,
        ),
        title: Text(
          'Nightlife',
          style: AppTheme.headlineSmall.copyWith(
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
          indicatorColor: AppTheme.primaryColor,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.secondaryTextColor,
          labelStyle: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w600),
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelPadding: const EdgeInsets.symmetric(horizontal: 16),
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Bars'),
            Tab(text: 'Clubs'),
            Tab(text: 'Lounges'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNightlifeList('All'),
          _buildNightlifeList('Bars'),
          _buildNightlifeList('Clubs'),
          _buildNightlifeList('Lounges'),
        ],
      ),
    );
  }

  Widget _buildNightlifeList(String category) {
    final places = _getMockNightlifePlaces(category);
    
    if (places.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.nightlife,
              size: 64,
              color: AppTheme.secondaryTextColor,
            ),
            const SizedBox(height: 16),
            Text(
              'No nightlife venues found',
              style: AppTheme.headlineSmall.copyWith(
                color: AppTheme.secondaryTextColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for new venues',
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
              'Filter Nightlife',
              style: AppTheme.headlineSmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            // Add filter options here
            Text(
              'Filter options coming soon...',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.secondaryTextColor,
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
              'Sort Nightlife',
              style: AppTheme.headlineSmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            // Add sort options here
            Text(
              'Sort options coming soon...',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.secondaryTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getMockNightlifePlaces(String category) {
    final allPlaces = [
      {
        'id': '1',
        'name': 'Sky Lounge',
        'location': 'Kigali Heights, Kigali',
        'image': 'https://images.unsplash.com/photo-1571266028243-e68f96d1e2b5?w=500',
        'rating': 4.5,
        'reviews': 128,
        'priceRange': 'RWF 15,000 - 25,000',
        'category': 'Lounge',
        'type': 'Lounges',
      },
      {
        'id': '2',
        'name': 'Club Amahoro',
        'location': 'Kimisagara, Kigali',
        'image': 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=500',
        'rating': 4.2,
        'reviews': 95,
        'priceRange': 'RWF 10,000 - 20,000',
        'category': 'Club',
        'type': 'Clubs',
      },
      {
        'id': '3',
        'name': 'Rooftop Bar',
        'location': 'Kacyiru, Kigali',
        'image': 'https://images.unsplash.com/photo-1514933651103-005eec06c04b?w=500',
        'rating': 4.7,
        'reviews': 156,
        'priceRange': 'RWF 12,000 - 22,000',
        'category': 'Bar',
        'type': 'Bars',
      },
      {
        'id': '4',
        'name': 'Jazz Lounge',
        'location': 'Nyarutarama, Kigali',
        'image': 'https://images.unsplash.com/photo-1493225457124-a3b16123c1c0?w=500',
        'rating': 4.4,
        'reviews': 89,
        'priceRange': 'RWF 8,000 - 18,000',
        'category': 'Lounge',
        'type': 'Lounges',
      },
      {
        'id': '5',
        'name': 'Dance Club',
        'location': 'Remera, Kigali',
        'image': 'https://images.unsplash.com/photo-1571266028243-e68f96d1e2b5?w=500',
        'rating': 4.3,
        'reviews': 112,
        'priceRange': 'RWF 10,000 - 20,000',
        'category': 'Club',
        'type': 'Clubs',
      },
      {
        'id': '6',
        'name': 'Cocktail Bar',
        'location': 'Kiyovu, Kigali',
        'image': 'https://images.unsplash.com/photo-1514933651103-005eec06c04b?w=500',
        'rating': 4.6,
        'reviews': 134,
        'priceRange': 'RWF 15,000 - 25,000',
        'category': 'Bar',
        'type': 'Bars',
      },
      {
        'id': '7',
        'name': 'Wine Lounge',
        'location': 'Gacuriro, Kigali',
        'image': 'https://images.unsplash.com/photo-1493225457124-a3b16123c1c0?w=500',
        'rating': 4.8,
        'reviews': 167,
        'priceRange': 'RWF 20,000 - 35,000',
        'category': 'Lounge',
        'type': 'Lounges',
      },
      {
        'id': '8',
        'name': 'Sports Bar',
        'location': 'Kimironko, Kigali',
        'image': 'https://images.unsplash.com/photo-1514933651103-005eec06c04b?w=500',
        'rating': 4.1,
        'reviews': 78,
        'priceRange': 'RWF 8,000 - 15,000',
        'category': 'Bar',
        'type': 'Bars',
      },
    ];

    if (category == 'All') {
      return allPlaces;
    }

    return allPlaces.where((place) => place['type'] == category).toList();
  }
}
