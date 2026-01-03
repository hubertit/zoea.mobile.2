import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/theme/text_theme_extensions.dart';
import '../../../core/providers/orders_provider.dart';

class OrderConfirmationScreen extends ConsumerWidget {
  final String orderId;

  const OrderConfirmationScreen({
    super.key,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderByIdProvider(orderId));

    return Scaffold(
      backgroundColor: context.grey50,
      appBar: AppBar(
        backgroundColor: context.backgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => context.go('/profile'),
            icon: Icon(
              Icons.close,
              color: context.primaryTextColor,
            ),
          ),
        ],
      ),
      body: orderAsync.when(
        data: (orderData) {
          final order = orderData as Map<String, dynamic>;
          final orderNumber = order['orderNumber'] as String? ?? order['order_number'] as String?;
          final status = order['status'] as String? ?? 'pending';
          final totalAmount = (order['totalAmount'] ?? order['total_amount'] ?? 0).toDouble();
          final currency = order['currency'] as String? ?? 'RWF';
          final listing = order['listing'] as Map<String, dynamic>?;
          final listingName = listing?['name'] as String? ?? 'Unknown';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // Success Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: context.successColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    size: 48,
                    color: context.successColor,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Success Message
                Text(
                  'Order Placed Successfully!',
                  style: context.headlineMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: context.primaryTextColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Your order has been received and is being processed',
                  style: context.bodyMedium.copyWith(
                    color: context.secondaryTextColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                
                // Order Details Card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: context.cardColor,
                    borderRadius: BorderRadius.circular(16),
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
                        'Order Details',
                        style: context.titleLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color: context.primaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDetailRow(
                        context,
                        'Order Number',
                        orderNumber ?? 'N/A',
                        Icons.receipt,
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        context,
                        'Merchant',
                        listingName,
                        Icons.store,
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        context,
                        'Status',
                        status.toUpperCase(),
                        Icons.info,
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        context,
                        'Total Amount',
                        '$currency ${totalAmount.toStringAsFixed(0)}',
                        Icons.payments,
                        isAmount: true,
                      ),
                      if (order['createdAt'] != null || order['created_at'] != null) ...[
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          context,
                          'Order Date',
                          DateFormat('MMM dd, yyyy HH:mm').format(
                            DateTime.parse(
                              order['createdAt'] as String? ?? order['created_at'] as String,
                            ),
                          ),
                          Icons.calendar_today,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Action Buttons
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      context.go('/profile');
                    },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'View My Orders',
                      style: context.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      context.go('/explore');
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: context.primaryColorTheme,
                      side: BorderSide(color: context.primaryColorTheme),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Continue Shopping',
                      style: context.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.primaryColorTheme,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => Center(child: CircularProgressIndicator(color: context.primaryColorTheme)),
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
                'Failed to load order details',
                style: context.titleMedium.copyWith(
                  color: context.errorColor,
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  ref.invalidate(orderByIdProvider(orderId));
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    bool isAmount = false,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: context.secondaryTextColor,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: context.bodySmall.copyWith(
                  color: context.secondaryTextColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: isAmount
                    ? context.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: context.primaryColorTheme,
                      )
                    : context.bodyMedium.copyWith(
                        fontWeight: FontWeight.w500,
                        color: context.primaryTextColor,
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

