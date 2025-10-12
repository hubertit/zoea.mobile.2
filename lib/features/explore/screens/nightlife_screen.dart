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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
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
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.backgroundColor,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search bars, clubs, lounges...',
                hintStyle: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.secondaryTextColor,
                ),
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppTheme.primaryColor,
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildNightlifeList('All'),
                _buildNightlifeList('Bars'),
                _buildNightlifeList('Clubs'),
                _buildNightlifeList('Lounges'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNightlifeList(String category) {
    final places = _getMockNightlifePlaces(category);
    final filteredPlaces = _searchQuery.isEmpty
        ? places
        : places.where((place) {
            final name = place['name'].toString().toLowerCase();
            final location = place['location'].toString().toLowerCase();
            final query = _searchQuery.toLowerCase();
            return name.contains(query) || location.contains(query);
          }).toList();
    
    if (filteredPlaces.isEmpty) {
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
      itemCount: filteredPlaces.length,
      itemBuilder: (context, index) {
        final place = filteredPlaces[index];
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
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: SingleChildScrollView(
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
            
            // Price Range Filter
            Text(
              'Price Range',
              style: AppTheme.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildFilterChip('Under RWF 10,000', false),
                _buildFilterChip('RWF 10,000 - 20,000', false),
                _buildFilterChip('RWF 20,000 - 30,000', false),
                _buildFilterChip('Above RWF 30,000', false),
              ],
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
                _buildFilterChip('Live Music', false),
                _buildFilterChip('Dance Floor', false),
                _buildFilterChip('Outdoor Seating', false),
                _buildFilterChip('VIP Section', false),
                _buildFilterChip('Parking', false),
                _buildFilterChip('WiFi', false),
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
              'Sort Nightlife',
              style: AppTheme.headlineSmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            
            // Sort Options
            _buildSortOption('Distance', Icons.location_on, true),
            _buildSortOption('Rating', Icons.star, false),
            _buildSortOption('Price: Low to High', Icons.arrow_upward, false),
            _buildSortOption('Price: High to Low', Icons.arrow_downward, false),
            _buildSortOption('Most Popular', Icons.trending_up, false),
            _buildSortOption('Newest', Icons.schedule, false),
            _buildSortOption('Name A-Z', Icons.sort_by_alpha, false),
            
            const SizedBox(height: 20),
            
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
                    child: const Text('Cancel'),
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
                    child: const Text('Apply'),
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

  Widget _buildFilterChip(String label, bool isSelected) {
    return FilterChip(
      label: Text(
        label,
        style: AppTheme.bodySmall.copyWith(
          color: isSelected ? Colors.white : AppTheme.primaryTextColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        // Handle filter selection
      },
      selectedColor: AppTheme.primaryColor,
      backgroundColor: AppTheme.backgroundColor,
      side: BorderSide(
        color: isSelected ? AppTheme.primaryColor : AppTheme.dividerColor,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  Widget _buildSortOption(String label, IconData icon, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          // Handle sort selection
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppTheme.primaryColor : AppTheme.dividerColor,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? AppTheme.primaryColor : AppTheme.secondaryTextColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: AppTheme.bodyMedium.copyWith(
                    color: isSelected ? AppTheme.primaryColor : AppTheme.primaryTextColor,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check,
                  size: 20,
                  color: AppTheme.primaryColor,
                ),
            ],
          ),
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
