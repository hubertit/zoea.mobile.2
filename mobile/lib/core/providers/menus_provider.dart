import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/menus_service.dart';
import '../models/menu.dart';

final menusServiceProvider = Provider<MenusService>((ref) {
  return MenusService();
});

/// Provider for menus by listing
final menusByListingProvider = FutureProvider.family<List<Menu>, String>((ref, listingId) async {
  final menusService = ref.watch(menusServiceProvider);
  return await menusService.getMenus(listingId: listingId, isActive: true);
});

/// Provider for single menu by ID
final menuByIdProvider = FutureProvider.family<Menu, String>((ref, menuId) async {
  final menusService = ref.watch(menusServiceProvider);
  return await menusService.getMenuById(menuId);
});

/// Provider for all menu categories
final menuCategoriesProvider = FutureProvider<List<MenuCategory>>((ref) async {
  final menusService = ref.watch(menusServiceProvider);
  return await menusService.getCategories();
});

