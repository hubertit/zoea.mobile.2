import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/providers/services_provider.dart';
import '../../../core/config/app_config.dart';

class ServicesScreen extends ConsumerStatefulWidget {
  final String? listingId;
  final String? category;
  final String? search;

  const ServicesScreen({
    super.key,
    this.listingId,
    this.category,
    this.search,
  });

  @override
  ConsumerState<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends ConsumerState<ServicesScreen> {
  int _currentPage = 1;
  final int _pageSize = 20;
  String? _selectedStatus;
  String? _selectedSort = 'popular';
  double? _minPrice;
  double? _maxPrice;
  bool? _isFeatured;

  @override
  Widget build(BuildContext context) {
    final params = ServicesParams(
      page: _currentPage,
      limit: _pageSize,
      listingId: widget.listingId,
      status: _selectedStatus ?? 'active',
      search: widget.search,
      category: widget.category,
      minPrice: _minPrice,
      maxPrice: _maxPrice,
      isFeatured: _isFeatured,
      sortBy: _selectedSort,
    );

    final servicesAsync = ref.watch(servicesProvider(params));

    return Scaffold(
      backgroundColor: context.grey50,
      appBar: AppBar(
        backgroundColor: context.backgroundColor,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          onPressed: () => context.canPop() ? context.pop() : context.go('/explore'),
          icon: Icon(
            Icons.chevron_left,
            size: 32,
            color: context.primaryTextColor,
          ),
        ),
        title: Text(
          widget.listingId != null ? 'Services' : 'Services',
          style: AppTheme.headlineMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: context.primaryTextColor,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: context.primaryTextColor),
            onPressed: _showSearchDialog,
          ),
          IconButton(
            icon: Icon(Icons.filter_list, color: context.primaryTextColor),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: servicesAsync.when(
        data: (data) {
          final services = (data['data'] as List? ?? [])
              .map((s) => s as Map<String, dynamic>)
              .toList();
          final meta = data['meta'] as Map<String, dynamic>? ?? {};
          final total = meta['total'] as int? ?? 0;
          final totalPages = meta['totalPages'] as int? ?? 1;

          if (services.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(servicesProvider(params));
            },
            child: Column(
              children: [
                if (total > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: context.cardColor,
                    child: Row(
                      children: [
                        Text(
                          '$total ${total == 1 ? 'service' : 'services'}',
                          style: AppTheme.bodyMedium.copyWith(
                            color: context.secondaryTextColor,
                          ),
                        ),
                        const Spacer(),
                        if (_selectedSort != null)
                          GestureDetector(
                            onTap: _showSortBottomSheet,
                            child: Row(
                              children: [
                                Text(
                                  'Sort: ${_getSortLabel(_selectedSort!)}',
                                  style: AppTheme.bodySmall.copyWith(
                                    color: context.primaryColorTheme,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_drop_down,
                                  size: 20,
                                  color: context.primaryColorTheme,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: services.length + (_currentPage < totalPages ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == services.length) {
                        return _buildLoadMoreButton(totalPages);
                      }
                      return _buildServiceCard(services[index]);
                    },
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(error),
      ),
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service) {
    final name = service['name'] as String? ?? 'Unknown';
    final basePrice = (service['basePrice'] ?? service['base_price'] ?? 0).toDouble();
    final priceUnit = service['priceUnit'] as String? ?? service['price_unit'] as String? ?? 'fixed';
    final images = service['images'] as List? ?? [];
    final imageUrl = images.isNotEmpty
        ? '${AppConfig.apiBaseUrl.replaceAll('/api', '')}/media/${images[0]}'
        : null;
    final isAvailable = service['isAvailable'] as bool? ?? service['is_available'] as bool? ?? true;
    final status = service['status'] as String? ?? 'active';
    final durationMinutes = service['durationMinutes'] as int? ?? service['duration_minutes'] as int?;
    final description = service['shortDescription'] as String? ?? service['short_description'] as String? ?? service['description'] as String?;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: context.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          context.push('/service/${service['id']}');
        },
        borderRadius: BorderRadius.circular(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                        color: context.grey100,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 120,
                        height: 120,
                        color: context.grey100,
                        child: Icon(
                          Icons.image_not_supported,
                          color: context.secondaryTextColor,
                        ),
                      ),
                    )
                  : Container(
                      width: 120,
                      height: 120,
                      color: context.grey100,
                      child: Icon(
                        Icons.image_not_supported,
                        color: context.secondaryTextColor,
                      ),
                    ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: AppTheme.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                              color: context.primaryTextColor,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (service['isFeatured'] == true)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: context.primaryColorTheme,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Featured',
                              style: AppTheme.bodySmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: AppTheme.bodySmall.copyWith(
                          color: context.secondaryTextColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const Spacer(),
                    Row(
                      children: [
                        Text(
                          '${AppConfig.currencySymbol} ${basePrice.toStringAsFixed(0)}',
                          style: AppTheme.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.primaryColorTheme,
                          ),
                        ),
                        if (priceUnit != 'fixed') ...[
                          const SizedBox(width: 4),
                          Text(
                            '/${_getPriceUnitLabel(priceUnit)}',
                            style: AppTheme.bodySmall.copyWith(
                              color: context.secondaryTextColor,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (durationMinutes != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: context.secondaryTextColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${durationMinutes} min',
                            style: AppTheme.bodySmall.copyWith(
                              color: context.secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (!isAvailable || status != 'active') ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: context.errorColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          !isAvailable ? 'Unavailable' : 'Inactive',
                          style: AppTheme.bodySmall.copyWith(
                            color: context.errorColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.room_service_outlined,
              size: 64,
              color: context.secondaryTextColor,
            ),
            const SizedBox(height: 16),
            Text(
              'No services found',
              style: AppTheme.headlineSmall.copyWith(
                color: context.primaryTextColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters or search',
              style: AppTheme.bodyMedium.copyWith(
                color: context.secondaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedStatus = null;
                  _selectedSort = 'popular';
                  _minPrice = null;
                  _maxPrice = null;
                  _isFeatured = null;
                });
              },
              child: const Text('Clear Filters'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
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
              'Failed to load services',
              style: AppTheme.headlineSmall.copyWith(
                color: context.errorColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString().replaceFirst('Exception: ', ''),
              style: AppTheme.bodyMedium.copyWith(
                color: context.secondaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final params = ServicesParams(
                  page: _currentPage,
                  limit: _pageSize,
                  listingId: widget.listingId,
                  status: _selectedStatus ?? 'active',
                  search: widget.search,
                  category: widget.category,
                  minPrice: _minPrice,
                  maxPrice: _maxPrice,
                  isFeatured: _isFeatured,
                  sortBy: _selectedSort,
                );
                ref.invalidate(servicesProvider(params));
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadMoreButton(int totalPages) {
    if (_currentPage >= totalPages) return const SizedBox.shrink();

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

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Services'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter service name...',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) {
            Navigator.pop(context);
            context.push('/services?search=${Uri.encodeComponent(value)}');
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter Services',
                style: AppTheme.headlineSmall.copyWith(
                  color: context.primaryTextColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              _buildFilterSection(
                'Status',
                ['All', 'Active', 'Inactive'],
                _selectedStatus == null ? 'All' : _selectedStatus!.toUpperCase(),
                (value) {
                  setModalState(() {
                    _selectedStatus = value == 'All' ? null : value.toLowerCase();
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildFilterSection(
                'Featured',
                ['All', 'Featured Only'],
                _isFeatured == null ? 'All' : 'Featured Only',
                (value) {
                  setModalState(() {
                    _isFeatured = value == 'All' ? null : true;
                  });
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setModalState(() {
                          _selectedStatus = null;
                          _isFeatured = null;
                          _minPrice = null;
                          _maxPrice = null;
                        });
                      },
                      child: const Text('Reset'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          _currentPage = 1;
                        });
                      },
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection(String title, List<String> options, String selected, Function(String) onSelect) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: context.primaryTextColor,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: options.map((option) {
            final isSelected = option == selected;
            return FilterChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) onSelect(option);
              },
              selectedColor: context.primaryColorTheme.withOpacity(0.2),
              checkmarkColor: context.primaryColorTheme,
            );
          }).toList(),
        ),
      ],
    );
  }

  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sort By',
              style: AppTheme.headlineSmall.copyWith(
                color: context.primaryTextColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...[
              'popular',
              'name_asc',
              'name_desc',
              'price_asc',
              'price_desc',
              'createdAt_desc'
            ].map((sort) => RadioListTile<String>(
                  title: Text(_getSortLabel(sort)),
                  value: sort,
                  groupValue: _selectedSort,
                  onChanged: (value) {
                    setState(() {
                      _selectedSort = value;
                      _currentPage = 1;
                    });
                    Navigator.pop(context);
                  },
                )),
          ],
        ),
      ),
    );
  }

  String _getSortLabel(String sort) {
    switch (sort) {
      case 'popular':
        return 'Popular';
      case 'name_asc':
        return 'Name (A-Z)';
      case 'name_desc':
        return 'Name (Z-A)';
      case 'price_asc':
        return 'Price (Low to High)';
      case 'price_desc':
        return 'Price (High to Low)';
      case 'createdAt_desc':
        return 'Newest First';
      default:
        return sort;
    }
  }

  String _getPriceUnitLabel(String unit) {
    switch (unit) {
      case 'per_hour':
        return 'hour';
      case 'per_session':
        return 'session';
      case 'per_person':
        return 'person';
      default:
        return '';
    }
  }
}

