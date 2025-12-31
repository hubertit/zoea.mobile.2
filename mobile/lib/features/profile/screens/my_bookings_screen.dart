import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/providers/bookings_provider.dart';

class MyBookingsScreen extends ConsumerStatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  ConsumerState<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends ConsumerState<MyBookingsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'My Bookings',
          style: AppTheme.titleLarge,
        ),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () => context.go('/profile'),
          icon: const Icon(Icons.chevron_left, size: 32),
          style: IconButton.styleFrom(
            foregroundColor: AppTheme.primaryTextColor,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _showSearchBottomSheet();
            },
            icon: const Icon(Icons.search_outlined),
            style: IconButton.styleFrom(
              backgroundColor: AppTheme.dividerColor,
              foregroundColor: AppTheme.primaryTextColor,
            ),
          ),
          const SizedBox(width: 16),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryColor,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.secondaryTextColor,
          labelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
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

    // Fetch bookings from API
    final bookingsAsync = ref.watch(
      bookingsProvider(
        BookingsParams(
          page: 1,
          limit: 100, // Fetch all bookings for now
          status: statusFilter,
        ),
      ),
    );

    return bookingsAsync.when(
      data: (response) {
        final bookings = (response['data'] as List<dynamic>?)
                ?.map((b) => b as Map<String, dynamic>)
                .toList() ??
            [];

        // Filter bookings based on tab
        var filteredBookings = _filterBookings(bookings, filter);
        
        // Apply search filter if search query exists
        if (_searchQuery.isNotEmpty) {
          filteredBookings = _searchBookings(filteredBookings, _searchQuery);
        }

        if (filteredBookings.isEmpty) {
          return _buildEmptyState(filter);
        }

        return RefreshIndicator(
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
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredBookings.length,
            itemBuilder: (context, index) {
              final booking = filteredBookings[index];
              return _buildBookingCard(booking);
            },
          ),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(
          color: AppTheme.primaryColor,
        ),
      ),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.secondaryTextColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load bookings',
              style: AppTheme.titleMedium.copyWith(
                color: AppTheme.secondaryTextColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.secondaryTextColor,
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
        title = 'No Upcoming Bookings';
        subtitle = 'You don\'t have any upcoming reservations';
        icon = Icons.event_available;
        break;
      case 'past':
        title = 'No Past Bookings';
        subtitle = 'Your booking history will appear here';
        icon = Icons.history;
        break;
      case 'cancelled':
        title = 'No Cancelled Bookings';
        subtitle = 'Cancelled bookings will appear here';
        icon = Icons.cancel;
        break;
      default:
        title = 'No Bookings Yet';
        subtitle = 'Start exploring and make your first booking!';
        icon = Icons.explore;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppTheme.dividerColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 48,
              color: AppTheme.secondaryTextColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: AppTheme.titleLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.secondaryTextColor,
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
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
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
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                      color: AppTheme.dividerColor,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 200,
                      color: AppTheme.dividerColor,
                      child: Icon(
                        _getBookingTypeIcon(bookingType),
                        size: 64,
                        color: AppTheme.secondaryTextColor,
                      ),
                    ),
                  )
                else
                  Container(
                    height: 200,
                    color: AppTheme.dividerColor,
                    child: Icon(
                      _getBookingTypeIcon(bookingType),
                      size: 64,
                      color: AppTheme.secondaryTextColor,
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
                      style: AppTheme.labelSmall.copyWith(
                        color: Colors.white,
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
                      style: AppTheme.labelSmall.copyWith(
                        color: Colors.white,
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
                  style: AppTheme.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Date and Time
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: AppTheme.secondaryTextColor,
                    ),
                    const SizedBox(width: 8),
                    if (eventDate != null)
                      Text(
                        dateFormat.format(eventDate),
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.secondaryTextColor,
                        ),
                      ),
                    if (bookingTime != null) ...[
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.access_time,
                        size: 16,
                        color: AppTheme.secondaryTextColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        bookingTime,
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.secondaryTextColor,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                // Location
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 16,
                      color: AppTheme.secondaryTextColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        location,
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.secondaryTextColor,
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
                      const Icon(
                        Icons.shopping_cart,
                        size: 16,
                        color: AppTheme.secondaryTextColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Booked on ${dateFormat.format(bookingDate)}',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.secondaryTextColor,
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
                      style: AppTheme.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    Text(
                      '$guestCount guest${guestCount > 1 ? 's' : ''}',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.secondaryTextColor,
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
                foregroundColor: AppTheme.primaryColor,
                backgroundColor: AppTheme.backgroundColor,
                side: const BorderSide(color: AppTheme.primaryColor),
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
                foregroundColor: AppTheme.primaryColor,
                backgroundColor: AppTheme.backgroundColor,
                side: const BorderSide(color: AppTheme.primaryColor),
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
                foregroundColor: Colors.red,
                backgroundColor: AppTheme.backgroundColor,
                side: const BorderSide(color: Colors.red),
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
                foregroundColor: AppTheme.primaryColor,
                backgroundColor: AppTheme.backgroundColor,
                side: const BorderSide(color: AppTheme.primaryColor),
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
        return AppTheme.successColor;
      case 'pending':
        return Colors.orange;
      case 'upcoming':
        return AppTheme.primaryColor;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      case 'checked_in':
        return Colors.green;
      default:
        return AppTheme.secondaryTextColor;
    }
  }

  List<Map<String, dynamic>> _filterBookings(
      List<Map<String, dynamic>> bookings, String filter) {
    final now = DateTime.now();

    switch (filter) {
      case 'upcoming':
        return bookings.where((booking) {
          final status = (booking['status'] as String? ?? '').toLowerCase();
          if (status == 'cancelled') return false;

          // Determine event date based on booking type
          DateTime? eventDate;
          final bookingType = booking['bookingType'] as String? ?? 'hotel';

          if (bookingType == 'hotel') {
            if (booking['checkInDate'] != null) {
              eventDate = DateTime.parse(booking['checkInDate'] as String);
            }
          } else if (bookingType == 'restaurant') {
            if (booking['bookingDate'] != null) {
              eventDate = DateTime.parse(booking['bookingDate'] as String);
            }
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

          if (eventDate == null) return false;
          return eventDate.isAfter(now);
        }).toList();
      case 'past':
        return bookings.where((booking) {
          final status = (booking['status'] as String? ?? '').toLowerCase();
          if (status == 'cancelled') return false;

          // Determine event date based on booking type
          DateTime? eventDate;
          final bookingType = booking['bookingType'] as String? ?? 'hotel';

          if (bookingType == 'hotel') {
            if (booking['checkOutDate'] != null) {
              eventDate = DateTime.parse(booking['checkOutDate'] as String);
            }
          } else if (bookingType == 'restaurant') {
            if (booking['bookingDate'] != null) {
              eventDate = DateTime.parse(booking['bookingDate'] as String);
            }
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

          if (eventDate == null) return false;
          return eventDate.isBefore(now);
        }).toList();
      case 'cancelled':
        return bookings.where((booking) {
          final status = (booking['status'] as String? ?? '').toLowerCase();
          return status == 'cancelled';
        }).toList();
      default:
        return bookings;
    }
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
        title: Text(
          'Booking Details',
          style: AppTheme.titleMedium,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Booking ID: ${bookingNumber ?? bookingId}'),
            const SizedBox(height: 8),
            Text('Name: $name'),
            const SizedBox(height: 8),
            Text('Guests: $guestCount'),
            const SizedBox(height: 8),
            Text('Price: ${totalAmount.toStringAsFixed(0)} $currency'),
            const SizedBox(height: 8),
            Text('Status: ${status.toUpperCase()}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.primaryColor,
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
        title: Text(
          'Cancel Booking',
          style: AppTheme.titleMedium.copyWith(
            color: Colors.red,
          ),
        ),
        content: Text(
          'Are you sure you want to cancel your booking for "$name"? This action cannot be undone.',
          style: AppTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Keep Booking',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.secondaryTextColor,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _cancelBooking(bookingId);
            },
            child: Text(
              'Cancel Booking',
              style: AppTheme.bodyMedium.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
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
            style: AppTheme.bodyMedium.copyWith(
              color: Colors.white,
            ),
          ),
          backgroundColor: AppTheme.successColor,
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
            style: AppTheme.bodyMedium.copyWith(
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.red,
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
          title: Text(
            'Book Again',
            style: AppTheme.titleMedium,
          ),
          content: Text(
            'Would you like to book "$name" again?',
            style: AppTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.secondaryTextColor,
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
              child: Text(
                'Book Now',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.primaryColor,
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
            style: AppTheme.titleMedium,
          ),
          content: Text(
            'Would you like to book "$name" again?',
            style: AppTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.secondaryTextColor,
                ),
              ),
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
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.primaryColor,
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
                    style: AppTheme.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Search by name, location, or booking number...',
                      hintStyle: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.secondaryTextColor,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppTheme.secondaryTextColor,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                              icon: const Icon(
                                Icons.clear,
                                color: AppTheme.secondaryTextColor,
                              ),
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.primaryColor),
                      ),
                      filled: true,
                      fillColor: AppTheme.backgroundColor,
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
                            foregroundColor: AppTheme.secondaryTextColor,
                            side: BorderSide(color: Colors.grey[300]!),
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

  List<Map<String, dynamic>> _searchBookings(
    List<Map<String, dynamic>> bookings,
    String query,
  ) {
    if (query.isEmpty) return bookings;

    final lowerQuery = query.toLowerCase().trim();

    return bookings.where((booking) {
      // Search by booking number
      final bookingNumber = (booking['bookingNumber'] as String? ?? '').toLowerCase();
      if (bookingNumber.contains(lowerQuery)) return true;

      // Search by name (listing/event/tour name)
      String name = '';
      final bookingType = booking['bookingType'] as String? ?? 'hotel';
      
      if (bookingType == 'hotel' || bookingType == 'restaurant') {
        final listing = booking['listing'] as Map<String, dynamic>?;
        name = (listing?['name'] as String? ?? '').toLowerCase();
      } else if (bookingType == 'event') {
        final event = booking['event'] as Map<String, dynamic>?;
        name = (event?['name'] as String? ?? '').toLowerCase();
      } else if (bookingType == 'tour') {
        final tour = booking['tour'] as Map<String, dynamic>?;
        name = (tour?['name'] as String? ?? '').toLowerCase();
      }
      
      if (name.contains(lowerQuery)) return true;

      // Search by location
      String location = '';
      if (bookingType == 'hotel' || bookingType == 'restaurant') {
        final listing = booking['listing'] as Map<String, dynamic>?;
        final address = listing?['address'] as String? ?? '';
        final city = listing?['city'] as Map<String, dynamic>?;
        final cityName = city?['name'] as String? ?? '';
        location = '$address $cityName'.toLowerCase();
      } else if (bookingType == 'event') {
        final event = booking['event'] as Map<String, dynamic>?;
        location = (event?['locationName'] as String? ?? 
                   event?['venueName'] as String? ?? 
                   event?['address'] as String? ?? '').toLowerCase();
      }
      
      if (location.contains(lowerQuery)) return true;

      // Search by status
      final status = (booking['status'] as String? ?? '').toLowerCase();
      if (status.contains(lowerQuery)) return true;

      return false;
    }).toList();
  }
}
