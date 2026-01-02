import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/theme/text_theme_extensions.dart';

class DiningBookingConfirmationScreen extends ConsumerStatefulWidget {
  final String? bookingId;
  final String? bookingNumber;
  final String placeName;
  final String placeLocation;
  final DateTime? date;
  final String time;
  final int guests;
  final String fullName;
  final String phone;
  final String email;
  final String specialRequests;

  const DiningBookingConfirmationScreen({
    super.key,
    this.bookingId,
    this.bookingNumber,
    required this.placeName,
    required this.placeLocation,
    this.date,
    required this.time,
    required this.guests,
    required this.fullName,
    required this.phone,
    required this.email,
    required this.specialRequests,
  });

  @override
  ConsumerState<DiningBookingConfirmationScreen> createState() => _DiningBookingConfirmationScreenState();
}

class _DiningBookingConfirmationScreenState extends ConsumerState<DiningBookingConfirmationScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: context.backgroundColor,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.chevron_left, size: 32),
          style: IconButton.styleFrom(
            foregroundColor: context.primaryTextColor,
          ),
        ),
        title: Text(
          'Booking Confirmation',
          style: context.headlineMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: context.primaryTextColor,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Success Header
            _buildSuccessHeader(),
            const SizedBox(height: 24),
            
            // Booking Details
            _buildBookingDetails(),
            const SizedBox(height: 24),
            
            // Restaurant Info
            _buildRestaurantInfo(),
            const SizedBox(height: 24),
            
            // Guest Information
            _buildGuestInfo(),
            const SizedBox(height: 24),
            
            // Special Requests
            if (widget.specialRequests.isNotEmpty) ...[
              _buildSpecialRequests(),
              const SizedBox(height: 24),
            ],
            
            // Important Notes
            _buildImportantNotes(),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildSuccessHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.successColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.successColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.check_circle,
            size: 64,
            color: context.successColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Reservation Confirmed!',
            style: context.headlineMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: context.successColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your table has been reserved successfully',
            style: context.bodyMedium.copyWith(
              color: context.secondaryTextColor,
            ),
            textAlign: TextAlign.center,
          ),
          if (widget.bookingNumber != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: context.backgroundColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: context.successColor.withOpacity(0.3)),
              ),
              child: Text(
                'Booking #${widget.bookingNumber}',
                style: context.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.successColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBookingDetails() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reservation Details',
            style: context.headlineSmall.copyWith(
              fontWeight: FontWeight.w600,
              color: context.primaryTextColor,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            icon: Icons.calendar_today,
            label: 'Date',
            value: widget.date != null 
                ? '${widget.date!.day}/${widget.date!.month}/${widget.date!.year}'
                : 'Not specified',
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            icon: Icons.access_time,
            label: 'Time',
            value: widget.time,
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            icon: Icons.people,
            label: 'Guests',
            value: '${widget.guests} ${widget.guests == 1 ? 'person' : 'people'}',
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Restaurant Information',
            style: context.headlineSmall.copyWith(
              fontWeight: FontWeight.w600,
              color: context.primaryTextColor,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            icon: Icons.restaurant,
            label: 'Restaurant',
            value: widget.placeName,
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            icon: Icons.location_on,
            label: 'Location',
            value: widget.placeLocation,
          ),
        ],
      ),
    );
  }

  Widget _buildGuestInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Guest Information',
            style: context.headlineSmall.copyWith(
              fontWeight: FontWeight.w600,
              color: context.primaryTextColor,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            icon: Icons.person,
            label: 'Name',
            value: widget.fullName,
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            icon: Icons.phone,
            label: 'Phone',
            value: widget.phone,
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            icon: Icons.email,
            label: 'Email',
            value: widget.email,
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialRequests() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Special Requests',
            style: context.headlineSmall.copyWith(
              fontWeight: FontWeight.w600,
              color: context.primaryTextColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.specialRequests,
            style: context.bodyMedium.copyWith(
              color: context.primaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImportantNotes() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.blue[700],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Important Information',
                style: context.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '• Please arrive 5-10 minutes before your reservation time\n'
            '• If you need to cancel or modify your reservation, please call the restaurant directly\n'
            '• Late arrivals may result in table forfeiture\n'
            '• Dress code may apply - please check with the restaurant',
            style: context.bodySmall.copyWith(
              color: Colors.blue[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: context.primaryColorTheme,
        ),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: context.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: context.secondaryTextColor,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: context.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
              color: context.primaryTextColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.backgroundColor,
        border: Border(
          top: BorderSide(color: Colors.grey[200]!),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => context.go('/explore'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.primaryColorTheme,
                  side: BorderSide(color: context.primaryColorTheme),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Browse More',
                  style: context.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.primaryTextColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _isLoading ? null : _viewMyBookings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.primaryColorTheme,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'View My Bookings',
                        style: context.bodyMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _viewMyBookings() {
    setState(() {
      _isLoading = true;
    });

    // Simulate loading
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
      });
      context.go('/my-bookings');
    });
  }
}
