import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/services/bookings_service.dart';
import '../../../core/providers/auth_provider.dart';

class DiningBookingScreen extends ConsumerStatefulWidget {
  final String placeId;
  final String placeName;
  final String placeLocation;
  final String placeImage;
  final double placeRating;
  final String priceRange;

  const DiningBookingScreen({
    super.key,
    required this.placeId,
    required this.placeName,
    required this.placeLocation,
    required this.placeImage,
    required this.placeRating,
    required this.priceRange,
  });

  @override
  ConsumerState<DiningBookingScreen> createState() => _DiningBookingScreenState();
}

class _DiningBookingScreenState extends ConsumerState<DiningBookingScreen> {
  DateTime? _selectedDate;
  String? _selectedTimeSlot;
  int _guestCount = 2;
  String _specialRequests = '';
  String _contactNumber = '';
  String _email = '';
  String _fullName = '';
  String _couponCode = '';
  double _discountAmount = 0.0;
  bool _isCouponApplied = false;
  bool _isLoading = false;
  
  final BookingsService _bookingsService = BookingsService();
  
  // Text controllers for pre-filling
  late TextEditingController _fullNameController;
  late TextEditingController _contactNumberController;
  late TextEditingController _emailController;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize controllers (will be populated after first build)
    _fullNameController = TextEditingController();
    _contactNumberController = TextEditingController();
    _emailController = TextEditingController();
  }
  
  void _prefillUserData() {
    // Get current user and pre-fill fields
    final currentUser = ref.read(currentUserProvider);
    if (currentUser != null) {
      _fullName = currentUser.fullName;
      _contactNumber = currentUser.phoneNumber ?? '';
      _email = currentUser.email;
      
      // Update controllers
      _fullNameController.text = _fullName;
      _contactNumberController.text = _contactNumber;
      _emailController.text = _email;
    }
  }
  
  @override
  void dispose() {
    _fullNameController.dispose();
    _contactNumberController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Pre-fill user data on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_fullName.isEmpty && _email.isEmpty) {
        _prefillUserData();
      }
    });
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.chevron_left, size: 32),
          style: IconButton.styleFrom(
            foregroundColor: AppTheme.primaryTextColor,
          ),
        ),
        title: Text(
          'Book Table',
          style: AppTheme.headlineMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Place Info Card
            _buildPlaceInfoCard(),
            const SizedBox(height: 24),
            
            // Booking Details
            _buildBookingDetailsSection(),
            const SizedBox(height: 24),
            
            // Guest Count
            _buildGuestSelection(),
            const SizedBox(height: 24),
            
            // Contact Information
            _buildContactSection(),
            const SizedBox(height: 24),
            
            // Special Requests
            _buildSpecialRequests(),
            const SizedBox(height: 24),
            
            // Coupon Code
            _buildCouponSection(),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildPlaceInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
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
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              widget.placeImage,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[200],
                  child: Icon(
                    Icons.restaurant,
                    color: Colors.grey[400],
                    size: 40,
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.placeName,
                  style: AppTheme.headlineSmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: AppTheme.secondaryTextColor,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.placeLocation,
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.secondaryTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      size: 16,
                      color: Colors.amber[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.placeRating.toString(),
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.priceRange,
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.secondaryTextColor,
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

  Widget _buildBookingDetailsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
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
            style: AppTheme.headlineSmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildDateField(
            label: 'Date',
            date: _selectedDate,
            onTap: () => _selectDate(),
          ),
          if (_selectedDate != null) ...[
            const SizedBox(height: 16),
            _buildTimeSlotsSection(),
          ],
        ],
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.secondaryTextColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              date != null
                  ? '${date.day}/${date.month}/${date.year}'
                  : 'Select date',
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlotsSection() {
    final timeSlots = _getAvailableTimeSlots();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Times',
          style: AppTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.secondaryTextColor,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: timeSlots.map((slot) {
            final isSelected = _selectedTimeSlot == slot['time'];
            final isAvailable = slot['available'] as bool;
            
            return GestureDetector(
              onTap: isAvailable ? () {
                setState(() {
                  _selectedTimeSlot = slot['time'] as String;
                });
              } : null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppTheme.primaryColor 
                      : isAvailable 
                          ? Colors.grey[100] 
                          : Colors.grey[50],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected 
                        ? AppTheme.primaryColor 
                        : isAvailable 
                            ? Colors.grey[300]! 
                            : Colors.grey[200]!,
                  ),
                ),
                child: Text(
                  slot['time'] as String,
                  style: AppTheme.bodySmall.copyWith(
                    color: isSelected 
                        ? Colors.white 
                        : isAvailable 
                            ? AppTheme.primaryTextColor 
                            : Colors.grey[400],
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildGuestSelection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
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
            'Number of Guests',
            style: AppTheme.headlineSmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              IconButton(
                onPressed: _guestCount > 1 ? () => setState(() => _guestCount--) : null,
                icon: const Icon(Icons.remove),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey[100],
                  foregroundColor: _guestCount > 1 ? AppTheme.primaryTextColor : Colors.grey[400],
                ),
              ),
              const SizedBox(width: 16),
              Text(
                _guestCount.toString(),
                style: AppTheme.headlineMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                onPressed: _guestCount < 20 ? () => setState(() => _guestCount++) : null,
                icon: const Icon(Icons.add),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey[100],
                  foregroundColor: _guestCount < 20 ? AppTheme.primaryTextColor : Colors.grey[400],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
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
            style: AppTheme.headlineSmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _fullNameController,
            onChanged: (value) => setState(() => _fullName = value),
            decoration: InputDecoration(
              labelText: 'Full Name',
              hintText: 'John Doe',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppTheme.primaryColor),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _contactNumberController,
            onChanged: (value) => setState(() => _contactNumber = value),
            decoration: InputDecoration(
              labelText: 'Phone Number',
              hintText: '+250 788 123 456',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppTheme.primaryColor),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _emailController,
            onChanged: (value) => setState(() => _email = value),
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email Address',
              hintText: 'your.email@example.com',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppTheme.primaryColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialRequests() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
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
            style: AppTheme.headlineSmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            onChanged: (value) => setState(() => _specialRequests = value),
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Any special dietary requirements, seating preferences, etc.',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppTheme.primaryColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
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
          Row(
            children: [
              Icon(
                Icons.local_offer,
                color: AppTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Coupon Code',
                style: AppTheme.headlineSmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _couponCode = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter coupon code',
                    hintStyle: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.secondaryTextColor,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppTheme.primaryColor),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _couponCode.isNotEmpty ? _applyCoupon : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _couponCode.isNotEmpty 
                      ? AppTheme.primaryColor 
                      : Colors.grey[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                child: Text(
                  'Apply',
                  style: AppTheme.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (_isCouponApplied) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.successColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.successColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: AppTheme.successColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Coupon Applied!',
                          style: AppTheme.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.successColor,
                          ),
                        ),
                        Text(
                          'You saved RWF ${_discountAmount.toStringAsFixed(0)}',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.successColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _removeCoupon,
                    icon: Icon(
                      Icons.close,
                      color: AppTheme.successColor,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final canBook = _selectedDate != null && 
                    _selectedTimeSlot != null && 
                    _fullName.isNotEmpty &&
                    _contactNumber.isNotEmpty && 
                    _email.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.secondaryTextColor,
                    ),
                  ),
                  Text(
                    'RWF ${_calculateTotalPrice().toStringAsFixed(0)}',
                    style: AppTheme.headlineSmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: canBook ? _confirmBooking : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: canBook ? AppTheme.primaryColor : Colors.grey[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Confirm Booking',
                  style: AppTheme.bodyMedium.copyWith(
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

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  List<Map<String, dynamic>> _getAvailableTimeSlots() {
    // Mock available time slots - in real app, this would come from the restaurant's API
    return [
      {'time': '12:00 PM', 'available': true},
      {'time': '12:30 PM', 'available': true},
      {'time': '1:00 PM', 'available': false},
      {'time': '1:30 PM', 'available': true},
      {'time': '2:00 PM', 'available': true},
      {'time': '2:30 PM', 'available': false},
      {'time': '6:00 PM', 'available': true},
      {'time': '6:30 PM', 'available': true},
      {'time': '7:00 PM', 'available': true},
      {'time': '7:30 PM', 'available': false},
      {'time': '8:00 PM', 'available': true},
      {'time': '8:30 PM', 'available': true},
      {'time': '9:00 PM', 'available': true},
      {'time': '9:30 PM', 'available': false},
      {'time': '10:00 PM', 'available': true},
    ];
  }

  void _applyCoupon() {
    // Mock coupon validation
    final validCoupons = {
      'DINE10': 0.10, // 10% discount
      'SAVE20': 0.20, // 20% discount
      'FIRST15': 0.15, // 15% discount
    };

    if (validCoupons.containsKey(_couponCode.toUpperCase())) {
      setState(() {
        _isCouponApplied = true;
        _discountAmount = _calculateBasePrice() * validCoupons[_couponCode.toUpperCase()]!;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Coupon applied successfully!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid coupon code'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  void _removeCoupon() {
    setState(() {
      _isCouponApplied = false;
      _discountAmount = 0.0;
      _couponCode = '';
    });
  }

  double _calculateBasePrice() {
    // Mock base price calculation - in real app, this would be from the restaurant
    return 15000.0; // Base price per person
  }

  double _calculateTotalPrice() {
    final basePrice = _calculateBasePrice() * _guestCount;
    return basePrice - _discountAmount;
  }

  void _confirmBooking() {
    // Show confirmation bottom sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.backgroundColor,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Title
            Text(
              'Confirm Booking',
              style: AppTheme.headlineSmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            
            // Booking details
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('Restaurant', widget.placeName),
                  const SizedBox(height: 12),
                  _buildDetailRow('Date', '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'),
                  const SizedBox(height: 12),
                  _buildDetailRow('Time', _selectedTimeSlot ?? 'Not selected'),
                  const SizedBox(height: 12),
                  _buildDetailRow('Guests', _guestCount.toString()),
                  const SizedBox(height: 12),
                  _buildDetailRow('Name', _fullName),
                  const SizedBox(height: 12),
                  _buildDetailRow('Phone', _contactNumber),
                  const SizedBox(height: 12),
                  _buildDetailRow('Email', _email),
                  if (_specialRequests.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildDetailRow('Special Requests', _specialRequests),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: AppTheme.primaryColor),
                    ),
                    child: Text(
                      'Cancel',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () async {
                      if (_selectedDate == null || _selectedTimeSlot == null) {
                        return;
                      }
                      
                      setState(() {
                        _isLoading = true;
                      });
                      
                      try {
                        // Convert time from 12-hour to 24-hour format
                        String time24 = _selectedTimeSlot!;
                        if (_selectedTimeSlot!.contains('PM') || _selectedTimeSlot!.contains('AM')) {
                          final timeParts = _selectedTimeSlot!.split(' ');
                          final time = timeParts[0];
                          final period = timeParts[1];
                          final hourMin = time.split(':');
                          int hour = int.parse(hourMin[0]);
                          final minute = hourMin[1];
                          
                          if (period == 'PM' && hour != 12) {
                            hour += 12;
                          } else if (period == 'AM' && hour == 12) {
                            hour = 0;
                          }
                          
                          time24 = '${hour.toString().padLeft(2, '0')}:$minute';
                        }
                        
                        // Create booking via API
                        final booking = await _bookingsService.createRestaurantBooking(
                          listingId: widget.placeId,
                          bookingDate: _selectedDate!,
                          bookingTime: time24,
                          partySize: _guestCount,
                          guests: [
                            {
                              'fullName': _fullName,
                              'email': _email,
                              'phone': _contactNumber,
                              'isPrimary': true,
                            }
                          ],
                          specialRequests: _specialRequests.isNotEmpty ? _specialRequests : null,
                        );
                        
                        if (mounted) {
                          Navigator.of(context).pop();
                          // Navigate to confirmation screen with actual booking ID
                          context.push('/dining-booking-confirmation', extra: {
                            'bookingId': booking['id'],
                            'placeName': widget.placeName,
                            'placeLocation': widget.placeLocation,
                            'date': _selectedDate,
                            'time': _selectedTimeSlot,
                            'guests': _guestCount,
                            'fullName': _fullName,
                            'phone': _contactNumber,
                            'email': _email,
                            'specialRequests': _specialRequests,
                          });
                        }
                      } catch (e) {
                        if (mounted) {
                          setState(() {
                            _isLoading = false;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to create booking: ${e.toString()}'),
                              backgroundColor: AppTheme.errorColor,
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
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
                            'Confirm',
                            style: AppTheme.bodyMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  ),
                ),
              ],
            ),
            
            // Add bottom padding for safe area
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: AppTheme.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
