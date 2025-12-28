import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/categories_service.dart';

final categoriesServiceProvider = Provider<CategoriesService>((ref) {
  return CategoriesService();
});

/// Provider for all categories
final categoriesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final categoriesService = ref.watch(categoriesServiceProvider);
  return await categoriesService.getCategories();
});

/// Provider for a single category by ID
final categoryByIdProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, categoryId) async {
  final categoriesService = ref.watch(categoriesServiceProvider);
  return await categoriesService.getCategoryById(categoryId);
});

/// Provider for a category by slug
final categoryBySlugProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, slug) async {
  final categoriesService = ref.watch(categoriesServiceProvider);
  return await categoriesService.getCategoryBySlug(slug);
});

/// Provider for subcategories of a parent category
final subcategoriesProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, parentId) async {
  final categoriesService = ref.watch(categoriesServiceProvider);
  return await categoriesService.getSubcategories(parentId);
});

