import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/theme/text_theme_extensions.dart';
import '../../../core/providers/cart_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/orders_service.dart';
import '../../../core/models/order.dart';
import '../../../core/models/cart.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  final String? listingId;

  const CheckoutScreen({
    super.key,
    this.listingId,
  });

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _notesController = TextEditingController();

  FulfillmentType _fulfillmentType = FulfillmentType.pickup;
  DateTime? _deliveryDate;
  String? _deliveryTimeSlot;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _prefillUserData();
  }

  void _prefillUserData() {
    final user = ref.read(currentUserProvider);
    if (user != null) {
      _nameController.text = user.fullName;
      _emailController.text = user.email;
      _phoneController.text = user.phoneNumber ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartAsync = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: context.grey50,
      appBar: AppBar(
        backgroundColor: context.backgroundColor,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(
            Icons.chevron_left,
            size: 32,
            color: context.primaryTextColor,
          ),
        ),
        title: Text(
          'Checkout',
          style: context.headlineMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: context.primaryTextColor,
          ),
        ),
      ),
      body: cartAsync.when(
        data: (cart) {
          if (cart.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 64,
                    color: context.secondaryTextColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your cart is empty',
                    style: context.titleMedium.copyWith(
                      color: context.primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: const Text('Continue Shopping'),
                  ),
                ],
              ),
            );
          }

          // Get listing ID from first cart item or widget parameter
          String? listingId = widget.listingId;
          
          if (listingId == null && cart.items.isNotEmpty) {
            final firstItem = cart.items.first;
            listingId = firstItem.product?['listingId'] as String? ??
                firstItem.service?['listingId'] as String? ??
                firstItem.menuItem?['listingId'] as String?;
          }

          if (listingId == null) {
            return Center(
              child: Text(
                'Unable to determine listing',
                style: context.bodyMedium.copyWith(
                  color: context.errorColor,
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order Summary
                  _buildOrderSummary(cart),
                  const SizedBox(height: 24),
                  
                  // Fulfillment Type
                  _buildFulfillmentTypeSection(),
                  const SizedBox(height: 24),
                  
                  // Delivery Address (if delivery selected)
                  if (_fulfillmentType == FulfillmentType.delivery) ...[
                    _buildDeliveryAddressSection(),
                    const SizedBox(height: 24),
                  ],
                  
                  // Customer Information
                  _buildCustomerInfoSection(),
                  const SizedBox(height: 24),
                  
                  // Special Notes
                  _buildNotesSection(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
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
                'Failed to load cart',
                style: context.titleMedium.copyWith(
                  color: context.errorColor,
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  ref.invalidate(cartProvider);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(cartAsync.valueOrNull),
    );
  }

  Widget _buildOrderSummary(Cart cart) {
    final subtotal = cart.totalAmount;
    final shipping = _fulfillmentType == FulfillmentType.delivery ? 2000.0 : 0.0;
    final tax = subtotal * 0.18; // 18% VAT
    final total = subtotal + shipping + tax;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: context.isDarkMode 
                ? Colors.black.withOpacity(0.3) 
                : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: context.titleLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: context.primaryTextColor,
            ),
          ),
          const SizedBox(height: 16),
          // Items List
          ...cart.items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.itemName,
                        style: context.bodyMedium.copyWith(
                          fontWeight: FontWeight.w500,
                          color: context.primaryTextColor,
                        ),
                      ),
                      Text(
                        'Qty: ${item.quantity}',
                        style: context.bodySmall.copyWith(
                          color: context.secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${item.currency} ${item.totalPrice.toStringAsFixed(0)}',
                  style: context.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.primaryTextColor,
                  ),
                ),
              ],
            ),
          )),
          const Divider(height: 24),
          // Price Breakdown
          _buildPriceRow('Subtotal', subtotal, cart.items.first.currency),
          const SizedBox(height: 8),
          _buildPriceRow('Tax (18%)', tax, cart.items.first.currency),
          if (shipping > 0) ...[
            const SizedBox(height: 8),
            _buildPriceRow('Shipping', shipping, cart.items.first.currency),
          ],
          const Divider(height: 24),
          _buildPriceRow(
            'Total',
            total,
            cart.items.first.currency,
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, String currency, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? context.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: context.primaryTextColor,
                )
              : context.bodyMedium.copyWith(
                  color: context.secondaryTextColor,
                ),
        ),
        Text(
          '$currency ${amount.toStringAsFixed(0)}',
          style: isTotal
              ? context.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: context.primaryColorTheme,
                )
              : context.bodyMedium.copyWith(
                  color: context.primaryTextColor,
                ),
        ),
      ],
    );
  }

  Widget _buildFulfillmentTypeSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Delivery Method',
            style: context.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: context.primaryTextColor,
            ),
          ),
          const SizedBox(height: 16),
          RadioListTile<FulfillmentType>(
            title: const Text('Pickup'),
            subtitle: const Text('Collect from store'),
            value: FulfillmentType.pickup,
            groupValue: _fulfillmentType,
            onChanged: (value) {
              setState(() {
                _fulfillmentType = value!;
                _deliveryDate = null;
                _deliveryTimeSlot = null;
              });
            },
            activeColor: context.primaryColorTheme,
          ),
          RadioListTile<FulfillmentType>(
            title: const Text('Delivery'),
            subtitle: const Text('Delivered to your address'),
            value: FulfillmentType.delivery,
            groupValue: _fulfillmentType,
            onChanged: (value) {
              setState(() {
                _fulfillmentType = value!;
              });
            },
            activeColor: context.primaryColorTheme,
          ),
          RadioListTile<FulfillmentType>(
            title: const Text('Dine In'),
            subtitle: const Text('Eat at the restaurant'),
            value: FulfillmentType.dineIn,
            groupValue: _fulfillmentType,
            onChanged: (value) {
              setState(() {
                _fulfillmentType = value!;
                _deliveryDate = null;
                _deliveryTimeSlot = null;
              });
            },
            activeColor: context.primaryColorTheme,
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryAddressSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Delivery Address',
            style: context.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: context.primaryTextColor,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _addressController,
            decoration: InputDecoration(
              labelText: 'Street Address',
              hintText: 'Enter your street address',
              prefixIcon: const Icon(Icons.location_on),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (_fulfillmentType == FulfillmentType.delivery && 
                  (value == null || value.trim().isEmpty)) {
                return 'Please enter your delivery address';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _cityController,
            decoration: InputDecoration(
              labelText: 'City',
              hintText: 'Enter your city',
              prefixIcon: const Icon(Icons.location_city),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (_fulfillmentType == FulfillmentType.delivery && 
                  (value == null || value.trim().isEmpty)) {
                return 'Please enter your city';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contact Information',
            style: context.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: context.primaryTextColor,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Full Name',
              hintText: 'Enter your full name',
              prefixIcon: const Icon(Icons.person),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email (Optional)',
              hintText: 'Enter your email',
              prefixIcon: const Icon(Icons.email),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: 'Phone Number',
              hintText: 'Enter your phone number',
              prefixIcon: const Icon(Icons.phone),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your phone number';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Special Instructions (Optional)',
            style: context.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: context.primaryTextColor,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _notesController,
            decoration: InputDecoration(
              hintText: 'Add any special instructions for your order...',
              prefixIcon: const Icon(Icons.note),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(Cart? cart) {
    if (cart == null || cart.items.isEmpty) {
      return const SizedBox.shrink();
    }

    final subtotal = cart.totalAmount;
    final shipping = _fulfillmentType == FulfillmentType.delivery ? 2000.0 : 0.0;
    final tax = subtotal * 0.18;
    final total = subtotal + shipping + tax;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: context.isDarkMode 
                ? Colors.black.withOpacity(0.3) 
                : Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: context.titleLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.primaryTextColor,
                  ),
                ),
                Text(
                  '${cart.items.first.currency} ${total.toStringAsFixed(0)}',
                  style: context.titleLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: context.primaryColorTheme,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _placeOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.primaryColorTheme,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Place Order',
                        style: context.titleMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final cart = ref.read(cartProvider).valueOrNull;
    if (cart == null || cart.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Your cart is empty'),
          backgroundColor: context.errorColor,
        ),
      );
      return;
    }

    // Get listing ID
    String? listingId = widget.listingId;
    
    if (listingId == null && cart.items.isNotEmpty) {
      listingId = cart.items.first.product?['listingId'] as String? ??
          cart.items.first.service?['listingId'] as String? ??
          cart.items.first.menuItem?['listingId'] as String?;
    }

    if (listingId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Unable to determine listing'),
          backgroundColor: context.errorColor,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final ordersService = OrdersService();
      
      // Prepare delivery address if needed
      Map<String, dynamic>? deliveryAddress;
      if (_fulfillmentType == FulfillmentType.delivery) {
        deliveryAddress = {
          'street': _addressController.text.trim(),
          'city': _cityController.text.trim(),
        };
      }

      // Calculate totals
      final subtotal = cart.totalAmount;
      final shipping = _fulfillmentType == FulfillmentType.delivery ? 2000.0 : 0.0;
      final tax = subtotal * 0.18;

      final order = await ordersService.createOrder(
        listingId: listingId,
        fulfillmentType: _fulfillmentType,
        deliveryAddress: deliveryAddress,
        pickupLocation: _fulfillmentType == FulfillmentType.pickup 
            ? 'Store pickup' 
            : null,
        deliveryDate: _deliveryDate,
        deliveryTimeSlot: _deliveryTimeSlot,
        customerName: _nameController.text.trim(),
        customerEmail: _emailController.text.trim().isNotEmpty 
            ? _emailController.text.trim() 
            : null,
        customerPhone: _phoneController.text.trim(),
        customerNotes: _notesController.text.trim().isNotEmpty 
            ? _notesController.text.trim() 
            : null,
        taxAmount: tax,
        shippingAmount: shipping,
      );

      // Clear cart
      ref.invalidate(cartProvider);

      // Navigate to order confirmation
      if (mounted) {
        context.pushReplacement('/order-confirmation/${order.id}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to place order: ${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: context.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}

