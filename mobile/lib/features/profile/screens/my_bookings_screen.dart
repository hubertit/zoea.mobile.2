import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/theme/text_theme_extensions.dart';
import '../../../core/providers/bookings_provider.dart';
import '../../../core/providers/orders_provider.dart';

class MyBookingsScreen extends ConsumerStatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  ConsumerState<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends ConsumerState<MyBookingsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // Shimmer animation controller
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // Start shimmer animation
    _shimmerController.repeat();
    
    // Shimmer animation
    _shimmerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));
    
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _shimmerController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: Text(
          'My Bookings',
          style: context.titleLarge.copyWith(
            color: context.primaryTextColor,
          ),
        ),
        backgroundColor: context.backgroundColor,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () => context.go('/profile'),
          icon: Icon(Icons.chevron_left, size: 32, color: context.primaryTextColor),
          style: IconButton.styleFrom(
            foregroundColor: context.primaryTextColor,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _showSearchBottomSheet();
            },
            icon: Icon(Icons.search_outlined, color: context.primaryTextColor),
            style: IconButton.styleFrom(
              backgroundColor: context.dividerColor,
              foregroundColor: context.primaryTextColor,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              context.push('/profile');
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: context.primaryColorTheme,
          labelColor: context.primaryColorTheme,
          unselectedLabelColor: context.secondaryTextColor,
          labelStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: context.primaryColorTheme,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: context.secondaryTextColor,
          ),
          tabAlignment: TabAlignment.start,
          isScrollable: true,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Upcoming'),
            Tab(text: 'Past'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        key: ValueKey(_searchQuery), // Rebuild when search query changes
        children: [
          _buildBookingsList('all'),
          _buildBookingsList('upcoming'),
          _buildBookingsList('past'),
          _buildBookingsList('cancelled'),
        ],
      ),
    );
  }

  Widget _buildBookingsList(String filter) {
    // Determine status filter for API
    String? statusFilter;
    if (filter == 'cancelled') {
      statusFilter = 'cancelled';
    }

    // Fetch bookings and orders from API
    final bookingsAsync = ref.watch(
      bookingsProvider(
        BookingsParams(
          page: 1,
          limit: 100, // Fetch all bookings for now
          status: statusFilter,
        ),
      ),
    );

    final ordersAsync = ref.watch(
      ordersProvider(
        OrdersParams(
          page: 1,
          limit: 100, // Fetch all orders for now
          status: statusFilter == 'cancelled' ? 'cancelled' : null,
        ),
      ),
    );

    return bookingsAsync.when(
      data: (bookingsResponse) {
        return ordersAsync.when(
          data: (ordersResponse) {
            // Combine bookings and orders
            final bookings = (bookingsResponse['data'] as List<dynamic>?)
                    ?.map((b) => {
                      ...b as Map<String, dynamic>,
                      '_type': 'booking', // Add type identifier
                    })
                    .toList() ??
                [];

            final orders = (ordersResponse['data'] as List<dynamic>?)
                    ?.map((o) => {
                      ...o as Map<String, dynamic>,
                      '_type': 'order', // Add type identifier
                    })
                    .toList() ??
                [];

            // Combine and sort by creation date (newest first)
            final allItems = [...bookings, ...orders];
            allItems.sort((a, b) {
              final aDate = DateTime.tryParse(a['createdAt'] as String? ?? '') ?? DateTime(1970);
              final bDate = DateTime.tryParse(b['createdAt'] as String? ?? '') ?? DateTime(1970);
              return bDate.compareTo(aDate);
            });

            // Filter items based on tab
            var filteredItems = _filterItems(allItems, filter);
            
            // Apply search filter if search query exists
            if (_searchQuery.isNotEmpty) {
              filteredItems = _searchItems(filteredItems, _searchQuery);
            }

            if (filteredItems.isEmpty) {
              return _buildEmptyState(filter);
            }

            return RefreshIndicator(
              color: context.primaryColorTheme,
              backgroundColor: context.cardColor,
              onRefresh: () async {
                ref.invalidate(
                  bookingsProvider(
                    BookingsParams(
                      page: 1,
                      limit: 100,
                      status: statusFilter,
                    ),
                  ),
                );
                ref.invalidate(
                  ordersProvider(
                    OrdersParams(
                      page: 1,
                      limit: 100,
                      status: statusFilter == 'cancelled' ? 'cancelled' : null,
                    ),
                  ),
                );
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  final item = filteredItems[index];
                  final type = item['_type'] as String? ?? 'booking';
                  if (type == 'order') {
                    return _buildOrderCard(item);
                  } else {
                    return _buildBookingCard(item);
                  }
                },
              ),
            );
          },
          loading: () => ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 3,
            itemBuilder: (context, index) {
              return _buildBookingCardSkeleton();
            },
          ),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: context.errorColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'Failed to load orders',
                  style: context.bodyMedium.copyWith(
                    color: context.errorColor,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    ref.invalidate(
                      ordersProvider(
                        OrdersParams(
                          page: 1,
                          limit: 100,
                          status: statusFilter == 'cancelled' ? 'cancelled' : null,
                        ),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: context.primaryColorTheme,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 3,
        itemBuilder: (context, index) {
          return _buildBookingCardSkeleton();
        },
      ),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: context.secondaryTextColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load bookings',
              style: context.titleMedium.copyWith(
                color: context.primaryTextColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: context.bodySmall.copyWith(
                color: context.secondaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(
                  bookingsProvider(
                    BookingsParams(
                      page: 1,
                      limit: 100,
                      status: statusFilter,
                    ),
                  ),
                );
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

  Widget _buildEmptyState(String filter) {
    String title;
    String subtitle;
    IconData icon;

    switch (filter) {
      case 'upcoming':
        title = 'No Upcoming Bookings or Orders';
        subtitle = 'You don\'t have any upcoming reservations or orders';
        icon = Icons.event_available;
        break;
      case 'past':
        title = 'No Past Bookings or Orders';
        subtitle = 'Your booking and order history will appear here';
        icon = Icons.history;
        break;
      case 'cancelled':
        title = 'No Cancelled Bookings or Orders';
        subtitle = 'Cancelled bookings and orders will appear here';
        icon = Icons.cancel;
        break;
      default:
        title = 'No Bookings or Orders Yet';
        subtitle = 'Start exploring and make your first booking or order!';
        icon = Icons.explore;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: context.dividerColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 48,
              color: context.secondaryTextColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: context.titleLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: context.primaryTextColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: context.bodyMedium.copyWith(
              color: context.secondaryTextColor,
            ),
            textAlign: TextAlign.center,
          ),
          if (filter == 'all') ...[
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/explore'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Explore Now',
                style: context.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.primaryTextColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    // Parse booking data from API response
    final bookingId = booking['id'] as String? ?? '';
    final bookingNumber = booking['bookingNumber'] as String?;
    final status = booking['status'] as String? ?? 'pending';
    final bookingType = booking['bookingType'] as String? ?? 'hotel';
    
    // Get dates based on booking type
    DateTime? eventDate;
    DateTime? bookingDate;
    String? bookingTime;
    
    if (bookingType == 'hotel') {
      if (booking['checkInDate'] != null) {
        eventDate = DateTime.parse(booking['checkInDate'] as String);
      }
      if (booking['checkOutDate'] != null) {
        // Use check-out date for display
        eventDate = DateTime.parse(booking['checkOutDate'] as String);
      }
    } else if (bookingType == 'restaurant') {
      if (booking['bookingDate'] != null) {
        eventDate = DateTime.parse(booking['bookingDate'] as String);
        bookingDate = eventDate;
      }
      bookingTime = booking['bookingTime'] as String?;
    } else if (bookingType == 'event') {
      final event = booking['event'] as Map<String, dynamic>?;
      if (event?['startDate'] != null) {
        eventDate = DateTime.parse(event!['startDate'] as String);
      }
    } else if (bookingType == 'tour') {
      final tourSchedule = booking['tourSchedule'] as Map<String, dynamic>?;
      if (tourSchedule?['date'] != null) {
        eventDate = DateTime.parse(tourSchedule!['date'] as String);
      }
    }
    
    // Fallback to createdAt if no event date
    if (eventDate == null && booking['createdAt'] != null) {
      eventDate = DateTime.parse(booking['createdAt'] as String);
    }
    if (bookingDate == null && booking['createdAt'] != null) {
      bookingDate = DateTime.parse(booking['createdAt'] as String);
    }

    // Get name and location based on booking type
    String name = 'Unknown';
    String location = 'Location not specified';
    String? imageUrl;

    if (bookingType == 'hotel' || bookingType == 'restaurant') {
      final listing = booking['listing'] as Map<String, dynamic>?;
      if (listing != null) {
        name = listing['name'] as String? ?? 'Unknown';
        // Get location from listing address or city
        final address = listing['address'] as String?;
        final city = listing['city'] as Map<String, dynamic>?;
        if (address != null && address.isNotEmpty) {
          location = address;
        } else if (city != null && city['name'] != null) {
          location = city['name'] as String;
        }
        
        // Get primary image
        final images = listing['images'] as List<dynamic>?;
        if (images != null && images.isNotEmpty) {
          final image = images[0] as Map<String, dynamic>?;
          final media = image?['media'] as Map<String, dynamic>?;
          imageUrl = media?['url'] as String?;
        }
      }
    } else if (bookingType == 'event') {
      final event = booking['event'] as Map<String, dynamic>?;
      if (event != null) {
        name = event['name'] as String? ?? 'Unknown';
        location = event['locationName'] as String? ??
            event['venueName'] as String? ??
            event['address'] as String? ??
            'Location not specified';
        
        // Get main flyer image
        final attachments = event['attachments'] as List<dynamic>?;
        if (attachments != null && attachments.isNotEmpty) {
          final attachment = attachments[0] as Map<String, dynamic>?;
          final media = attachment?['media'] as Map<String, dynamic>?;
          imageUrl = media?['url'] as String?;
        }
      }
    } else if (bookingType == 'tour') {
      final tour = booking['tour'] as Map<String, dynamic>?;
      if (tour != null) {
        name = tour['name'] as String? ?? 'Unknown';
        location = 'Tour Location'; // Tours might not have location in response
        
        // Get primary image
        final images = tour['images'] as List<dynamic>?;
        if (images != null && images.isNotEmpty) {
          final image = images[0] as Map<String, dynamic>?;
          final media = image?['media'] as Map<String, dynamic>?;
          imageUrl = media?['url'] as String?;
        }
      }
    }

    // Get price and guest count
    // Handle both string and number types from API
    final totalAmountValue = booking['totalAmount'];
    final totalAmount = totalAmountValue is num
        ? totalAmountValue.toDouble()
        : totalAmountValue is String
            ? double.tryParse(totalAmountValue) ?? 0.0
            : 0.0;
    final guestCount = booking['guestCount'] is int
        ? booking['guestCount'] as int
        : booking['guestCount'] is String
            ? int.tryParse(booking['guestCount'] as String) ?? 1
            : 1;
    final currency = booking['currency'] as String? ?? 'RWF';

    final dateFormat = DateFormat('MMM dd, yyyy');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: context.isDarkMode ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Booking Image and Status
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Stack(
              children: [
                // Image
                if (imageUrl != null && imageUrl.isNotEmpty)
                  CachedNetworkImage(
                    imageUrl: imageUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 200,
                      color: context.dividerColor,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: context.primaryColorTheme,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 200,
                      color: context.dividerColor,
                      child: Icon(
                        _getBookingTypeIcon(bookingType),
                        size: 64,
                        color: context.secondaryTextColor,
                      ),
                    ),
                  )
                else
                  Container(
                    height: 200,
                    color: context.dividerColor,
                    child: Icon(
                      _getBookingTypeIcon(bookingType),
                      size: 64,
                      color: context.secondaryTextColor,
                    ),
                  ),
                // Status Badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: context.labelSmall.copyWith(
                        color: Colors.white, // White on colored status badge is intentional
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                // Booking ID/Number
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '#${bookingNumber ?? bookingId.substring(0, 8)}',
                      style: context.labelSmall.copyWith(
                        color: Colors.white, // White on dark overlay is intentional
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Booking Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                Text(
                  name,
                  style: context.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.primaryTextColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Date and Time
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: context.secondaryTextColor,
                    ),
                    const SizedBox(width: 8),
                    if (eventDate != null)
                      Text(
                        dateFormat.format(eventDate),
                        style: context.bodyMedium.copyWith(
                          color: context.secondaryTextColor,
                        ),
                      ),
                    if (bookingTime != null) ...[
                      const SizedBox(width: 16),
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: context.secondaryTextColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        bookingTime,
                        style: context.bodyMedium.copyWith(
                          color: context.secondaryTextColor,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                // Location
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: context.secondaryTextColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        location,
                        style: context.bodyMedium.copyWith(
                          color: context.secondaryTextColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Booking Date
                if (bookingDate != null)
                  Row(
                    children: [
                      Icon(
                        Icons.shopping_cart,
                        size: 16,
                        color: context.secondaryTextColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Booked on ${dateFormat.format(bookingDate)}',
                        style: context.bodySmall.copyWith(
                          color: context.secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 12),
                // Price and Guests
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${totalAmount.toStringAsFixed(0)} $currency',
                      style: context.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.primaryColorTheme,
                      ),
                    ),
                    Text(
                      '$guestCount guest${guestCount > 1 ? 's' : ''}',
                      style: context.bodyMedium.copyWith(
                        color: context.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Action Buttons
                _buildActionButtons(booking, bookingId, status),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getBookingTypeIcon(String bookingType) {
    switch (bookingType.toLowerCase()) {
      case 'hotel':
        return Icons.hotel;
      case 'restaurant':
        return Icons.restaurant;
      case 'event':
        return Icons.event;
      case 'tour':
        return Icons.tour;
      default:
        return Icons.event;
    }
  }

  Widget _buildActionButtons(Map<String, dynamic> booking, String bookingId, String status) {
    if (status.toLowerCase() == 'cancelled') {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                _showBookAgainDialog(booking);
              },
              icon: const Icon(Icons.repeat, size: 16),
              label: const Text('Book Again'),
              style: OutlinedButton.styleFrom(
                foregroundColor: context.primaryColorTheme,
                backgroundColor: context.cardColor,
                side: BorderSide(color: context.primaryColorTheme),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      );
    } else if (status.toLowerCase() == 'pending' ||
        status.toLowerCase() == 'confirmed' ||
        status.toLowerCase() == 'upcoming') {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                _showBookingDetails(booking);
              },
              icon: const Icon(Icons.visibility, size: 16),
              label: const Text('View Details'),
              style: OutlinedButton.styleFrom(
                foregroundColor: context.primaryColorTheme,
                backgroundColor: context.cardColor,
                side: BorderSide(color: context.primaryColorTheme),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                _showCancelBookingDialog(booking, bookingId);
              },
              icon: const Icon(Icons.cancel, size: 16),
              label: const Text('Cancel'),
              style: OutlinedButton.styleFrom(
                foregroundColor: context.errorColor,
                backgroundColor: context.cardColor,
                side: BorderSide(color: context.errorColor),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                _showBookingDetails(booking);
              },
              icon: const Icon(Icons.visibility, size: 16),
              label: const Text('View Details'),
              style: OutlinedButton.styleFrom(
                foregroundColor: context.primaryColorTheme,
                backgroundColor: context.cardColor,
                side: BorderSide(color: context.primaryColorTheme),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      );
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return AppTheme.successColor; // Success color is intentional
      case 'pending':
        return Colors.orange; // Orange for pending is intentional
      case 'upcoming':
        return context.primaryColorTheme;
      case 'completed':
        return Colors.blue; // Blue for completed is intentional
      case 'cancelled':
        return Colors.red[700] ?? Colors.red; // More vibrant red for visibility
      case 'checked_in':
        return Colors.green; // Green for checked in is intentional
      default:
        return context.secondaryTextColor;
    }
  }

  Widget _buildBookingCardSkeleton() {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
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
              // Image skeleton
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Stack(
                  children: [
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            context.grey300,
                            context.grey200,
                            context.grey300,
                          ],
                          stops: [
                            0.0,
                            _shimmerAnimation.value,
                            1.0,
                          ],
                        ),
                      ),
                    ),
                    // Status badge skeleton
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        height: 24,
                        width: 80,
                        decoration: BoxDecoration(
                          color: context.grey400,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    // Booking ID skeleton
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        height: 20,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Booking Details skeleton
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name skeleton
                    Container(
                      height: 20,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: context.grey300,
                        borderRadius: BorderRadius.circular(4),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            context.grey300,
                            context.grey200,
                            context.grey300,
                          ],
                          stops: [
                            0.0,
                            _shimmerAnimation.value,
                            1.0,
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 20,
                      width: 200,
                      decoration: BoxDecoration(
                        color: context.grey300,
                        borderRadius: BorderRadius.circular(4),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            context.grey300,
                            context.grey200,
                            context.grey300,
                          ],
                          stops: [
                            0.0,
                            _shimmerAnimation.value,
                            1.0,
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Date skeleton
                    Row(
                      children: [
                        Container(
                          height: 16,
                          width: 16,
                          decoration: BoxDecoration(
                            color: context.grey200,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          height: 14,
                          width: 100,
                          decoration: BoxDecoration(
                            color: context.grey200,
                            borderRadius: BorderRadius.circular(4),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                context.grey200,
                                context.grey100,
                                context.grey200,
                              ],
                              stops: [
                                0.0,
                                _shimmerAnimation.value,
                                1.0,
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Location skeleton
                    Row(
                      children: [
                        Container(
                          height: 16,
                          width: 16,
                          decoration: BoxDecoration(
                            color: context.grey200,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          height: 14,
                          width: 150,
                          decoration: BoxDecoration(
                            color: context.grey200,
                            borderRadius: BorderRadius.circular(4),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                context.grey200,
                                context.grey100,
                                context.grey200,
                              ],
                              stops: [
                                0.0,
                                _shimmerAnimation.value,
                                1.0,
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Booked on skeleton
                    Row(
                      children: [
                        Container(
                          height: 16,
                          width: 16,
                          decoration: BoxDecoration(
                            color: context.grey200,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          height: 14,
                          width: 120,
                          decoration: BoxDecoration(
                            color: context.grey200,
                            borderRadius: BorderRadius.circular(4),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                context.grey200,
                                context.grey100,
                                context.grey200,
                              ],
                              stops: [
                                0.0,
                                _shimmerAnimation.value,
                                1.0,
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Price and guest count skeleton
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 18,
                          width: 80,
                          decoration: BoxDecoration(
                            color: context.grey300,
                            borderRadius: BorderRadius.circular(4),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                context.grey300,
                                context.grey200,
                                context.grey300,
                              ],
                              stops: [
                                0.0,
                                _shimmerAnimation.value,
                                1.0,
                              ],
                            ),
                          ),
                        ),
                        Container(
                          height: 18,
                          width: 60,
                          decoration: BoxDecoration(
                            color: context.grey200,
                            borderRadius: BorderRadius.circular(4),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                context.grey200,
                                context.grey100,
                                context.grey200,
                              ],
                              stops: [
                                0.0,
                                _shimmerAnimation.value,
                                1.0,
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Action button skeleton
                    Container(
                      height: 40,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: context.grey200,
                        borderRadius: BorderRadius.circular(8),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            context.grey200,
                            context.grey100,
                            context.grey200,
                          ],
                          stops: [
                            0.0,
                            _shimmerAnimation.value,
                            1.0,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Map<String, dynamic>> _filterItems(
      List<Map<String, dynamic>> items, String filter) {
    final now = DateTime.now();

    switch (filter) {
      case 'all':
        return items;
      case 'upcoming':
        return items.where((item) {
          final type = item['_type'] as String? ?? 'booking';
          final status = (item['status'] as String? ?? '').toLowerCase();
          if (status == 'cancelled') return false;

          DateTime? eventDate;

          if (type == 'order') {
            // For orders, use deliveryDate or createdAt
            if (item['deliveryDate'] != null) {
              eventDate = DateTime.tryParse(item['deliveryDate'] as String);
            } else if (item['createdAt'] != null) {
              eventDate = DateTime.tryParse(item['createdAt'] as String);
            }
          } else {
            // For bookings, determine event date based on booking type
            final bookingType = item['bookingType'] as String? ?? 'hotel';

            if (bookingType == 'hotel') {
              if (item['checkInDate'] != null) {
                eventDate = DateTime.tryParse(item['checkInDate'] as String);
              }
            } else if (bookingType == 'restaurant') {
              if (item['bookingDate'] != null) {
                eventDate = DateTime.tryParse(item['bookingDate'] as String);
              }
            } else if (bookingType == 'event') {
              final event = item['event'] as Map<String, dynamic>?;
              if (event?['startDate'] != null) {
                eventDate = DateTime.tryParse(event!['startDate'] as String);
              }
            } else if (bookingType == 'tour') {
              final tourSchedule = item['tourSchedule'] as Map<String, dynamic>?;
              if (tourSchedule?['date'] != null) {
                eventDate = DateTime.tryParse(tourSchedule!['date'] as String);
              }
            }
          }

          if (eventDate == null) return false;
          return eventDate.isAfter(now);
        }).toList();
      case 'past':
        return items.where((item) {
          final type = item['_type'] as String? ?? 'booking';
          final status = (item['status'] as String? ?? '').toLowerCase();
          if (status == 'cancelled') return false;

          DateTime? eventDate;

          if (type == 'order') {
            // For orders, use deliveryDate or createdAt
            if (item['deliveryDate'] != null) {
              eventDate = DateTime.tryParse(item['deliveryDate'] as String);
            } else if (item['createdAt'] != null) {
              eventDate = DateTime.tryParse(item['createdAt'] as String);
            }
          } else {
            // For bookings, determine event date based on booking type
            final bookingType = item['bookingType'] as String? ?? 'hotel';

            if (bookingType == 'hotel') {
              if (item['checkOutDate'] != null) {
                eventDate = DateTime.tryParse(item['checkOutDate'] as String);
              }
            } else if (bookingType == 'restaurant') {
              if (item['bookingDate'] != null) {
                eventDate = DateTime.tryParse(item['bookingDate'] as String);
              }
            } else if (bookingType == 'event') {
              final event = item['event'] as Map<String, dynamic>?;
              if (event?['startDate'] != null) {
                eventDate = DateTime.tryParse(event!['startDate'] as String);
              }
            } else if (bookingType == 'tour') {
              final tourSchedule = item['tourSchedule'] as Map<String, dynamic>?;
              if (tourSchedule?['date'] != null) {
                eventDate = DateTime.tryParse(tourSchedule!['date'] as String);
              }
            }
          }

          if (eventDate == null) return false;
          return eventDate.isBefore(now);
        }).toList();
      case 'cancelled':
        return items.where((item) {
          final status = (item['status'] as String? ?? '').toLowerCase();
          return status == 'cancelled';
        }).toList();
      default:
        return items;
    }
  }

  /// Build order card similar to booking card
  Widget _buildOrderCard(Map<String, dynamic> order) {
    final orderId = order['id'] as String? ?? '';
    final orderNumber = order['orderNumber'] as String?;
    final status = order['status'] as String? ?? 'pending';
    
    // Get dates
    DateTime? eventDate;
    DateTime? orderDate;
    
    if (order['deliveryDate'] != null) {
      eventDate = DateTime.tryParse(order['deliveryDate'] as String);
    }
    if (order['createdAt'] != null) {
      orderDate = DateTime.tryParse(order['createdAt'] as String);
      if (eventDate == null) {
        eventDate = orderDate;
      }
    }

    // Get listing info
    String name = 'Unknown';
    String location = 'Location not specified';
    String? imageUrl;
    
    final listing = order['listing'] as Map<String, dynamic>?;
    if (listing != null) {
      name = listing['name'] as String? ?? 'Unknown';
      final address = listing['address'] as String?;
      final city = listing['city'] as Map<String, dynamic>?;
      if (address != null && address.isNotEmpty) {
        location = address;
      } else if (city != null && city['name'] != null) {
        location = city['name'] as String;
      }
      
      // Get primary image
      final images = listing['images'] as List<dynamic>?;
      if (images != null && images.isNotEmpty) {
        final image = images[0] as Map<String, dynamic>?;
        final media = image?['media'] as Map<String, dynamic>?;
        imageUrl = media?['url'] as String?;
      }
    }

    // Get price
    final totalAmountValue = order['totalAmount'];
    final totalAmount = totalAmountValue is num
        ? totalAmountValue.toDouble()
        : totalAmountValue is String
            ? double.tryParse(totalAmountValue) ?? 0.0
            : 0.0;
    final currency = order['currency'] as String? ?? 'RWF';

    // Get item count
    final items = order['items'] as List<dynamic>? ?? [];
    final itemCount = items.length;

    final dateFormat = DateFormat('MMM dd, yyyy');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: context.isDarkMode ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Image and Status
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Stack(
              children: [
                // Image
                if (imageUrl != null && imageUrl.isNotEmpty)
                  CachedNetworkImage(
                    imageUrl: imageUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 200,
                      color: context.dividerColor,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: context.primaryColorTheme,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 200,
                      color: context.dividerColor,
                      child: Icon(
                        Icons.image_not_supported,
                        size: 48,
                        color: context.secondaryTextColor,
                      ),
                    ),
                  )
                else
                  Container(
                    height: 200,
                    color: context.dividerColor,
                    child: Icon(
                      Icons.shopping_bag,
                      size: 48,
                      color: context.secondaryTextColor,
                    ),
                  ),
                // Status Badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: context.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                // Order Number Badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      orderNumber ?? orderId.substring(0, 8).toUpperCase(),
                      style: context.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                // Order Type Badge
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.shopping_bag, size: 12, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          'ORDER',
                          style: context.labelSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Order Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: context.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.primaryTextColor,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: context.secondaryTextColor),
                    const SizedBox(width: 4),
                    Text(
                      eventDate != null
                          ? dateFormat.format(eventDate)
                          : 'Date not specified',
                      style: context.bodySmall.copyWith(
                        color: context.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: context.secondaryTextColor),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location,
                        style: context.bodySmall.copyWith(
                          color: context.secondaryTextColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.shopping_cart, size: 16, color: context.secondaryTextColor),
                    const SizedBox(width: 4),
                    Text(
                      'Ordered on ${orderDate != null ? dateFormat.format(orderDate) : "N/A"}',
                      style: context.bodySmall.copyWith(
                        color: context.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$currency ${totalAmount.toStringAsFixed(0)}',
                          style: context.titleLarge.copyWith(
                            fontWeight: FontWeight.w700,
                            color: context.primaryColorTheme,
                          ),
                        ),
                        Text(
                          '$itemCount item${itemCount != 1 ? 's' : ''}',
                          style: context.bodySmall.copyWith(
                            color: context.secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Action Buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildOrderActions(order, orderId, status),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderActions(Map<String, dynamic> order, String orderId, String status) {
    final isCancelled = status.toLowerCase() == 'cancelled';
    
    if (isCancelled) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                _showOrderDetails(order);
              },
              icon: const Icon(Icons.visibility, size: 16),
              label: const Text('View Details'),
              style: OutlinedButton.styleFrom(
                foregroundColor: context.primaryColorTheme,
                backgroundColor: context.cardColor,
                side: BorderSide(color: context.primaryColorTheme),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                _showOrderDetails(order);
              },
              icon: const Icon(Icons.visibility, size: 16),
              label: const Text('View Details'),
              style: OutlinedButton.styleFrom(
                foregroundColor: context.primaryColorTheme,
                backgroundColor: context.cardColor,
                side: BorderSide(color: context.primaryColorTheme),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                _showCancelOrderDialog(order, orderId);
              },
              icon: const Icon(Icons.cancel, size: 16),
              label: const Text('Cancel'),
              style: OutlinedButton.styleFrom(
                foregroundColor: context.errorColor,
                backgroundColor: context.cardColor,
                side: BorderSide(color: context.errorColor),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      );
    }
  }

  void _showOrderDetails(Map<String, dynamic> order) {
    // TODO: Navigate to order detail screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Order details for ${order['orderNumber'] ?? 'order'}'),
        backgroundColor: context.primaryColorTheme,
      ),
    );
  }

  void _showCancelOrderDialog(Map<String, dynamic> order, String orderId) {
    // TODO: Implement order cancellation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Cancel order functionality coming soon'),
        backgroundColor: context.primaryColorTheme,
      ),
    );
  }

  void _showBookingDetails(Map<String, dynamic> booking) {
    final bookingId = booking['id'] as String? ?? 'N/A';
    final bookingNumber = booking['bookingNumber'] as String?;
    final status = booking['status'] as String? ?? 'pending';
    // Handle both string and number types from API
    final totalAmountValue = booking['totalAmount'];
    final totalAmount = totalAmountValue is num
        ? totalAmountValue.toDouble()
        : totalAmountValue is String
            ? double.tryParse(totalAmountValue) ?? 0.0
            : 0.0;
    final currency = booking['currency'] as String? ?? 'RWF';
    final guestCountValue = booking['guestCount'];
    final guestCount = guestCountValue is int
        ? guestCountValue
        : guestCountValue is String
            ? int.tryParse(guestCountValue) ?? 1
            : 1;

    // Get name based on booking type
    String name = 'Unknown';
    final bookingType = booking['bookingType'] as String? ?? 'hotel';
    if (bookingType == 'hotel' || bookingType == 'restaurant') {
      final listing = booking['listing'] as Map<String, dynamic>?;
      name = listing?['name'] as String? ?? 'Unknown';
    } else if (bookingType == 'event') {
      final event = booking['event'] as Map<String, dynamic>?;
      name = event?['name'] as String? ?? 'Unknown';
    } else if (bookingType == 'tour') {
      final tour = booking['tour'] as Map<String, dynamic>?;
      name = tour?['name'] as String? ?? 'Unknown';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.cardColor,
        title: Text(
          'Booking Details',
          style: context.titleMedium.copyWith(
            color: context.primaryTextColor,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Booking ID: ${bookingNumber ?? bookingId}',
              style: context.bodyMedium.copyWith(
                color: context.primaryTextColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Name: $name',
              style: context.bodyMedium.copyWith(
                color: context.primaryTextColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Guests: $guestCount',
              style: context.bodyMedium.copyWith(
                color: context.primaryTextColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Price: ${totalAmount.toStringAsFixed(0)} $currency',
              style: context.bodyMedium.copyWith(
                color: context.primaryTextColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Status: ${status.toUpperCase()}',
              style: context.bodyMedium.copyWith(
                color: context.primaryTextColor,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: context.primaryColorTheme,
            ),
            child: const Text(
              'Close',
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelBookingDialog(Map<String, dynamic> booking, String bookingId) {
    // Get name for display
    String name = 'Unknown';
    final bookingType = booking['bookingType'] as String? ?? 'hotel';
    if (bookingType == 'hotel' || bookingType == 'restaurant') {
      final listing = booking['listing'] as Map<String, dynamic>?;
      name = listing?['name'] as String? ?? 'Unknown';
    } else if (bookingType == 'event') {
      final event = booking['event'] as Map<String, dynamic>?;
      name = event?['name'] as String? ?? 'Unknown';
    } else if (bookingType == 'tour') {
      final tour = booking['tour'] as Map<String, dynamic>?;
      name = tour?['name'] as String? ?? 'Unknown';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.cardColor,
        title: Text(
          'Cancel Booking',
          style: context.titleMedium.copyWith(
            color: context.errorColor,
          ),
        ),
        content: Text(
          'Are you sure you want to cancel your booking for "$name"? This action cannot be undone.',
          style: context.bodyMedium.copyWith(
            color: context.primaryTextColor,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: context.secondaryTextColor,
            ),
            child: const Text('Keep Booking'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _cancelBooking(bookingId);
            },
            style: TextButton.styleFrom(
              foregroundColor: context.errorColor,
            ),
            child: const Text('Cancel Booking'),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelBooking(String bookingId) async {
    try {
      final bookingsService = ref.read(bookingsServiceProvider);
      await bookingsService.cancelBooking(id: bookingId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Booking cancelled successfully!',
            style: context.bodyMedium.copyWith(
              color: Colors.white,
            ),
          ),
          backgroundColor: AppTheme.successColor, // Success color is intentional
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Refresh bookings - invalidate all provider instances for different tabs
      ref.invalidate(bookingsProvider(
        const BookingsParams(page: 1, limit: 100, status: null),
      ));
      ref.invalidate(bookingsProvider(
        const BookingsParams(page: 1, limit: 100, status: 'cancelled'),
      ));
    } catch (e) {
      if (!mounted) return;

      // Extract user-friendly error message
      String errorMessage = 'Failed to cancel booking.';
      final errorString = e.toString();
      
      if (errorString.contains('Cannot cancel this booking') ||
          errorString.contains('cannot be cancelled')) {
        errorMessage = 'This booking cannot be cancelled. It may have already been cancelled, completed, or refunded.';
      } else if (errorString.contains('Unauthorized')) {
        errorMessage = 'You are not authorized to cancel this booking.';
      } else if (errorString.contains('not found')) {
        errorMessage = 'Booking not found.';
      } else if (errorString.contains('Connection timeout') || 
                 errorString.contains('No internet')) {
        errorMessage = 'Network error. Please check your connection and try again.';
      } else if (e is Exception) {
        final message = e.toString();
        // Remove "Exception: " prefix if present
        if (message.startsWith('Exception: ')) {
          errorMessage = message.substring(11);
        } else {
          errorMessage = message;
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errorMessage,
            style: context.bodyMedium.copyWith(
              color: Colors.white,
            ),
          ),
          backgroundColor: context.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showBookAgainDialog(Map<String, dynamic> booking) {
    // Get name for display
    String name = 'Unknown';
    final bookingType = booking['bookingType'] as String? ?? 'hotel';
    if (bookingType == 'hotel' || bookingType == 'restaurant') {
      final listing = booking['listing'] as Map<String, dynamic>?;
      name = listing?['name'] as String? ?? 'Unknown';
      final listingId = listing?['id'] as String?;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: context.cardColor,
          title: Text(
            'Book Again',
            style: context.titleMedium.copyWith(
              color: context.primaryTextColor,
            ),
          ),
          content: Text(
            'Would you like to book "$name" again?',
            style: context.bodyMedium.copyWith(
              color: context.primaryTextColor,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: context.bodyMedium.copyWith(
                  color: context.secondaryTextColor,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Navigate to listing detail or booking screen
                if (listingId != null) {
                  if (bookingType == 'hotel') {
                    context.go('/accommodation/$listingId');
                  } else if (bookingType == 'restaurant') {
                    context.go('/listing/$listingId');
                  }
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: context.primaryColorTheme,
              ),
              child: const Text(
                'Book Now',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    } else if (bookingType == 'event') {
      final event = booking['event'] as Map<String, dynamic>?;
      name = event?['name'] as String? ?? 'Unknown';
      final eventId = event?['id'] as String?;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Book Again',
            style: context.titleMedium,
          ),
          content: Text(
            'Would you like to book "$name" again?',
            style: context.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: context.secondaryTextColor,
              ),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Navigate to event detail
                if (eventId != null) {
                  context.go('/event/$eventId');
                }
              },
              child: Text(
                'Book Now',
                style: context.bodyMedium.copyWith(
                  color: context.primaryColorTheme,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  void _showSearchBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: context.backgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.grey300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Search Bookings',
                    style: context.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    autofocus: true,
                    style: context.bodyMedium.copyWith(
                      color: context.primaryTextColor,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search by name, location, booking or order number...',
                      hintStyle: context.bodyMedium.copyWith(
                        color: context.secondaryTextColor,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: context.secondaryTextColor,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                              icon: Icon(
                                Icons.clear,
                                color: context.secondaryTextColor,
                              ),
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: context.grey300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: context.grey300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: context.primaryColorTheme),
                      ),
                      filled: true,
                      fillColor: context.backgroundColor,
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: context.secondaryTextColor,
                            side: BorderSide(color: context.grey300),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Clear'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Search'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _searchItems(
    List<Map<String, dynamic>> items,
    String query,
  ) {
    if (query.isEmpty) return items;

    final lowerQuery = query.toLowerCase().trim();

    return items.where((item) {
      final type = item['_type'] as String? ?? 'booking';
      
      // Search by booking/order number
      final number = type == 'order' 
          ? (item['orderNumber'] as String? ?? '').toLowerCase()
          : (item['bookingNumber'] as String? ?? '').toLowerCase();
      if (number.contains(lowerQuery)) return true;

      // Search by name (listing/event/tour name)
      String name = '';
      
      if (type == 'order') {
        final listing = item['listing'] as Map<String, dynamic>?;
        name = (listing?['name'] as String? ?? '').toLowerCase();
      } else {
        final bookingType = item['bookingType'] as String? ?? 'hotel';
        
        if (bookingType == 'hotel' || bookingType == 'restaurant') {
          final listing = item['listing'] as Map<String, dynamic>?;
          name = (listing?['name'] as String? ?? '').toLowerCase();
        } else if (bookingType == 'event') {
          final event = item['event'] as Map<String, dynamic>?;
          name = (event?['name'] as String? ?? '').toLowerCase();
        } else if (bookingType == 'tour') {
          final tour = item['tour'] as Map<String, dynamic>?;
          name = (tour?['name'] as String? ?? '').toLowerCase();
        }
      }
      
      if (name.contains(lowerQuery)) return true;

      // Search by location
      String location = '';
      
      if (type == 'order') {
        final listing = item['listing'] as Map<String, dynamic>?;
        final address = listing?['address'] as String? ?? '';
        final city = listing?['city'] as Map<String, dynamic>?;
        final cityName = city?['name'] as String? ?? '';
        location = '$address $cityName'.toLowerCase();
      } else {
        final bookingType = item['bookingType'] as String? ?? 'hotel';
        
        if (bookingType == 'hotel' || bookingType == 'restaurant') {
          final listing = item['listing'] as Map<String, dynamic>?;
          final address = listing?['address'] as String? ?? '';
          final city = listing?['city'] as Map<String, dynamic>?;
          final cityName = city?['name'] as String? ?? '';
          location = '$address $cityName'.toLowerCase();
        } else if (bookingType == 'event') {
          final event = item['event'] as Map<String, dynamic>?;
          location = (event?['locationName'] as String? ?? 
                     event?['venueName'] as String? ?? 
                     event?['address'] as String? ?? '').toLowerCase();
        }
      }
      
      if (location.contains(lowerQuery)) return true;

      // Search by status
      final status = (item['status'] as String? ?? '').toLowerCase();
      if (status.contains(lowerQuery)) return true;

      return false;
    }).toList();
  }
}
