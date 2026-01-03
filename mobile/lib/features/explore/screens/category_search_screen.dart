import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/theme/text_theme_extensions.dart';
import '../../../core/widgets/place_card.dart';
import '../../../core/providers/categories_provider.dart';
import '../../../core/providers/listings_provider.dart';

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
  String? _selectedSubCategoryId;

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
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        backgroundColor: context.backgroundColor,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.chevron_left, size: 32),
          style: IconButton.styleFrom(
            foregroundColor: context.primaryTextColor,
          ),
        ),
        title: Text(
          'Search ${_getCategoryTitle()}',
          style: context.headlineMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: context.primaryTextColor,
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
            padding: const EdgeInsets.all(12),
            color: context.backgroundColor,
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: _getSearchHint(),
                hintStyle: context.bodyMedium.copyWith(
                  color: context.secondaryTextColor,
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
                fillColor: context.grey50,
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
                    color: context.primaryColorTheme,
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
          
          // Sub-category Filter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: context.backgroundColor,
            child: _buildSubCategoryChips(),
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

  Widget _buildSubCategoryChips() {
    // Fetch category by slug to get subcategories
    final categoryAsync = ref.watch(categoryBySlugProvider(widget.category));
    
    return categoryAsync.when(
      data: (categoryData) {
        final children = categoryData['children'] as List?;
        List<Map<String, String?>> subCategories = [
          {'label': 'All', 'value': 'All', 'id': null}
        ];
        
        // Add subcategories from API if available
        if (children != null && children.isNotEmpty) {
          for (var child in children) {
            final childMap = child as Map<String, dynamic>;
            final name = childMap['name'] as String? ?? '';
            final id = childMap['id'] as String?;
            if (name.isNotEmpty && id != null) {
              subCategories.add({
                'label': name,
                'value': name,
                'id': id,
              });
            }
          }
        } else {
          // Fallback to hardcoded subcategories if API doesn't provide children
          switch (widget.category) {
            case 'dining':
              subCategories.addAll([
                {'label': 'Restaurants', 'value': 'Restaurants', 'id': null},
                {'label': 'Cafes', 'value': 'Cafes', 'id': null},
                {'label': 'Fast Food', 'value': 'Fast Food', 'id': null},
              ]);
              break;
            case 'nightlife':
              subCategories.addAll([
                {'label': 'Bars', 'value': 'Bar', 'id': null},
                {'label': 'Clubs', 'value': 'Club', 'id': null},
                {'label': 'Lounges', 'value': 'Lounge', 'id': null},
              ]);
              break;
            case 'experiences':
              subCategories.addAll([
                {'label': 'Tours', 'value': 'Tours', 'id': null},
                {'label': 'Adventures', 'value': 'Adventures', 'id': null},
                {'label': 'Cultural', 'value': 'Cultural', 'id': null},
                {'label': 'Operators', 'value': 'Operators', 'id': null},
              ]);
              break;
          }
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: subCategories.map((subCategory) {
              final isSelected = _selectedSubCategory == subCategory['value'];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(
                    subCategory['label']!,
                    style: context.bodySmall.copyWith(
                      color: isSelected ? context.primaryTextColor : context.primaryTextColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedSubCategory = subCategory['value']!;
                        _selectedSubCategoryId = subCategory['id'];
                      });
                    }
                  },
                  selectedColor: context.primaryColorTheme,
                  backgroundColor: context.backgroundColor,
                  side: BorderSide(
                    color: isSelected ? context.primaryColorTheme : context.dividerColor,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              );
            }).toList(),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }

  Widget _buildSearchResults() {
    // Fetch category by slug to get category ID
    final categoryAsync = ref.watch(categoryBySlugProvider(widget.category));
    
    return categoryAsync.when(
      data: (categoryData) {
        final categoryId = categoryData['id'] as String?;
        
        if (categoryId == null) {
          return Center(
            child: Text(
              'Category not found',
              style: context.bodyMedium.copyWith(
                color: context.secondaryTextColor,
              ),
            ),
          );
        }
        
        // Use subcategory ID if available, otherwise use main category ID
        final categoryIdForListings = _selectedSubCategoryId ?? categoryId;
        
        // Fetch listings with search query and category filter
        final listingsAsync = ref.watch(
          listingsProvider(
            ListingsParams(
              page: 1,
              limit: 100, // Fetch enough results for search
              category: categoryIdForListings,
              search: _searchQuery.isEmpty ? null : _searchQuery,
              status: 'active', // Only fetch active listings
            ),
          ),
        );
        
        return listingsAsync.when(
          data: (response) {
            List listings = List.from(response['data'] as List? ?? []);
            
            // If subcategory ID is not available, filter by name as fallback
            if (_selectedSubCategory != 'All' && _selectedSubCategoryId == null) {
              listings = listings.where((listing) {
                final listingCategory = listing['category'] as Map<String, dynamic>?;
                final categoryName = listingCategory?['name'] as String?;
                return categoryName == _selectedSubCategory;
              }).toList();
            }
            
            if (listings.isEmpty) {
              return _buildEmptyState();
            }
            
            return RefreshIndicator(
              color: context.primaryColorTheme,
              backgroundColor: context.cardColor,
              onRefresh: () async {
                ref.invalidate(
                  listingsProvider(
                    ListingsParams(
                      page: 1,
                      limit: 100,
                      category: categoryIdForListings,
                      search: _searchQuery.isEmpty ? null : _searchQuery,
                      status: 'active',
                    ),
                  ),
                );
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: listings.length,
                itemBuilder: (context, index) {
                  final listing = listings[index] as Map<String, dynamic>;
                  
                  // Special handling for tour operators
                  if (widget.category == 'experiences' && _selectedSubCategory == 'Operators') {
                    return _buildTourOperatorCard(listing);
                  }
                  
                  return _buildListingCard(listing);
                },
              ),
            );
          },
          loading: () => Center(
            child: CircularProgressIndicator(color: context.primaryColorTheme),
          ),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: context.secondaryTextColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'Failed to load listings',
                  style: context.headlineSmall.copyWith(
                    color: context.secondaryTextColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: context.bodyMedium.copyWith(
                    color: context.secondaryTextColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    ref.invalidate(categoryBySlugProvider(widget.category));
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => Center(
        child: CircularProgressIndicator(color: context.primaryColorTheme),
      ),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: context.secondaryTextColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load category',
              style: context.headlineSmall.copyWith(
                color: context.secondaryTextColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: context.bodyMedium.copyWith(
                color: context.secondaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(categoryBySlugProvider(widget.category));
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildListingCard(Map<String, dynamic> listing) {
    // Extract listing data
    final name = listing['name'] as String? ?? 'Unknown';
    final location = listing['location'] as Map<String, dynamic>?;
    final city = location?['city'] as Map<String, dynamic>?;
    final locationName = city?['name'] as String? ?? 'Unknown Location';
    final images = listing['images'] as List?;
    final imageUrl = images != null && images.isNotEmpty 
        ? images[0] as String? 
        : null;
    final rating = (listing['rating'] as num?)?.toDouble() ?? 0.0;
    final reviews = (listing['reviews'] as List?)?.length ?? 0;
    final priceRange = listing['priceRange'] as String?;
    final category = listing['category'] as Map<String, dynamic>?;
    final categoryName = category?['name'] as String? ?? '';
    final id = listing['id'] as String? ?? '';
    final isFavorite = listing['isFavorite'] as bool? ?? false;
    
    return PlaceCard(
      name: name,
      location: locationName,
      image: imageUrl ?? 'https://via.placeholder.com/400x300',
      rating: rating,
      reviews: reviews,
      priceRange: priceRange ?? '',
      category: categoryName,
      isFavorite: isFavorite,
      onFavorite: () {
        // TODO: Implement favorite toggle
      },
      onTap: () {
        context.push('/place/$id');
      },
    );
  }

  Widget _buildTourOperatorCard(Map<String, dynamic> operator) {
    // Extract operator data
    final name = operator['name'] as String? ?? 'Unknown';
    final location = operator['location'] as Map<String, dynamic>?;
    final city = location?['city'] as Map<String, dynamic>?;
    final locationName = city?['name'] as String? ?? 'Unknown Location';
    final images = operator['images'] as List?;
    final imageUrl = images != null && images.isNotEmpty 
        ? images[0] as String? 
        : null;
    final rating = (operator['rating'] as num?)?.toDouble() ?? 0.0;
    final reviews = (operator['reviews'] as List?)?.length ?? 0;
    final description = operator['description'] as String?;
    final id = operator['id'] as String? ?? '';
    
    return GestureDetector(
      onTap: () {
        context.push('/place/$id');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: context.backgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: context.primaryTextColor.withOpacity(0.05),
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
                imageUrl ?? 'https://via.placeholder.com/400x300',
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  color: context.grey200,
                  child: const Icon(Icons.business, size: 50),
                ),
              ),
            ),
            // Operator content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: context.headlineSmall.copyWith(
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
                          color: context.primaryColorTheme.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Tour Operator',
                          style: context.bodySmall.copyWith(
                            color: context.primaryColorTheme,
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
                        color: context.secondaryTextColor,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          locationName,
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
                      const Icon(
                        Icons.star,
                        size: 16,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        rating.toStringAsFixed(1),
                        style: context.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '($reviews reviews)',
                        style: context.bodySmall.copyWith(
                          color: context.secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                  if (description != null && description.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      description,
                      style: context.bodyMedium.copyWith(
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
            color: context.secondaryTextColor,
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty 
                ? 'Search for ${_getCategoryTitle().toLowerCase()}'
                : 'No results found',
            style: context.headlineSmall.copyWith(
              color: context.secondaryTextColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty
                ? _getSearchSuggestions()
                : 'Try different keywords or categories',
            style: context.bodyMedium.copyWith(
              color: context.secondaryTextColor,
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
      backgroundColor: context.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter ${_getCategoryTitle()}',
                style: context.headlineSmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.primaryTextColor,
                ),
              ),
              const SizedBox(height: 20),
              
              // Price Range Filter
              Text(
                'Price Range',
                style: context.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.primaryTextColor,
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
                'Sort ${_getCategoryTitle()}',
                style: context.headlineSmall.copyWith(
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
                        foregroundColor: context.primaryColorTheme,
                        side: BorderSide(color: context.primaryColorTheme),
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
        style: context.bodySmall.copyWith(
          color: isSelected ? context.primaryTextColor : context.primaryTextColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        // Handle filter selection
      },
      selectedColor: context.primaryColorTheme,
      backgroundColor: context.backgroundColor,
      side: BorderSide(
        color: isSelected ? context.primaryColorTheme : context.dividerColor,
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
            color: isSelected ? context.primaryColorTheme.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? context.primaryColorTheme : context.dividerColor,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? context.primaryColorTheme : context.secondaryTextColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: context.bodyMedium.copyWith(
                    color: isSelected ? context.primaryColorTheme : context.primaryTextColor,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check,
                  size: 20,
                  color: context.primaryColorTheme,
                ),
            ],
          ),
        ),
      ),
    );
  }

}
