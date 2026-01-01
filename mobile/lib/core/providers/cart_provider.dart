import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/cart_service.dart';
import '../models/cart.dart';

final cartServiceProvider = Provider<CartService>((ref) {
  return CartService();
});

/// Provider for cart
final cartProvider = FutureProvider<Cart>((ref) async {
  final cartService = ref.watch(cartServiceProvider);
  return await cartService.getCart();
});

