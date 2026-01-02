import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/theme/text_theme_extensions.dart';
import '../../../core/config/app_config.dart';
import '../../../core/providers/favorites_provider.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen>
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
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Favorites',
          style: context.titleLarge,
        ),
        backgroundColor: context.backgroundColor,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          onPressed: () => context.go('/profile'),
          icon: const Icon(Icons.chevron_left, size: 32),
          style: IconButton.styleFrom(
            foregroundColor: context.primaryTextColor,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: context.primaryColorTheme,
          unselectedLabelColor: context.secondaryTextColor,
          indicatorColor: context.primaryColorTheme,
          labelStyle: context.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
            color: context.primaryTextColor,
          ),
          unselectedLabelStyle: context.bodyMedium,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Events'),
            Tab(text: 'Places'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAllFavorites(),
          _buildEventFavorites(),
          _buildPlaceFavorites(),
        ],
      ),
    );
  }

  Widget _buildAllFavorites() {
    final favoritesAsync = ref.watch(favoritesProvider(const FavoritesParams(page: 1, limit: 100)));

    return favoritesAsync.when(
      data: (response) {
        final favorites = response['data'] as List? ?? [];
        
        if (favorites.isEmpty) {
          return _buildEmptyState(
            icon: Icons.favorite_border,
            title: 'No Favorites Yet',
            subtitle: 'Start exploring and save your favorite events and places',
            actionText: 'Explore Now',
            onAction: () => context.go('/explore'),
          );
        }

        return RefreshIndicator(
          color: context.primaryColorTheme,
          backgroundColor: context.cardColor,
          onRefresh: () async {
            ref.invalidate(favoritesProvider(const FavoritesParams(page: 1, limit: 100)));
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final favorite = favorites[index];
              return _buildFavoriteCardFromApi(favorite);
            },
          ),
        );
      },
      loading: () => Center(child: CircularProgressIndicator(color: context.primaryColorTheme)),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: context.errorColor),
            const SizedBox(height: 16),
            Text(
              'Failed to load favorites',
              style: context.headlineSmall.copyWith(color: context.errorColor),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString().replaceFirst('Exception: ', ''),
              style: context.bodyMedium.copyWith(color: context.secondaryTextColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(favoritesProvider(const FavoritesParams(page: 1, limit: 100)));
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventFavorites() {
    final favoritesAsync = ref.watch(favoritesProvider(const FavoritesParams(page: 1, limit: 100)));

    return favoritesAsync.when(
      data: (response) {
        final favorites = response['data'] as List? ?? [];
        final eventFavorites = favorites.where((f) => f['eventId'] != null && f['event'] != null).toList();

        if (eventFavorites.isEmpty) {
          return _buildEmptyState(
            icon: Icons.event,
            title: 'No Favorite Events',
            subtitle: 'Save events you\'re interested in to see them here',
            actionText: 'Browse Events',
            onAction: () => context.go('/events'),
          );
        }

        return RefreshIndicator(
          color: context.primaryColorTheme,
          backgroundColor: context.cardColor,
          onRefresh: () async {
            ref.invalidate(favoritesProvider(const FavoritesParams(page: 1, limit: 100)));
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: eventFavorites.length,
            itemBuilder: (context, index) {
              final favorite = eventFavorites[index];
              return _buildEventFavoriteCardFromApi(favorite);
            },
          ),
        );
      },
      loading: () => Center(child: CircularProgressIndicator(color: context.primaryColorTheme)),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: context.errorColor),
            const SizedBox(height: 16),
            Text(
              'Failed to load favorites',
              style: context.headlineSmall.copyWith(color: context.errorColor),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString().replaceFirst('Exception: ', ''),
              style: context.bodyMedium.copyWith(color: context.secondaryTextColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(favoritesProvider(const FavoritesParams(page: 1, limit: 100)));
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceFavorites() {
    final favoritesAsync = ref.watch(favoritesProvider(const FavoritesParams(page: 1, limit: 100)));

    return favoritesAsync.when(
      data: (response) {
        final favorites = response['data'] as List? ?? [];
        final placeFavorites = favorites.where((f) => f['listingId'] != null && f['listing'] != null).toList();

        if (placeFavorites.isEmpty) {
          return _buildEmptyState(
            icon: Icons.place,
            title: 'No Favorite Places',
            subtitle: 'Save places you want to visit to see them here',
            actionText: 'Explore Places',
            onAction: () => context.go('/explore'),
          );
        }

        return RefreshIndicator(
          color: context.primaryColorTheme,
          backgroundColor: context.cardColor,
          onRefresh: () async {
            ref.invalidate(favoritesProvider(const FavoritesParams(page: 1, limit: 100)));
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: placeFavorites.length,
            itemBuilder: (context, index) {
              final favorite = placeFavorites[index];
              return _buildPlaceFavoriteCardFromApi(favorite);
            },
          ),
        );
      },
      loading: () => Center(child: CircularProgressIndicator(color: context.primaryColorTheme)),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: context.errorColor),
            const SizedBox(height: 16),
            Text(
              'Failed to load favorites',
              style: context.headlineSmall.copyWith(color: context.errorColor),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString().replaceFirst('Exception: ', ''),
              style: context.bodyMedium.copyWith(color: context.secondaryTextColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(favoritesProvider(const FavoritesParams(page: 1, limit: 100)));
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteCard(Map<String, dynamic> item) {
    final isEvent = item['type'] == 'event';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: context.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: context.dividerColor.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: CachedNetworkImage(
              imageUrl: item['image'],
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 200,
                color: context.dividerColor,
                child: Center(
                  child: CircularProgressIndicator(color: context.primaryColorTheme),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                height: 200,
                color: context.dividerColor,
                child: const Icon(Icons.image_not_supported),
              ),
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Type Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isEvent 
                        ? context.primaryColorTheme.withOpacity(0.1)
                        : context.successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isEvent ? 'Event' : 'Place',
                    style: context.labelSmall.copyWith(
                      color: isEvent ? context.primaryColorTheme : context.successColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                
                // Title
                Text(
                  item['name'],
                  style: context.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.primaryTextColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                
                // Subtitle
                Text(
                  item['location'],
                  style: context.bodyMedium.copyWith(
                    color: context.secondaryTextColor,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Date/Info
                Row(
                  children: [
                    Icon(
                      isEvent ? Icons.event : Icons.place,
                      size: 16,
                      color: context.secondaryTextColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isEvent ? item['date'] : item['category'],
                      style: context.bodySmall.copyWith(
                        color: context.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: View details
                        },
                        icon: const Icon(Icons.visibility_outlined, size: 18),
                        label: const Text('View Details'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: context.primaryColorTheme,
                          backgroundColor: context.backgroundColor,
                          side: BorderSide(color: context.primaryColorTheme),
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
                          _showRemoveFavoriteDialog(item);
                        },
                        icon: const Icon(Icons.favorite, size: 18),
                        label: const Text('Remove'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: context.primaryTextColor,
                          backgroundColor: context.errorColor,
                          side: BorderSide(color: context.errorColor),
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

  Widget _buildEventFavoriteCard(Map<String, dynamic> event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: context.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: context.dividerColor.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: CachedNetworkImage(
              imageUrl: event['image'],
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 200,
                color: context.dividerColor,
                child: Center(
                  child: CircularProgressIndicator(color: context.primaryColorTheme),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                height: 200,
                color: context.dividerColor,
                child: const Icon(Icons.image_not_supported),
              ),
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  event['name'],
                  style: context.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.primaryTextColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                
                // Location
                Text(
                  event['location'],
                  style: context.bodyMedium.copyWith(
                    color: context.secondaryTextColor,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Date
                Row(
                  children: [
                    Icon(
                      Icons.event,
                      size: 16,
                      color: context.secondaryTextColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      event['date'],
                      style: context.bodySmall.copyWith(
                        color: context.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: View event details
                        },
                        icon: const Icon(Icons.visibility_outlined, size: 18),
                        label: const Text('View Event'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: context.primaryColorTheme,
                          backgroundColor: context.backgroundColor,
                          side: BorderSide(color: context.primaryColorTheme),
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
                          _showRemoveFavoriteDialog(event);
                        },
                        icon: const Icon(Icons.favorite, size: 18),
                        label: const Text('Remove'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: context.primaryTextColor,
                          backgroundColor: context.errorColor,
                          side: BorderSide(color: context.errorColor),
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

  Widget _buildPlaceFavoriteCard(Map<String, dynamic> place) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: context.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: context.dividerColor.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: CachedNetworkImage(
              imageUrl: place['image'],
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 200,
                color: context.dividerColor,
                child: Center(
                  child: CircularProgressIndicator(color: context.primaryColorTheme),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                height: 200,
                color: context.dividerColor,
                child: const Icon(Icons.image_not_supported),
              ),
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  place['name'],
                  style: context.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.primaryTextColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                
                // Location
                Text(
                  place['location'],
                  style: context.bodyMedium.copyWith(
                    color: context.secondaryTextColor,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Category
                Row(
                  children: [
                    Icon(
                      Icons.place,
                      size: 16,
                      color: context.secondaryTextColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      place['category'],
                      style: context.bodySmall.copyWith(
                        color: context.secondaryTextColor,
                      ),
                    ),
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
                          foregroundColor: context.primaryColorTheme,
                          backgroundColor: context.backgroundColor,
                          side: BorderSide(color: context.primaryColorTheme),
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
                          _showRemoveFavoriteDialog(place);
                        },
                        icon: const Icon(Icons.favorite, size: 18),
                        label: const Text('Remove'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: context.primaryTextColor,
                          backgroundColor: context.errorColor,
                          side: BorderSide(color: context.errorColor),
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

  Widget _buildFavoriteCardFromApi(Map<String, dynamic> favorite) {
    final isEvent = favorite['eventId'] != null && favorite['event'] != null;
    final isListing = favorite['listingId'] != null && favorite['listing'] != null;
    
    if (isEvent) {
      return _buildEventFavoriteCardFromApi(favorite);
    } else if (isListing) {
      return _buildPlaceFavoriteCardFromApi(favorite);
    }
    
    // Fallback for unknown types
    return const SizedBox.shrink();
  }

  Widget _buildEventFavoriteCardFromApi(Map<String, dynamic> favorite) {
    final event = favorite['event'] as Map<String, dynamic>?;
    if (event == null) return const SizedBox.shrink();
    
    final eventName = event['name'] ?? 'Unknown Event';
    final location = event['locationName'] ?? event['address'] ?? 'Unknown Location';
    final flyer = event['flyer'] ?? '';
    final startDate = event['startDate'] != null 
        ? DateTime.tryParse(event['startDate']) 
        : null;
    
    String dateText = 'Date TBA';
    if (startDate != null) {
      dateText = '${startDate.day}/${startDate.month}/${startDate.year}';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: context.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: context.dividerColor.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: CachedNetworkImage(
              imageUrl: flyer,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 200,
                color: context.dividerColor,
                child: Center(child: CircularProgressIndicator(color: context.primaryColorTheme)),
              ),
              errorWidget: (context, url, error) => Container(
                height: 200,
                color: context.dividerColor,
                child: const Icon(Icons.event, size: 50),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: context.primaryColorTheme.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Event',
                    style: context.labelSmall.copyWith(
                      color: context.primaryColorTheme,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  eventName,
                  style: context.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.primaryTextColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  location,
                  style: context.bodyMedium.copyWith(color: context.secondaryTextColor),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.event, size: 16, color: context.secondaryTextColor),
                    const SizedBox(width: 4),
                    Text(
                      dateText,
                      style: context.bodySmall.copyWith(color: context.secondaryTextColor),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          final eventId = favorite['eventId']?.toString();
                          if (eventId != null) {
                            context.push('/event/$eventId');
                          }
                        },
                        icon: const Icon(Icons.visibility_outlined, size: 18),
                        label: const Text('View Event'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: context.primaryColorTheme,
                          backgroundColor: context.backgroundColor,
                          side: BorderSide(color: context.primaryColorTheme),
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
                          _showRemoveFavoriteDialogFromApi(favorite);
                        },
                        icon: const Icon(Icons.favorite, size: 18),
                        label: const Text('Remove'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: context.primaryTextColor,
                          backgroundColor: context.errorColor,
                          side: BorderSide(color: context.errorColor),
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

  Widget _buildPlaceFavoriteCardFromApi(Map<String, dynamic> favorite) {
    final listing = favorite['listing'] as Map<String, dynamic>?;
    if (listing == null) return const SizedBox.shrink();
    
    final listingName = listing['name'] ?? 'Unknown Place';
    final address = listing['address'] ?? listing['city']?['name'] ?? 'Unknown Location';
    final category = listing['type'] ?? 'Place';
    
    // Extract image URL
    String? imageUrl;
    final images = listing['images'] as List?;
    if (images != null && images.isNotEmpty) {
      final firstImage = images[0];
      if (firstImage is Map && firstImage['media'] != null) {
        imageUrl = firstImage['media']['url'] ?? firstImage['media']['thumbnailUrl'];
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: context.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: context.dividerColor.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 200,
                      color: context.dividerColor,
                      child: Center(child: CircularProgressIndicator(color: context.primaryColorTheme)),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 200,
                      color: context.dividerColor,
                      child: const Icon(Icons.place, size: 50),
                    ),
                  )
                : Container(
                    height: 200,
                    color: context.dividerColor,
                    child: const Icon(Icons.place, size: 50),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: context.successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Place',
                    style: context.labelSmall.copyWith(
                      color: context.successColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  listingName,
                  style: context.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.primaryTextColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  address,
                  style: context.bodyMedium.copyWith(color: context.secondaryTextColor),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.place, size: 16, color: context.secondaryTextColor),
                    const SizedBox(width: 4),
                    Text(
                      category,
                      style: context.bodySmall.copyWith(color: context.secondaryTextColor),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          final listingId = favorite['listingId']?.toString();
                          if (listingId != null) {
                            context.push('/listing/$listingId');
                          }
                        },
                        icon: const Icon(Icons.visibility_outlined, size: 18),
                        label: const Text('View Place'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: context.primaryColorTheme,
                          backgroundColor: context.backgroundColor,
                          side: BorderSide(color: context.primaryColorTheme),
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
                          _showRemoveFavoriteDialogFromApi(favorite);
                        },
                        icon: const Icon(Icons.favorite, size: 18),
                        label: const Text('Remove'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: context.primaryTextColor,
                          backgroundColor: context.errorColor,
                          side: BorderSide(color: context.errorColor),
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

  void _showRemoveFavoriteDialogFromApi(Map<String, dynamic> favorite) {
    final listing = favorite['listing'] as Map<String, dynamic>?;
    final event = favorite['event'] as Map<String, dynamic>?;
    final tour = favorite['tour'] as Map<String, dynamic>?;
    final itemName = listing?['name'] ?? event?['name'] ?? tour?['name'] ?? 'this item';
    
    // Extract the actual item ID (listingId, eventId, or tourId)
    final listingId = listing?['id']?.toString();
    final eventId = event?['id']?.toString();
    final tourId = tour?['id']?.toString();
    
    if (listingId == null && eventId == null && tourId == null) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Remove from Favorites',
          style: context.titleMedium,
        ),
        content: Text(
          'Are you sure you want to remove "$itemName" from your favorites?',
          style: context.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: context.bodyMedium.copyWith(color: context.secondaryTextColor),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final favoritesService = ref.read(favoritesServiceProvider);
                await favoritesService.removeFromFavorites(
                  listingId: listingId,
                  eventId: eventId,
                  tourId: tourId,
                );
                
                // Invalidate to refresh
                ref.invalidate(favoritesProvider(const FavoritesParams(page: 1, limit: 100)));
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    AppTheme.successSnackBar(
                      message: AppConfig.favoriteRemovedMessage,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    AppTheme.errorSnackBar(
                      message: 'Failed to remove favorite: ${e.toString().replaceFirst('Exception: ', '')}',
                    ),
                  );
                }
              }
            },
            child: Text(
              'Remove',
              style: context.bodyMedium.copyWith(
                color: context.errorColor,
                fontWeight: FontWeight.w500,
              ),
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
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.primaryColorTheme.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: context.primaryColorTheme,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: context.titleLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: context.primaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: context.bodyMedium.copyWith(
                color: context.secondaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            OutlinedButton(
              onPressed: onAction,
              style: OutlinedButton.styleFrom(
                foregroundColor: context.primaryColorTheme,
                backgroundColor: context.backgroundColor,
                side: BorderSide(color: context.primaryColorTheme),
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

  void _showRemoveFavoriteDialog(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Remove from Favorites',
          style: context.titleMedium,
        ),
        content: Text(
          'Are you sure you want to remove "${item['name']}" from your favorites?',
          style: context.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: context.bodyMedium.copyWith(
                color: context.secondaryTextColor,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Remove from favorites
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Removed from favorites'),
                  backgroundColor: context.successColor,
                ),
              );
            },
            child: Text(
              'Remove',
              style: context.bodyMedium.copyWith(
                color: context.errorColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getMockEvents() {
    return [
      {
        'type': 'event',
        'name': 'Kigali Fashion Week',
        'location': 'Kigali Convention Centre',
        'date': 'Dec 15, 2024',
        'image': 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=400',
      },
      {
        'type': 'event',
        'name': 'Rwanda Cultural Festival',
        'location': 'Amahoro Stadium',
        'date': 'Jan 20, 2025',
        'image': 'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=400',
      },
    ];
  }

  List<Map<String, dynamic>> _getMockPlaces() {
    return [
      {
        'type': 'place',
        'name': 'Volcanoes National Park',
        'location': 'Musanze, Rwanda',
        'category': 'National Park',
        'image': 'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=400',
      },
      {
        'type': 'place',
        'name': 'Kigali Genocide Memorial',
        'location': 'Kigali, Rwanda',
        'category': 'Memorial',
        'image': 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400',
      },
    ];
  }
}