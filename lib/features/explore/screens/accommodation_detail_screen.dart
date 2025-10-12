import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class AccommodationDetailScreen extends ConsumerStatefulWidget {
  final String accommodationId;

  const AccommodationDetailScreen({
    super.key,
    required this.accommodationId,
  });

  @override
  ConsumerState<AccommodationDetailScreen> createState() => _AccommodationDetailScreenState();
}

class _AccommodationDetailScreenState extends ConsumerState<AccommodationDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isFavorite = false;
  int _selectedImageIndex = 0;
  Map<String, Map<String, dynamic>> _selectedRooms = {}; // roomType -> {roomType, quantity}

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accommodation = _getAccommodationDetails(widget.accommodationId);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(accommodation),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildAccommodationInfo(accommodation),
                _buildTabBar(),
                _buildTabContent(accommodation),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(accommodation),
    );
  }

  Widget _buildSliverAppBar(Map<String, dynamic> accommodation) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: AppTheme.backgroundColor,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: const Icon(Icons.chevron_left, size: 32),
        style: IconButton.styleFrom(
          foregroundColor: AppTheme.primaryTextColor,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () {
            // Share functionality
          },
        ),
        IconButton(
          icon: Icon(
            _isFavorite ? Icons.favorite : Icons.favorite_border,
            color: _isFavorite ? Colors.red : AppTheme.primaryTextColor,
          ),
          onPressed: () {
            setState(() {
              _isFavorite = !_isFavorite;
            });
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              onPageChanged: (index) {
                setState(() {
                  _selectedImageIndex = index;
                });
              },
              itemCount: accommodation['images'].length,
              itemBuilder: (context, index) {
                return Image.network(
                  accommodation['images'][index],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.grey[400],
                        size: 48,
                      ),
                    );
                  },
                );
              },
            ),
            // Image indicators
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  accommodation['images'].length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _selectedImageIndex == index
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
            ),
            // Price badge
            Positioned(
              top: 100,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'RWF ${accommodation['price']}',
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
    );
  }

  Widget _buildAccommodationInfo(Map<String, dynamic> accommodation) {
    return Container(
      color: AppTheme.backgroundColor,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  accommodation['name'],
                  style: AppTheme.headlineMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    accommodation['rating'].toString(),
                    style: AppTheme.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    ' (${accommodation['reviews']} reviews)',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.secondaryTextColor,
                    ),
                  ),
                ],
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
              Text(
                accommodation['location'],
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.secondaryTextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Quick amenities
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: accommodation['quickAmenities'].map<Widget>((amenity) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  amenity,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.primaryTextColor,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppTheme.backgroundColor,
      child: TabBar(
        controller: _tabController,
        labelColor: AppTheme.primaryColor,
        unselectedLabelColor: AppTheme.secondaryTextColor,
        indicatorColor: AppTheme.primaryColor,
        indicatorWeight: 2,
        labelStyle: AppTheme.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
        ),
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Rooms'),
          Tab(text: 'Amenities'),
          Tab(text: 'Reviews'),
          Tab(text: 'Photos'),
        ],
      ),
    );
  }

  Widget _buildTabContent(Map<String, dynamic> accommodation) {
    return Container(
      height: 400,
      color: AppTheme.backgroundColor,
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(accommodation),
          _buildRoomsTab(accommodation),
          _buildAmenitiesTab(accommodation),
          _buildReviewsTab(accommodation),
          _buildPhotosTab(accommodation),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(Map<String, dynamic> accommodation) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About this place',
            style: AppTheme.headlineSmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            accommodation['description'],
            style: AppTheme.bodyMedium.copyWith(
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Check-in & Check-out',
            style: AppTheme.headlineSmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Check-in',
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '3:00 PM',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Check-out',
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '11:00 AM',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoomsTab(Map<String, dynamic> accommodation) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Available Rooms',
            style: AppTheme.headlineSmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          if (accommodation['roomTypes'] != null) ...[
            ...accommodation['roomTypes'].map<Widget>((roomType) => 
              _buildSelectableRoomTypeCard(roomType)
            ).toList(),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  'No room types available',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.secondaryTextColor,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAmenitiesTab(Map<String, dynamic> accommodation) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Amenities',
            style: AppTheme.headlineSmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...accommodation['amenities'].map<Widget>((amenity) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Icon(
                    amenity['icon'],
                    size: 20,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    amenity['name'],
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
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

  Widget _buildReviewsTab(Map<String, dynamic> accommodation) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Reviews',
                style: AppTheme.headlineSmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${accommodation['reviews']} reviews',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.secondaryTextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...accommodation['reviewList'].map<Widget>((review) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(review['userImage']),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              review['userName'],
                              style: AppTheme.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Row(
                              children: [
                                ...List.generate(5, (index) {
                                  return Icon(
                                    Icons.star,
                                    size: 16,
                                    color: index < review['rating']
                                        ? Colors.amber
                                        : Colors.grey[300],
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
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildPhotosTab(Map<String, dynamic> accommodation) {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: accommodation['images'].length,
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            accommodation['images'][index],
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[200],
                child: Icon(
                  Icons.image_not_supported,
                  color: Colors.grey[400],
                  size: 32,
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildBottomBar(Map<String, dynamic> accommodation) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getTotalPrice(),
                  style: AppTheme.headlineSmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
                Text(
                  _getPriceDescription(),
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _selectedRooms.isNotEmpty ? () {
                context.push('/accommodation/${widget.accommodationId}/book');
              } : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedRooms.isNotEmpty 
                    ? AppTheme.primaryColor 
                    : Colors.grey[300],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
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
    );
  }

  Map<String, dynamic> _getAccommodationDetails(String id) {
    // Mock accommodation details
    return {
      'id': id,
      'name': 'Kigali Marriott Hotel',
      'location': 'Kacyiru, Kigali',
      'rating': 4.8,
      'reviews': 1247,
      'price': '120,000',
      'description': 'Experience luxury and comfort at the Kigali Marriott Hotel, located in the heart of Kigali\'s business district. Our hotel offers world-class amenities, exceptional service, and stunning views of the city.',
      'quickAmenities': ['WiFi', 'Pool', 'Spa', 'Restaurant'],
      'images': [
        'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800',
        'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=800',
        'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=800',
        'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=800',
      ],
      'amenities': [
        {'name': 'Free WiFi', 'icon': Icons.wifi},
        {'name': 'Swimming Pool', 'icon': Icons.pool},
        {'name': 'Spa & Wellness', 'icon': Icons.spa},
        {'name': 'Restaurant', 'icon': Icons.restaurant},
        {'name': 'Fitness Center', 'icon': Icons.fitness_center},
        {'name': 'Business Center', 'icon': Icons.business},
        {'name': 'Parking', 'icon': Icons.local_parking},
        {'name': 'Airport Shuttle', 'icon': Icons.airport_shuttle},
      ],
      'roomTypes': [
        {
          'type': 'Deluxe Room',
          'price': '120,000',
          'available': 3,
          'maxGuests': 2,
          'amenities': 'King bed, City view, WiFi',
        },
        {
          'type': 'Executive Suite',
          'price': '180,000',
          'available': 1,
          'maxGuests': 4,
          'amenities': 'King bed, Living area, City view, WiFi',
        },
      ],
      'reviewList': [
        {
          'userName': 'John Doe',
          'userImage': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100',
          'rating': 5,
          'date': '2 days ago',
          'comment': 'Excellent hotel with great service and amenities. The staff was very helpful and the rooms were clean and comfortable.',
        },
        {
          'userName': 'Sarah Wilson',
          'userImage': 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=100',
          'rating': 4,
          'date': '1 week ago',
          'comment': 'Beautiful hotel with amazing views. The pool area is fantastic and the restaurant serves delicious food.',
        },
        {
          'userName': 'Michael Brown',
          'userImage': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100',
          'rating': 5,
          'date': '2 weeks ago',
          'comment': 'Perfect location for business travelers. The conference facilities are top-notch and the staff is very professional.',
        },
      ],
    };
  }

  Widget _buildSelectableRoomTypeCard(Map<String, dynamic> roomType) {
    final roomTypeKey = roomType['type'];
    final isSelected = _selectedRooms.containsKey(roomTypeKey);
    final quantity = _selectedRooms[roomTypeKey]?['quantity'] ?? 0;
    final maxAvailable = roomType['available'] as int;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppTheme.primaryColor : Colors.grey[200]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  roomType['type'],
                  style: AppTheme.headlineSmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'RWF ${roomType['price']}',
                  style: AppTheme.bodySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.bed,
                size: 16,
                color: AppTheme.secondaryTextColor,
              ),
              const SizedBox(width: 4),
              Text(
                '${roomType['maxGuests']} guests',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.secondaryTextColor,
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.hotel,
                size: 16,
                color: AppTheme.secondaryTextColor,
              ),
              const SizedBox(width: 4),
              Text(
                '${roomType['available']} available',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.secondaryTextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            roomType['amenities'],
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.secondaryTextColor,
            ),
          ),
          const SizedBox(height: 12),
          // Quantity selector
          Row(
            children: [
              Text(
                'Quantity:',
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: quantity > 0 ? () {
                        setState(() {
                          if (quantity > 1) {
                            _selectedRooms[roomTypeKey] = {
                              'roomType': roomType,
                              'quantity': quantity - 1,
                            };
                          } else {
                            _selectedRooms.remove(roomTypeKey);
                          }
                        });
                      } : null,
                      icon: Icon(
                        Icons.remove,
                        size: 16,
                        color: quantity > 0 ? AppTheme.primaryColor : Colors.grey[400],
                      ),
                      style: IconButton.styleFrom(
                        padding: const EdgeInsets.all(8),
                        minimumSize: const Size(32, 32),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Text(
                        quantity.toString(),
                        style: AppTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: quantity < maxAvailable ? () {
                        setState(() {
                          _selectedRooms[roomTypeKey] = {
                            'roomType': roomType,
                            'quantity': quantity + 1,
                          };
                        });
                      } : null,
                      icon: Icon(
                        Icons.add,
                        size: 16,
                        color: quantity < maxAvailable ? AppTheme.primaryColor : Colors.grey[400],
                      ),
                      style: IconButton.styleFrom(
                        padding: const EdgeInsets.all(8),
                        minimumSize: const Size(32, 32),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (quantity > 0)
                Text(
                  'Total: RWF ${(int.parse(roomType['price'].replaceAll(',', '')) * quantity).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _getTotalPrice() {
    final accommodation = _getAccommodationDetails(widget.accommodationId);
    
    if (_selectedRooms.isEmpty) {
      return 'RWF ${accommodation['price']}';
    }
    
    int total = 0;
    for (var roomSelection in _selectedRooms.values) {
      final roomType = roomSelection['roomType'] as Map<String, dynamic>;
      final quantity = roomSelection['quantity'] as int;
      final price = int.parse(roomType['price'].toString().replaceAll(',', ''));
      total += price * quantity;
    }
    
    return 'RWF ${total.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  String _getPriceDescription() {
    if (_selectedRooms.isEmpty) {
      return 'per night';
    }
    
    int totalRooms = 0;
    for (var roomSelection in _selectedRooms.values) {
      totalRooms += roomSelection['quantity'] as int;
    }
    
    if (totalRooms == 1) {
      return '1 room - per night';
    } else {
      return '$totalRooms rooms - per night';
    }
  }
}
