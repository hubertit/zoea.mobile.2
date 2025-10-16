import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/place_card.dart';

class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen>
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
          'Recommendations',
          style: AppTheme.headlineSmall.copyWith(
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
          indicatorColor: AppTheme.primaryColor,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.secondaryTextColor,
          labelStyle: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w600),
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
    final places = _getMockRecommendations(category);
    
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
              'No recommendations found',
              style: AppTheme.headlineSmall.copyWith(
                color: AppTheme.secondaryTextColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for new recommendations',
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

  List<Map<String, dynamic>> _getMockRecommendations(String category) {
    final allRecommendations = [
      {
        'id': '1',
        'name': 'Volcanoes National Park',
        'location': 'Musanze, Rwanda',
        'image': 'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=800',
        'rating': 4.9,
        'reviews': 1247,
        'priceRange': 'From \$1,500',
        'category': 'Wildlife',
      },
      {
        'id': '2',
        'name': 'Nyungwe Forest',
        'location': 'Nyungwe, Rwanda',
        'image': 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=800',
        'rating': 4.8,
        'reviews': 892,
        'priceRange': 'From \$200',
        'category': 'Nature',
      },
      {
        'id': '3',
        'name': 'Lake Kivu',
        'location': 'Rubavu, Rwanda',
        'image': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
        'rating': 4.7,
        'reviews': 654,
        'priceRange': 'From \$80',
        'category': 'Water',
      },
      {
        'id': '4',
        'name': 'Kigali Genocide Memorial',
        'location': 'Kigali, Rwanda',
        'image': 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800',
        'rating': 4.9,
        'reviews': 2156,
        'priceRange': 'Free',
        'category': 'History',
      },
      {
        'id': '5',
        'name': 'Akagera National Park',
        'location': 'Eastern Rwanda',
        'image': 'https://images.unsplash.com/photo-1516026672322-bc52d61a55d5?w=800',
        'rating': 4.6,
        'reviews': 743,
        'priceRange': 'From \$300',
        'category': 'Wildlife',
      },
      {
        'id': '6',
        'name': 'Mount Karisimbi',
        'location': 'Volcanoes National Park',
        'image': 'https://images.unsplash.com/photo-1464822759844-d150baec1b4b?w=800',
        'rating': 4.8,
        'reviews': 456,
        'priceRange': 'From \$400',
        'category': 'Adventure',
      },
      {
        'id': '7',
        'name': 'Inema Arts Center',
        'location': 'Kigali, Rwanda',
        'image': 'https://images.unsplash.com/photo-1541961017774-22349e4a1262?w=800',
        'rating': 4.5,
        'reviews': 234,
        'priceRange': 'From \$10',
        'category': 'Culture',
      },
    ];

    if (category == 'All') {
      return allRecommendations;
    }
    
    return allRecommendations.where((place) => place['category'] == category).toList();
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
                'Filter Recommendations',
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
                'Sort Recommendations',
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
