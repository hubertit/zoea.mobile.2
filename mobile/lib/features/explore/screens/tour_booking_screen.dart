import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/theme/text_theme_extensions.dart';
import '../../../core/services/bookings_service.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/user_data_collection_provider.dart';
import '../../../core/config/app_config.dart';

class TourBookingScreen extends ConsumerStatefulWidget {
  final String listingId;
  final String? tourId;
  final String? tourName;
  final String? tourImage;
  final double? tourRating;
  final String? tourLocation;

  const TourBookingScreen({
    super.key,
    required this.listingId,
    this.tourId,
    this.tourName,
    this.tourImage,
    this.tourRating,
    this.tourLocation,
  });

  @override
  ConsumerState<TourBookingScreen> createState() => _TourBookingScreenState();
}

class _TourBookingScreenState extends ConsumerState<TourBookingScreen> {
  String? _selectedTourId;
  String? _selectedScheduleId;
  DateTime? _selectedDate;
  String? _selectedTime;
  int _adults = 1;
  int _children = 0;
  int _infants = 0;
  String _specialRequests = '';
  String _contactNumber = '';
  String _email = '';
  String _fullName = '';
  String _pickupLocation = '';
  bool _isLoading = false;
  bool _isLoadingSchedules = false;
  
  List<Map<String, dynamic>> _tours = [];
  List<Map<String, dynamic>> _schedules = [];
  Map<String, dynamic>? _selectedTour;
  
  final BookingsService _bookingsService = BookingsService();
  
  // Text controllers
  late TextEditingController _fullNameController;
  late TextEditingController _contactNumberController;
  late TextEditingController _emailController;
  late TextEditingController _pickupLocationController;
  
  @override
  void initState() {
    super.initState();
    _selectedTourId = widget.tourId;
    _fullNameController = TextEditingController();
    _contactNumberController = TextEditingController();
    _emailController = TextEditingController();
    _pickupLocationController = TextEditingController();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _trackBookingAttempt();
      _prefillUserData();
      if (_selectedTourId != null) {
        _loadTourSchedules();
      } else {
        _loadTours();
      }
    });
  }

  void _trackBookingAttempt() {
    try {
      final analyticsService = ref.read(analyticsServiceProvider);
      analyticsService.trackBookingAttempt(
        listingId: widget.listingId,
        listingType: 'tour',
      );
    } catch (e) {
      // Silently fail - analytics should never break the app
    }
  }
  
  void _prefillUserData() {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser != null) {
      _fullName = currentUser.fullName;
      _contactNumber = currentUser.phoneNumber ?? '';
      _email = currentUser.email;
      
      _fullNameController.text = _fullName;
      _contactNumberController.text = _contactNumber;
      _emailController.text = _email;
    }
  }

  Future<void> _loadTours() async {
    try {
      final dio = await AppConfig.authenticatedDioInstance();
      final response = await dio.get(
        AppConfig.toursEndpoint,
        queryParameters: {
          'listingId': widget.listingId,
          'status': 'active',
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final tours = data is List 
            ? (data as List).map((e) => e as Map<String, dynamic>).toList()
            : (data['data'] != null 
                ? (data['data'] as List).map((e) => e as Map<String, dynamic>).toList()
                : <Map<String, dynamic>>[]);
        
        setState(() {
          _tours = tours;
          if (tours.isNotEmpty && _selectedTourId == null) {
            _selectedTourId = tours[0]['id'] as String?;
            _selectedTour = tours[0];
            _loadTourSchedules();
          }
        });
      }
    } catch (e) {
      // Handle error silently or show snackbar
    }
  }

  Future<void> _loadTourSchedules() async {
    if (_selectedTourId == null) return;
    
    setState(() {
      _isLoadingSchedules = true;
      _schedules = [];
      _selectedScheduleId = null;
      _selectedDate = null;
      _selectedTime = null;
    });

    try {
      final dio = await AppConfig.authenticatedDioInstance();
      final response = await dio.get(
        '${AppConfig.toursEndpoint}/$_selectedTourId/schedules',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final schedules = data is List 
            ? (data as List).map((e) => e as Map<String, dynamic>).toList()
            : (data['data'] != null 
                ? (data['data'] as List).map((e) => e as Map<String, dynamic>).toList()
                : <Map<String, dynamic>>[]);
        
        // Filter available schedules (future dates, available spots)
        final now = DateTime.now();
        final availableSchedules = schedules.where((schedule) {
          final date = DateTime.parse(schedule['date'] as String);
          final availableSpots = schedule['availableSpots'] as int? ?? 0;
          final bookedSpots = schedule['bookedSpots'] as int? ?? 0;
          final isAvailable = schedule['isAvailable'] as bool? ?? true;
          
          return date.isAfter(now.subtract(const Duration(days: 1))) &&
                 isAvailable &&
                 (availableSpots - bookedSpots) > 0;
        }).toList();
        
        setState(() {
          _schedules = availableSchedules;
          _isLoadingSchedules = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingSchedules = false;
      });
    }
  }
  
  @override
  void dispose() {
    _fullNameController.dispose();
    _contactNumberController.dispose();
    _emailController.dispose();
    _pickupLocationController.dispose();
    super.dispose();
  }

  int get _totalGuests => _adults + _children + _infants;
  double get _basePrice {
    if (_selectedTour == null) return 0.0;
    final pricePerPerson = (_selectedTour!['pricePerPerson'] ?? 0).toDouble();
    return pricePerPerson * _totalGuests;
  }
  
  double get _totalPrice => _basePrice; // Can add discounts, taxes later

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
          'Book Tour',
          style: context.headlineMedium.copyWith(
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
            // Tour Info Card
            _buildTourInfoCard(),
            const SizedBox(height: 24),
            
            // Tour Selection (if multiple tours)
            if (_tours.length > 1) ...[
              _buildTourSelection(),
              const SizedBox(height: 24),
            ],
            
            // Schedule Selection
            _buildScheduleSelection(),
            const SizedBox(height: 24),
            
            // Guest Count
            _buildGuestSelection(),
            const SizedBox(height: 24),
            
            // Contact Information
            _buildContactSection(),
            const SizedBox(height: 24),
            
            // Pickup Location
            _buildPickupLocationSection(),
            const SizedBox(height: 24),
            
            // Special Requests
            _buildSpecialRequests(),
            const SizedBox(height: 24),
            
            // Price Breakdown
            _buildPriceBreakdown(),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildTourInfoCard() {
    final tourName = widget.tourName ?? _selectedTour?['name'] ?? 'Tour';
    final tourImage = widget.tourImage ?? 
        (_selectedTour?['images'] != null && (_selectedTour!['images'] as List).isNotEmpty
            ? (_selectedTour!['images'][0]['media']?['url'] ?? '')
            : '');
    final tourLocation = widget.tourLocation ?? 
        _selectedTour?['startLocationName'] ?? 
        _selectedTour?['city']?['name'] ?? 
        'Location';
    final tourRating = widget.tourRating ?? 
        (_selectedTour?['rating']?.toDouble() ?? 0.0);
    final pricePerPerson = _selectedTour?['pricePerPerson']?.toDouble() ?? 0.0;
    final currency = _selectedTour?['currency'] ?? 'RWF';

    return Container(
      padding: const EdgeInsets.all(12),
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
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: tourImage.isNotEmpty
                ? Image.network(
                    tourImage,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 80,
                      height: 80,
                      color: context.grey200,
                      child: Icon(
                        Icons.image,
                        color: context.secondaryTextColor,
                        size: 40,
                      ),
                    ),
                  )
                : Container(
                    width: 80,
                    height: 80,
                    color: context.grey200,
                    child: Icon(
                      Icons.terrain,
                      color: context.secondaryTextColor,
                      size: 40,
                    ),
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tourName,
                  style: context.headlineSmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.primaryTextColor,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: context.secondaryTextColor,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        tourLocation,
                        style: context.bodyMedium.copyWith(
                          color: context.secondaryTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (tourRating > 0) ...[
                      Icon(
                        Icons.star,
                        size: 16,
                        color: Colors.amber[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        tourRating.toStringAsFixed(1),
                        style: context.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: context.primaryTextColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      '$currency ${pricePerPerson.toStringAsFixed(0)}/person',
                      style: context.bodyMedium.copyWith(
                        color: context.primaryTextColor,
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

  Widget _buildTourSelection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Tour',
            style: context.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: context.primaryTextColor,
            ),
          ),
          const SizedBox(height: 16),
          ..._tours.map((tour) {
            return RadioListTile<String>(
              title: Text(tour['name'] ?? 'Tour'),
              subtitle: Text(
                '${tour['currency'] ?? 'RWF'} ${(tour['pricePerPerson'] ?? 0).toStringAsFixed(0)}/person',
              ),
              value: tour['id'] as String,
              groupValue: _selectedTourId,
                onChanged: (value) {
                  setState(() {
                    _selectedTourId = value;
                    _selectedTour = tour;
                  });
                  _loadTourSchedules();
                },
                selected: tour['id'] == _selectedTourId,
              activeColor: context.primaryColorTheme,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildScheduleSelection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Date & Time',
            style: context.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: context.primaryTextColor,
            ),
          ),
          const SizedBox(height: 16),
          if (_isLoadingSchedules)
            Center(child: CircularProgressIndicator(color: context.primaryColorTheme))
          else if (_schedules.isEmpty)
            Text(
              'No available schedules',
              style: context.bodyMedium.copyWith(
                color: context.secondaryTextColor,
              ),
            )
          else
            ..._schedules.map((schedule) {
              final date = DateTime.parse(schedule['date'] as String);
              final startTime = schedule['startTime'] as String?;
              final availableSpots = schedule['availableSpots'] as int? ?? 0;
              final bookedSpots = schedule['bookedSpots'] as int? ?? 0;
              final remaining = availableSpots - bookedSpots;
              
              return RadioListTile<String>(
                title: Text(DateFormat('MMM dd, yyyy').format(date)),
                subtitle: Text(
                  startTime != null 
                      ? 'Time: $startTime | Spots: $remaining available'
                      : 'Spots: $remaining available',
                ),
                value: schedule['id'] as String,
                groupValue: _selectedScheduleId,
                onChanged: (value) {
                  setState(() {
                    _selectedScheduleId = value;
                    _selectedDate = date;
                    _selectedTime = startTime;
                  });
                },
                activeColor: context.primaryColorTheme,
              );
            }),
        ],
      ),
    );
  }

  Widget _buildGuestSelection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Number of Guests',
            style: context.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: context.primaryTextColor,
            ),
          ),
          const SizedBox(height: 16),
          _buildGuestCounter('Adults', _adults, (value) {
            setState(() => _adults = value);
          }, min: 1),
          const SizedBox(height: 12),
          _buildGuestCounter('Children', _children, (value) {
            setState(() => _children = value);
          }),
          const SizedBox(height: 12),
          _buildGuestCounter('Infants', _infants, (value) {
            setState(() => _infants = value);
          }),
        ],
      ),
    );
  }

  Widget _buildGuestCounter(
    String label,
    int value,
    ValueChanged<int> onChanged, {
    int min = 0,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: context.bodyMedium.copyWith(
            color: context.primaryTextColor,
          ),
        ),
        Row(
          children: [
            IconButton(
              onPressed: value > min ? () => onChanged(value - 1) : null,
              icon: const Icon(Icons.remove),
              style: IconButton.styleFrom(
                backgroundColor: context.grey100,
                foregroundColor: value > min ? context.primaryTextColor : context.grey400,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              value.toString(),
              style: context.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 16),
            IconButton(
              onPressed: () => onChanged(value + 1),
              icon: const Icon(Icons.add),
              style: IconButton.styleFrom(
                backgroundColor: context.grey100,
                foregroundColor: context.primaryTextColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContactSection() {
    return Container(
      padding: const EdgeInsets.all(12),
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
          TextField(
            controller: _fullNameController,
            onChanged: (value) => setState(() => _fullName = value),
            decoration: InputDecoration(
              labelText: 'Full Name',
              hintText: 'John Doe',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _contactNumberController,
            onChanged: (value) => setState(() => _contactNumber = value),
            decoration: InputDecoration(
              labelText: 'Phone Number',
              hintText: '+250 788 123 456',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _emailController,
            onChanged: (value) => setState(() => _email = value),
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email Address',
              hintText: 'your.email@example.com',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickupLocationSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pickup Location (Optional)',
            style: context.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: context.primaryTextColor,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _pickupLocationController,
            onChanged: (value) => setState(() => _pickupLocation = value),
            decoration: InputDecoration(
              hintText: 'Enter pickup location or leave blank for default',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialRequests() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Special Requests',
            style: context.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: context.primaryTextColor,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            onChanged: (value) => setState(() => _specialRequests = value),
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Any special requirements, dietary preferences, etc.',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBreakdown() {
    final currency = _selectedTour?['currency'] ?? 'RWF';
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Price Breakdown',
            style: context.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: context.primaryTextColor,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Adults (${_adults}x)',
                style: context.bodyMedium.copyWith(
                  color: context.secondaryTextColor,
                ),
              ),
              Text(
                '$currency ${((_selectedTour?['pricePerPerson']?.toDouble() ?? 0) * _adults).toStringAsFixed(0)}',
                style: context.bodyMedium.copyWith(
                  color: context.primaryTextColor,
                ),
              ),
            ],
          ),
          if (_children > 0) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Children (${_children}x)',
                  style: context.bodyMedium.copyWith(
                    color: context.secondaryTextColor,
                  ),
                ),
                Text(
                  '$currency ${((_selectedTour?['pricePerPerson']?.toDouble() ?? 0) * _children).toStringAsFixed(0)}',
                  style: context.bodyMedium.copyWith(
                    color: context.primaryTextColor,
                  ),
                ),
              ],
            ),
          ],
          if (_infants > 0) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Infants (${_infants}x)',
                  style: context.bodyMedium.copyWith(
                    color: context.secondaryTextColor,
                  ),
                ),
                Text(
                  'Free',
                  style: context.bodyMedium.copyWith(
                    color: context.primaryTextColor,
                  ),
                ),
              ],
            ),
          ],
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: context.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: context.primaryTextColor,
                ),
              ),
              Text(
                '$currency ${_totalPrice.toStringAsFixed(0)}',
                style: context.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: context.primaryColorTheme,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final canBook = _selectedTourId != null &&
        _selectedScheduleId != null &&
        _totalGuests > 0 &&
        _fullName.isNotEmpty &&
        _contactNumber.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(12),
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
                  '${_selectedTour?['currency'] ?? 'RWF'} ${_totalPrice.toStringAsFixed(0)}',
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
                onPressed: canBook && !_isLoading ? _bookTour : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.primaryColorTheme,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Book Tour',
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

  Future<void> _bookTour() async {
    if (_selectedTourId == null || _selectedScheduleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a tour and schedule'),
          backgroundColor: context.errorColor,
        ),
      );
      return;
    }

    if (_fullName.isEmpty || _contactNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill in all required fields'),
          backgroundColor: context.errorColor,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final booking = await _bookingsService.createTourBooking(
        listingId: widget.listingId, // Optional - tours don't always have listings
        tourId: _selectedTourId!,
        tourScheduleId: _selectedScheduleId!,
        guestCount: _totalGuests,
        adults: _adults,
        children: _children,
        infants: _infants,
        fullName: _fullName,
        contactNumber: _contactNumber,
        email: _email.isNotEmpty ? _email : null,
        specialRequests: _specialRequests.isNotEmpty ? _specialRequests : null,
        pickupLocation: _pickupLocation.isNotEmpty ? _pickupLocation : null,
      );

      if (mounted) {
        context.pushReplacement(
          '/booking-confirmation',
          extra: booking,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to book tour: ${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: context.errorColor,
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

