import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/providers/listings_provider.dart';

class ListingsScreen extends ConsumerStatefulWidget {
  final String? type;
  final String? category;
  
  const ListingsScreen({
    super.key,
    this.type,
    this.category,
  });

  @override
  ConsumerState<ListingsScreen> createState() => _ListingsScreenState();
}

class _ListingsScreenState extends ConsumerState<ListingsScreen> {
  int _currentPage = 1;
  final int _pageSize = 20;

  @override
  Widget build(BuildContext context) {
    final listingsAsync = ref.watch(
      listingsProvider({
        'page': _currentPage,
        'limit': _pageSize,
        'type': widget.type,
        'category': widget.category,
      }),
    );

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(widget.type != null ? widget.type!.toUpperCase() : 'Listings'),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              context.push('/search');
            },
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {
              // TODO: Show filter bottom sheet
            },
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: listingsAsync.when(
        data: (response) {
          final listings = response['data'] as List? ?? [];
          final meta = response['meta'] as Map<String, dynamic>?;
          final totalPages = meta?['totalPages'] ?? 1;

          if (listings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.list,
                    size: 64,
                    color: AppTheme.secondaryTextColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No listings found',
                    style: AppTheme.headlineSmall.copyWith(
                      color: AppTheme.secondaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try adjusting your filters',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.secondaryTextColor,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: listings.length + (_currentPage < totalPages ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == listings.length) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _currentPage++;
                        });
                      },
                      child: const Text('Load More'),
                    ),
                  ),
                );
              }

              final listing = listings[index] as Map<String, dynamic>;
              return _buildListingCard(listing);
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppTheme.errorColor,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load listings',
                style: AppTheme.headlineSmall.copyWith(
                  color: AppTheme.errorColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString().replaceFirst('Exception: ', ''),
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.secondaryTextColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(listingsProvider({
                    'page': _currentPage,
                    'limit': _pageSize,
                    'type': widget.type,
                    'category': widget.category,
                  }));
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListingCard(Map<String, dynamic> listing) {
    // Extract image URL
    String? imageUrl;
    if (listing['images'] != null && listing['images'] is List && (listing['images'] as List).isNotEmpty) {
      final firstImage = (listing['images'] as List).first;
      if (firstImage is Map && firstImage['media'] != null) {
        imageUrl = firstImage['media']['url'] ?? firstImage['media']['thumbnailUrl'];
      }
    }

    // Extract data
    final name = listing['name'] ?? 'Unknown';
    final address = listing['address'] ?? listing['city']?['name'] ?? '';
    final rating = listing['rating'] != null 
        ? (listing['rating'] is String 
            ? double.tryParse(listing['rating']) 
            : listing['rating']?.toDouble())
        : 0.0;
    final reviewCount = listing['reviewCount'] ?? 0;
    final minPrice = listing['minPrice'];
    final currency = listing['currency'] ?? 'RWF';
    final id = listing['id'] ?? '';

    return GestureDetector(
      onTap: () {
        context.push('/listing/$id');
      },
      child: Container(
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
              child: imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 120,
                        height: 120,
                        color: AppTheme.dividerColor,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 120,
                        height: 120,
                        color: AppTheme.dividerColor,
                        child: const Icon(Icons.image_not_supported),
                      ),
                    )
                  : Container(
                      width: 120,
                      height: 120,
                      color: AppTheme.dividerColor,
                      child: const Icon(Icons.image_not_supported),
                    ),
            ),
            
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      name,
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    
                    // Address
                    if (address.isNotEmpty)
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 12,
                            color: AppTheme.secondaryTextColor,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              address,
                              style: AppTheme.bodySmall.copyWith(
                                color: AppTheme.secondaryTextColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    
                    const Spacer(),
                    
                    // Rating and Price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Rating
                        if (rating > 0)
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                size: 14,
                                color: AppTheme.primaryColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                rating.toStringAsFixed(1),
                                style: AppTheme.bodySmall.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (reviewCount > 0) ...[
                                const SizedBox(width: 4),
                                Text(
                                  '($reviewCount)',
                                  style: AppTheme.bodySmall.copyWith(
                                    color: AppTheme.secondaryTextColor,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        
                        // Price
                        if (minPrice != null)
                          Text(
                            '$currency ${minPrice.toString()}',
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
