import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';

class VisitedPlacesScreen extends ConsumerStatefulWidget {
  const VisitedPlacesScreen({super.key});

  @override
  ConsumerState<VisitedPlacesScreen> createState() => _VisitedPlacesScreenState();
}

class _VisitedPlacesScreenState extends ConsumerState<VisitedPlacesScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Visited Places',
          style: AppTheme.titleLarge,
        ),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () => context.go('/profile'),
          icon: const Icon(Icons.chevron_left, size: 32),
          style: IconButton.styleFrom(
            foregroundColor: AppTheme.primaryTextColor,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Add search functionality
            },
            icon: const Icon(Icons.search_outlined),
            style: IconButton.styleFrom(
              backgroundColor: AppTheme.dividerColor,
              foregroundColor: AppTheme.primaryTextColor,
            ),
          ),
          const SizedBox(width: 16),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryColor,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.secondaryTextColor,
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          tabAlignment: TabAlignment.start,
          isScrollable: true,
          tabs: const [
            Tab(text: 'All Places'),
            Tab(text: 'This Year'),
            Tab(text: 'Favorites'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPlacesList(),
          _buildPlacesList(),
          _buildPlacesList(),
        ],
      ),
    );
  }

  Widget _buildPlacesList() {
    // Mock data for demonstration
    final places = _getMockPlaces();
    
    if (places.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: places.length,
      itemBuilder: (context, index) {
        final place = places[index];
        return _buildPlaceCard(place);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppTheme.dividerColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.place,
              size: 48,
              color: AppTheme.secondaryTextColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Places Visited',
            style: AppTheme.titleLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start exploring Rwanda to build your\nvisited places collection',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.secondaryTextColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/explore'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Explore Places',
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceCard(Map<String, dynamic> place) {
    final visitDate = place['visitDate'] as DateTime;
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Place Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: place['image'] as String,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 200,
                    color: AppTheme.dividerColor,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 200,
                    color: AppTheme.dividerColor,
                    child: const Icon(
                      Icons.place,
                      size: 64,
                      color: AppTheme.secondaryTextColor,
                    ),
                  ),
                ),
                // Visited Badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.successColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          size: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Visited',
                          style: AppTheme.labelSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Category Badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      place['category'] as String,
                      style: AppTheme.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Place Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Place Name
                Text(
                  place['name'] as String,
                  style: AppTheme.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Location
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 16,
                      color: AppTheme.secondaryTextColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        place['location'] as String,
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.secondaryTextColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Visit Date
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: AppTheme.secondaryTextColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Visited on ${dateFormat.format(visitDate)}',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Rating
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      size: 16,
                      color: Colors.amber[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      place['rating'].toString(),
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${place['reviewCount']} reviews)',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Navigate to place details
                          // context.go('/place/${place['id']}');
                        },
                        icon: const Icon(Icons.visibility, size: 16),
                        label: const Text('View Details'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryColor,
                          backgroundColor: AppTheme.backgroundColor,
                          side: const BorderSide(color: AppTheme.primaryColor),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Add to favorites
                        },
                        icon: const Icon(Icons.favorite_border, size: 16),
                        label: const Text('Favorite'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: AppTheme.primaryColor,
                          side: const BorderSide(color: AppTheme.primaryColor),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
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

  List<Map<String, dynamic>> _getMockPlaces() {
    // Mock data for demonstration - using simple Map structure
    return [
      {
        'id': '1',
        'name': 'Volcanoes National Park',
        'location': 'Musanze, Northern Province',
        'category': 'National Park',
        'visitDate': DateTime.now().subtract(const Duration(days: 45)),
        'rating': 4.8,
        'reviewCount': 1250,
        'image': 'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=400&h=300&fit=crop',
      },
      {
        'id': '2',
        'name': 'Kigali Genocide Memorial',
        'location': 'Kigali, Rwanda',
        'category': 'Museum',
        'visitDate': DateTime.now().subtract(const Duration(days: 20)),
        'rating': 4.9,
        'reviewCount': 890,
        'image': 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=300&fit=crop',
      },
      {
        'id': '3',
        'name': 'Lake Kivu',
        'location': 'Rubavu, Western Province',
        'category': 'Lake',
        'visitDate': DateTime.now().subtract(const Duration(days: 10)),
        'rating': 4.6,
        'reviewCount': 650,
        'image': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=300&fit=crop',
      },
      {
        'id': '4',
        'name': 'Nyungwe Forest National Park',
        'location': 'Nyungwe, Southern Province',
        'category': 'National Park',
        'visitDate': DateTime.now().subtract(const Duration(days: 5)),
        'rating': 4.7,
        'reviewCount': 420,
        'image': 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=400&h=300&fit=crop',
      },
      {
        'id': '5',
        'name': 'Inema Arts Center',
        'location': 'Kigali, Rwanda',
        'category': 'Art Gallery',
        'visitDate': DateTime.now().subtract(const Duration(days: 3)),
        'rating': 4.5,
        'reviewCount': 180,
        'image': 'https://images.unsplash.com/photo-1541961017774-22349e4a1262?w=400&h=300&fit=crop',
      },
    ];
  }
}
