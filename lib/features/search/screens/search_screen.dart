import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_theme.dart';

class SearchScreen extends StatefulWidget {
  final String? initialQuery;
  
  const SearchScreen({
    super.key,
    this.initialQuery,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late TextEditingController _searchController;
  String _currentQuery = '';
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery ?? '');
    _currentQuery = widget.initialQuery ?? '';
    if (_currentQuery.isNotEmpty) {
      _performSearch(_currentQuery);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    // Simulate search delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _searchResults = _getSearchResults(query);
          _isSearching = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left,
            color: AppTheme.primaryTextColor,
            size: 32,
          ),
          onPressed: () => context.pop(),
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search events, places, experiences...',
            hintStyle: AppTheme.bodyMedium.copyWith(
              color: AppTheme.secondaryTextColor,
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.only(left: 8, top: 8, bottom: 8),
          ),
          style: AppTheme.bodyMedium,
          onChanged: (value) {
            setState(() {
              _currentQuery = value;
            });
            _performSearch(value);
          },
        ),
        actions: [
          if (_currentQuery.isNotEmpty)
            IconButton(
              icon: Icon(
                Icons.clear,
                color: AppTheme.secondaryTextColor,
              ),
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _currentQuery = '';
                  _searchResults = [];
                });
              },
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_currentQuery.isEmpty) {
      return _buildEmptyState();
    }

    if (_isSearching) {
      return _buildLoadingState();
    }

    if (_searchResults.isEmpty) {
      return _buildNoResultsState();
    }

    return _buildSearchResults();
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent searches
          Text(
            'Recent Searches',
            style: AppTheme.headlineSmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ..._getRecentSearches().map((search) => _buildRecentSearchItem(search)),
          
          const SizedBox(height: 32),
          
          // Popular searches
          Text(
            'Popular Searches',
            style: AppTheme.headlineSmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ..._getPopularSearches().map((search) => _buildPopularSearchItem(search)),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
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
            color: AppTheme.secondaryTextColor,
          ),
          const SizedBox(height: 16),
          Text(
            'No results found',
            style: AppTheme.headlineSmall.copyWith(
              color: AppTheme.secondaryTextColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching with different keywords',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final result = _searchResults[index];
        return _buildSearchResultCard(result);
      },
    );
  }

  Widget _buildSearchResultCard(Map<String, dynamic> result) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryTextColor.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: result['image'],
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              width: 50,
              height: 50,
              color: AppTheme.dividerColor,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              width: 50,
              height: 50,
              color: AppTheme.dividerColor,
              child: const Icon(Icons.image_not_supported),
            ),
          ),
        ),
        title: Text(
          result['title'],
          style: AppTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              result['subtitle'],
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.secondaryTextColor,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  result['type'] == 'event' ? Icons.event : Icons.place,
                  size: 12,
                  color: AppTheme.secondaryTextColor,
                ),
                const SizedBox(width: 4),
                Text(
                  result['type'] == 'event' ? 'Event' : 'Place',
                  style: AppTheme.labelSmall.copyWith(
                    color: AppTheme.secondaryTextColor,
                  ),
                ),
                const SizedBox(width: 8),
                if (result['rating'] != null) ...[
                  Icon(
                    Icons.star,
                    size: 12,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    result['rating'].toString(),
                    style: AppTheme.labelSmall.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        onTap: () {
          // TODO: Navigate to detail screen
        },
      ),
    );
  }

  Widget _buildRecentSearchItem(String search) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          Icons.history,
          color: AppTheme.secondaryTextColor,
          size: 20,
        ),
        title: Text(
          search,
          style: AppTheme.bodyMedium,
        ),
        onTap: () {
          _searchController.text = search;
          _performSearch(search);
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
          color: AppTheme.primaryColor,
          size: 20,
        ),
        title: Text(
          search,
          style: AppTheme.bodyMedium,
        ),
        onTap: () {
          _searchController.text = search;
          _performSearch(search);
        },
      ),
    );
  }

  List<Map<String, dynamic>> _getSearchResults(String query) {
    final allResults = _getAllSearchableItems();
    return allResults.where((item) {
      final title = item['title'].toLowerCase();
      final subtitle = item['subtitle'].toLowerCase();
      final searchQuery = query.toLowerCase();
      return title.contains(searchQuery) || subtitle.contains(searchQuery);
    }).toList();
  }

  List<Map<String, dynamic>> _getAllSearchableItems() {
    return [
      {
        'title': 'Gorilla Trekking Experience',
        'subtitle': 'Volcanoes National Park, Musanze',
        'type': 'event',
        'rating': 4.8,
        'image': 'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=200',
      },
      {
        'title': 'Kigali Genocide Memorial',
        'subtitle': 'Gisozi, Kigali',
        'type': 'place',
        'rating': 4.9,
        'image': 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=200',
      },
      {
        'title': 'Cultural Village Tour',
        'subtitle': 'Iby\'iwacu Cultural Village, Musanze',
        'type': 'event',
        'rating': 4.7,
        'image': 'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=200',
      },
      {
        'title': 'Lake Kivu Boat Trip',
        'subtitle': 'Rubavu, Western Province',
        'type': 'event',
        'rating': 4.6,
        'image': 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=200',
      },
      {
        'title': 'Nyungwe Forest National Park',
        'subtitle': 'Nyungwe, Southern Province',
        'type': 'place',
        'rating': 4.8,
        'image': 'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=200',
      },
      {
        'title': 'Akagera National Park',
        'subtitle': 'Eastern Province',
        'type': 'place',
        'rating': 4.5,
        'image': 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=200',
      },
    ];
  }

  List<String> _getRecentSearches() {
    return [
      'Gorilla Trekking',
      'Kigali Memorial',
      'Lake Kivu',
      'Cultural Tour',
    ];
  }

  List<String> _getPopularSearches() {
    return [
      'Volcanoes National Park',
      'Nyungwe Forest',
      'Akagera Safari',
      'Kigali City Tour',
      'Rwanda Cultural Experience',
    ];
  }
}
