import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/place_card.dart';

class ExperiencesScreen extends ConsumerStatefulWidget {
  const ExperiencesScreen({super.key});

  @override
  ConsumerState<ExperiencesScreen> createState() => _ExperiencesScreenState();
}

class _ExperiencesScreenState extends ConsumerState<ExperiencesScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'All';
  String _selectedSort = 'Popular';
  Set<String> _favoriteExperiences = {};

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
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          onPressed: () => context.go('/explore'),
          icon: const Icon(Icons.chevron_left, size: 32),
          style: IconButton.styleFrom(
            foregroundColor: AppTheme.primaryTextColor,
          ),
        ),
        title: Text(
          'Experiences',
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
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryColor,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.secondaryTextColor,
          labelStyle: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w600),
          isScrollable: true,
          labelPadding: const EdgeInsets.symmetric(horizontal: 16),
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Tours'),
            Tab(text: 'Adventures'),
            Tab(text: 'Cultural'),
            Tab(text: 'Operators'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildExperiencesList('All'),
          _buildExperiencesList('Tours'),
          _buildExperiencesList('Adventures'),
          _buildExperiencesList('Cultural'),
          _buildTourOperatorsList(),
        ],
      ),
    );
  }

  Widget _buildExperiencesList(String category) {
    final experiences = _getMockExperiences(category);

    if (experiences.isEmpty) {
      return _buildEmptyState(category);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: experiences.length,
      itemBuilder: (context, index) {
        final experience = experiences[index];
        return PlaceCard(
          name: experience['name'],
          location: experience['location'],
          image: experience['image'],
          rating: experience['rating'],
          reviews: experience['reviews'],
          priceRange: experience['priceRange'],
          category: experience['category'],
          onTap: () {
            context.push('/place/${experience['id']}');
          },
          onFavorite: () {
            setState(() {
              if (_favoriteExperiences.contains(experience['id'])) {
                _favoriteExperiences.remove(experience['id']);
              } else {
                _favoriteExperiences.add(experience['id']);
              }
            });
          },
          isFavorite: _favoriteExperiences.contains(experience['id']),
        );
      },
    );
  }

  Widget _buildTourOperatorsList() {
    final operators = _getMockTourOperators();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: operators.length,
      itemBuilder: (context, index) {
        final operator = operators[index];
        return _buildTourOperatorCard(operator);
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
            // Header with logo and business info
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Company logo
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[100],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        operator['logo'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.business,
                          size: 30,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Business details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          operator['name'],
                          style: AppTheme.headlineSmall.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 16,
                              color: AppTheme.secondaryTextColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              operator['location'],
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppTheme.secondaryTextColor,
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
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '(${operator['reviews']} reviews)',
                              style: AppTheme.bodySmall.copyWith(
                                color: AppTheme.secondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Favorite button
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (_favoriteExperiences.contains(operator['id'])) {
                          _favoriteExperiences.remove(operator['id']);
                        } else {
                          _favoriteExperiences.add(operator['id']);
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        _favoriteExperiences.contains(operator['id'])
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: _favoriteExperiences.contains(operator['id'])
                            ? Colors.red
                            : AppTheme.primaryColor,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Business info section
            Container(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Services offered
                  Text(
                    'Services Offered',
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: operator['services'].map<Widget>((service) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          service,
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  // Contact and pricing info
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Starting from',
                              style: AppTheme.bodySmall.copyWith(
                                color: AppTheme.secondaryTextColor,
                              ),
                            ),
                            Text(
                              operator['priceRange'],
                              style: AppTheme.bodyLarge.copyWith(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w600,
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
                              'Contact',
                              style: AppTheme.bodySmall.copyWith(
                                color: AppTheme.secondaryTextColor,
                              ),
                            ),
                            Text(
                              operator['phone'],
                              style: AppTheme.bodyMedium.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String category) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.explore,
            size: 80,
            color: AppTheme.secondaryTextColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No $category found',
            style: AppTheme.headlineSmall.copyWith(
              color: AppTheme.secondaryTextColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for new experiences',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.secondaryTextColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getMockExperiences(String category) {
    final allExperiences = [
      {
        'id': '1',
        'name': 'Gorilla Trekking Adventure',
        'location': 'Volcanoes National Park, Rwanda',
        'image': 'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=500',
        'rating': 4.9,
        'reviews': 156,
        'priceRange': '\$\$\$\$',
        'category': 'Adventure',
        'type': 'Adventures',
      },
      {
        'id': '2',
        'name': 'Kigali City Walking Tour',
        'location': 'Kigali, Rwanda',
        'image': 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=500',
        'rating': 4.6,
        'reviews': 89,
        'priceRange': '\$\$',
        'category': 'Tour',
        'type': 'Tours',
      },
      {
        'id': '3',
        'name': 'Traditional Dance Workshop',
        'location': 'Kigali Cultural Center',
        'image': 'https://images.unsplash.com/photo-1547036967-23d11aacaee0?w=500',
        'rating': 4.4,
        'reviews': 67,
        'priceRange': '\$\$',
        'category': 'Cultural',
        'type': 'Cultural',
      },
      {
        'id': '4',
        'name': 'Lake Kivu Boat Safari',
        'location': 'Lake Kivu, Rwanda',
        'image': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=500',
        'rating': 4.7,
        'reviews': 123,
        'priceRange': '\$\$\$',
        'category': 'Adventure',
        'type': 'Adventures',
      },
      {
        'id': '5',
        'name': 'Genocide Memorial Tour',
        'location': 'Kigali Genocide Memorial',
        'image': 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=500',
        'rating': 4.8,
        'reviews': 234,
        'priceRange': '\$',
        'category': 'Cultural',
        'type': 'Cultural',
      },
      {
        'id': '6',
        'name': 'Coffee Farm Experience',
        'location': 'Huye, Rwanda',
        'image': 'https://images.unsplash.com/photo-1559056199-641a0ac8b55e?w=500',
        'rating': 4.5,
        'reviews': 98,
        'priceRange': '\$\$',
        'category': 'Tour',
        'type': 'Tours',
      },
      {
        'id': '7',
        'name': 'Nyungwe Forest Canopy Walk',
        'location': 'Nyungwe National Park',
        'image': 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=500',
        'rating': 4.6,
        'reviews': 145,
        'priceRange': '\$\$\$',
        'category': 'Adventure',
        'type': 'Adventures',
      },
      {
        'id': '8',
        'name': 'Traditional Pottery Class',
        'location': 'Butare, Rwanda',
        'image': 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=500',
        'rating': 4.3,
        'reviews': 56,
        'priceRange': '\$\$',
        'category': 'Cultural',
        'type': 'Cultural',
      },
    ];

    if (category == 'All') {
      return allExperiences;
    }

    return allExperiences.where((experience) => experience['type'] == category).toList();
  }

  List<Map<String, dynamic>> _getMockTourOperators() {
    return [
      {
        'id': 'op1',
        'name': 'Rwanda Gorilla Tours',
        'location': 'Kigali, Rwanda',
        'logo': 'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=200',
        'rating': 4.8,
        'reviews': 234,
        'priceRange': 'RWF 1,500',
        'phone': '+250 788 123 456',
        'services': ['Gorilla Trekking', 'Wildlife Safaris', 'Mountain Hiking', 'Photography Tours'],
      },
      {
        'id': 'op2',
        'name': 'Kigali City Tours',
        'location': 'Kigali, Rwanda',
        'logo': 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=200',
        'rating': 4.6,
        'reviews': 189,
        'priceRange': 'RWF 50,000',
        'phone': '+250 789 234 567',
        'services': ['City Walking Tours', 'Cultural Sites', 'Museums', 'Local Markets'],
      },
      {
        'id': 'op3',
        'name': 'Rwanda Cultural Adventures',
        'location': 'Butare, Rwanda',
        'logo': 'https://images.unsplash.com/photo-1547036967-23d11aacaee0?w=200',
        'rating': 4.7,
        'reviews': 156,
        'priceRange': 'RWF 75,000',
        'phone': '+250 790 345 678',
        'services': ['Traditional Dance', 'Pottery Classes', 'Cultural Workshops', 'Village Visits'],
      },
      {
        'id': 'op4',
        'name': 'Lake Kivu Adventures',
        'location': 'Gisenyi, Rwanda',
        'logo': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=200',
        'rating': 4.5,
        'reviews': 98,
        'priceRange': 'RWF 100,000',
        'phone': '+250 791 456 789',
        'services': ['Boat Safaris', 'Fishing Tours', 'Water Sports', 'Island Visits'],
      },
      {
        'id': 'op5',
        'name': 'Nyungwe Forest Tours',
        'location': 'Huye, Rwanda',
        'logo': 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=200',
        'rating': 4.9,
        'reviews': 267,
        'priceRange': 'RWF 120,000',
        'phone': '+250 792 567 890',
        'services': ['Canopy Walks', 'Bird Watching', 'Nature Hikes', 'Wildlife Photography'],
      },
      {
        'id': 'op6',
        'name': 'Rwanda Coffee Tours',
        'location': 'Huye, Rwanda',
        'logo': 'https://images.unsplash.com/photo-1559056199-641a0ac8b55e?w=200',
        'rating': 4.4,
        'reviews': 123,
        'priceRange': 'RWF 40,000',
        'phone': '+250 793 678 901',
        'services': ['Coffee Farm Visits', 'Tasting Sessions', 'Processing Tours', 'Agricultural Education'],
      },
    ];
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
              'Filter by',
              style: AppTheme.headlineSmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildFilterOption('All', 'All'),
            _buildFilterOption('Tours', 'Tours'),
            _buildFilterOption('Adventures', 'Adventures'),
            _buildFilterOption('Cultural', 'Cultural'),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(String label, String value) {
    return ListTile(
      title: Text(label),
      leading: Radio<String>(
        value: value,
        groupValue: _selectedFilter,
        onChanged: (value) {
          setState(() {
            _selectedFilter = value!;
          });
          Navigator.pop(context);
        },
        activeColor: AppTheme.primaryColor,
      ),
      onTap: () {
        setState(() {
          _selectedFilter = value;
        });
        Navigator.pop(context);
      },
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
              'Sort by',
              style: AppTheme.headlineSmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildSortOption('Popular', 'Popular'),
            _buildSortOption('Rating', 'Rating'),
            _buildSortOption('Distance', 'Distance'),
            _buildSortOption('Price', 'Price'),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String label, String value) {
    return ListTile(
      title: Text(label),
      leading: Radio<String>(
        value: value,
        groupValue: _selectedSort,
        onChanged: (value) {
          setState(() {
            _selectedSort = value!;
          });
          Navigator.pop(context);
        },
        activeColor: AppTheme.primaryColor,
      ),
      onTap: () {
        setState(() {
          _selectedSort = value;
        });
        Navigator.pop(context);
      },
    );
  }
}
