import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/theme/app_theme.dart';

class ReviewsRatingsScreen extends ConsumerStatefulWidget {
  const ReviewsRatingsScreen({super.key});

  @override
  ConsumerState<ReviewsRatingsScreen> createState() => _ReviewsRatingsScreenState();
}

class _ReviewsRatingsScreenState extends ConsumerState<ReviewsRatingsScreen>
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
          'Reviews & Ratings',
          style: AppTheme.titleLarge,
        ),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          onPressed: () => context.go('/profile'),
          icon: const Icon(Icons.chevron_left, size: 32),
          style: IconButton.styleFrom(
            foregroundColor: AppTheme.primaryTextColor,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.secondaryTextColor,
          indicatorColor: AppTheme.primaryColor,
          labelStyle: AppTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
          ),
          unselectedLabelStyle: AppTheme.bodyMedium,
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
          _buildAllReviews(),
          _buildThisYearReviews(),
          _buildHelpfulReviews(),
        ],
      ),
    );
  }

  Widget _buildAllReviews() {
    final reviews = _getMockReviews();

    if (reviews.isEmpty) {
      return _buildEmptyState(
        icon: Icons.reviews_outlined,
        title: 'No Reviews Yet',
        subtitle: 'Share your experiences by writing reviews',
        actionText: 'Write Review',
        onAction: () {
          // TODO: Navigate to write review
        },
      );
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

  Widget _buildThisYearReviews() {
    final thisYearReviews = _getMockReviews()
        .where((review) => review['date'].contains('2024'))
        .toList();

    if (thisYearReviews.isEmpty) {
      return _buildEmptyState(
        icon: Icons.calendar_today,
        title: 'No Reviews This Year',
        subtitle: 'Start writing reviews to share your experiences',
        actionText: 'Write Review',
        onAction: () {
          // TODO: Navigate to write review
        },
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: thisYearReviews.length,
      itemBuilder: (context, index) {
        final review = thisYearReviews[index];
        return _buildReviewCard(review);
      },
    );
  }

  Widget _buildHelpfulReviews() {
    final helpfulReviews = _getMockReviews()
        .where((review) => review['helpfulCount'] >= 5)
        .toList();

    if (helpfulReviews.isEmpty) {
      return _buildEmptyState(
        icon: Icons.thumb_up_outlined,
        title: 'No Helpful Reviews',
        subtitle: 'Write detailed reviews to help other travelers',
        actionText: 'Write Review',
        onAction: () {
          // TODO: Navigate to write review
        },
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: helpfulReviews.length,
      itemBuilder: (context, index) {
        final review = helpfulReviews[index];
        return _buildReviewCard(review);
      },
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
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
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Place Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: review['placeImage'],
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 60,
                      height: 60,
                      color: AppTheme.dividerColor,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 60,
                      height: 60,
                      color: AppTheme.dividerColor,
                      child: const Icon(Icons.image_not_supported),
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
                        review['placeName'],
                        style: AppTheme.titleMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        review['placeLocation'],
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
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star,
                        size: 16,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        review['rating'].toString(),
                        style: AppTheme.labelSmall.copyWith(
                          color: AppTheme.primaryColor,
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
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Review Text
                Text(
                  review['reviewText'],
                  style: AppTheme.bodyMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                
                // Review Images (if any)
                if (review['reviewImages'] != null && review['reviewImages'].isNotEmpty)
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: review['reviewImages'].length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.only(right: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: review['reviewImages'][index],
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                width: 80,
                                height: 80,
                                color: AppTheme.dividerColor,
                              ),
                              errorWidget: (context, url, error) => Container(
                                width: 80,
                                height: 80,
                                color: AppTheme.dividerColor,
                                child: const Icon(Icons.image_not_supported),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 12),
                
                // Review Meta
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: AppTheme.secondaryTextColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      review['date'],
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.secondaryTextColor,
                      ),
                    ),
                    const Spacer(),
                    if (review['helpfulCount'] > 0) ...[
                      Icon(
                        Icons.thumb_up_outlined,
                        size: 14,
                        color: AppTheme.secondaryTextColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${review['helpfulCount']} helpful',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.secondaryTextColor,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                
                // Actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: View place details
                        },
                        icon: const Icon(Icons.visibility_outlined, size: 18),
                        label: const Text('View Place'),
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
                          _showEditReviewDialog(review);
                        },
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: const Text('Edit Review'),
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

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required String actionText,
    required VoidCallback onAction,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: AppTheme.titleLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.secondaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            OutlinedButton(
              onPressed: onAction,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
                backgroundColor: AppTheme.backgroundColor,
                side: const BorderSide(color: AppTheme.primaryColor),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(actionText),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditReviewDialog(Map<String, dynamic> review) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Edit Review',
          style: AppTheme.titleMedium,
        ),
        content: Text(
          'Edit your review for "${review['placeName']}"?',
          style: AppTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.secondaryTextColor,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navigate to edit review
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Edit review feature coming soon'),
                  backgroundColor: AppTheme.primaryColor,
                ),
              );
            },
            child: Text(
              'Edit',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getMockReviews() {
    return [
      {
        'placeName': 'Volcanoes National Park',
        'placeLocation': 'Musanze, Rwanda',
        'placeImage': 'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=100',
        'rating': 5.0,
        'reviewText': 'Amazing experience! The gorilla trekking was incredible. Our guide was knowledgeable and the gorillas were magnificent. Highly recommend this experience.',
        'reviewImages': [
          'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=200',
          'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=200',
        ],
        'date': 'Dec 10, 2024',
        'helpfulCount': 12,
      },
      {
        'placeName': 'Kigali Genocide Memorial',
        'placeLocation': 'Kigali, Rwanda',
        'placeImage': 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=100',
        'rating': 5.0,
        'reviewText': 'A deeply moving and educational experience. The memorial provides important historical context and honors the victims with dignity.',
        'reviewImages': [],
        'date': 'Nov 28, 2024',
        'helpfulCount': 8,
      },
      {
        'placeName': 'Lake Kivu',
        'placeLocation': 'Rubavu, Rwanda',
        'placeImage': 'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=100',
        'rating': 4.5,
        'reviewText': 'Beautiful lake with stunning views. The boat ride was relaxing and the scenery was breathtaking. Great for a peaceful getaway.',
        'reviewImages': [
          'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=200',
        ],
        'date': 'Nov 15, 2024',
        'helpfulCount': 5,
      },
      {
        'placeName': 'Nyungwe Forest National Park',
        'placeLocation': 'Nyungwe, Rwanda',
        'placeImage': 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=100',
        'rating': 4.0,
        'reviewText': 'Great hiking trails and canopy walk. The forest is beautiful and the canopy walk offers amazing views. Bring good hiking shoes!',
        'reviewImages': [],
        'date': 'Oct 22, 2024',
        'helpfulCount': 3,
      },
    ];
  }
}
