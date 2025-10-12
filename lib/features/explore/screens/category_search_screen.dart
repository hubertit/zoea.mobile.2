import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/place_card.dart';

class CategorySearchScreen extends ConsumerStatefulWidget {
  final String category;
  
  const CategorySearchScreen({
    super.key,
    required this.category,
  });

  @override
  ConsumerState<CategorySearchScreen> createState() => _CategorySearchScreenState();
}

class _CategorySearchScreenState extends ConsumerState<CategorySearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedSubCategory = 'All';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
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
        centerTitle: false,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.chevron_left, size: 32),
          style: IconButton.styleFrom(
            foregroundColor: AppTheme.primaryTextColor,
          ),
        ),
        title: Text(
          'Search ${_getCategoryTitle()}',
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
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.backgroundColor,
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: _getSearchHint(),
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
          
          // Sub-category Filter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppTheme.backgroundColor,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _buildSubCategoryChips(),
              ),
            ),
          ),
          
          // Search Results
          Expanded(
            child: _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  String _getCategoryTitle() {
    switch (widget.category) {
      case 'dining':
        return 'Dining';
      case 'nightlife':
        return 'Nightlife';
      case 'experiences':
        return 'Experiences';
      default:
        return 'Places';
    }
  }

  String _getSearchHint() {
    switch (widget.category) {
      case 'dining':
        return 'Search restaurants, cafes...';
      case 'nightlife':
        return 'Search bars, clubs, lounges...';
      case 'experiences':
        return 'Search tours, adventures, experiences...';
      default:
        return 'Search places...';
    }
  }

  List<Widget> _buildSubCategoryChips() {
    List<Map<String, String>> subCategories = [];
    
    switch (widget.category) {
      case 'dining':
        subCategories = [
          {'label': 'All', 'value': 'All'},
          {'label': 'Restaurants', 'value': 'Restaurants'},
          {'label': 'Cafes', 'value': 'Cafes'},
          {'label': 'Fast Food', 'value': 'Fast Food'},
        ];
        break;
      case 'nightlife':
        subCategories = [
          {'label': 'All', 'value': 'All'},
          {'label': 'Bars', 'value': 'Bar'},
          {'label': 'Clubs', 'value': 'Club'},
          {'label': 'Lounges', 'value': 'Lounge'},
        ];
        break;
      case 'experiences':
        subCategories = [
          {'label': 'All', 'value': 'All'},
          {'label': 'Tours', 'value': 'Tours'},
          {'label': 'Adventures', 'value': 'Adventures'},
          {'label': 'Cultural', 'value': 'Cultural'},
          {'label': 'Operators', 'value': 'Operators'},
        ];
        break;
    }

    return subCategories.map((subCategory) {
      final isSelected = _selectedSubCategory == subCategory['value'];
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: FilterChip(
          label: Text(
            subCategory['label']!,
            style: AppTheme.bodySmall.copyWith(
              color: isSelected ? Colors.white : AppTheme.primaryTextColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _selectedSubCategory = subCategory['value']!;
            });
          },
          selectedColor: AppTheme.primaryColor,
          backgroundColor: AppTheme.backgroundColor,
          side: BorderSide(
            color: isSelected ? AppTheme.primaryColor : AppTheme.dividerColor,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      );
    }).toList();
  }

  Widget _buildSearchResults() {
    final places = _getMockPlaces();
    final filteredPlaces = _searchQuery.isEmpty
        ? places
        : places.where((place) {
            final name = place['name'].toString().toLowerCase();
            final location = place['location'].toString().toLowerCase();
            final query = _searchQuery.toLowerCase();
            return name.contains(query) || location.contains(query);
          }).toList();

    if (filteredPlaces.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredPlaces.length,
      itemBuilder: (context, index) {
        final place = filteredPlaces[index];
        
        // Special handling for tour operators
        if (widget.category == 'experiences' && _selectedSubCategory == 'Operators') {
          return _buildTourOperatorCard(place);
        }
        
        return PlaceCard(
          name: place['name'],
          location: place['location'],
          image: place['image'],
          rating: place['rating'],
          reviews: place['reviews'],
          priceRange: place['priceRange'],
          category: place['category'],
          isFavorite: place['isFavorite'] ?? false,
          onFavoriteToggle: () {
            setState(() {
              if (place['isFavorite'] == true) {
                place['isFavorite'] = false;
              } else {
                place['isFavorite'] = true;
              }
            });
          },
          onTap: () {
            context.push('/place/${place['id']}');
          },
        );
      },
    );
  }

  Widget _buildTourOperatorCard(Map<String, dynamic> operator) {
    return GestureDetector(
      onTap: () {
        context.push('/place/${operator['id']}');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppTheme.backgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryTextColor.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Operator image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                operator['image'],
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  color: Colors.grey[200],
                  child: const Icon(Icons.business, size: 50),
                ),
              ),
            ),
            // Operator content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          operator['name'],
                          style: AppTheme.headlineSmall.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Tour Operator',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
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
                          operator['location'],
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.secondaryTextColor,
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
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        operator['rating'].toString(),
                        style: AppTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${operator['reviews']} reviews)',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                  if (operator['description'] != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      operator['description'],
                      style: AppTheme.bodyMedium.copyWith(
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppTheme.secondaryTextColor,
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty 
                ? 'Search for ${_getCategoryTitle().toLowerCase()}'
                : 'No results found',
            style: AppTheme.headlineSmall.copyWith(
              color: AppTheme.secondaryTextColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty
                ? _getSearchSuggestions()
                : 'Try different keywords or categories',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.secondaryTextColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getSearchSuggestions() {
    switch (widget.category) {
      case 'dining':
        return 'Try searching for "pizza", "coffee", or "sushi"';
      case 'nightlife':
        return 'Try searching for "bar", "club", or "lounge"';
      case 'experiences':
        return 'Try searching for "gorilla", "hiking", or "cultural"';
      default:
        return 'Try searching for specific places or locations';
    }
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
                'Filter ${_getCategoryTitle()}',
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
                children: _buildPriceRangeFilters(),
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
                children: _buildFeatureFilters(),
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

  List<Widget> _buildPriceRangeFilters() {
    switch (widget.category) {
      case 'dining':
        return [
          _buildFilterChip('Under RWF 5,000', false),
          _buildFilterChip('RWF 5,000 - 15,000', false),
          _buildFilterChip('RWF 15,000 - 30,000', false),
          _buildFilterChip('Above RWF 30,000', false),
        ];
      case 'nightlife':
        return [
          _buildFilterChip('Under RWF 10,000', false),
          _buildFilterChip('RWF 10,000 - 20,000', false),
          _buildFilterChip('RWF 20,000 - 30,000', false),
          _buildFilterChip('Above RWF 30,000', false),
        ];
      case 'experiences':
        return [
          _buildFilterChip('Under RWF 50,000', false),
          _buildFilterChip('RWF 50,000 - 100,000', false),
          _buildFilterChip('RWF 100,000 - 200,000', false),
          _buildFilterChip('Above RWF 200,000', false),
        ];
      default:
        return [
          _buildFilterChip('Under RWF 10,000', false),
          _buildFilterChip('RWF 10,000 - 30,000', false),
          _buildFilterChip('Above RWF 30,000', false),
        ];
    }
  }

  List<Widget> _buildFeatureFilters() {
    switch (widget.category) {
      case 'dining':
        return [
          _buildFilterChip('WiFi', false),
          _buildFilterChip('Parking', false),
          _buildFilterChip('Outdoor Seating', false),
          _buildFilterChip('Delivery', false),
          _buildFilterChip('Takeaway', false),
          _buildFilterChip('Vegetarian Options', false),
        ];
      case 'nightlife':
        return [
          _buildFilterChip('Live Music', false),
          _buildFilterChip('Dance Floor', false),
          _buildFilterChip('Outdoor Seating', false),
          _buildFilterChip('VIP Section', false),
          _buildFilterChip('Parking', false),
          _buildFilterChip('WiFi', false),
        ];
      case 'experiences':
        return [
          _buildFilterChip('Guided Tours', false),
          _buildFilterChip('Transport Included', false),
          _buildFilterChip('Meals Included', false),
          _buildFilterChip('Equipment Provided', false),
          _buildFilterChip('Group Tours', false),
          _buildFilterChip('Private Tours', false),
        ];
      default:
        return [
          _buildFilterChip('WiFi', false),
          _buildFilterChip('Parking', false),
          _buildFilterChip('Accessible', false),
        ];
    }
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
                'Sort ${_getCategoryTitle()}',
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

  List<Map<String, dynamic>> _getMockPlaces() {
    switch (widget.category) {
      case 'dining':
        return _getMockDiningPlaces();
      case 'nightlife':
        return _getMockNightlifePlaces();
      case 'experiences':
        return _selectedSubCategory == 'Operators' 
            ? _getMockTourOperators() 
            : _getMockExperiences();
      default:
        return [];
    }
  }

  List<Map<String, dynamic>> _getMockDiningPlaces() {
    final allPlaces = [
      {
        'id': '1',
        'name': 'The Hut Restaurant',
        'location': 'Kigali Heights, Kigali',
        'image': 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=500',
        'rating': 4.5,
        'reviews': 120,
        'priceRange': 'RWF 8,000 - 25,000',
        'category': 'Restaurant',
        'isFavorite': false,
      },
      {
        'id': '2',
        'name': 'Bourbon Coffee',
        'location': 'Kacyiru, Kigali',
        'image': 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=500',
        'rating': 4.3,
        'reviews': 85,
        'priceRange': 'RWF 3,000 - 8,000',
        'category': 'Cafe',
        'isFavorite': false,
      },
      {
        'id': '3',
        'name': 'Pizza Corner',
        'location': 'Remera, Kigali',
        'image': 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=500',
        'rating': 4.1,
        'reviews': 95,
        'priceRange': 'RWF 5,000 - 15,000',
        'category': 'Fast Food',
        'isFavorite': false,
      },
    ];

    if (_selectedSubCategory == 'All') return allPlaces;
    return allPlaces.where((place) => place['category'] == _selectedSubCategory).toList();
  }

  List<Map<String, dynamic>> _getMockNightlifePlaces() {
    final allPlaces = [
      {
        'id': 'nightlife_1',
        'name': 'Sky Lounge',
        'location': 'Kigali Heights, Kigali',
        'image': 'https://images.unsplash.com/photo-1533174072545-7bd46c006744?w=500',
        'rating': 4.5,
        'reviews': 120,
        'priceRange': 'RWF 15,000 - 30,000',
        'category': 'Lounge',
        'isFavorite': false,
      },
      {
        'id': 'nightlife_2',
        'name': 'Club Amahoro',
        'location': 'Remera, Kigali',
        'image': 'https://images.unsplash.com/photo-1598032790856-ce216b72780b?w=500',
        'rating': 4.2,
        'reviews': 85,
        'priceRange': 'RWF 10,000 - 25,000',
        'category': 'Club',
        'isFavorite': false,
      },
      {
        'id': 'nightlife_3',
        'name': 'Rooftop Bar',
        'location': 'Kiyovu, Kigali',
        'image': 'https://images.unsplash.com/photo-1514933651105-0646ef958e0e?w=500',
        'rating': 4.7,
        'reviews': 150,
        'priceRange': 'RWF 20,000 - 35,000',
        'category': 'Bar',
        'isFavorite': false,
      },
    ];

    if (_selectedSubCategory == 'All') return allPlaces;
    return allPlaces.where((place) => place['category'] == _selectedSubCategory).toList();
  }

  List<Map<String, dynamic>> _getMockExperiences() {
    final allExperiences = [
      {
        'id': 'exp_1',
        'name': 'Gorilla Trekking Experience',
        'location': 'Volcanoes National Park, Musanze',
        'image': 'https://images.unsplash.com/photo-1551632436-cbf8dd35adfa?w=500',
        'rating': 4.9,
        'reviews': 250,
        'priceRange': 'RWF 150,000 - 200,000',
        'category': 'Tours',
        'isFavorite': false,
      },
      {
        'id': 'exp_2',
        'name': 'Nyungwe Canopy Walk',
        'location': 'Nyungwe National Park, Huye',
        'image': 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=500',
        'rating': 4.7,
        'reviews': 180,
        'priceRange': 'RWF 80,000 - 120,000',
        'category': 'Adventures',
        'isFavorite': false,
      },
      {
        'id': 'exp_3',
        'name': 'Cultural Village Tour',
        'location': 'Iby\'Iwacu Cultural Village, Musanze',
        'image': 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=500',
        'rating': 4.5,
        'reviews': 120,
        'priceRange': 'RWF 30,000 - 50,000',
        'category': 'Cultural',
        'isFavorite': false,
      },
    ];

    if (_selectedSubCategory == 'All') return allExperiences;
    return allExperiences.where((exp) => exp['category'] == _selectedSubCategory).toList();
  }

  List<Map<String, dynamic>> _getMockTourOperators() {
    return [
      {
        'id': 'op_1',
        'name': 'Rwanda Eco Tours',
        'location': 'Kigali, Rwanda',
        'image': 'https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=500',
        'rating': 4.8,
        'reviews': 150,
        'description': 'Specialized in eco-friendly tours and wildlife experiences.',
      },
      {
        'id': 'op_2',
        'name': 'Adventure Rwanda',
        'location': 'Musanze, Rwanda',
        'image': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=500',
        'rating': 4.6,
        'reviews': 200,
        'description': 'Leading adventure tour operator with expert guides.',
      },
    ];
  }
}
