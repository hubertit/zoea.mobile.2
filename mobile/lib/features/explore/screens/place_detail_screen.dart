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
  late ScrollController _scrollController;
  bool _isFavorite = false;
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.offset > 200 && !_isScrolled) {
      setState(() {
        _isScrolled = true;
      });
    } else if (_scrollController.offset <= 200 && _isScrolled) {
      setState(() {
        _isScrolled = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Mock place data - in real app, fetch by placeId
    final place = _getMockPlaceData(widget.placeId);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: _isScrolled ? Colors.white : AppTheme.backgroundColor,
            leading: IconButton(
              icon: Icon(
                Icons.chevron_left, 
                color: _isScrolled ? AppTheme.primaryTextColor : Colors.white, 
                size: 32
              ),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isScrolled ? AppTheme.primaryTextColor : Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _isFavorite = !_isFavorite;
                  });
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.rate_review, 
                  color: _isScrolled ? AppTheme.primaryTextColor : Colors.white
                ),
                onPressed: () {
                  _showReviewBottomSheet();
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.share, 
                  color: _isScrolled ? AppTheme.primaryTextColor : Colors.white
                ),
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
                              '(${place['reviewCount']} reviews)',
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
            if (_shouldShowReserveButton(place['category'])) ...[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Navigate to dining booking
                    context.push('/dining-booking', extra: {
                      'placeId': widget.placeId,
                      'placeName': place['name'],
                      'placeLocation': place['location'],
                      'placeImage': place['image'],
                      'placeRating': place['rating'],
                      'priceRange': place['priceRange'],
                    });
                  },
                  icon: const Icon(Icons.calendar_today, size: 18),
                  label: const Text('Reserve Table'),
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
            ],
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
    final menuData = place['menu'];
    if (menuData == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'No menu available for this place',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }
    
    final menuCategories = menuData as List<Map<String, dynamic>>;
    
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
    final photos = place['photos'] as List<String>? ?? [];
    
    if (photos.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'No photos available for this place',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }
    
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: photos.length,
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CachedNetworkImage(
            imageUrl: photos[index],
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

  bool _shouldShowReserveButton(String category) {
    return category.toLowerCase().contains('restaurant') || 
           category.toLowerCase().contains('dining') ||
           category.toLowerCase().contains('cafe') ||
           category.toLowerCase().contains('food');
  }

  Map<String, dynamic> _getMockPlaceData(String placeId) {
    // Return different data based on place ID
    switch (placeId) {
      case 'near_me_1': // Kigali Convention Centre
        return {
          'name': 'Kigali Convention Centre',
          'location': 'Kigali, Rwanda',
          'image': 'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=800',
          'rating': 4.8,
          'reviewCount': 245,
          'priceRange': 'Venue',
          'category': 'Venue',
          'description': 'A world-class convention center in the heart of Kigali, hosting international conferences, exhibitions, and events. Features state-of-the-art facilities and modern architecture.',
          'features': ['WiFi', 'Parking', 'Accessibility', 'Air Conditioning', 'Event Planning'],
          'openingHours': [
            {'day': 'Monday', 'time': '8:00 AM - 6:00 PM'},
            {'day': 'Tuesday', 'time': '8:00 AM - 6:00 PM'},
            {'day': 'Wednesday', 'time': '8:00 AM - 6:00 PM'},
            {'day': 'Thursday', 'time': '8:00 AM - 6:00 PM'},
            {'day': 'Friday', 'time': '8:00 AM - 6:00 PM'},
            {'day': 'Saturday', 'time': '9:00 AM - 5:00 PM'},
            {'day': 'Sunday', 'time': 'Closed'},
          ],
          'photos': [
            'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=400',
            'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400',
          ],
          'reviews': [
            {
              'user': 'Conference Organizer',
              'rating': 5,
              'date': '1 week ago',
              'comment': 'Excellent facilities and professional staff. Perfect for international events.',
              'avatar': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100',
            },
          ],
        };
      
      case 'near_me_2': // Kimisagara Market
        return {
          'name': 'Kimisagara Market',
          'location': 'Kimisagara, Kigali',
          'image': 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800',
          'rating': 4.2,
          'reviewCount': 89,
          'priceRange': 'Market',
          'category': 'Market',
          'description': 'A vibrant local market offering fresh produce, traditional crafts, and authentic Rwandan goods. Experience the local culture and find unique souvenirs.',
          'features': ['Fresh Produce', 'Local Crafts', 'Traditional Goods', 'Cultural Experience'],
          'openingHours': [
            {'day': 'Monday', 'time': '6:00 AM - 6:00 PM'},
            {'day': 'Tuesday', 'time': '6:00 AM - 6:00 PM'},
            {'day': 'Wednesday', 'time': '6:00 AM - 6:00 PM'},
            {'day': 'Thursday', 'time': '6:00 AM - 6:00 PM'},
            {'day': 'Friday', 'time': '6:00 AM - 6:00 PM'},
            {'day': 'Saturday', 'time': '6:00 AM - 6:00 PM'},
            {'day': 'Sunday', 'time': '6:00 AM - 6:00 PM'},
          ],
          'photos': [
            'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400',
            'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=400',
          ],
          'reviews': [
            {
              'user': 'Local Shopper',
              'rating': 4,
              'date': '3 days ago',
              'comment': 'Great place to find fresh vegetables and local crafts. Very authentic experience.',
              'avatar': 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=100',
            },
          ],
        };
      
      case 'near_me_3': // Kigali Genocide Memorial
        return {
          'name': 'Kigali Genocide Memorial',
          'location': 'Kigali, Rwanda',
          'image': 'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=800',
          'rating': 4.9,
          'reviewCount': 1203,
          'priceRange': 'Memorial',
          'category': 'Memorial',
          'description': 'A powerful memorial dedicated to the victims of the 1994 genocide against the Tutsi. A place of remembrance, education, and reflection on Rwanda\'s journey of reconciliation and healing.',
          'features': ['Educational Tours', 'Guided Visits', 'Memorial Gardens', 'Museum', 'Peace Education'],
          'openingHours': [
            {'day': 'Monday', 'time': '8:00 AM - 5:00 PM'},
            {'day': 'Tuesday', 'time': '8:00 AM - 5:00 PM'},
            {'day': 'Wednesday', 'time': '8:00 AM - 5:00 PM'},
            {'day': 'Thursday', 'time': '8:00 AM - 5:00 PM'},
            {'day': 'Friday', 'time': '8:00 AM - 5:00 PM'},
            {'day': 'Saturday', 'time': '8:00 AM - 5:00 PM'},
            {'day': 'Sunday', 'time': '8:00 AM - 5:00 PM'},
          ],
          'photos': [
            'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=400',
            'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400',
          ],
          'reviews': [
            {
              'user': 'Visitor',
              'rating': 5,
              'date': '1 week ago',
              'comment': 'A deeply moving and educational experience. Essential visit for understanding Rwanda\'s history.',
              'avatar': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100',
            },
          ],
        };
      
      case 'near_me_4': // Kimisagara Restaurant
        return {
          'name': 'Kimisagara Restaurant',
          'location': 'Kimisagara, Kigali',
          'image': 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800',
          'rating': 4.6,
          'reviewCount': 156,
          'priceRange': '\$\$',
          'category': 'Restaurant',
          'description': 'Authentic Rwandan restaurant serving traditional dishes in a warm, family-friendly atmosphere. Experience the rich flavors of local cuisine.',
          'features': ['WiFi', 'Parking', 'Outdoor Seating', 'Takeaway', 'Family Friendly'],
          'openingHours': [
            {'day': 'Monday', 'time': '7:00 AM - 10:00 PM'},
            {'day': 'Tuesday', 'time': '7:00 AM - 10:00 PM'},
            {'day': 'Wednesday', 'time': '7:00 AM - 10:00 PM'},
            {'day': 'Thursday', 'time': '7:00 AM - 10:00 PM'},
            {'day': 'Friday', 'time': '7:00 AM - 11:00 PM'},
            {'day': 'Saturday', 'time': '8:00 AM - 11:00 PM'},
            {'day': 'Sunday', 'time': '8:00 AM - 9:00 PM'},
          ],
          'photos': [
            'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400',
            'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=400',
          ],
          'menu': [
            {
              'name': 'Traditional Dishes',
              'items': [
                {
                  'name': 'Ugali with Fish',
                  'description': 'Traditional maize meal with grilled fish',
                  'price': 'RWF 5,000',
                  'image': 'https://images.unsplash.com/photo-1571091718767-18b5b1457add?w=200',
                  'isVegetarian': false,
                  'isSpicy': false,
                },
                {
                  'name': 'Beef Brochettes',
                  'description': 'Tender beef skewers with local spices',
                  'price': 'RWF 7,000',
                  'image': 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=200',
                  'isVegetarian': false,
                  'isSpicy': true,
                },
              ],
            },
          ],
          'reviews': [
            {
              'user': 'Food Lover',
              'rating': 5,
              'date': '2 days ago',
              'comment': 'Amazing traditional food! The beef brochettes are the best in Kigali.',
              'avatar': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100',
            },
          ],
        };
      
      case 'near_me_5': // Kigali City Tower
        return {
          'name': 'Kigali City Tower',
          'location': 'Kigali, Rwanda',
          'image': 'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=800',
          'rating': 4.3,
          'reviewCount': 456,
          'priceRange': 'Shopping',
          'category': 'Shopping',
          'description': 'A modern shopping and business complex in the heart of Kigali. Features retail stores, restaurants, offices, and entertainment facilities with panoramic city views.',
          'features': ['Shopping Mall', 'Restaurants', 'Entertainment', 'Business Center', 'City Views'],
          'openingHours': [
            {'day': 'Monday', 'time': '8:00 AM - 9:00 PM'},
            {'day': 'Tuesday', 'time': '8:00 AM - 9:00 PM'},
            {'day': 'Wednesday', 'time': '8:00 AM - 9:00 PM'},
            {'day': 'Thursday', 'time': '8:00 AM - 9:00 PM'},
            {'day': 'Friday', 'time': '8:00 AM - 10:00 PM'},
            {'day': 'Saturday', 'time': '9:00 AM - 10:00 PM'},
            {'day': 'Sunday', 'time': '9:00 AM - 8:00 PM'},
          ],
          'photos': [
            'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=400',
            'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400',
          ],
          'reviews': [
            {
              'user': 'Shopper',
              'rating': 4,
              'date': '2 days ago',
              'comment': 'Great shopping experience with good variety of stores and restaurants.',
              'avatar': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100',
            },
          ],
        };
      
      // Dining places (IDs 1-6)
      case '1': // Volcanoes National Park
        return {
          'name': 'Volcanoes National Park',
          'location': 'Musanze, Rwanda',
          'image': 'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=800',
          'rating': 4.9,
          'reviewCount': 1247,
          'priceRange': 'From \$1,500',
          'category': 'Wildlife',
          'description': 'Home to the endangered mountain gorillas, Volcanoes National Park offers one of the most incredible wildlife experiences on Earth. Trek through dense forests to encounter these magnificent creatures in their natural habitat.',
          'features': ['Gorilla Trekking', 'Guided Tours', 'Photography', 'Wildlife Viewing', 'Hiking'],
          'openingHours': [
            {'day': 'Monday', 'time': '7:00 AM - 6:00 PM'},
            {'day': 'Tuesday', 'time': '7:00 AM - 6:00 PM'},
            {'day': 'Wednesday', 'time': '7:00 AM - 6:00 PM'},
            {'day': 'Thursday', 'time': '7:00 AM - 6:00 PM'},
            {'day': 'Friday', 'time': '7:00 AM - 6:00 PM'},
            {'day': 'Saturday', 'time': '7:00 AM - 6:00 PM'},
            {'day': 'Sunday', 'time': '7:00 AM - 6:00 PM'},
          ],
          'photos': [
            'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=400',
            'https://images.unsplash.com/photo-1516026672322-bc52d61a55d5?w=400',
          ],
          'reviews': [
            {
              'user': 'Wildlife Enthusiast',
              'rating': 5,
              'date': '2 days ago',
              'comment': 'Absolutely incredible experience! Seeing the gorillas up close was a once-in-a-lifetime moment.',
              'avatar': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100',
            },
          ],
        };
      
      case '2': // Nyungwe Forest
        return {
          'name': 'Nyungwe Forest',
          'location': 'Nyungwe, Rwanda',
          'image': 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=800',
          'rating': 4.8,
          'reviewCount': 892,
          'priceRange': 'From \$200',
          'category': 'Nature',
          'description': 'Explore one of Africa\'s oldest rainforests with its incredible biodiversity. Walk across the famous canopy walkway and spot chimpanzees, colobus monkeys, and over 300 bird species.',
          'features': ['Canopy Walk', 'Chimpanzee Tracking', 'Bird Watching', 'Hiking Trails', 'Guided Tours'],
          'openingHours': [
            {'day': 'Monday', 'time': '6:00 AM - 6:00 PM'},
            {'day': 'Tuesday', 'time': '6:00 AM - 6:00 PM'},
            {'day': 'Wednesday', 'time': '6:00 AM - 6:00 PM'},
            {'day': 'Thursday', 'time': '6:00 AM - 6:00 PM'},
            {'day': 'Friday', 'time': '6:00 AM - 6:00 PM'},
            {'day': 'Saturday', 'time': '6:00 AM - 6:00 PM'},
            {'day': 'Sunday', 'time': '6:00 AM - 6:00 PM'},
          ],
          'photos': [
            'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=400',
            'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=400',
          ],
          'reviews': [
            {
              'user': 'Nature Lover',
              'rating': 5,
              'date': '1 week ago',
              'comment': 'The canopy walk was breathtaking! The forest is so peaceful and full of life.',
              'avatar': 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=100',
            },
          ],
        };
      
      case '3': // Lake Kivu
        return {
          'name': 'Lake Kivu',
          'location': 'Rubavu, Rwanda',
          'image': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
          'rating': 4.7,
          'reviewCount': 654,
          'priceRange': 'From \$80',
          'category': 'Water',
          'description': 'Relax on the shores of one of Africa\'s great lakes. Enjoy boat cruises, fishing, and stunning sunsets over the water. Perfect for a peaceful getaway.',
          'features': ['Boat Cruises', 'Fishing', 'Swimming', 'Sunset Views', 'Water Sports'],
          'openingHours': [
            {'day': 'Monday', 'time': '8:00 AM - 8:00 PM'},
            {'day': 'Tuesday', 'time': '8:00 AM - 8:00 PM'},
            {'day': 'Wednesday', 'time': '8:00 AM - 8:00 PM'},
            {'day': 'Thursday', 'time': '8:00 AM - 8:00 PM'},
            {'day': 'Friday', 'time': '8:00 AM - 8:00 PM'},
            {'day': 'Saturday', 'time': '8:00 AM - 8:00 PM'},
            {'day': 'Sunday', 'time': '8:00 AM - 8:00 PM'},
          ],
          'photos': [
            'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400',
            'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=400',
          ],
          'reviews': [
            {
              'user': 'Lake Explorer',
              'rating': 4,
              'date': '3 days ago',
              'comment': 'Beautiful lake with amazing views. The boat cruise was very relaxing.',
              'avatar': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100',
            },
          ],
        };
      
      case '4': // Kigali Genocide Memorial
        return {
          'name': 'Kigali Genocide Memorial',
          'location': 'Kigali, Rwanda',
          'image': 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800',
          'rating': 4.9,
          'reviewCount': 2156,
          'priceRange': 'Free',
          'category': 'History',
          'description': 'A powerful memorial dedicated to the victims of the 1994 genocide against the Tutsi. A place of remembrance, education, and reflection on Rwanda\'s journey of reconciliation and healing.',
          'features': ['Educational Tours', 'Guided Visits', 'Memorial Gardens', 'Museum', 'Peace Education'],
          'openingHours': [
            {'day': 'Monday', 'time': '8:00 AM - 5:00 PM'},
            {'day': 'Tuesday', 'time': '8:00 AM - 5:00 PM'},
            {'day': 'Wednesday', 'time': '8:00 AM - 5:00 PM'},
            {'day': 'Thursday', 'time': '8:00 AM - 5:00 PM'},
            {'day': 'Friday', 'time': '8:00 AM - 5:00 PM'},
            {'day': 'Saturday', 'time': '8:00 AM - 5:00 PM'},
            {'day': 'Sunday', 'time': '8:00 AM - 5:00 PM'},
          ],
          'photos': [
            'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400',
            'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=400',
          ],
          'reviews': [
            {
              'user': 'Visitor',
              'rating': 5,
              'date': '1 week ago',
              'comment': 'A deeply moving and educational experience. Essential for understanding Rwanda\'s history.',
              'avatar': 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=100',
            },
          ],
        };
      
      case '5': // Akagera National Park
        return {
          'name': 'Akagera National Park',
          'location': 'Eastern Rwanda',
          'image': 'https://images.unsplash.com/photo-1516026672322-bc52d61a55d5?w=800',
          'rating': 4.6,
          'reviewCount': 743,
          'priceRange': 'From \$300',
          'category': 'Wildlife',
          'description': 'Experience a classic African safari in Rwanda\'s only savanna national park. Spot the Big Five, including lions, elephants, and rhinos, in their natural habitat.',
          'features': ['Safari Drives', 'Big Five Viewing', 'Bird Watching', 'Game Drives', 'Wildlife Photography'],
          'openingHours': [
            {'day': 'Monday', 'time': '6:00 AM - 6:00 PM'},
            {'day': 'Tuesday', 'time': '6:00 AM - 6:00 PM'},
            {'day': 'Wednesday', 'time': '6:00 AM - 6:00 PM'},
            {'day': 'Thursday', 'time': '6:00 AM - 6:00 PM'},
            {'day': 'Friday', 'time': '6:00 AM - 6:00 PM'},
            {'day': 'Saturday', 'time': '6:00 AM - 6:00 PM'},
            {'day': 'Sunday', 'time': '6:00 AM - 6:00 PM'},
          ],
          'photos': [
            'https://images.unsplash.com/photo-1516026672322-bc52d61a55d5?w=400',
            'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=400',
          ],
          'reviews': [
            {
              'user': 'Safari Enthusiast',
              'rating': 4,
              'date': '5 days ago',
              'comment': 'Amazing wildlife viewing! Saw lions, elephants, and many other animals. Great safari experience.',
              'avatar': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100',
            },
          ],
        };
      
      case '6': // Pizza Inn
        return {
          'name': 'Pizza Inn',
          'location': 'Kacyiru, Kigali',
          'image': 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=800',
          'rating': 4.1,
          'reviewCount': 156,
          'priceRange': '\$\$',
          'category': 'Fast Food',
          'description': 'Family-friendly pizza restaurant with a variety of pizzas, pasta, and Italian dishes. Great for casual dining with friends and family.',
          'features': ['WiFi', 'Parking', 'Family Friendly', 'Takeaway', 'Delivery'],
          'openingHours': [
            {'day': 'Monday', 'time': '11:00 AM - 10:00 PM'},
            {'day': 'Tuesday', 'time': '11:00 AM - 10:00 PM'},
            {'day': 'Wednesday', 'time': '11:00 AM - 10:00 PM'},
            {'day': 'Thursday', 'time': '11:00 AM - 10:00 PM'},
            {'day': 'Friday', 'time': '11:00 AM - 11:00 PM'},
            {'day': 'Saturday', 'time': '11:00 AM - 11:00 PM'},
            {'day': 'Sunday', 'time': '11:00 AM - 10:00 PM'},
          ],
          'photos': [
            'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=400',
            'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=400',
          ],
          'menu': [
            {
              'name': 'Pizza & Pasta',
              'items': [
                {
                  'name': 'Pepperoni Pizza',
                  'description': 'Classic pizza with pepperoni and cheese',
                  'price': 'RWF 8,500',
                  'image': 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=200',
                  'isVegetarian': false,
                  'isSpicy': true,
                },
                {
                  'name': 'Spaghetti Bolognese',
                  'description': 'Traditional pasta with meat sauce',
                  'price': 'RWF 7,000',
                  'image': 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=200',
                  'isVegetarian': false,
                  'isSpicy': false,
                },
              ],
            },
          ],
          'reviews': [
            {
              'user': 'Pizza Lover',
              'rating': 4,
              'date': '5 days ago',
              'comment': 'Good pizza and family atmosphere. Kids loved it!',
              'avatar': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100',
            },
          ],
        };
      
      // Shopping places
      case 'shop_1': // Kigali City Tower
        return {
          'name': 'Kigali City Tower',
          'location': 'Kigali, Rwanda',
          'image': 'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=800',
          'rating': 4.3,
          'reviewCount': 456,
          'priceRange': 'Shopping',
          'category': 'Mall',
          'description': 'Modern shopping mall in the heart of Kigali with international and local brands, restaurants, and entertainment options.',
          'features': ['WiFi', 'Parking', 'Air Conditioning', 'ATM', 'Food Court'],
          'openingHours': [
            {'day': 'Monday', 'time': '9:00 AM - 9:00 PM'},
            {'day': 'Tuesday', 'time': '9:00 AM - 9:00 PM'},
            {'day': 'Wednesday', 'time': '9:00 AM - 9:00 PM'},
            {'day': 'Thursday', 'time': '9:00 AM - 9:00 PM'},
            {'day': 'Friday', 'time': '9:00 AM - 10:00 PM'},
            {'day': 'Saturday', 'time': '9:00 AM - 10:00 PM'},
            {'day': 'Sunday', 'time': '10:00 AM - 8:00 PM'},
          ],
          'photos': [
            'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=400',
            'https://images.unsplash.com/photo-1555529902-1c0a6a2b5b5b?w=400',
          ],
          'reviews': [
            {
              'user': 'Sarah M.',
              'rating': 5,
              'comment': 'Great shopping experience with good variety of stores.',
              'date': '2 days ago',
              'avatar': 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=100',
            },
            {
              'user': 'John K.',
              'rating': 4,
              'comment': 'Clean and modern mall with good parking facilities.',
              'date': '1 week ago',
              'avatar': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100',
            },
          ],
        };
      
      case 'shop_2': // Kimisagara Market
        return {
          'name': 'Kimisagara Market',
          'location': 'Kimisagara, Kigali',
          'image': 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800',
          'rating': 4.2,
          'reviewCount': 89,
          'priceRange': 'Market',
          'category': 'Market',
          'description': 'Traditional local market offering fresh produce, crafts, and local goods. Experience authentic Rwandan market culture.',
          'features': ['Fresh Produce', 'Local Crafts', 'Bargaining', 'Local Experience'],
          'openingHours': [
            {'day': 'Monday', 'time': '6:00 AM - 6:00 PM'},
            {'day': 'Tuesday', 'time': '6:00 AM - 6:00 PM'},
            {'day': 'Wednesday', 'time': '6:00 AM - 6:00 PM'},
            {'day': 'Thursday', 'time': '6:00 AM - 6:00 PM'},
            {'day': 'Friday', 'time': '6:00 AM - 6:00 PM'},
            {'day': 'Saturday', 'time': '6:00 AM - 6:00 PM'},
            {'day': 'Sunday', 'time': '6:00 AM - 6:00 PM'},
          ],
          'photos': [
            'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400',
            'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=400',
          ],
          'reviews': [
            {
              'user': 'Marie R.',
              'rating': 5,
              'comment': 'Authentic market experience with fresh local produce.',
              'date': '3 days ago',
              'avatar': 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=100',
            },
            {
              'user': 'David L.',
              'rating': 4,
              'comment': 'Great place to buy local crafts and souvenirs.',
              'date': '1 week ago',
              'avatar': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100',
            },
          ],
        };
      
      case 'shop_3': // Rwanda Fashion House
        return {
          'name': 'Rwanda Fashion House',
          'location': 'Nyarutarama, Kigali',
          'image': 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=800',
          'rating': 4.6,
          'reviewCount': 123,
          'priceRange': 'Boutique',
          'category': 'Boutique',
          'description': 'High-end fashion boutique featuring contemporary African designs and international brands. Perfect for special occasions.',
          'features': ['Fashion', 'Designer Clothes', 'Personal Styling', 'Alterations'],
          'openingHours': [
            {'day': 'Monday', 'time': '9:00 AM - 7:00 PM'},
            {'day': 'Tuesday', 'time': '9:00 AM - 7:00 PM'},
            {'day': 'Wednesday', 'time': '9:00 AM - 7:00 PM'},
            {'day': 'Thursday', 'time': '9:00 AM - 7:00 PM'},
            {'day': 'Friday', 'time': '9:00 AM - 8:00 PM'},
            {'day': 'Saturday', 'time': '9:00 AM - 8:00 PM'},
            {'day': 'Sunday', 'time': '10:00 AM - 6:00 PM'},
          ],
          'photos': [
            'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=400',
            'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=400',
          ],
          'reviews': [
            {
              'user': 'Grace N.',
              'rating': 5,
              'comment': 'Beautiful designs and excellent customer service.',
              'date': '1 day ago',
              'avatar': 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=100',
            },
            {
              'user': 'Paul M.',
              'rating': 5,
              'comment': 'Great selection of African fashion and accessories.',
              'date': '5 days ago',
              'avatar': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100',
            },
          ],
        };
      
      case 'shop_4': // Kigali Heights Mall
        return {
          'name': 'Kigali Heights Mall',
          'location': 'Kigali Heights, Rwanda',
          'image': 'https://images.unsplash.com/photo-1555529902-1c0a6a2b5b5b?w=800',
          'rating': 4.4,
          'reviewCount': 234,
          'priceRange': 'Mall',
          'category': 'Mall',
          'description': 'Premium shopping destination with luxury brands, fine dining, and entertainment. The ultimate shopping experience in Kigali.',
          'features': ['Luxury Brands', 'Fine Dining', 'Cinema', 'Parking', 'WiFi'],
          'openingHours': [
            {'day': 'Monday', 'time': '10:00 AM - 9:00 PM'},
            {'day': 'Tuesday', 'time': '10:00 AM - 9:00 PM'},
            {'day': 'Wednesday', 'time': '10:00 AM - 9:00 PM'},
            {'day': 'Thursday', 'time': '10:00 AM - 9:00 PM'},
            {'day': 'Friday', 'time': '10:00 AM - 10:00 PM'},
            {'day': 'Saturday', 'time': '10:00 AM - 10:00 PM'},
            {'day': 'Sunday', 'time': '11:00 AM - 8:00 PM'},
          ],
          'photos': [
            'https://images.unsplash.com/photo-1555529902-1c0a6a2b5b5b?w=400',
            'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=400',
          ],
          'reviews': [
            {
              'user': 'Anna K.',
              'rating': 5,
              'comment': 'Luxury shopping at its finest with great restaurants.',
              'date': '2 days ago',
              'avatar': 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=100',
            },
            {
              'user': 'Michael T.',
              'rating': 4,
              'comment': 'Excellent mall with good variety of stores and dining.',
              'date': '1 week ago',
              'avatar': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100',
            },
          ],
        };
      
      case 'shop_5': // Nyabugogo Market
        return {
          'name': 'Nyabugogo Market',
          'location': 'Nyabugogo, Kigali',
          'image': 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800',
          'rating': 4.1,
          'reviewCount': 156,
          'priceRange': 'Market',
          'category': 'Market',
          'description': 'One of Kigali\'s largest traditional markets offering everything from fresh produce to household goods and local crafts.',
          'features': ['Fresh Produce', 'Household Goods', 'Local Crafts', 'Bargaining'],
          'openingHours': [
            {'day': 'Monday', 'time': '5:00 AM - 7:00 PM'},
            {'day': 'Tuesday', 'time': '5:00 AM - 7:00 PM'},
            {'day': 'Wednesday', 'time': '5:00 AM - 7:00 PM'},
            {'day': 'Thursday', 'time': '5:00 AM - 7:00 PM'},
            {'day': 'Friday', 'time': '5:00 AM - 7:00 PM'},
            {'day': 'Saturday', 'time': '5:00 AM - 7:00 PM'},
            {'day': 'Sunday', 'time': '6:00 AM - 6:00 PM'},
          ],
          'photos': [
            'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400',
            'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=400',
          ],
          'reviews': [
            {
              'user': 'Claire U.',
              'rating': 4,
              'comment': 'Huge market with everything you need at good prices.',
              'date': '4 days ago',
              'avatar': 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=100',
            },
            {
              'user': 'Robert H.',
              'rating': 4,
              'comment': 'Authentic local market experience, great for souvenirs.',
              'date': '1 week ago',
              'avatar': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100',
            },
          ],
        };
      
      case 'shop_6': // Rwanda Crafts Boutique
        return {
          'name': 'Rwanda Crafts Boutique',
          'location': 'Kacyiru, Kigali',
          'image': 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=800',
          'rating': 4.7,
          'reviewCount': 78,
          'priceRange': 'Boutique',
          'category': 'Boutique',
          'description': 'Specialized boutique featuring authentic Rwandan crafts, traditional art, and handmade souvenirs. Supporting local artisans.',
          'features': ['Local Crafts', 'Traditional Art', 'Handmade Items', 'Artisan Support'],
          'openingHours': [
            {'day': 'Monday', 'time': '9:00 AM - 6:00 PM'},
            {'day': 'Tuesday', 'time': '9:00 AM - 6:00 PM'},
            {'day': 'Wednesday', 'time': '9:00 AM - 6:00 PM'},
            {'day': 'Thursday', 'time': '9:00 AM - 6:00 PM'},
            {'day': 'Friday', 'time': '9:00 AM - 7:00 PM'},
            {'day': 'Saturday', 'time': '9:00 AM - 7:00 PM'},
            {'day': 'Sunday', 'time': '10:00 AM - 5:00 PM'},
          ],
          'photos': [
            'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=400',
            'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=400',
          ],
          'reviews': [
            {
              'user': 'Linda S.',
              'rating': 5,
              'comment': 'Beautiful authentic crafts, perfect for gifts.',
              'date': '1 day ago',
              'avatar': 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=100',
            },
            {
              'user': 'James W.',
              'rating': 5,
              'comment': 'Amazing selection of traditional Rwandan art.',
              'date': '3 days ago',
              'avatar': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100',
            },
          ],
        };
      
      case 'shop_7': // Kigali Convention Centre Shops
        return {
          'name': 'Kigali Convention Centre Shops',
          'location': 'Kigali, Rwanda',
          'image': 'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=800',
          'rating': 4.0,
          'reviewCount': 67,
          'priceRange': 'Mall',
          'category': 'Mall',
          'description': 'Convenient shopping area within the convention centre featuring international brands, souvenirs, and business essentials.',
          'features': ['International Brands', 'Souvenirs', 'Business Essentials', 'WiFi'],
          'openingHours': [
            {'day': 'Monday', 'time': '8:00 AM - 6:00 PM'},
            {'day': 'Tuesday', 'time': '8:00 AM - 6:00 PM'},
            {'day': 'Wednesday', 'time': '8:00 AM - 6:00 PM'},
            {'day': 'Thursday', 'time': '8:00 AM - 6:00 PM'},
            {'day': 'Friday', 'time': '8:00 AM - 6:00 PM'},
            {'day': 'Saturday', 'time': '9:00 AM - 5:00 PM'},
            {'day': 'Sunday', 'time': 'Closed'},
          ],
          'photos': [
            'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=400',
            'https://images.unsplash.com/photo-1555529902-1c0a6a2b5b5b?w=400',
          ],
          'reviews': [
            {
              'user': 'Business Traveler',
              'rating': 4,
              'comment': 'Convenient shopping for business travelers.',
              'date': '2 days ago',
              'avatar': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100',
            },
            {
              'user': 'Conference Attendee',
              'rating': 4,
              'comment': 'Good selection of souvenirs and essentials.',
              'date': '1 week ago',
              'avatar': 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=100',
            },
          ],
        };
      
      case 'shop_8': // Kimironko Market
        return {
          'name': 'Kimironko Market',
          'location': 'Kimironko, Kigali',
          'image': 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800',
          'rating': 4.3,
          'reviewCount': 98,
          'priceRange': 'Market',
          'category': 'Market',
          'description': 'Vibrant local market known for fresh produce, textiles, and household items. A great place to experience local culture and find unique items.',
          'features': ['Fresh Produce', 'Textiles', 'Household Items', 'Local Culture'],
          'openingHours': [
            {'day': 'Monday', 'time': '6:00 AM - 6:00 PM'},
            {'day': 'Tuesday', 'time': '6:00 AM - 6:00 PM'},
            {'day': 'Wednesday', 'time': '6:00 AM - 6:00 PM'},
            {'day': 'Thursday', 'time': '6:00 AM - 6:00 PM'},
            {'day': 'Friday', 'time': '6:00 AM - 6:00 PM'},
            {'day': 'Saturday', 'time': '6:00 AM - 6:00 PM'},
            {'day': 'Sunday', 'time': '6:00 AM - 6:00 PM'},
          ],
          'photos': [
            'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400',
            'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=400',
          ],
          'reviews': [
            {
              'user': 'Tourist Guide',
              'rating': 5,
              'comment': 'Authentic market experience with friendly vendors.',
              'date': '3 days ago',
              'avatar': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100',
            },
            {
              'user': 'Local Shopper',
              'rating': 4,
              'comment': 'Great prices and fresh produce, very convenient.',
              'date': '5 days ago',
              'avatar': 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=100',
            },
          ],
        };
      
      default: // Default restaurant data
        return {
          'name': 'The Hut Restaurant',
          'location': 'Kigali, Rwanda',
          'image': 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800',
          'rating': 4.5,
          'reviewCount': 128,
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
        };
    }
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

  void _showReviewBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ReviewBottomSheet(),
    );
  }
}

class _ReviewBottomSheet extends StatefulWidget {
  @override
  _ReviewBottomSheetState createState() => _ReviewBottomSheetState();
}

class _ReviewBottomSheetState extends State<_ReviewBottomSheet> {
  int _selectedRating = 5;
  final TextEditingController _reviewController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Title
          Text(
            'Write a Review',
            style: AppTheme.headlineMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          
          // Rating selection
          Text(
            'How was your experience?',
            style: AppTheme.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          
          Row(
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedRating = index + 1;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: Icon(
                    index < _selectedRating ? Icons.star : Icons.star_border,
                    color: index < _selectedRating 
                        ? Colors.amber 
                        : Colors.grey[400],
                    size: 32,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),
          
          // Review text field
          Text(
            'Tell us about your experience',
            style: AppTheme.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          
          TextField(
            controller: _reviewController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Share your thoughts about this place...',
              hintStyle: AppTheme.bodyMedium.copyWith(
                color: AppTheme.secondaryTextColor,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.primaryColor),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 24),
          
          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitReview,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Submit Review',
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _submitReview() async {
    if (_reviewController.text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please write a review before submitting'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Thank you for your review!'),
          backgroundColor: AppTheme.successColor,
          action: SnackBarAction(
            label: 'View',
            textColor: Colors.white,
            onPressed: () {
              // TODO: Navigate to reviews tab
            },
          ),
        ),
      );

      // Close bottom sheet
      Navigator.pop(context);
    }
  }
}
