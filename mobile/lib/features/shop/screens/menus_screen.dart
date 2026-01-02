import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/theme/text_theme_extensions.dart';
import '../../../core/providers/menus_provider.dart';
import '../../../core/models/menu.dart';
import 'menu_detail_screen.dart';

class MenusScreen extends ConsumerStatefulWidget {
  final String listingId;

  const MenusScreen({
    super.key,
    required this.listingId,
  });

  @override
  ConsumerState<MenusScreen> createState() => _MenusScreenState();
}

class _MenusScreenState extends ConsumerState<MenusScreen> {
  Menu? _selectedMenu;

  @override
  Widget build(BuildContext context) {
    final menusAsync = ref.watch(menusByListingProvider(widget.listingId));

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
          'Menu',
          style: context.headlineMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: context.primaryTextColor,
          ),
        ),
      ),
      body: menusAsync.when(
        data: (menus) {
          if (menus.isEmpty) {
            return _buildEmptyState();
          }

          // If only one menu, show it directly
          if (menus.length == 1) {
            return MenuDetailScreen(menuId: menus[0].id);
          }

          // If multiple menus, show menu selector
          _selectedMenu ??= menus.firstWhere(
            (m) => m.isDefault,
            orElse: () => menus.first,
          );

          return Column(
            children: [
              if (menus.length > 1)
                Container(
                  height: 60,
                  color: context.cardColor,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: menus.length,
                    itemBuilder: (context, index) {
                      final menu = menus[index];
                      final isSelected = _selectedMenu?.id == menu.id;
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: ChoiceChip(
                          label: Text(menu.name),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedMenu = menu;
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
              Expanded(
                child: _selectedMenu != null
                    ? MenuDetailScreen(menuId: _selectedMenu!.id)
                    : const SizedBox(),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(error),
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
              Icons.restaurant_menu_outlined,
              size: 64,
              color: context.secondaryTextColor,
            ),
            const SizedBox(height: 16),
            Text(
              'No menu available',
              style: context.headlineSmall.copyWith(
                color: context.primaryTextColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This restaurant hasn\'t added a menu yet',
              style: context.bodyMedium.copyWith(
                color: context.secondaryTextColor,
              ),
              textAlign: TextAlign.center,
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
              'Failed to load menu',
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
                ref.invalidate(menusByListingProvider(widget.listingId));
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

