import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/theme/theme_extensions.dart';
import '../../../core/theme/text_theme_extensions.dart';
import '../../../core/providers/products_provider.dart';
import '../../../core/config/app_config.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  final String? listingId;
  final String? category;
  final String? search;

  const ProductsScreen({
    super.key,
    this.listingId,
    this.category,
    this.search,
  });

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  int _currentPage = 1;
  final int _pageSize = 20;
  String? _selectedStatus;
  String? _selectedSort = 'popular';
  double? _minPrice;
  double? _maxPrice;
  bool? _isFeatured;

  @override
  Widget build(BuildContext context) {
    final params = ProductsParams(
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

    final productsAsync = widget.listingId != null
        ? ref.watch(productsByListingProvider(params))
        : ref.watch(productsProvider(params));

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
          widget.listingId != null ? 'Products' : 'Shop',
          style: context.headlineMedium.copyWith(
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
      body: productsAsync.when(
        data: (data) {
          final products = (data['data'] as List? ?? [])
              .map((p) => p as Map<String, dynamic>)
              .toList();
          final meta = data['meta'] as Map<String, dynamic>? ?? {};
          final total = meta['total'] as int? ?? 0;
          final totalPages = meta['totalPages'] as int? ?? 1;

          if (products.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            color: context.primaryColorTheme,
            backgroundColor: context.cardColor,
            onRefresh: () async {
              ref.invalidate(productsProvider(params));
              if (widget.listingId != null) {
                ref.invalidate(productsByListingProvider(params));
              }
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
                          '$total ${total == 1 ? 'product' : 'products'}',
                          style: context.bodyMedium.copyWith(
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
                                  style: context.bodySmall.copyWith(
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
                  child: GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: products.length + (_currentPage < totalPages ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == products.length) {
                        return _buildLoadMoreButton(totalPages);
                      }
                      return _buildProductCard(products[index]);
                    },
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => Center(child: CircularProgressIndicator(color: context.primaryColorTheme)),
        error: (error, stack) => _buildErrorState(error),
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    final name = product['name'] as String? ?? 'Unknown';
    final basePrice = (product['basePrice'] ?? product['base_price'] ?? 0).toDouble();
    final compareAtPrice = product['compareAtPrice'] != null || product['compare_at_price'] != null
        ? ((product['compareAtPrice'] ?? product['compare_at_price']) as num).toDouble()
        : null;
    final images = product['images'] as List? ?? [];
    final imageUrl = images.isNotEmpty
        ? '${AppConfig.apiBaseUrl.replaceAll('/api', '')}/media/${images[0]}'
        : null;
    final isAvailable = product['status'] == 'active' &&
        (!(product['trackInventory'] ?? product['track_inventory'] ?? true) ||
            (product['inventoryQuantity'] ?? product['inventory_quantity'] ?? 0) > 0);
    final discountPercent = compareAtPrice != null && compareAtPrice > basePrice
        ? ((compareAtPrice - basePrice) / compareAtPrice * 100).round()
        : null;

    return GestureDetector(
      onTap: () {
        context.push('/product/${product['id']}');
      },
      child: Card(
        elevation: 0,
        color: context.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          width: double.infinity,
                          height: 140,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            width: double.infinity,
                            height: 140,
                            color: context.grey100,
                            child: Center(child: CircularProgressIndicator(color: context.primaryColorTheme)),
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: double.infinity,
                            height: 140,
                            color: context.grey100,
                            child: Icon(
                              Icons.image_not_supported,
                              color: context.secondaryTextColor,
                            ),
                          ),
                        )
                      : Container(
                          width: double.infinity,
                          height: 140,
                          color: context.grey100,
                          child: Icon(
                            Icons.image_not_supported,
                            color: context.secondaryTextColor,
                          ),
                        ),
                ),
                if (discountPercent != null)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: context.errorColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '-$discountPercent%',
                        style: context.bodySmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                if (!isAvailable)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      ),
                      child: Center(
                        child: Text(
                          'Out of Stock',
                          style: context.bodyMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: context.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.primaryTextColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Text(
                          '${AppConfig.currencySymbol} ${basePrice.toStringAsFixed(0)}',
                          style: context.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.primaryColorTheme,
                          ),
                        ),
                        if (compareAtPrice != null && compareAtPrice > basePrice) ...[
                          const SizedBox(width: 8),
                          Text(
                            '${AppConfig.currencySymbol} ${compareAtPrice.toStringAsFixed(0)}',
                            style: context.bodySmall.copyWith(
                              color: context.secondaryTextColor,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: context.secondaryTextColor,
            ),
            const SizedBox(height: 16),
            Text(
              'No products found',
              style: context.headlineSmall.copyWith(
                color: context.primaryTextColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters or search',
              style: context.bodyMedium.copyWith(
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
              'Failed to load products',
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
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final params = ProductsParams(
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
                ref.invalidate(productsProvider(params));
                if (widget.listingId != null) {
                  ref.invalidate(productsByListingProvider(params));
                }
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
        padding: const EdgeInsets.all(12),
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
        title: const Text('Search Products'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter product name...',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) {
            Navigator.pop(context);
            context.push('/products?search=$value');
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
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter Products',
                style: context.headlineSmall.copyWith(
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
          style: context.bodyMedium.copyWith(
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
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sort By',
              style: context.headlineSmall.copyWith(
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
                    ))
                .toList(),
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
}

