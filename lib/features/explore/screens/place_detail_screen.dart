import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/theme/app_theme.dart';

class PlaceDetailScreen extends ConsumerStatefulWidget {
  final String placeId;
  
  const PlaceDetailScreen({
    super.key,
    required this.placeId,
  });

  @override
  ConsumerState<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends ConsumerState<PlaceDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isFavorite = false;

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
    // Mock place data - in real app, fetch by placeId
    final place = _getMockPlaceData();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppTheme.backgroundColor,
            leading: IconButton(
              icon: const Icon(Icons.chevron_left, color: Colors.white, size: 32),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _isFavorite = !_isFavorite;
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: () {
                  // TODO: Implement share functionality
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: place['image'],
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.place, size: 100),
                    ),
                  ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Content
          SliverToBoxAdapter(
            child: Container(
              color: Colors.grey[50],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Place Info
                  Container(
                    color: AppTheme.backgroundColor,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Text(
                                    place['name'],
                                    style: AppTheme.headlineMedium.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.verified,
                                          size: 14,
                                          color: Colors.blue[700],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Verified',
                                          style: AppTheme.bodySmall.copyWith(
                                            color: Colors.blue[700],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                place['category'],
                                style: AppTheme.bodyMedium.copyWith(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 18,
                              color: AppTheme.secondaryTextColor,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                place['location'],
                                style: AppTheme.bodyLarge.copyWith(
                                  color: AppTheme.secondaryTextColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 18,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              place['rating'].toString(),
                              style: AppTheme.bodyLarge.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '(${place['reviews']} reviews)',
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppTheme.secondaryTextColor,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              place['priceRange'],
                              style: AppTheme.bodyLarge.copyWith(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Tabs
                  Container(
                    color: AppTheme.backgroundColor,
                    child: TabBar(
                      controller: _tabController,
                      labelColor: AppTheme.primaryColor,
                      unselectedLabelColor: AppTheme.secondaryTextColor,
                      indicatorColor: AppTheme.primaryColor,
                      tabs: const [
                        Tab(text: 'Overview'),
                        Tab(text: 'Menu'),
                        Tab(text: 'Reviews'),
                        Tab(text: 'Photos'),
                      ],
                    ),
                  ),
                  // Tab Content
                  Container(
                    height: 400,
                    color: AppTheme.backgroundColor,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildOverviewTab(place),
                        _buildMenuTab(place),
                        _buildReviewsTab(),
                        _buildPhotosTab(place),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: AppTheme.backgroundColor,
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // TODO: Navigate to booking
                },
                icon: const Icon(Icons.calendar_today, size: 18),
                label: const Text('Book Now'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                  backgroundColor: AppTheme.backgroundColor,
                  side: const BorderSide(color: AppTheme.primaryColor),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Navigate to contact
                },
                icon: const Icon(Icons.phone, size: 18),
                label: const Text('Contact'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab(Map<String, dynamic> place) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About',
            style: AppTheme.headlineSmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            place['description'],
            style: AppTheme.bodyMedium.copyWith(
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Features',
            style: AppTheme.headlineSmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: place['features'].map<Widget>((feature) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  feature,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Text(
            'Opening Hours',
            style: AppTheme.headlineSmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...place['openingHours'].map<Widget>((hours) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(
                      hours['day'],
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    hours['time'],
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.secondaryTextColor,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildMenuTab(Map<String, dynamic> place) {
    final menuCategories = place['menu'] as List<Map<String, dynamic>>;
    
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: menuCategories.length,
      itemBuilder: (context, categoryIndex) {
        final category = menuCategories[categoryIndex];
        return Container(
          margin: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category['name'],
                style: AppTheme.headlineSmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              ...category['items'].map<Widget>((item) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey[200]!,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Menu item image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: item['image'],
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey[200],
                            child: const Icon(Icons.restaurant, size: 30),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Menu item details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['name'],
                              style: AppTheme.bodyLarge.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['description'],
                              style: AppTheme.bodySmall.copyWith(
                                color: AppTheme.secondaryTextColor,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                if (item['isVegetarian'] == true)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Veg',
                                      style: AppTheme.bodySmall.copyWith(
                                        color: Colors.green,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                if (item['isSpicy'] == true) ...[
                                  if (item['isVegetarian'] == true) const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Spicy',
                                      style: AppTheme.bodySmall.copyWith(
                                        color: Colors.red,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Price
                      Text(
                        item['price'],
                        style: AppTheme.bodyLarge.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReviewsTab() {
    final reviews = _getMockReviews();
    
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: reviews.length,
      itemBuilder: (context, index) {
        final review = reviews[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey[200]!,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: CachedNetworkImageProvider(review['avatar']),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          review['name'],
                          style: AppTheme.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          children: [
                            ...List.generate(5, (i) {
                              return Icon(
                                i < review['rating'] ? Icons.star : Icons.star_border,
                                size: 16,
                                color: Colors.amber,
                              );
                            }),
                            const SizedBox(width: 8),
                            Text(
                              review['date'],
                              style: AppTheme.bodySmall.copyWith(
                                color: AppTheme.secondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                review['comment'],
                style: AppTheme.bodyMedium.copyWith(
                  height: 1.4,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPhotosTab(Map<String, dynamic> place) {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: place['photos'].length,
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CachedNetworkImage(
            imageUrl: place['photos'][index],
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: Colors.grey[200],
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              color: Colors.grey[200],
              child: const Icon(Icons.image, size: 50),
            ),
          ),
        );
      },
    );
  }

  Map<String, dynamic> _getMockPlaceData() {
    return {
      'name': 'The Hut Restaurant',
      'location': 'Kigali, Rwanda',
      'image': 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800',
      'rating': 4.5,
      'reviews': 128,
      'priceRange': '\$\$',
      'category': 'Restaurant',
      'description': 'Experience authentic Rwandan cuisine in a cozy atmosphere. Our restaurant offers traditional dishes with a modern twist, using locally sourced ingredients. Perfect for family dinners, romantic dates, or business meetings.',
      'features': ['WiFi', 'Parking', 'Outdoor Seating', 'Takeaway', 'Delivery'],
      'openingHours': [
        {'day': 'Monday', 'time': '8:00 AM - 10:00 PM'},
        {'day': 'Tuesday', 'time': '8:00 AM - 10:00 PM'},
        {'day': 'Wednesday', 'time': '8:00 AM - 10:00 PM'},
        {'day': 'Thursday', 'time': '8:00 AM - 10:00 PM'},
        {'day': 'Friday', 'time': '8:00 AM - 11:00 PM'},
        {'day': 'Saturday', 'time': '9:00 AM - 11:00 PM'},
        {'day': 'Sunday', 'time': '9:00 AM - 9:00 PM'},
      ],
      'photos': [
        'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=400',
        'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=400',
        'https://images.unsplash.com/photo-1571091718767-18b5b1457add?w=400',
        'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=400',
      ],
      'menu': [
        {
          'name': 'Appetizers',
          'items': [
            {
              'name': 'Grilled Plantains',
              'description': 'Traditional Rwandan plantains grilled to perfection',
              'price': 'RWF 3,000',
              'image': 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=200',
              'isVegetarian': true,
              'isSpicy': false,
            },
            {
              'name': 'Beef Brochettes',
              'description': 'Tender beef skewers marinated in local spices',
              'price': 'RWF 8,000',
              'image': 'https://images.unsplash.com/photo-1571091718767-18b5b1457add?w=200',
              'isVegetarian': false,
              'isSpicy': true,
            },
            {
              'name': 'Fish Samosas',
              'description': 'Crispy samosas filled with fresh fish and vegetables',
              'price': 'RWF 4,500',
              'image': 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=200',
              'isVegetarian': false,
              'isSpicy': false,
            },
          ],
        },
        {
          'name': 'Main Courses',
          'items': [
            {
              'name': 'Ugali with Fish',
              'description': 'Traditional maize meal served with grilled fish and vegetables',
              'price': 'RWF 12,000',
              'image': 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=200',
              'isVegetarian': false,
              'isSpicy': false,
            },
            {
              'name': 'Chicken Pilau',
              'description': 'Aromatic rice with tender chicken and local spices',
              'price': 'RWF 10,000',
              'image': 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=200',
              'isVegetarian': false,
              'isSpicy': true,
            },
            {
              'name': 'Vegetable Curry',
              'description': 'Mixed vegetables in coconut curry sauce',
              'price': 'RWF 7,500',
              'image': 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=200',
              'isVegetarian': true,
              'isSpicy': true,
            },
          ],
        },
        {
          'name': 'Desserts',
          'items': [
            {
              'name': 'Passion Fruit Mousse',
              'description': 'Light and creamy mousse made with local passion fruit',
              'price': 'RWF 4,000',
              'image': 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=200',
              'isVegetarian': true,
              'isSpicy': false,
            },
            {
              'name': 'Banana Fritters',
              'description': 'Sweet banana fritters served with honey',
              'price': 'RWF 3,500',
              'image': 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=200',
              'isVegetarian': true,
              'isSpicy': false,
            },
          ],
        },
      ],
    };
  }

  List<Map<String, dynamic>> _getMockReviews() {
    return [
      {
        'name': 'John Doe',
        'avatar': 'https://i.pravatar.cc/100?img=1',
        'rating': 5,
        'date': '2 days ago',
        'comment': 'Amazing food and great service! The staff was very friendly and the atmosphere was perfect for our family dinner.',
      },
      {
        'name': 'Jane Smith',
        'avatar': 'https://i.pravatar.cc/100?img=2',
        'rating': 4,
        'date': '1 week ago',
        'comment': 'Good food but a bit pricey. The location is convenient and the restaurant is clean.',
      },
      {
        'name': 'Mike Johnson',
        'avatar': 'https://i.pravatar.cc/100?img=3',
        'rating': 5,
        'date': '2 weeks ago',
        'comment': 'Excellent traditional Rwandan cuisine! Highly recommend the grilled fish and plantains.',
      },
    ];
  }
}
