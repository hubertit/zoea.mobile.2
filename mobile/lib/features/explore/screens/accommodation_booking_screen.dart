import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/theme/text_theme_extensions.dart';
import '../../../core/services/bookings_service.dart';
import '../../../core/services/token_storage_service.dart';
import '../../../core/providers/listings_provider.dart';
import '../../../core/providers/user_data_collection_provider.dart';

class AccommodationBookingScreen extends ConsumerStatefulWidget {
  final String accommodationId;
  final Map<String, Map<String, dynamic>>? selectedRooms;
  final DateTime? checkInDate;
  final DateTime? checkOutDate;
  final TimeOfDay? checkInTime;
  final int? guestCount;

  const AccommodationBookingScreen({
    super.key,
    required this.accommodationId,
    this.selectedRooms,
    this.checkInDate,
    this.checkOutDate,
    this.checkInTime,
    this.guestCount,
  });

  @override
  ConsumerState<AccommodationBookingScreen> createState() => _AccommodationBookingScreenState();
}

class _AccommodationBookingScreenState extends ConsumerState<AccommodationBookingScreen> {
  late DateTime? _checkInDate;
  late DateTime? _checkOutDate;
  int _guestCount = 1;
  int _roomCount = 1;
  String _couponCode = '';
  double _discountAmount = 0.0;
  bool _isCouponApplied = false;
  bool _isLoading = false;
  String _specialRequests = '';
  
  final BookingsService _bookingsService = BookingsService();

  @override
  void initState() {
    super.initState();
    _checkInDate = widget.checkInDate;
    _checkOutDate = widget.checkOutDate;
    _guestCount = widget.guestCount ?? 1;
    
    // Track booking attempt for analytics
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _trackBookingAttempt();
    });
  }

  void _trackBookingAttempt() {
    try {
      final analyticsService = ref.read(analyticsServiceProvider);
      analyticsService.trackBookingAttempt(
        listingId: widget.accommodationId,
        listingType: 'accommodation',
      );
    } catch (e) {
      // Silently fail - analytics should never break the app
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.grey50,
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
          'Book Your Stay',
          style: context.headlineSmall.copyWith(
            fontWeight: FontWeight.w600,
            color: context.primaryTextColor,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAccommodationCard(),
            const SizedBox(height: 24),
            if (widget.selectedRooms != null && widget.selectedRooms!.isNotEmpty) ...[
              _buildSelectedRoomsSection(),
              const SizedBox(height: 24),
            ],
            _buildDateSelection(),
            const SizedBox(height: 24),
            _buildGuestSelection(),
            const SizedBox(height: 24),
            _buildRoomSelection(),
            const SizedBox(height: 24),
            _buildPriceBreakdown(),
            const SizedBox(height: 24),
            _buildSpecialRequests(),
            const SizedBox(height: 24),
            _buildCouponSection(),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildAccommodationCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.backgroundColor,
        borderRadius: BorderRadius.circular(12),
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
              'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=100',
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 80,
                  height: 80,
                    color: context.grey200,
                  child: Icon(
                    Icons.hotel,
                    color: context.grey400,
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
                  'Kigali Marriott Hotel',
                  style: context.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.primaryTextColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Kacyiru, Kigali',
                  style: context.bodyMedium.copyWith(
                    color: context.secondaryTextColor,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '4.8 (1,247 reviews)',
                      style: context.bodySmall.copyWith(
                        color: context.secondaryTextColor,
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

  Widget _buildDateSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Dates',
          style: context.headlineSmall.copyWith(
            fontWeight: FontWeight.w600,
            color: context.primaryTextColor,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildDateField(
                label: 'Check-in',
                date: _checkInDate,
                onTap: () => _selectDate(true),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDateField(
                label: 'Check-out',
                date: _checkOutDate,
                onTap: () => _selectDate(false),
              ),
            ),
          ],
        ),
      ],
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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: context.grey300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: context.bodyMedium.copyWith(
                color: context.secondaryTextColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              date != null
                  ? '${date.day}/${date.month}/${date.year}'
                  : 'Select date',
              style: context.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
                color: context.primaryTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Guests',
          style: context.headlineSmall.copyWith(
            fontWeight: FontWeight.w600,
            color: context.primaryTextColor,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: context.grey300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$_guestCount guest${_guestCount > 1 ? 's' : ''}',
                style: context.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: _guestCount > 1 ? () {
                      setState(() {
                        _guestCount--;
                      });
                    } : null,
                    icon: const Icon(Icons.remove),
                    style: IconButton.styleFrom(
                      backgroundColor: context.grey100,
                      shape: const CircleBorder(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    onPressed: _guestCount < 10 ? () {
                      setState(() {
                        _guestCount++;
                      });
                    } : null,
                    icon: const Icon(Icons.add),
                    style: IconButton.styleFrom(
                      backgroundColor: context.primaryColorTheme,
                      foregroundColor: Colors.white,
                      shape: const CircleBorder(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoomSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rooms',
          style: context.headlineSmall.copyWith(
            fontWeight: FontWeight.w600,
            color: context.primaryTextColor,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: context.grey300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$_roomCount room${_roomCount > 1 ? 's' : ''}',
                style: context.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: _roomCount > 1 ? () {
                      setState(() {
                        _roomCount--;
                      });
                    } : null,
                    icon: const Icon(Icons.remove),
                    style: IconButton.styleFrom(
                      backgroundColor: context.grey100,
                      shape: const CircleBorder(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    onPressed: _roomCount < 5 ? () {
                      setState(() {
                        _roomCount++;
                      });
                    } : null,
                    icon: const Icon(Icons.add),
                    style: IconButton.styleFrom(
                      backgroundColor: context.primaryColorTheme,
                      foregroundColor: Colors.white,
                      shape: const CircleBorder(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceBreakdown() {
    const basePrice = 120000;
    final totalPrice = basePrice * _roomCount;
    final tax = (totalPrice * 0.18).round();
    final total = totalPrice + tax;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Price Breakdown',
          style: context.headlineSmall.copyWith(
            fontWeight: FontWeight.w600,
            color: context.primaryTextColor,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.backgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: context.grey200!),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'RWF ${basePrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} × $_roomCount room${_roomCount > 1 ? 's' : ''}',
                    style: context.bodyMedium,
                  ),
                  Text(
                    'RWF ${totalPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                    style: context.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Taxes & Fees',
                    style: context.bodyMedium,
                  ),
                  Text(
                    'RWF ${tax.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                    style: context.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: context.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'RWF ${total.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                    style: context.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.primaryColorTheme,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSpecialRequests() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Special Requests (Optional)',
          style: context.headlineSmall.copyWith(
            fontWeight: FontWeight.w600,
            color: context.primaryTextColor,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: context.grey300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            onChanged: (value) => setState(() => _specialRequests = value),
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Any special requests or preferences...',
              hintStyle: context.bodyMedium.copyWith(
                color: context.secondaryTextColor,
              ),
              border: InputBorder.none,
            ),
            style: context.bodyMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: (_checkInDate != null && _checkOutDate != null && !_isLoading)
              ? () async {
                  await _submitBooking();
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: (_checkInDate != null && _checkOutDate != null && !_isLoading)
                ? context.primaryColorTheme
                : context.grey300,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
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
                  'Continue to Payment',
                  style: context.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }

  Future<void> _selectDate(bool isCheckIn) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isCheckIn
          ? (_checkInDate ?? DateTime.now())
          : (_checkOutDate ?? DateTime.now().add(const Duration(days: 1))),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          _checkInDate = picked;
          if (_checkOutDate != null && _checkOutDate!.isBefore(_checkInDate!.add(const Duration(days: 1)))) {
            _checkOutDate = _checkInDate!.add(const Duration(days: 1));
          }
        } else {
          _checkOutDate = picked;
        }
      });
    }
  }

  Widget _buildSelectedRoomsSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.primaryColorTheme.withOpacity(0.3)),
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
                Icons.hotel,
                color: context.primaryColorTheme,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Selected Rooms',
                style: context.headlineSmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.primaryColorTheme,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...widget.selectedRooms!.entries.map((entry) {
            final roomType = entry.value['roomType'] as Map<String, dynamic>;
            final quantity = entry.value['quantity'] as int;
            final totalPrice = int.parse(roomType['price'].toString().replaceAll(',', '')) * quantity;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.grey50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: context.grey200!),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          roomType['type'],
                          style: context.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${roomType['maxGuests']} guests • ${roomType['amenities']}',
                          style: context.bodySmall.copyWith(
                            color: context.secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Qty: $quantity',
                        style: context.bodySmall.copyWith(
                          color: context.secondaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'RWF ${totalPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                        style: context.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: context.primaryColorTheme,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCouponSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.grey200!),
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
                color: context.primaryColorTheme,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Coupon Code',
                style: context.headlineSmall.copyWith(
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
                    hintStyle: context.bodyMedium.copyWith(
                      color: context.secondaryTextColor,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: context.grey300!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: context.grey300!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: context.primaryColorTheme),
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
                      ? context.primaryColorTheme 
                      : context.grey300,
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
                  style: context.bodyMedium.copyWith(
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
                  const Icon(
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
                          style: context.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.successColor,
                          ),
                        ),
                        Text(
                          'You saved RWF ${_discountAmount.toStringAsFixed(0)}',
                          style: context.bodySmall.copyWith(
                            color: AppTheme.successColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _removeCoupon,
                    icon: const Icon(
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

  void _applyCoupon() {
    // Mock coupon validation
    final validCoupons = {
      'WELCOME10': 0.10, // 10% discount
      'SAVE20': 0.20,    // 20% discount
      'FIRST15': 0.15,   // 15% discount
    };

    if (validCoupons.containsKey(_couponCode.toUpperCase())) {
      setState(() {
        _isCouponApplied = true;
        _discountAmount = _calculateTotalPrice() * validCoupons[_couponCode.toUpperCase()]!;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Coupon applied successfully!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
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

  double _calculateTotalPrice() {
    // Mock calculation - in real app, this would calculate from selected rooms
    return 150000.0; // Example total price
  }

  Future<void> _submitBooking() async {
    if (_checkInDate == null || _checkOutDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select check-in and check-out dates'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    // Validate check-out is after check-in
    if (_checkOutDate!.isBefore(_checkInDate!) || 
        _checkOutDate!.isAtSameMomentAs(_checkInDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Check-out date must be after check-in date'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get user info for guests array
      final tokenStorage = await TokenStorageService.getInstance();
      final user = await tokenStorage.getUserData();
      
      // Extract roomTypeId from selectedRooms if available
      String? roomTypeId;
      if (widget.selectedRooms != null && widget.selectedRooms!.isNotEmpty) {
        // Get the first room type ID from selected rooms
        final firstRoom = widget.selectedRooms!.entries.first;
        final roomType = firstRoom.value['roomType'] as Map<String, dynamic>?;
        roomTypeId = roomType?['id'] as String?;
      }
      
      // If no roomTypeId from selectedRooms, fetch from listing
      if (roomTypeId == null) {
        try {
          final listing = await ref.read(listingByIdProvider(widget.accommodationId).future);
          final roomTypes = listing['roomTypes'] as List?;
          if (roomTypes != null && roomTypes.isNotEmpty) {
            // Get the first available room type
            final firstRoomType = roomTypes.first as Map<String, dynamic>;
            roomTypeId = firstRoomType['id'] as String?;
          }
        } catch (e) {
          // If fetching listing fails, continue without roomTypeId
          // The API will return an error which we'll handle below
        }
      }
      
      // Validate that we have a roomTypeId
      if (roomTypeId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select a room type to continue'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Build guests array from user info
      final guests = <Map<String, dynamic>>[];
      if (user != null) {
        guests.add({
          'fullName': user.fullName,
          'email': user.email,
          if (user.phoneNumber != null) 'phone': user.phoneNumber,
          'isPrimary': true,
        });
      }

      final booking = await _bookingsService.createHotelBooking(
        listingId: widget.accommodationId,
        checkInDate: _checkInDate!,
        checkOutDate: _checkOutDate!,
        roomTypeId: roomTypeId,
        guestCount: _guestCount,
        adults: _guestCount, // Default to guestCount if not specified
        children: 0, // Default to 0
        specialRequests: _specialRequests.isNotEmpty ? _specialRequests : null,
        guests: guests.isNotEmpty ? guests : null,
      );

      if (mounted) {
        // Track booking completion for analytics
        try {
          final analyticsService = ref.read(analyticsServiceProvider);
          analyticsService.trackBookingCompletion(
            bookingId: booking['id'] as String,
            listingId: widget.accommodationId,
          );
        } catch (e) {
          // Silently fail
        }
        
        // Navigate to confirmation screen with booking ID
        context.push('/booking-confirmation/${booking['id'] as String}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create booking: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: AppTheme.errorColor,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
