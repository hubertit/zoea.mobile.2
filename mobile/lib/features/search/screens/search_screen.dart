import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/theme/text_theme_extensions.dart';
import '../../../core/providers/search_provider.dart';
import '../../../core/providers/user_data_collection_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  final String? initialQuery;
  final String? category;
  
  const SearchScreen({
    super.key,
    this.initialQuery,
    this.category,
  });

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late TextEditingController _searchController;
  String _currentQuery = '';
  String _searchQuery = ''; // This is the actual query used for API calls (after debounce)
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery ?? '');
    _currentQuery = widget.initialQuery ?? '';
    _searchQuery = widget.initialQuery ?? '';
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _performSearch(String query) {
    _debounceTimer?.cancel();
    
    // Update current query immediately for UI
    setState(() {
      _currentQuery = query;
    });

    if (query.trim().isEmpty) {
      // Clear search query immediately if empty
      setState(() {
        _searchQuery = '';
      });
      return;
    }

    // Debounce search to avoid too many API calls
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        final trimmedQuery = query.trim();
        setState(() {
          _searchQuery = trimmedQuery;
        });
        
        // Don't track search here - only track when user actually selects a result or submits
      }
    });
  }

  void _trackSearch(String query) {
    try {
      final analyticsService = ref.read(analyticsServiceProvider);
      analyticsService.trackSearch(
        query: query,
        category: widget.category,
      );
    } catch (e) {
      // Silently fail - analytics should never break the app
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.grey50,
      appBar: AppBar(
        backgroundColor: context.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left,
            color: context.primaryTextColor,
            size: 32,
          ),
          onPressed: () => context.pop(),
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search events, places, experiences...',
            hintStyle: context.bodyMedium.copyWith(
              color: context.secondaryTextColor,
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.only(left: 8, top: 8, bottom: 8),
          ),
          style: context.bodyMedium.copyWith(
            color: context.primaryTextColor,
          ),
          onChanged: (value) {
            setState(() {
              _currentQuery = value;
            });
            _performSearch(value);
          },
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              _performSearch(value);
              // Track search when user submits (presses enter)
              _trackSearch(value.trim());
            }
          },
        ),
        actions: [
          if (_currentQuery.isNotEmpty)
            IconButton(
              icon: Icon(
                Icons.clear,
                color: context.secondaryTextColor,
              ),
              onPressed: () {
                _searchController.clear();
                _debounceTimer?.cancel();
                setState(() {
                  _currentQuery = '';
                  _searchQuery = '';
                });
              },
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_searchQuery.isEmpty) {
      return _buildEmptyState();
    }

    // Watch search provider with the debounced search query
    // Create a stable search params object to prevent unnecessary rebuilds
    final searchParams = SearchParams(
      query: _searchQuery,
      category: widget.category,
    );
    
    final searchAsync = ref.watch(searchProvider(searchParams));

    return searchAsync.when(
      data: (results) {
        final listings = results['listings'] as List? ?? [];
        final events = results['events'] as List? ?? [];
        final tours = results['tours'] as List? ?? [];
        
        final allResults = <Map<String, dynamic>>[];
        allResults.addAll(listings.map((e) => {...e, 'type': 'listing'}));
        allResults.addAll(events.map((e) => {...e, 'type': 'event'}));
        allResults.addAll(tours.map((e) => {...e, 'type': 'tour'}));

        if (allResults.isEmpty) {
          return _buildNoResultsState();
        }

        return _buildSearchResults(allResults);
      },
      loading: () => _buildLoadingState(),
      error: (error, stack) => _buildErrorState(error),
    );
  }

  Widget _buildEmptyState() {
    // Fetch search history and trending searches
    final searchHistoryAsync = ref.watch(searchHistoryProvider);
    final trendingAsync = ref.watch(trendingSearchesProvider);

    return RefreshIndicator(
      color: context.primaryColorTheme,
      backgroundColor: context.cardColor,
      onRefresh: () async {
        ref.invalidate(searchHistoryProvider);
        ref.invalidate(trendingSearchesProvider);
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recent searches
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Searches',
                  style: context.headlineSmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.primaryTextColor,
                  ),
                ),
                searchHistoryAsync.when(
                  data: (history) {
                    if (history.isEmpty) return const SizedBox.shrink();
                    return TextButton(
                      onPressed: () => _showClearHistoryDialog(),
                      child: Text(
                        'Clear',
                        style: context.bodySmall.copyWith(
                          color: context.primaryColorTheme,
                        ),
                      ),
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            searchHistoryAsync.when(
              data: (history) {
                if (history.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'No recent searches',
                      style: context.bodyMedium.copyWith(
                        color: context.secondaryTextColor,
                      ),
                    ),
                  );
                }
                return Column(
                  children: history.map((item) => _buildRecentSearchItem(item)).toList(),
                );
              },
              loading: () => Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(color: context.primaryColorTheme),
                ),
              ),
              error: (error, stack) {
                // If 401 (unauthorized), user is not logged in - show empty state
                final errorString = error.toString();
                if (errorString.contains('Unauthorized') || errorString.contains('401')) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'Sign in to see your search history',
                      style: context.bodyMedium.copyWith(
                        color: context.secondaryTextColor,
                      ),
                    ),
                  );
                }
                // For other errors, show error message
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'Failed to load recent searches',
                    style: context.bodyMedium.copyWith(
                      color: context.errorColor,
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 32),
            
            // Popular searches
            Text(
              'Popular Searches',
              style: context.headlineSmall.copyWith(
                fontWeight: FontWeight.w600,
                color: context.primaryTextColor,
              ),
            ),
            const SizedBox(height: 16),
            trendingAsync.when(
              data: (trending) {
                final trendingSearches = (trending['trendingSearches'] as List?)?.cast<String>() ?? [];
                if (trendingSearches.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'No popular searches available',
                      style: context.bodyMedium.copyWith(
                        color: context.secondaryTextColor,
                      ),
                    ),
                  );
                }
                // Limit to 5 items
                final limitedSearches = trendingSearches.take(5).toList();
                return Column(
                  children: limitedSearches.map((search) => _buildPopularSearchItem(search)).toList(),
                );
              },
              loading: () => Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(color: context.primaryColorTheme),
                ),
              ),
              error: (error, stack) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Failed to load popular searches',
                  style: context.bodyMedium.copyWith(
                    color: context.errorColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: CircularProgressIndicator(color: context.primaryColorTheme),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: context.secondaryTextColor,
          ),
          const SizedBox(height: 16),
          Text(
            'No results found',
            style: context.headlineSmall.copyWith(
              color: context.secondaryTextColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching with different keywords',
            style: context.bodyMedium.copyWith(
              color: context.secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(List<Map<String, dynamic>> results) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final result = results[index];
        return _buildSearchResultCard(result);
      },
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: context.errorColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Search failed',
            style: context.headlineSmall.copyWith(
              color: context.errorColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString().replaceFirst('Exception: ', ''),
            style: context.bodyMedium.copyWith(
              color: context.secondaryTextColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResultCard(Map<String, dynamic> result) {
    // Extract image URL from API response structure
    String? imageUrl;
    if (result['images'] != null && result['images'] is List && (result['images'] as List).isNotEmpty) {
      final firstImage = (result['images'] as List).first;
      if (firstImage is Map && firstImage['media'] != null) {
        imageUrl = firstImage['media']['url'] ?? firstImage['media']['thumbnailUrl'];
      } else if (firstImage is String) {
        imageUrl = firstImage;
      }
    } else if (result['image'] != null) {
      imageUrl = result['image'] is String ? result['image'] : result['image']['url'];
    } else if (result['flyer'] != null) {
      imageUrl = result['flyer'];
    }

    // Extract name/title
    final name = result['name'] ?? result['title'] ?? 'Unknown';
    
    // Extract location/address
    final location = result['address'] ?? 
                     result['locationName'] ?? 
                     result['city']?['name'] ?? 
                     result['subtitle'] ?? 
                     '';

    // Extract rating
    final rating = result['rating'] != null 
        ? (result['rating'] is String 
            ? double.tryParse(result['rating']) 
            : result['rating']?.toDouble())
        : null;

    // Determine type icon
    final resultType = result['type'] ?? '';
    IconData typeIcon;
    String typeLabel;
    if (resultType == 'event' || result['event'] != null) {
      typeIcon = Icons.event;
      typeLabel = 'Event';
    } else if (resultType == 'tour') {
      typeIcon = Icons.explore;
      typeLabel = 'Tour';
    } else {
      typeIcon = Icons.place;
      typeLabel = 'Place';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: context.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: context.primaryTextColor.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: imageUrl != null
              ? CachedNetworkImage(
                  imageUrl: imageUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 50,
                    height: 50,
                    color: context.dividerColor,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: context.primaryColorTheme,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 50,
                    height: 50,
                    color: context.dividerColor,
                    child: Icon(
                      typeIcon,
                      color: context.secondaryTextColor,
                    ),
                  ),
                )
              : Container(
                  width: 50,
                  height: 50,
                  color: context.dividerColor,
                  child: Icon(
                    typeIcon,
                    color: context.secondaryTextColor,
                  ),
                ),
        ),
        title: Text(
          name,
          style: context.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: context.primaryTextColor,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            if (location.isNotEmpty)
              Text(
                location,
                style: context.bodySmall.copyWith(
                  color: context.secondaryTextColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  typeIcon,
                  size: 12,
                  color: context.secondaryTextColor,
                ),
                const SizedBox(width: 4),
                Text(
                  typeLabel,
                  style: context.labelSmall.copyWith(
                    color: context.secondaryTextColor,
                  ),
                ),
                if (rating != null) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.star,
                    size: 12,
                    color: context.primaryColorTheme,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    rating.toStringAsFixed(1),
                    style: context.labelSmall.copyWith(
                      color: context.primaryColorTheme,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        onTap: () {
          // Track search when user taps on a result
          if (_searchQuery.isNotEmpty) {
            _trackSearch(_searchQuery);
          }
          
          final id = result['id'] ?? '';
          if (resultType == 'event' || result['event'] != null) {
            context.push('/event/$id');
          } else if (resultType == 'tour') {
            context.push('/tour/$id');
          } else {
            // Check if this is an accommodation listing
            final category = result['category'] as Map<String, dynamic>?;
            final categorySlug = category?['slug'] as String?;
            final categoryName = category?['name'] as String?;
            
            final isAccommodation = categorySlug == 'accommodation' || 
                                   categoryName?.toLowerCase() == 'accommodation';
            
            if (isAccommodation) {
              context.push('/accommodation/$id');
            } else {
              context.push('/listing/$id');
            }
          }
        },
      ),
    );
  }

  Widget _buildRecentSearchItem(Map<String, dynamic> historyItem) {
    final query = historyItem['query'] as String? ?? '';
    final createdAt = historyItem['createdAt'] as String?;
    String? timeAgo;
    
    if (createdAt != null) {
      try {
        final date = DateTime.parse(createdAt);
        final now = DateTime.now();
        final difference = now.difference(date);
        
        if (difference.inDays > 0) {
          timeAgo = '${difference.inDays}d ago';
        } else if (difference.inHours > 0) {
          timeAgo = '${difference.inHours}h ago';
        } else if (difference.inMinutes > 0) {
          timeAgo = '${difference.inMinutes}m ago';
        } else {
          timeAgo = 'Just now';
        }
      } catch (e) {
        // If parsing fails, don't show time
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          Icons.history,
          color: context.secondaryTextColor,
          size: 20,
        ),
        title: Text(
          query,
          style: context.bodyMedium.copyWith(
            color: context.primaryTextColor,
          ),
        ),
        trailing: timeAgo != null
            ? Text(
                timeAgo,
                style: context.bodySmall.copyWith(
                  color: context.secondaryTextColor,
                ),
              )
            : null,
        onTap: () {
          _searchController.text = query;
          setState(() {
            _currentQuery = query;
          });
          _performSearch(query);
          // Track search when user taps on a recent search item
          _trackSearch(query);
        },
      ),
    );
  }

  Widget _buildPopularSearchItem(String search) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          Icons.trending_up,
          color: context.primaryColorTheme,
          size: 20,
        ),
        title: Text(
          search,
          style: context.bodyMedium.copyWith(
            color: context.primaryTextColor,
          ),
        ),
        onTap: () {
          _searchController.text = search;
          setState(() {
            _currentQuery = search;
          });
          _performSearch(search);
          // Track search when user taps on a popular search item
          _trackSearch(search);
        },
      ),
    );
  }


  void _showClearHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Clear Search History',
          style: context.titleMedium,
        ),
        content: Text(
          'Are you sure you want to clear all your search history?',
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
            onPressed: () async {
              Navigator.pop(context);
              await _clearSearchHistory();
            },
            child: Text(
              'Clear',
              style: context.bodyMedium.copyWith(
                color: context.errorColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _clearSearchHistory() async {
    try {
      final searchService = ref.read(searchServiceProvider);
      await searchService.clearSearchHistory();

      if (!mounted) return;

      // Refresh search history
      ref.invalidate(searchHistoryProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Search history cleared',
            style: context.bodyMedium.copyWith(
              color: context.primaryTextColor,
            ),
          ),
          backgroundColor: context.cardColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to clear search history: ${e.toString().replaceFirst('Exception: ', '')}',
            style: context.bodyMedium.copyWith(
              color: context.primaryTextColor,
            ),
          ),
          backgroundColor: context.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
