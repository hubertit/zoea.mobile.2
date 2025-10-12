import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class AccommodationScreen extends ConsumerStatefulWidget {
  const AccommodationScreen({super.key});

  @override
  ConsumerState<AccommodationScreen> createState() => _AccommodationScreenState();
}

class _AccommodationScreenState extends ConsumerState<AccommodationScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final String _selectedLocation = 'Kigali';
  final String _selectedDates = 'Any dates';
  final int _guestCount = 1;
  Set<String> _favoriteAccommodations = {};

  final List<String> _tabs = [
    'All',
    'Hotels',
    'Hostels',
    'B&Bs',
    'Apartments',
    'Villas',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _loadFavorites();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadFavorites() {
    // Simulate loading favorites
    setState(() {
      _favoriteAccommodations = {'hotel_1', 'apartment_2'};
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Where to stay',
              style: AppTheme.headlineMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryTextColor,
              ),
            ),
            Text(
              'Find your perfect accommodation',
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.secondaryTextColor,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/search?category=accommodation'),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
          ),
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: _showMapView,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildQuickFilters(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _tabs.map((tab) => _buildAccommodationList(tab)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_on,
            color: AppTheme.primaryColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _selectedLocation,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.primaryTextColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            height: 20,
            width: 1,
            color: Colors.grey[300],
          ),
          const SizedBox(width: 12),
          Icon(
            Icons.calendar_today,
            color: AppTheme.secondaryTextColor,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _selectedDates,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.secondaryTextColor,
              ),
            ),
          ),
          Container(
            height: 20,
            width: 1,
            color: Colors.grey[300],
          ),
          const SizedBox(width: 12),
          Icon(
            Icons.person,
            color: AppTheme.secondaryTextColor,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            '$_guestCount guest${_guestCount > 1 ? 's' : ''}',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.secondaryTextColor,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.arrow_drop_down,
            color: AppTheme.secondaryTextColor,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickFilters() {
    final filters = [
      {'name': 'Price', 'icon': Icons.attach_money},
      {'name': 'Rating', 'icon': Icons.star},
      {'name': 'Distance', 'icon': Icons.location_on},
      {'name': 'Amenities', 'icon': Icons.wifi},
    ];

    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(
                filter['name'] as String,
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.primaryTextColor,
                ),
              ),
              avatar: Icon(
                filter['icon'] as IconData,
                size: 16,
                color: AppTheme.primaryColor,
              ),
              selected: false,
              onSelected: (selected) {
                // Handle filter selection
              },
              backgroundColor: AppTheme.backgroundColor,
              selectedColor: AppTheme.primaryColor.withOpacity(0.1),
              checkmarkColor: AppTheme.primaryColor,
              side: BorderSide(
                color: Colors.grey[300]!,
                width: 1,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppTheme.backgroundColor,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        labelPadding: const EdgeInsets.symmetric(horizontal: 16),
        indicatorColor: AppTheme.primaryColor,
        indicatorWeight: 2,
        labelColor: AppTheme.primaryColor,
        unselectedLabelColor: AppTheme.secondaryTextColor,
        labelStyle: AppTheme.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTheme.bodyMedium,
        tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
      ),
    );
  }

  Widget _buildAccommodationList(String category) {
    final accommodations = _getMockAccommodations(category);

    if (accommodations.isEmpty) {
      return _buildEmptyState(category);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: accommodations.length,
      itemBuilder: (context, index) {
        final accommodation = accommodations[index];
        return _buildAccommodationCard(accommodation);
      },
    );
  }

  Widget _buildAccommodationCard(Map<String, dynamic> accommodation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with favorite button
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  accommodation['image'],
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: Colors.grey[200],
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.grey[400],
                        size: 48,
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (_favoriteAccommodations.contains(accommodation['id'])) {
                        _favoriteAccommodations.remove(accommodation['id']);
                      } else {
                        _favoriteAccommodations.add(accommodation['id']);
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      _favoriteAccommodations.contains(accommodation['id'])
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: _favoriteAccommodations.contains(accommodation['id'])
                          ? Colors.red
                          : Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
              // Price badge
              Positioned(
                bottom: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'RWF ${accommodation['price']}',
                    style: AppTheme.bodySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        accommodation['name'],
                        style: AppTheme.headlineSmall.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          accommodation['rating'].toString(),
                          style: AppTheme.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          ' (${accommodation['reviews']})',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  accommodation['location'],
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.secondaryTextColor,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.wifi,
                      size: 16,
                      color: AppTheme.secondaryTextColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      accommodation['amenities'],
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          context.push('/accommodation/${accommodation['id']}');
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppTheme.primaryColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'View Details',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          context.push('/accommodation/${accommodation['id']}/book');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Book Now',
                          style: AppTheme.bodyMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String category) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.hotel,
            size: 64,
            color: AppTheme.secondaryTextColor,
          ),
          const SizedBox(height: 16),
          Text(
            'No ${category.toLowerCase()} found',
            style: AppTheme.headlineSmall.copyWith(
              color: AppTheme.secondaryTextColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.secondaryTextColor,
            ),
          ),
        ],
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
                'Filters',
                style: AppTheme.headlineSmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              // Price range
              Text(
                'Price Range',
                style: AppTheme.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              // Add price range slider here
              const SizedBox(height: 20),
              // Amenities
              Text(
                'Amenities',
                style: AppTheme.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              // Add amenities checkboxes here
              const SizedBox(height: 20),
              // Apply button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Apply Filters',
                    style: AppTheme.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMapView() {
    // Implement map view
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Map view coming soon!'),
      ),
    );
  }

  List<Map<String, dynamic>> _getMockAccommodations(String category) {
    final allAccommodations = [
      // Hotels
      {
        'id': 'hotel_1',
        'name': 'Kigali Marriott Hotel',
        'location': 'Kacyiru, Kigali',
        'rating': 4.8,
        'reviews': 1247,
        'price': '120,000',
        'amenities': 'WiFi, Pool, Spa, Restaurant',
        'category': 'hotels',
        'image': 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=500',
      },
      {
        'id': 'hotel_2',
        'name': 'Radisson Blu Hotel',
        'location': 'Kigali Heights, Kigali',
        'rating': 4.6,
        'reviews': 892,
        'price': '95,000',
        'amenities': 'WiFi, Pool, Gym, Restaurant',
        'category': 'hotels',
        'image': 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=500',
      },
      // Hostels
      {
        'id': 'hostel_1',
        'name': 'Discover Rwanda Hostel',
        'location': 'Nyamirambo, Kigali',
        'rating': 4.2,
        'reviews': 156,
        'price': '15,000',
        'amenities': 'WiFi, Kitchen, Common Area',
        'category': 'hostels',
        'image': 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=500',
      },
      // B&Bs
      {
        'id': 'bnb_1',
        'name': 'Heaven Boutique Hotel',
        'location': 'Kiyovu, Kigali',
        'rating': 4.7,
        'reviews': 234,
        'price': '45,000',
        'amenities': 'WiFi, Breakfast, Garden',
        'category': 'b&bs',
        'image': 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=500',
      },
      // Apartments
      {
        'id': 'apartment_1',
        'name': 'Kigali Heights Apartments',
        'location': 'Kigali Heights, Kigali',
        'rating': 4.5,
        'reviews': 89,
        'price': '80,000',
        'amenities': 'WiFi, Kitchen, Balcony',
        'category': 'apartments',
        'image': 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=500',
      },
      {
        'id': 'apartment_2',
        'name': 'Modern City Apartment',
        'location': 'Remera, Kigali',
        'rating': 4.3,
        'reviews': 67,
        'price': '65,000',
        'amenities': 'WiFi, Kitchen, Parking',
        'category': 'apartments',
        'image': 'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=500',
      },
      // Villas
      {
        'id': 'villa_1',
        'name': 'Luxury Villa Kigali',
        'location': 'Kiyovu, Kigali',
        'rating': 4.9,
        'reviews': 45,
        'price': '200,000',
        'amenities': 'WiFi, Pool, Garden, Security',
        'category': 'villas',
        'image': 'https://images.unsplash.com/photo-1613490493576-7fde63acd811?w=500',
      },
    ];

    if (category.toLowerCase() == 'all') {
      return allAccommodations;
    }

    return allAccommodations
        .where((accommodation) =>
            (accommodation['category'] as String).toLowerCase() == category.toLowerCase())
        .toList();
  }
}
