import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/products_service.dart';
import '../models/product.dart';

final productsServiceProvider = Provider<ProductsService>((ref) {
  return ProductsService();
});

/// Parameters for products query
class ProductsParams {
  final int? page;
  final int? limit;
  final String? listingId;
  final String? status;
  final String? search;
  final String? category;
  final double? minPrice;
  final double? maxPrice;
  final bool? isFeatured;
  final String? sortBy;

  const ProductsParams({
    this.page,
    this.limit,
    this.listingId,
    this.status,
    this.search,
    this.category,
    this.minPrice,
    this.maxPrice,
    this.isFeatured,
    this.sortBy,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductsParams &&
          runtimeType == other.runtimeType &&
          page == other.page &&
          limit == other.limit &&
          listingId == other.listingId &&
          status == other.status &&
          search == other.search &&
          category == other.category &&
          minPrice == other.minPrice &&
          maxPrice == other.maxPrice &&
          isFeatured == other.isFeatured &&
          sortBy == other.sortBy;

  @override
  int get hashCode =>
      page.hashCode ^
      limit.hashCode ^
      listingId.hashCode ^
      status.hashCode ^
      search.hashCode ^
      category.hashCode ^
      minPrice.hashCode ^
      maxPrice.hashCode ^
      isFeatured.hashCode ^
      sortBy.hashCode;
}

/// Provider for all products with pagination
final productsProvider = FutureProvider.family<Map<String, dynamic>, ProductsParams>((ref, params) async {
  final productsService = ref.watch(productsServiceProvider);
  return await productsService.getProducts(
    page: params.page,
    limit: params.limit,
    listingId: params.listingId,
    status: params.status,
    search: params.search,
    category: params.category,
    minPrice: params.minPrice,
    maxPrice: params.maxPrice,
    isFeatured: params.isFeatured,
    sortBy: params.sortBy,
  );
});

/// Provider for products by listing
final productsByListingProvider = FutureProvider.family<Map<String, dynamic>, ProductsParams>((ref, params) async {
  if (params.listingId == null) {
    throw Exception('listingId is required');
  }
  final productsService = ref.watch(productsServiceProvider);
  return await productsService.getProductsByListing(
    listingId: params.listingId!,
    page: params.page,
    limit: params.limit,
    status: params.status,
    search: params.search,
    category: params.category,
    sortBy: params.sortBy,
  );
});

/// Provider for single product by ID
final productByIdProvider = FutureProvider.family<Product, String>((ref, productId) async {
  final productsService = ref.watch(productsServiceProvider);
  return await productsService.getProductById(productId);
});

