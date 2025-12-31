import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/providers/content_views_provider.dart';

class VisitedPlacesScreen extends ConsumerStatefulWidget {
  const VisitedPlacesScreen({super.key});

  @override
  ConsumerState<VisitedPlacesScreen> createState() => _VisitedPlacesScreenState();
}

class _VisitedPlacesScreenState extends ConsumerState<VisitedPlacesScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentPage = 1;
  final int _limit = 20;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Places Visited',
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
            Tab(text: 'Listings Only'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPlacesList(filter: 'all'),
          _buildPlacesList(filter: 'year'),
          _buildPlacesList(filter: 'listings'),
        ],
      ),
    );
  }

  Widget _buildPlacesList({required String filter}) {
    final params = ContentViewsParams(
      page: _currentPage,
      limit: _limit,
      contentType: filter == 'listings' ? 'listing' : null,
    );

    final contentViewsAsync = ref.watch(myContentViewsProvider(params));

    return contentViewsAsync.when(
      data: (data) {
        final views = (data['data'] as List<dynamic>?) ?? [];

        // Filter by year if needed
        List<dynamic> filteredViews = views;
        if (filter == 'year') {
          final currentYear = DateTime.now().year;
          filteredViews = views.where((view) {
            final viewedAt = view['viewedAt'] as String?;
            if (viewedAt == null) return false;
            final date = DateTime.tryParse(viewedAt);
            return date != null && date.year == currentYear;
          }).toList();
        }

        // Only show listings (not events) for "Places Visited"
        filteredViews = filteredViews.where((view) {
          final contentType = view['contentType'] as String?;
          return contentType == 'listing';
        }).toList();

        if (filteredViews.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(myContentViewsProvider(params));
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredViews.length,
            itemBuilder: (context, index) {
              final view = filteredViews[index];
              return _buildPlaceCard(view);
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
              'Failed to load places',
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
                ref.invalidate(myContentViewsProvider(params));
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

  Widget _buildPlaceCard(Map<String, dynamic> view) {
    final viewedAt = view['viewedAt'] as String?;
    final visitDate = viewedAt != null ? DateTime.tryParse(viewedAt) : null;
    final dateFormat = DateFormat('MMM dd, yyyy');
    
    final content = view['content'] as Map<String, dynamic>?;
    if (content == null) {
      return const SizedBox.shrink();
    }

    final contentId = content['id'] as String?;
    final contentName = content['name'] as String? ?? 'Unknown';
    final contentImages = content['images'] as List<dynamic>? ?? [];
    final contentLocation = _getContentLocation(content);
    final rating = (content['rating'] as num?)?.toDouble() ?? 0.0;
    final reviewCount = content['reviewCount'] as int? ?? 0;
    final category = content['category'] as Map<String, dynamic>?;
    final categoryName = category?['name'] as String? ?? 'Place';

    // Get first image URL
    String? imageUrl;
    if (contentImages.isNotEmpty) {
      final firstImage = contentImages[0] as Map<String, dynamic>?;
      final media = firstImage?['media'] as Map<String, dynamic>?;
      imageUrl = media?['url'] as String? ?? media?['thumbnailUrl'] as String?;
    }

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
                imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
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
                      )
                    : Container(
                        height: 200,
                        color: AppTheme.dividerColor,
                        child: const Icon(
                          Icons.place,
                          size: 64,
                          color: AppTheme.secondaryTextColor,
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
                          'Viewed',
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
                      categoryName,
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
                  contentName,
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
                        contentLocation,
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
                if (visitDate != null)
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: AppTheme.secondaryTextColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Viewed on ${dateFormat.format(visitDate)}',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                if (visitDate != null) const SizedBox(height: 12),
                // Rating
                if (rating > 0)
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 16,
                        color: Colors.amber[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        rating.toStringAsFixed(1),
                        style: AppTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '($reviewCount ${reviewCount == 1 ? 'review' : 'reviews'})',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                if (rating > 0) const SizedBox(height: 12),
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: contentId != null
                            ? () {
                                context.go('/listings/$contentId');
                              }
                            : null,
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

  String _getContentLocation(Map<String, dynamic> content) {
    final location = content['location'] as Map<String, dynamic>?;
    if (location == null) return 'Unknown location';
    
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
    
    return 'Unknown location';
  }
}
