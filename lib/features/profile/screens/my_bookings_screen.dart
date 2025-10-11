import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';

class MyBookingsScreen extends ConsumerStatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  ConsumerState<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends ConsumerState<MyBookingsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
          icon: const Icon(Icons.chevron_left),
          style: IconButton.styleFrom(
            foregroundColor: AppTheme.primaryTextColor,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Add search functionality
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
    final bookings = _getMockBookings();
    final filteredBookings = _filterBookings(bookings, filter);
    
    if (filteredBookings.isEmpty) {
      return _buildEmptyState(filter);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredBookings.length,
      itemBuilder: (context, index) {
        final booking = filteredBookings[index];
        return _buildBookingCard(booking);
      },
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
            decoration: BoxDecoration(
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
    final bookingDate = booking['bookingDate'] as DateTime;
    final eventDate = booking['eventDate'] as DateTime;
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('HH:mm');
    final status = booking['status'] as String;

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
          // Event Image and Status
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: booking['image'] as String,
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
                    child: const Icon(
                      Icons.event,
                      size: 64,
                      color: AppTheme.secondaryTextColor,
                    ),
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
                // Booking ID
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
                      '#${booking['id']}',
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
                // Event Name
                Text(
                  booking['eventName'] as String,
                  style: AppTheme.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Event Date and Time
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: AppTheme.secondaryTextColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      dateFormat.format(eventDate),
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.secondaryTextColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: AppTheme.secondaryTextColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      timeFormat.format(eventDate),
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Location
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: AppTheme.secondaryTextColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        booking['location'] as String,
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
                Row(
                  children: [
                    Icon(
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
                      '${booking['price']} RWF',
                      style: AppTheme.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    Text(
                      '${booking['guests']} guest${booking['guests'] > 1 ? 's' : ''}',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Action Buttons
                _buildActionButtons(booking),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> booking) {
    final status = booking['status'] as String;
    
    if (status == 'cancelled') {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                // TODO: Book again
                _showBookAgainDialog(booking);
              },
              icon: const Icon(Icons.repeat, size: 16),
              label: const Text('Book Again'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
                backgroundColor: AppTheme.backgroundColor,
                side: BorderSide(color: AppTheme.primaryColor),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      );
    } else if (status == 'upcoming') {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                // TODO: View details
                _showBookingDetails(booking);
              },
              icon: const Icon(Icons.visibility, size: 16),
              label: const Text('View Details'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
                backgroundColor: AppTheme.backgroundColor,
                side: BorderSide(color: AppTheme.primaryColor),
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
                _showCancelBookingDialog(booking);
              },
              icon: const Icon(Icons.cancel, size: 16),
              label: const Text('Cancel'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                backgroundColor: AppTheme.backgroundColor,
                side: BorderSide(color: Colors.red),
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
                side: BorderSide(color: AppTheme.primaryColor),
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
      case 'upcoming':
        return AppTheme.primaryColor;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return AppTheme.secondaryTextColor;
    }
  }

  List<Map<String, dynamic>> _filterBookings(List<Map<String, dynamic>> bookings, String filter) {
    final now = DateTime.now();
    
    switch (filter) {
      case 'upcoming':
        return bookings.where((booking) {
          final eventDate = booking['eventDate'] as DateTime;
          return eventDate.isAfter(now) && booking['status'] != 'cancelled';
        }).toList();
      case 'past':
        return bookings.where((booking) {
          final eventDate = booking['eventDate'] as DateTime;
          return eventDate.isBefore(now) && booking['status'] != 'cancelled';
        }).toList();
      case 'cancelled':
        return bookings.where((booking) => booking['status'] == 'cancelled').toList();
      default:
        return bookings;
    }
  }

  List<Map<String, dynamic>> _getMockBookings() {
    return [
      {
        'id': 'BK001',
        'eventName': 'Kigali Jazz Festival',
        'location': 'Kigali Convention Centre',
        'eventDate': DateTime.now().add(const Duration(days: 15)),
        'bookingDate': DateTime.now().subtract(const Duration(days: 5)),
        'price': 25000,
        'guests': 2,
        'status': 'upcoming',
        'image': 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400&h=300&fit=crop',
      },
      {
        'id': 'BK002',
        'eventName': 'Volcanoes National Park Tour',
        'location': 'Musanze, Northern Province',
        'eventDate': DateTime.now().subtract(const Duration(days: 10)),
        'bookingDate': DateTime.now().subtract(const Duration(days: 20)),
        'price': 150000,
        'guests': 1,
        'status': 'completed',
        'image': 'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=400&h=300&fit=crop',
      },
      {
        'id': 'BK003',
        'eventName': 'Tech Meetup Rwanda',
        'location': 'KLab Innovation Hub',
        'eventDate': DateTime.now().subtract(const Duration(days: 30)),
        'bookingDate': DateTime.now().subtract(const Duration(days: 35)),
        'price': 0,
        'guests': 1,
        'status': 'cancelled',
        'image': 'https://images.unsplash.com/photo-1511578314322-379afb476865?w=400&h=300&fit=crop',
      },
      {
        'id': 'BK004',
        'eventName': 'Lake Kivu Boat Tour',
        'location': 'Rubavu, Western Province',
        'eventDate': DateTime.now().add(const Duration(days: 7)),
        'bookingDate': DateTime.now().subtract(const Duration(days: 2)),
        'price': 45000,
        'guests': 4,
        'status': 'upcoming',
        'image': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=300&fit=crop',
      },
      {
        'id': 'BK005',
        'eventName': 'Art Exhibition Opening',
        'location': 'Inema Arts Center',
        'eventDate': DateTime.now().subtract(const Duration(days: 5)),
        'bookingDate': DateTime.now().subtract(const Duration(days: 8)),
        'price': 10000,
        'guests': 2,
        'status': 'completed',
        'image': 'https://images.unsplash.com/photo-1541961017774-22349e4a1262?w=400&h=300&fit=crop',
      },
    ];
  }

  void _showBookingDetails(Map<String, dynamic> booking) {
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
            Text('Booking ID: ${booking['id']}'),
            const SizedBox(height: 8),
            Text('Event: ${booking['eventName']}'),
            const SizedBox(height: 8),
            Text('Location: ${booking['location']}'),
            const SizedBox(height: 8),
            Text('Guests: ${booking['guests']}'),
            const SizedBox(height: 8),
            Text('Price: ${booking['price']} RWF'),
            const SizedBox(height: 8),
            Text('Status: ${booking['status'].toUpperCase()}'),
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

  void _showCancelBookingDialog(Map<String, dynamic> booking) {
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
          'Are you sure you want to cancel this booking? This action cannot be undone.',
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
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement cancellation logic
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

  void _showBookAgainDialog(Map<String, dynamic> booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Book Again',
          style: AppTheme.titleMedium,
        ),
        content: Text(
          'Would you like to book "${booking['eventName']}" again?',
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
              // TODO: Navigate to booking flow
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Redirecting to booking...',
                    style: AppTheme.bodyMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  backgroundColor: AppTheme.primaryColor,
                  behavior: SnackBarBehavior.floating,
                ),
              );
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
