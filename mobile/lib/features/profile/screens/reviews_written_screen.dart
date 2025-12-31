import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/providers/reviews_provider.dart';

class ReviewsWrittenScreen extends ConsumerStatefulWidget {
  const ReviewsWrittenScreen({super.key});

  @override
  ConsumerState<ReviewsWrittenScreen> createState() => _ReviewsWrittenScreenState();
}

class _ReviewsWrittenScreenState extends ConsumerState<ReviewsWrittenScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentPage = 1;
  final int _limit = 20;
  bool _isSearchActive = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.trim();
    });
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _currentPage = 1;
      });
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
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
          icon: const Icon(Icons.chevron_left, size: 32),
          style: IconButton.styleFrom(
            foregroundColor: AppTheme.primaryTextColor,
          ),
        ),
        actions: [
          if (_isSearchActive)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Search reviews...',
                    hintStyle: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.secondaryTextColor,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                  ),
                  style: AppTheme.bodyMedium,
                ),
              ),
            )
          else
            IconButton(
              onPressed: () {
                setState(() {
                  _isSearchActive = true;
                });
              },
              icon: const Icon(Icons.search_outlined),
              style: IconButton.styleFrom(
                backgroundColor: AppTheme.dividerColor,
                foregroundColor: AppTheme.primaryTextColor,
              ),
            ),
          if (_isSearchActive)
            IconButton(
              onPressed: () {
                setState(() {
                  _isSearchActive = false;
                  _searchController.clear();
                  _searchQuery = '';
                });
              },
              icon: const Icon(Icons.close),
              style: IconButton.styleFrom(
                backgroundColor: AppTheme.dividerColor,
                foregroundColor: AppTheme.primaryTextColor,
              ),
            )
          else
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
          _buildReviewsList(filter: 'all'),
          _buildReviewsList(filter: 'year'),
          _buildReviewsList(filter: 'helpful'),
        ],
      ),
    );
  }

  Widget _buildReviewsList({required String filter}) {
    final params = MyReviewsParams(
      page: _currentPage,
      limit: _limit,
      sortBy: filter == 'helpful' ? 'helpful' : 'newest',
    );

    final reviewsAsync = ref.watch(myReviewsProvider(params));

    return reviewsAsync.when(
      data: (data) {
        final reviews = (data['data'] as List<dynamic>?) ?? [];

        // Filter by year if needed
        List<dynamic> filteredReviews = reviews;
        if (filter == 'year') {
          final currentYear = DateTime.now().year;
          filteredReviews = reviews.where((review) {
            final createdAt = review['createdAt'] as String?;
            if (createdAt == null) return false;
            final date = DateTime.tryParse(createdAt);
            return date != null && date.year == currentYear;
          }).toList();
        }

        // Apply search filter if active
        if (_searchQuery.isNotEmpty) {
          filteredReviews = filteredReviews.where((review) {
            final comment = (review['content'] ?? review['comment'] ?? review['text'] ?? '').toString().toLowerCase();
            final listing = review['listing'] as Map<String, dynamic>?;
            final event = review['event'] as Map<String, dynamic>?;
            final tour = review['tour'] as Map<String, dynamic>?;
            final content = listing ?? event ?? tour;
            final contentName = (content?['name'] ?? '').toString().toLowerCase();
            final category = listing?['category'] as Map<String, dynamic>?;
            final categoryName = (category?['name'] ?? '').toString().toLowerCase();
            final eventContext = event?['eventContext'] as Map<String, dynamic>?;
            final contextName = (eventContext?['name'] ?? '').toString().toLowerCase();
            
            final query = _searchQuery.toLowerCase();
            return comment.contains(query) ||
                   contentName.contains(query) ||
                   categoryName.contains(query) ||
                   contextName.contains(query);
          }).toList();
        }

        if (filteredReviews.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(myReviewsProvider(params));
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredReviews.length,
            itemBuilder: (context, index) {
              final review = filteredReviews[index];
              return _buildReviewCard(review);
            },
          ),
        );
      },
      loading: () => Center(
        child: CircularProgressIndicator(
          color: AppTheme.primaryColor,
        ),
      ),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: AppTheme.errorColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load reviews',
              style: AppTheme.titleMedium.copyWith(
                color: AppTheme.errorColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.secondaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(myReviewsProvider(params));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
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
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppTheme.dividerColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(
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
    final createdAt = review['createdAt'] as String?;
    final reviewDate = createdAt != null ? DateTime.tryParse(createdAt) : null;
    final dateFormat = DateFormat('MMM dd, yyyy');
    final rating = review['rating'] as num? ?? 0;
    final comment = review['content'] ?? review['comment'] ?? review['text'] ?? '';
    final helpfulCount = review['helpfulCount'] as int? ?? 0;

    // Get listing/event details
    final listing = review['listing'] as Map<String, dynamic>?;
    final event = review['event'] as Map<String, dynamic>?;
    final tour = review['tour'] as Map<String, dynamic>?;
    
    final content = listing ?? event ?? tour;
    final contentName = content?['name'] as String? ?? 'Unknown';
    final contentImages = content?['images'] as List<dynamic>? ?? [];
    final contentSubtitle = _getContentSubtitle(content, listing, event, tour);
    
    // Get first image URL
    String? imageUrl;
    if (contentImages.isNotEmpty) {
      final firstImage = contentImages[0] as Map<String, dynamic>?;
      final media = firstImage?['media'] as Map<String, dynamic>?;
      imageUrl = media?['url'] as String? ?? media?['thumbnailUrl'] as String?;
    }

    // Determine content ID and type for navigation
    final contentId = listing != null 
        ? listing['id'] as String?
        : event != null
            ? event['id'] as String?
            : tour?['id'] as String?;
    final contentType = listing != null 
        ? 'listing'
        : event != null
            ? 'event'
            : 'tour';

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
            decoration: const BoxDecoration(
              color: AppTheme.dividerColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                // Place Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
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
                        )
                      : Container(
                          width: 60,
                          height: 60,
                          color: AppTheme.backgroundColor,
                          child: const Icon(
                            Icons.place,
                            color: AppTheme.secondaryTextColor,
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
                        contentName,
                        style: AppTheme.titleMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        contentSubtitle,
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
                        rating.toStringAsFixed(0),
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
                if (comment.isNotEmpty)
                  Text(
                    comment,
                    style: AppTheme.bodyMedium,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (comment.isNotEmpty) const SizedBox(height: 12),
                // Review Date
                if (reviewDate != null)
                  Row(
                    children: [
                      const Icon(
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
                if (reviewDate != null) const SizedBox(height: 12),
                // Helpful Count
                if (helpfulCount > 0)
                  Row(
                    children: [
                      const Icon(
                        Icons.thumb_up,
                        size: 16,
                        color: AppTheme.secondaryTextColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$helpfulCount ${helpfulCount == 1 ? 'person' : 'people'} found this helpful',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                if (helpfulCount > 0) const SizedBox(height: 16),
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: contentId != null
                            ? () {
                                if (contentType == 'listing') {
                                  context.go('/listing/$contentId');
                                } else if (contentType == 'event') {
                                  // TODO: Navigate to event detail when route is available
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Event detail page coming soon'),
                                      backgroundColor: AppTheme.primaryColor,
                                    ),
                                  );
                                } else {
                                  // TODO: Navigate to tour detail when route is available
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Tour detail page coming soon'),
                                      backgroundColor: AppTheme.primaryColor,
                                    ),
                                  );
                                }
                              }
                            : null,
                        icon: const Icon(Icons.visibility, size: 14),
                        label: Text(
                          'View Place',
                          style: AppTheme.bodySmall.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryColor,
                          backgroundColor: AppTheme.backgroundColor,
                          side: const BorderSide(color: AppTheme.primaryColor),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          minimumSize: const Size(0, 36),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _showEditReviewBottomSheet(review);
                        },
                        icon: const Icon(Icons.edit, size: 14),
                        label: Text(
                          'Edit Review',
                          style: AppTheme.bodySmall.copyWith(
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: AppTheme.primaryColor,
                          side: const BorderSide(color: AppTheme.primaryColor),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          minimumSize: const Size(0, 36),
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

  String _getContentSubtitle(
    Map<String, dynamic>? content,
    Map<String, dynamic>? listing,
    Map<String, dynamic>? event,
    Map<String, dynamic>? tour,
  ) {
    // For listings, try category first, then type, then location
    if (listing != null) {
      final category = listing['category'] as Map<String, dynamic>?;
      final categoryName = category?['name'] as String?;
      if (categoryName != null && categoryName.isNotEmpty) {
        return categoryName;
      }
      
      final listingType = listing['type'] as String?;
      if (listingType != null && listingType.isNotEmpty) {
        // Capitalize first letter
        return listingType[0].toUpperCase() + listingType.substring(1);
      }
    }
    
    // For events, try eventContext first, then location
    if (event != null) {
      final eventContext = event['eventContext'] as Map<String, dynamic>?;
      final contextName = eventContext?['name'] as String?;
      if (contextName != null && contextName.isNotEmpty) {
        return contextName;
      }
    }
    
    // For tours, try category first, then location
    if (tour != null) {
      final category = tour['category'] as Map<String, dynamic>?;
      final categoryName = category?['name'] as String?;
      if (categoryName != null && categoryName.isNotEmpty) {
        return categoryName;
      }
    }
    
    // Try to get location as fallback
    if (content != null) {
      final location = content['location'] as Map<String, dynamic>?;
      if (location != null) {
        final address = location['address'] as String?;
        final city = location['city'] as Map<String, dynamic>?;
        final cityName = city?['name'] as String?;
        
        if (cityName != null && address != null) {
          return '$cityName, $address';
        } else if (cityName != null) {
          return cityName;
        } else if (address != null) {
          return address;
        }
      }
    }
    
    // Default fallback
    return 'Place';
  }

  void _showEditReviewBottomSheet(Map<String, dynamic> review) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EditReviewBottomSheet(
        review: review,
        onReviewUpdated: () {
          // Refresh the reviews list
          final params = MyReviewsParams(
            page: _currentPage,
            limit: _limit,
            sortBy: _tabController.index == 2 ? 'helpful' : 'newest',
          );
          ref.invalidate(myReviewsProvider(params));
        },
      ),
    );
  }
}

class _EditReviewBottomSheet extends ConsumerStatefulWidget {
  final Map<String, dynamic> review;
  final VoidCallback onReviewUpdated;

  const _EditReviewBottomSheet({
    required this.review,
    required this.onReviewUpdated,
  });

  @override
  ConsumerState<_EditReviewBottomSheet> createState() => _EditReviewBottomSheetState();
}

class _EditReviewBottomSheetState extends ConsumerState<_EditReviewBottomSheet> {
  late int _selectedRating;
  late TextEditingController _reviewController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedRating = (widget.review['rating'] as num?)?.toInt() ?? 5;
    // Try multiple field names for backward compatibility
    final reviewText = widget.review['content'] ?? 
                       widget.review['comment'] ?? 
                       widget.review['text'] ?? 
                       '';
    _reviewController = TextEditingController(
      text: reviewText.toString(),
    );
  }

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
            'Edit Review',
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
                borderSide: const BorderSide(color: AppTheme.primaryColor),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 24),
          
          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _updateReview,
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
                      'Update Review',
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

  Future<void> _updateReview() async {
    if (_reviewController.text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please write a review before updating'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final reviewsService = ref.read(reviewsServiceProvider);
      final reviewId = widget.review['id'] as String?;
      
      if (reviewId == null) {
        throw Exception('Review ID is missing');
      }
      
      await reviewsService.updateReview(
        reviewId: reviewId,
        rating: _selectedRating,
        content: _reviewController.text.trim(),
      );

      if (!mounted) return;

      // Call the callback to refresh reviews
      widget.onReviewUpdated();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Review updated successfully!'),
          backgroundColor: AppTheme.successColor,
        ),
      );

      // Close bottom sheet
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceAll('Exception: ', ''),
          ),
          backgroundColor: AppTheme.errorColor,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
}
