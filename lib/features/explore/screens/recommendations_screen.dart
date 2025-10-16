import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  String _selectedCategory = 'All';
  String _selectedSortBy = 'Popular';

  final List<String> _categories = [
    'All',
    'Wildlife',
    'Nature',
    'History',
    'Water',
    'Adventure',
    'Culture',
  ];

  final List<String> _sortOptions = [
    'Popular',
    'Rating',
    'Price',
    'Distance',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Recommendations',
          style: AppTheme.titleLarge,
        ),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Add filter functionality
            },
            icon: const Icon(Icons.filter_list),
            style: IconButton.styleFrom(
              backgroundColor: AppTheme.dividerColor,
              foregroundColor: AppTheme.primaryTextColor,
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // Category Filter
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primaryColor : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
                        ),
                      ),
                      child: Text(
                        category,
                        style: AppTheme.bodySmall.copyWith(
                          color: isSelected ? Colors.white : AppTheme.primaryTextColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Sort Options
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Text(
                  'Sort by:',
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedSortBy,
                      isExpanded: true,
                      style: AppTheme.bodyMedium,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedSortBy = newValue!;
                        });
                      },
                      items: _sortOptions.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Recommendations List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: 20, // Show 20 recommendations
              itemBuilder: (context, index) {
                return _buildRecommendationCard(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(int index) {
    // Sample recommendation data
    final recommendations = [
      {
        'title': 'Volcanoes National Park',
        'subtitle': 'Gorilla Trekking Experience',
        'image': 'assets/images/gorilla.jpg',
        'rating': 4.9,
        'category': 'Wildlife',
        'distance': '2.5 km',
        'duration': 'Full Day',
      },
      {
        'title': 'Nyungwe Forest',
        'subtitle': 'Canopy Walk Adventure',
        'image': 'assets/images/canopy.jpg',
        'rating': 4.8,
        'category': 'Nature',
        'distance': '5.2 km',
        'duration': 'Half Day',
      },
      {
        'title': 'Lake Kivu',
        'subtitle': 'Relaxing Boat Cruise',
        'image': 'assets/images/lake_kivu.jpg',
        'rating': 4.7,
        'category': 'Water',
        'distance': '1.8 km',
        'duration': '3 Hours',
      },
      {
        'title': 'Kigali Genocide Memorial',
        'subtitle': 'Historical Tour',
        'image': 'assets/images/memorial.jpg',
        'rating': 4.9,
        'category': 'History',
        'distance': '0.5 km',
        'duration': '2 Hours',
      },
      {
        'title': 'Akagera National Park',
        'subtitle': 'Safari Experience',
        'image': 'assets/images/safari.jpg',
        'rating': 4.6,
        'category': 'Wildlife',
        'distance': '120 km',
        'duration': 'Full Day',
      },
    ];

    final recommendation = recommendations[index % recommendations.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              color: Colors.grey[200],
            ),
            child: Stack(
              children: [
                // Placeholder for image
                Center(
                  child: Icon(
                    Icons.image,
                    color: Colors.grey[400],
                    size: 60,
                  ),
                ),
                // Category badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      recommendation['category'] as String,
                      style: AppTheme.bodySmall.copyWith(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                // Rating
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          recommendation['rating'].toString(),
                          style: AppTheme.bodySmall.copyWith(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Favorite button
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () {
                      // TODO: Add to favorites
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.favorite_border,
                        color: AppTheme.secondaryTextColor,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recommendation['title'] as String,
                  style: AppTheme.headlineSmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  recommendation['subtitle'] as String,
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.secondaryTextColor,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Details row
                Row(
                  children: [
                    // Duration
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: AppTheme.secondaryTextColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            recommendation['duration'] as String,
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.secondaryTextColor,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Distance
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: AppTheme.secondaryTextColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            recommendation['distance'] as String,
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.secondaryTextColor,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // View Details button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      recommendation['category'] as String,
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Navigate to place details
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'View Details',
                        style: AppTheme.bodySmall.copyWith(
                          fontWeight: FontWeight.w500,
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
}
