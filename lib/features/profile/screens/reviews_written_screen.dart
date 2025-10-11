import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';

class ReviewsWrittenScreen extends ConsumerStatefulWidget {
  const ReviewsWrittenScreen({super.key});

  @override
  ConsumerState<ReviewsWrittenScreen> createState() => _ReviewsWrittenScreenState();
}

class _ReviewsWrittenScreenState extends ConsumerState<ReviewsWrittenScreen>
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
          'Reviews Written',
          style: AppTheme.titleLarge,
        ),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () => context.go('/profile'),
          icon: const Icon(Icons.chevron_left),
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
            Tab(text: 'All Reviews'),
            Tab(text: 'This Year'),
            Tab(text: 'Helpful'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildReviewsList(),
          _buildReviewsList(),
          _buildReviewsList(),
        ],
      ),
    );
  }

  Widget _buildReviewsList() {
    // Mock data for demonstration
    final reviews = _getMockReviews();
    
    if (reviews.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reviews.length,
      itemBuilder: (context, index) {
        final review = reviews[index];
        return _buildReviewCard(review);
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
            decoration: BoxDecoration(
              color: AppTheme.dividerColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.rate_review,
              size: 48,
              color: AppTheme.secondaryTextColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Reviews Written',
            style: AppTheme.titleLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Share your experiences by writing\nreviews for places you\'ve visited',
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

  Widget _buildReviewCard(Map<String, dynamic> review) {
    final reviewDate = review['date'] as DateTime;
    final dateFormat = DateFormat('MMM dd, yyyy');
    final rating = review['rating'] as int;

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
          // Place Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.dividerColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                // Place Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: review['placeImage'] as String,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 60,
                      height: 60,
                      color: AppTheme.backgroundColor,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryColor,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 60,
                      height: 60,
                      color: AppTheme.backgroundColor,
                      child: const Icon(
                        Icons.place,
                        color: AppTheme.secondaryTextColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Place Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review['placeName'] as String,
                        style: AppTheme.titleMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        review['placeLocation'] as String,
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.secondaryTextColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Rating
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star,
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        rating.toString(),
                        style: AppTheme.labelSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Review Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Review Text
                Text(
                  review['text'] as String,
                  style: AppTheme.bodyMedium,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                // Review Date
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: AppTheme.secondaryTextColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Reviewed on ${dateFormat.format(reviewDate)}',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Helpful Count
                Row(
                  children: [
                    Icon(
                      Icons.thumb_up,
                      size: 16,
                      color: AppTheme.secondaryTextColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${review['helpfulCount']} people found this helpful',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Navigate to place details
                          // context.go('/place/${review['placeId']}');
                        },
                        icon: const Icon(Icons.visibility, size: 16),
                        label: const Text('View Place'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryColor,
                          backgroundColor: AppTheme.backgroundColor,
                          side: BorderSide(color: AppTheme.primaryColor),
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
                          // TODO: Edit review
                        },
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Edit Review'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: AppTheme.primaryColor,
                          side: BorderSide(color: AppTheme.primaryColor),
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

  List<Map<String, dynamic>> _getMockReviews() {
    // Mock data for demonstration - using simple Map structure
    return [
      {
        'id': '1',
        'placeId': '1',
        'placeName': 'Volcanoes National Park',
        'placeLocation': 'Musanze, Northern Province',
        'placeImage': 'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=400&h=300&fit=crop',
        'rating': 5,
        'text': 'An absolutely incredible experience! The gorilla trekking was challenging but so rewarding. Our guide was knowledgeable and the gorillas were magnificent. The park is well-maintained and the conservation efforts are truly inspiring. Highly recommend for anyone visiting Rwanda.',
        'date': DateTime.now().subtract(const Duration(days: 30)),
        'helpfulCount': 12,
      },
      {
        'id': '2',
        'placeId': '2',
        'placeName': 'Kigali Genocide Memorial',
        'placeLocation': 'Kigali, Rwanda',
        'placeImage': 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=300&fit=crop',
        'rating': 5,
        'text': 'A deeply moving and educational experience. The memorial does an excellent job of honoring the victims while educating visitors about the genocide. The audio guide is very informative. This is a must-visit for anyone wanting to understand Rwanda\'s history.',
        'date': DateTime.now().subtract(const Duration(days: 20)),
        'helpfulCount': 8,
      },
      {
        'id': '3',
        'placeId': '3',
        'placeName': 'Lake Kivu',
        'placeLocation': 'Rubavu, Western Province',
        'placeImage': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=300&fit=crop',
        'rating': 4,
        'text': 'Beautiful lake with stunning views. The boat ride was relaxing and the scenery is breathtaking. The water is clean and the surrounding hills create a picturesque landscape. Great for a day trip from Kigali.',
        'date': DateTime.now().subtract(const Duration(days: 15)),
        'helpfulCount': 6,
      },
      {
        'id': '4',
        'placeId': '4',
        'placeName': 'Nyungwe Forest National Park',
        'placeLocation': 'Nyungwe, Southern Province',
        'placeImage': 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=400&h=300&fit=crop',
        'rating': 5,
        'text': 'Amazing forest experience! The canopy walk was thrilling and the views are spectacular. We saw several species of monkeys and the biodiversity is incredible. The guides are very knowledgeable about the flora and fauna.',
        'date': DateTime.now().subtract(const Duration(days: 10)),
        'helpfulCount': 9,
      },
      {
        'id': '5',
        'placeId': '5',
        'placeName': 'Inema Arts Center',
        'placeLocation': 'Kigali, Rwanda',
        'placeImage': 'https://images.unsplash.com/photo-1541961017774-22349e4a1262?w=400&h=300&fit=crop',
        'rating': 4,
        'text': 'Wonderful art center showcasing contemporary African art. The exhibitions are thought-provoking and the artists are very talented. The center also offers workshops and classes. Great place to support local artists and learn about Rwandan culture.',
        'date': DateTime.now().subtract(const Duration(days: 5)),
        'helpfulCount': 4,
      },
    ];
  }
}
