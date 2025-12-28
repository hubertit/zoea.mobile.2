import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/providers/bookings_provider.dart';

class BookingConfirmationScreen extends ConsumerWidget {
  final String bookingId;

  const BookingConfirmationScreen({
    super.key,
    required this.bookingId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingAsync = ref.watch(bookingByIdProvider(bookingId));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Booking Confirmation'),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 32),
          onPressed: () => context.pop(),
          style: IconButton.styleFrom(
            foregroundColor: AppTheme.primaryTextColor,
          ),
        ),
      ),
      body: bookingAsync.when(
        data: (booking) => _buildBookingDetails(context, booking),
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: AppTheme.primaryColor,
          ),
        ),
        error: (error, stack) => _buildErrorState(context, ref, error),
      ),
    );
  }

  Widget _buildBookingDetails(BuildContext context, Map<String, dynamic> booking) {
    final bookingType = booking['bookingType'] as String? ?? 'hotel';
    final bookingNumber = booking['bookingNumber'] as String? ?? booking['id'] as String? ?? '';
    final status = booking['status'] as String? ?? 'confirmed';
    final totalAmount = _parseNumericValue(booking['totalAmount']) ?? 0.0;
    final currency = booking['currency'] as String? ?? 'RWF';
    
    // Get listing information
    final listing = booking['listing'] as Map<String, dynamic>?;
    final listingName = listing?['name'] as String? ?? 'Unknown';
    final listingAddress = listing?['address'] as String?;
    final city = listing?['city'] as Map<String, dynamic>?;
    final cityName = city?['name'] as String?;
    final location = listingAddress != null && cityName != null
        ? '$listingAddress, $cityName'
        : listingAddress ?? cityName ?? 'Location not specified';
    
    // Get images
    final images = listing?['images'] as List?;
    Map<String, dynamic>? primaryImage;
    if (images != null && images.isNotEmpty) {
      final firstImage = images[0] as Map<String, dynamic>?;
      primaryImage = firstImage?['media'] as Map<String, dynamic>?;
    }
    final imageUrl = primaryImage?['url'] as String?;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Success Header
          _buildSuccessHeader(),
          const SizedBox(height: 32),
          
          // Booking Info Card
          _buildBookingInfoCard(
            bookingNumber: bookingNumber,
            status: status,
            bookingType: bookingType,
          ),
          const SizedBox(height: 20),
          
          // Listing Card
          _buildListingCard(
            name: listingName,
            location: location,
            imageUrl: imageUrl,
          ),
          const SizedBox(height: 20),
          
          // Booking Details Card
          _buildBookingDetailsCard(booking, bookingType),
          const SizedBox(height: 20),
          
          // Price Summary Card
          _buildPriceSummaryCard(
            booking: booking,
            totalAmount: totalAmount,
            currency: currency,
          ),
          const SizedBox(height: 20),
          
          // Action Buttons
          _buildActionButtons(context),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSuccessHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.successColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.successColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppTheme.successColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                size: 48,
                color: Colors.white,
              ),
            ),
          const SizedBox(height: 16),
          Text(
            'Booking Confirmed!',
            style: AppTheme.headlineSmall.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.successColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your booking has been confirmed successfully',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.secondaryTextColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBookingInfoCard({
    required String bookingNumber,
    required String status,
    required String bookingType,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Booking Information',
            style: AppTheme.headlineSmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Booking Number', bookingNumber),
          const SizedBox(height: 12),
          _buildInfoRow('Type', bookingType.toUpperCase()),
          const SizedBox(height: 12),
          _buildInfoRow(
            'Status',
            status.toUpperCase(),
            valueColor: _getStatusColor(status),
          ),
        ],
      ),
    );
  }

  Widget _buildListingCard({
    required String name,
    required String location,
    String? imageUrl,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[200],
                    child: const Icon(
                      Icons.image,
                      color: Colors.grey,
                    ),
                    ),
                  )
                : Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[200],
                    child: Icon(
                      Icons.business,
                      color: Colors.grey[400],
                    ),
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTheme.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 16,
                      color: AppTheme.secondaryTextColor,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location,
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.secondaryTextColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingDetailsCard(Map<String, dynamic> booking, String bookingType) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Booking Details',
            style: AppTheme.headlineSmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          if (bookingType == 'hotel') ...[
            if (booking['checkInDate'] != null)
              _buildInfoRow(
                'Check-in',
                _formatDate(booking['checkInDate'] as String),
              ),
            if (booking['checkInDate'] != null) const SizedBox(height: 12),
            if (booking['checkOutDate'] != null)
              _buildInfoRow(
                'Check-out',
                _formatDate(booking['checkOutDate'] as String),
              ),
            if (booking['checkOutDate'] != null) const SizedBox(height: 12),
            if (booking['guestCount'] != null)
              _buildInfoRow(
                'Guests',
                '${booking['guestCount']}',
              ),
          ] else if (bookingType == 'restaurant') ...[
            if (booking['bookingDate'] != null)
              _buildInfoRow(
                'Date',
                _formatDate(booking['bookingDate'] as String),
              ),
            if (booking['bookingDate'] != null) const SizedBox(height: 12),
            if (booking['bookingTime'] != null)
              _buildInfoRow(
                'Time',
                _formatTime(booking['bookingTime'] as String),
              ),
            if (booking['bookingTime'] != null) const SizedBox(height: 12),
            if (booking['partySize'] != null)
              _buildInfoRow(
                'Party Size',
                '${booking['partySize']}',
              ),
          ],
          if (booking['specialRequests'] != null &&
              (booking['specialRequests'] as String).isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              'Special Requests',
              booking['specialRequests'] as String,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPriceSummaryCard({
    required Map<String, dynamic> booking,
    required double totalAmount,
    required String currency,
  }) {
    final subtotal = _parseNumericValue(booking['subtotal']);
    final taxAmount = _parseNumericValue(booking['taxAmount']);
    final discountAmount = _parseNumericValue(booking['discountAmount']);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Price Summary',
            style: AppTheme.headlineSmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          if (subtotal != null) ...[
            _buildPriceRow('Subtotal', subtotal, currency),
            const SizedBox(height: 8),
          ],
          if (taxAmount != null) ...[
            _buildPriceRow('Taxes & Fees', taxAmount, currency),
            const SizedBox(height: 8),
          ],
          if (discountAmount != null && discountAmount > 0) ...[
            _buildPriceRow('Discount', -discountAmount, currency, isDiscount: true),
            const SizedBox(height: 8),
          ],
          const Divider(height: 24),
          _buildPriceRow(
            'Total',
            totalAmount,
            currency,
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => context.go('/profile/my-bookings'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'View My Bookings',
              style: AppTheme.bodyMedium.copyWith(
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
            onPressed: () => context.go('/explore'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: AppTheme.primaryColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Continue Exploring',
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.errorColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load booking',
              style: AppTheme.titleLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString().replaceAll('Exception: ', ''),
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.secondaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(bookingByIdProvider(bookingId));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '$label:',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.secondaryTextColor,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTheme.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(
    String label,
    double amount,
    String currency, {
    bool isDiscount = false,
    bool isTotal = false,
  }) {
    final formattedAmount = _formatCurrency(amount.abs(), currency);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTheme.bodyMedium.copyWith(
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
            color: isDiscount ? AppTheme.successColor : AppTheme.primaryTextColor,
          ),
        ),
        Text(
          '${isDiscount ? '-' : ''}$formattedAmount',
          style: AppTheme.bodyMedium.copyWith(
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
            color: isDiscount
                ? AppTheme.successColor
                : isTotal
                    ? AppTheme.primaryColor
                    : AppTheme.primaryTextColor,
          ),
        ),
      ],
    );
  }

  /// Safely parse numeric values that can come as either String or num from API
  double? _parseNumericValue(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      return parsed;
    }
    return null;
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  String _formatTime(String timeString) {
    try {
      // Handle 24-hour format (e.g., "19:00")
      if (timeString.contains(':')) {
        final parts = timeString.split(':');
        final hour = int.parse(parts[0]);
        final minute = parts[1];
        final period = hour >= 12 ? 'PM' : 'AM';
        final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
        return '$displayHour:${minute.padLeft(2, '0')} $period';
      }
      return timeString;
    } catch (e) {
      return timeString;
    }
  }

  String _formatCurrency(double amount, String currency) {
    final formatted = amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    return '$currency $formatted';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return AppTheme.successColor;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return AppTheme.errorColor;
      case 'completed':
        return AppTheme.primaryColor;
      default:
        return AppTheme.secondaryTextColor;
    }
  }
}
