import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/providers/menus_provider.dart';
import '../../../core/services/cart_service.dart';
import '../../../core/config/app_config.dart';
import '../../../core/models/menu.dart';
import '../../../core/models/cart.dart';

class MenuDetailScreen extends ConsumerStatefulWidget {
  final String menuId;

  const MenuDetailScreen({
    super.key,
    required this.menuId,
  });

  @override
  ConsumerState<MenuDetailScreen> createState() => _MenuDetailScreenState();
}

class _MenuDetailScreenState extends ConsumerState<MenuDetailScreen> {
  String? _selectedCategoryId;
  bool _isAddingToCart = false;

  @override
  Widget build(BuildContext context) {
    final menuAsync = ref.watch(menuByIdProvider(widget.menuId));

    return Scaffold(
      backgroundColor: context.grey50,
      body: menuAsync.when(
        data: (menu) => _buildContent(menu),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(error),
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Scaffold(
      backgroundColor: context.grey50,
      appBar: AppBar(
        backgroundColor: context.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, size: 32, color: context.primaryTextColor),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
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
                'Failed to load menu',
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
                  ref.invalidate(menuByIdProvider(widget.menuId));
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(Menu menu) {
    final items = menu.items ?? [];
    final categories = _getCategoriesFromItems(items);
    final filteredItems = _selectedCategoryId == null
        ? items
        : items.where((item) => item.categoryId == _selectedCategoryId).toList();

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: context.backgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.chevron_left, size: 32, color: context.primaryTextColor),
            onPressed: () => context.pop(),
          ),
          title: Text(
            menu.name,
            style: AppTheme.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: context.primaryTextColor,
            ),
          ),
        ),
        if (menu.description != null)
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                menu.description!,
                style: AppTheme.bodyMedium.copyWith(
                  color: context.primaryTextColor,
                ),
              ),
            ),
          ),
        if (categories.isNotEmpty)
          SliverToBoxAdapter(
            child: Container(
              height: 50,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: categories.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    final isSelected = _selectedCategoryId == null;
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: ChoiceChip(
                        label: const Text('All'),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedCategoryId = null;
                            });
                          }
                        },
                        selectedColor: context.primaryColorTheme.withOpacity(0.2),
                        checkmarkColor: context.primaryColorTheme,
                      ),
                    );
                  }
                  final category = categories[index - 1];
                  final isSelected = _selectedCategoryId == category.id;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: ChoiceChip(
                      label: Text(category.name),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedCategoryId = category.id;
                          });
                        }
                      },
                      selectedColor: context.primaryColorTheme.withOpacity(0.2),
                      checkmarkColor: context.primaryColorTheme,
                    ),
                  );
                },
              ),
            ),
          ),
        if (filteredItems.isEmpty)
          SliverFillRemaining(
            child: Center(
              child: Text(
                'No items in this category',
                style: AppTheme.bodyMedium.copyWith(
                  color: context.secondaryTextColor,
                ),
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = filteredItems[index];
                return _buildMenuItemCard(item);
              },
              childCount: filteredItems.length,
            ),
          ),
      ],
    );
  }

  List<MenuCategory> _getCategoriesFromItems(List<MenuItem> items) {
    final categoryMap = <String, MenuCategory>{};
    for (final item in items) {
      if (item.category != null && !categoryMap.containsKey(item.category?.id)) {
        categoryMap[item.category!.id] = item.category!;
      }
    }
    return categoryMap.values.toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  Widget _buildMenuItemCard(MenuItem item) {
    final imageUrl = item.imageId != null
        ? '${AppConfig.apiBaseUrl.replaceAll('/api', '')}/media/${item.imageId}'
        : null;
    final discountPercent = item.discountPercent != null
        ? item.discountPercent!.round()
        : null;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: context.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showItemDetails(item),
        borderRadius: BorderRadius.circular(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 100,
                    height: 100,
                    color: context.grey100,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 100,
                    height: 100,
                    color: context.grey100,
                    child: Icon(
                      Icons.image_not_supported,
                      color: context.secondaryTextColor,
                    ),
                  ),
                ),
              )
            else
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: context.grey100,
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                ),
                child: Icon(
                  Icons.restaurant,
                  color: context.secondaryTextColor,
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
                            item.name,
                            style: AppTheme.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                              color: context.primaryTextColor,
                            ),
                          ),
                        ),
                        if (item.isPopular)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Popular',
                              style: AppTheme.bodySmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        if (item.isChefSpecial)
                          Container(
                            margin: const EdgeInsets.only(left: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: context.primaryColorTheme,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Chef\'s Special',
                              style: AppTheme.bodySmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (item.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.description!,
                        style: AppTheme.bodySmall.copyWith(
                          color: context.secondaryTextColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (item.dietaryTags.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 4,
                        children: item.dietaryTags.take(3).map((tag) {
                          return Chip(
                            label: Text(tag),
                            backgroundColor: context.grey100,
                            labelStyle: AppTheme.bodySmall.copyWith(
                              fontSize: 10,
                              color: context.primaryTextColor,
                            ),
                            padding: EdgeInsets.zero,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          );
                        }).toList(),
                      ),
                    ],
                    const Spacer(),
                    Row(
                      children: [
                        Text(
                          '${AppConfig.currencySymbol} ${item.price.toStringAsFixed(0)}',
                          style: AppTheme.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.primaryColorTheme,
                          ),
                        ),
                        if (item.compareAtPrice != null && item.compareAtPrice! > item.price) ...[
                          const SizedBox(width: 8),
                          Text(
                            '${AppConfig.currencySymbol} ${item.compareAtPrice!.toStringAsFixed(0)}',
                            style: AppTheme.bodySmall.copyWith(
                              color: context.secondaryTextColor,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          if (discountPercent != null) ...[
                            const SizedBox(width: 4),
                            Text(
                              '-$discountPercent%',
                              style: AppTheme.bodySmall.copyWith(
                                color: context.errorColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
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

  void _showItemDetails(MenuItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.name,
                    style: AppTheme.headlineSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.primaryTextColor,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            if (item.description != null) ...[
              const SizedBox(height: 16),
              Text(
                item.description!,
                style: AppTheme.bodyMedium.copyWith(
                  color: context.primaryTextColor,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  '${AppConfig.currencySymbol} ${item.price.toStringAsFixed(0)}',
                  style: AppTheme.headlineMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.primaryColorTheme,
                  ),
                ),
                if (item.compareAtPrice != null && item.compareAtPrice! > item.price) ...[
                  const SizedBox(width: 12),
                  Text(
                    '${AppConfig.currencySymbol} ${item.compareAtPrice!.toStringAsFixed(0)}',
                    style: AppTheme.bodyLarge.copyWith(
                      color: context.secondaryTextColor,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
              ],
            ),
            if (item.dietaryTags.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Dietary Information',
                style: AppTheme.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.primaryTextColor,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: item.dietaryTags.map((tag) {
                  return Chip(
                    label: Text(tag),
                    backgroundColor: context.grey100,
                  );
                }).toList(),
              ),
            ],
            if (item.allergens.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Allergens',
                style: AppTheme.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.primaryTextColor,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: item.allergens.map((allergen) {
                  return Chip(
                    label: Text(allergen),
                    backgroundColor: context.errorColor.withOpacity(0.1),
                    labelStyle: AppTheme.bodySmall.copyWith(
                      color: context.errorColor,
                    ),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: item.isAvailable && !_isAddingToCart
                    ? () => _addToCart(item)
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isAddingToCart
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        item.isAvailable ? 'Add to Cart' : 'Unavailable',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addToCart(MenuItem item) async {
    setState(() {
      _isAddingToCart = true;
    });

    try {
      final cartService = CartService();
      await cartService.addToCart(
        itemType: CartItemType.menuItem,
        menuItemId: item.id,
        quantity: 1,
      );

      if (mounted) {
        Navigator.pop(context); // Close item details
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Item added to cart'),
            backgroundColor: context.primaryColorTheme,
            action: SnackBarAction(
              label: 'View Cart',
              textColor: Colors.white,
              onPressed: () {
                context.push('/cart');
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add to cart: ${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: context.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAddingToCart = false;
        });
      }
    }
  }
}

