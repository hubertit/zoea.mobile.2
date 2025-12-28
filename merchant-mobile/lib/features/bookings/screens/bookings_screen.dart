import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/booking.dart';

class BookingsScreen extends ConsumerStatefulWidget {
  const BookingsScreen({super.key});

  @override
  ConsumerState<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends ConsumerState<BookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Booking> _bookings = _getMockBookings();

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

  List<Booking> _getFilteredBookings(BookingStatus? status) {
    if (status == null) return _bookings;
    return _bookings.where((b) => b.status == status).toList();
  }

  void _updateBookingStatus(String bookingId, BookingStatus newStatus) {
    setState(() {
      _bookings = _bookings.map((b) {
        if (b.id == bookingId) {
          return Booking(
            id: b.id,
            listingId: b.listingId,
            businessId: b.businessId,
            customerId: b.customerId,
            customerName: b.customerName,
            customerEmail: b.customerEmail,
            customerPhone: b.customerPhone,
            type: b.type,
            status: newStatus,
            totalAmount: b.totalAmount,
            currency: b.currency,
            paymentMethod: b.paymentMethod,
            paymentStatus: b.paymentStatus,
            createdAt: b.createdAt,
            updatedAt: DateTime.now(),
            listingName: b.listingName,
            businessName: b.businessName,
            specialRequests: b.specialRequests,
            accommodationDetails: b.accommodationDetails,
            diningDetails: b.diningDetails,
            tourDetails: b.tourDetails,
            eventDetails: b.eventDetails,
          );
        }
        return b;
      }).toList();
    });
  }

  void _confirmBooking(Booking booking) {
    _updateBookingStatus(booking.id, BookingStatus.confirmed);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Booking for ${booking.customerName} confirmed'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _declineBooking(Booking booking) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Decline Booking'),
        content: Text('Are you sure you want to decline ${booking.customerName}\'s booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _updateBookingStatus(booking.id, BookingStatus.cancelled);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Booking declined'),
                  backgroundColor: AppTheme.errorColor,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Decline'),
          ),
        ],
      ),
    );
  }

  void _checkInGuest(Booking booking) {
    _updateBookingStatus(booking.id, BookingStatus.checkedIn);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${booking.customerName} checked in successfully'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.backgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Filter by Type',
                style: AppTheme.headlineSmall.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Text('🏨', style: TextStyle(fontSize: 24)),
              title: const Text('Accommodation'),
              onTap: () {
                Navigator.pop(context);
                _filterByType(BookingType.accommodation);
              },
            ),
            ListTile(
              leading: const Text('🍽️', style: TextStyle(fontSize: 24)),
              title: const Text('Dining'),
              onTap: () {
                Navigator.pop(context);
                _filterByType(BookingType.dining);
              },
            ),
            ListTile(
              leading: const Text('🥾', style: TextStyle(fontSize: 24)),
              title: const Text('Tours'),
              onTap: () {
                Navigator.pop(context);
                _filterByType(BookingType.tour);
              },
            ),
            ListTile(
              leading: const Text('🎫', style: TextStyle(fontSize: 24)),
              title: const Text('Events'),
              onTap: () {
                Navigator.pop(context);
                _filterByType(BookingType.event);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.clear_all),
              title: const Text('Clear Filters'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _bookings = _getMockBookings();
                });
              },
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ),
    );
  }

  void _filterByType(BookingType type) {
    setState(() {
      _bookings = _getMockBookings().where((b) => b.type == type).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        title: Text(
          'Bookings',
          style: AppTheme.headlineSmall.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: _showFilterOptions,
            icon: const Icon(Icons.filter_list_rounded),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.secondaryTextColor,
          indicatorColor: AppTheme.primaryColor,
          isScrollable: true,
          tabs: [
            Tab(text: 'All (${_bookings.length})'),
            Tab(text: 'Pending (${_getFilteredBookings(BookingStatus.pending).length})'),
            Tab(text: 'Confirmed (${_getFilteredBookings(BookingStatus.confirmed).length})'),
            Tab(text: 'Completed (${_getFilteredBookings(BookingStatus.completed).length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBookingsList(null),
          _buildBookingsList(BookingStatus.pending),
          _buildBookingsList(BookingStatus.confirmed),
          _buildBookingsList(BookingStatus.completed),
        ],
      ),
    );
  }

  Widget _buildBookingsList(BookingStatus? status) {
    final bookings = _getFilteredBookings(status);

    if (bookings.isEmpty) {
      return _buildEmptyState(status);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        return _BookingCard(
          booking: bookings[index],
          onTap: () => _showBookingDetails(bookings[index]),
        );
      },
    );
  }

  Widget _buildEmptyState(BookingStatus? status) {
    String message;
    switch (status) {
      case BookingStatus.pending:
        message = 'No pending bookings';
        break;
      case BookingStatus.confirmed:
        message = 'No confirmed bookings';
        break;
      case BookingStatus.completed:
        message = 'No completed bookings';
        break;
      default:
        message = 'No bookings yet';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 64,
            color: AppTheme.secondaryTextColor.withOpacity(0.5),
          ),
          const SizedBox(height: AppTheme.spacing16),
          Text(
            message,
            style: AppTheme.bodyLarge.copyWith(
              color: AppTheme.secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  void _showBookingDetails(Booking booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _BookingDetailsSheet(
        booking: booking,
        onConfirm: () {
          Navigator.pop(context);
          _confirmBooking(booking);
        },
        onDecline: () {
          Navigator.pop(context);
          _declineBooking(booking);
        },
        onCheckIn: () {
          Navigator.pop(context);
          _checkInGuest(booking);
        },
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback onTap;

  const _BookingCard({
    required this.booking,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacing12),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius12),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius12),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        booking.type.icon,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.customerName,
                          style: AppTheme.titleMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          booking.listingName ?? 'Unknown Listing',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(booking.status),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoItem(
                    Icons.calendar_today_outlined,
                    DateFormat('MMM dd, yyyy').format(booking.bookingDate),
                  ),
                  const SizedBox(width: 16),
                  _buildInfoItem(
                    _getGuestIcon(booking.type),
                    _getGuestText(booking),
                  ),
                  const Spacer(),
                  Text(
                    '${booking.currency} ${booking.totalAmount.toStringAsFixed(0)}',
                    style: AppTheme.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getGuestIcon(BookingType type) {
    switch (type) {
      case BookingType.accommodation:
        return Icons.hotel_outlined;
      case BookingType.dining:
        return Icons.people_outline;
      case BookingType.tour:
        return Icons.hiking;
      case BookingType.event:
        return Icons.confirmation_number_outlined;
    }
  }

  String _getGuestText(Booking booking) {
    switch (booking.type) {
      case BookingType.accommodation:
        final details = booking.accommodationDetails;
        return '${details?.nights ?? 1} nights, ${booking.guestCount} guests';
      case BookingType.dining:
        return '${booking.guestCount} guests';
      case BookingType.tour:
        return '${booking.guestCount} participants';
      case BookingType.event:
        return '${booking.guestCount} tickets';
    }
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppTheme.secondaryTextColor),
        const SizedBox(width: 4),
        Text(
          text,
          style: AppTheme.bodySmall.copyWith(
            color: AppTheme.secondaryTextColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(BookingStatus status) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case BookingStatus.pending:
        bgColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange;
        break;
      case BookingStatus.confirmed:
        bgColor = Colors.blue.withOpacity(0.1);
        textColor = Colors.blue;
        break;
      case BookingStatus.checkedIn:
        bgColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green;
        break;
      case BookingStatus.completed:
        bgColor = Colors.grey.withOpacity(0.1);
        textColor = Colors.grey;
        break;
      case BookingStatus.cancelled:
      case BookingStatus.noShow:
        bgColor = Colors.red.withOpacity(0.1);
        textColor = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _BookingDetailsSheet extends StatelessWidget {
  final Booking booking;
  final VoidCallback? onConfirm;
  final VoidCallback? onDecline;
  final VoidCallback? onCheckIn;

  const _BookingDetailsSheet({
    required this.booking,
    this.onConfirm,
    this.onDecline,
    this.onCheckIn,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(AppTheme.spacing20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.dividerColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacing20),
                Row(
                  children: [
                    Text(
                      '${booking.type.icon} ${booking.type.displayName} Booking',
                      style: AppTheme.headlineSmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    _buildStatusChip(booking.status),
                  ],
                ),
                const SizedBox(height: AppTheme.spacing24),
                _buildSection('Customer', [
                  _buildDetailRow('Name', booking.customerName),
                  if (booking.customerEmail != null)
                    _buildDetailRow('Email', booking.customerEmail!),
                  if (booking.customerPhone != null)
                    _buildDetailRow('Phone', booking.customerPhone!),
                ]),
                const SizedBox(height: AppTheme.spacing20),
                _buildSection('Booking Info', _getBookingInfoRows()),
                const SizedBox(height: AppTheme.spacing20),
                _buildSection('Payment', [
                  _buildDetailRow('Amount', '${booking.currency} ${booking.totalAmount.toStringAsFixed(0)}'),
                  _buildDetailRow('Method', booking.paymentMethod.displayName),
                  _buildDetailRow('Status', booking.paymentStatus.displayName),
                ]),
                if (booking.specialRequests != null) ...[
                  const SizedBox(height: AppTheme.spacing20),
                  _buildSection('Special Requests', [
                    Text(
                      booking.specialRequests!,
                      style: AppTheme.bodyMedium,
                    ),
                  ]),
                ],
                const SizedBox(height: AppTheme.spacing24),
                if (booking.status == BookingStatus.pending) ...[
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onDecline,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.errorColor,
                            side: const BorderSide(color: AppTheme.errorColor),
                          ),
                          child: const Text('Decline'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onConfirm,
                          child: const Text('Confirm'),
                        ),
                      ),
                    ],
                  ),
                ],
                if (booking.status == BookingStatus.confirmed) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onCheckIn,
                      icon: const Icon(Icons.login_rounded),
                      label: const Text('Check In Guest'),
                    ),
                  ),
                ],
                const SizedBox(height: AppTheme.spacing16),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _getBookingInfoRows() {
    final rows = <Widget>[
      _buildDetailRow('Listing', booking.listingName ?? 'N/A'),
      _buildDetailRow('Business', booking.businessName ?? 'N/A'),
    ];

    switch (booking.type) {
      case BookingType.accommodation:
        final details = booking.accommodationDetails;
        if (details != null) {
          rows.add(_buildDetailRow('Check-in', DateFormat('MMM dd, yyyy').format(details.checkInDate)));
          rows.add(_buildDetailRow('Check-out', DateFormat('MMM dd, yyyy').format(details.checkOutDate)));
          rows.add(_buildDetailRow('Nights', '${details.nights}'));
          rows.add(_buildDetailRow('Rooms', '${details.roomCount}'));
          rows.add(_buildDetailRow('Guests', '${details.guestCount}'));
        }
        break;
      case BookingType.dining:
        final details = booking.diningDetails;
        if (details != null) {
          rows.add(_buildDetailRow('Date', DateFormat('MMM dd, yyyy').format(details.reservationDate)));
          rows.add(_buildDetailRow('Time', details.timeSlot));
          rows.add(_buildDetailRow('Party Size', '${details.partySize}'));
          if (details.tablePreference != null) {
            rows.add(_buildDetailRow('Table', details.tablePreference!));
          }
        }
        break;
      case BookingType.tour:
        final details = booking.tourDetails;
        if (details != null) {
          rows.add(_buildDetailRow('Tour Date', DateFormat('MMM dd, yyyy').format(details.tourDate)));
          rows.add(_buildDetailRow('Participants', '${details.participants}'));
          if (details.pickupLocation != null) {
            rows.add(_buildDetailRow('Pickup', details.pickupLocation!));
          }
        }
        break;
      case BookingType.event:
        final details = booking.eventDetails;
        if (details != null) {
          rows.add(_buildDetailRow('Event Date', DateFormat('MMM dd, yyyy').format(details.eventDate)));
          rows.add(_buildDetailRow('Ticket Type', details.ticketType));
          rows.add(_buildDetailRow('Tickets', '${details.ticketCount}'));
        }
        break;
    }

    return rows;
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.secondaryTextColor,
          ),
        ),
        const SizedBox(height: AppTheme.spacing12),
        Container(
          padding: const EdgeInsets.all(AppTheme.spacing16),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(AppTheme.borderRadius12),
            border: Border.all(color: AppTheme.dividerColor),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.secondaryTextColor,
            ),
          ),
          Text(
            value,
            style: AppTheme.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(BookingStatus status) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case BookingStatus.pending:
        bgColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange;
        break;
      case BookingStatus.confirmed:
        bgColor = Colors.blue.withOpacity(0.1);
        textColor = Colors.blue;
        break;
      case BookingStatus.checkedIn:
        bgColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green;
        break;
      case BookingStatus.completed:
        bgColor = Colors.grey.withOpacity(0.1);
        textColor = Colors.grey;
        break;
      case BookingStatus.cancelled:
      case BookingStatus.noShow:
        bgColor = Colors.red.withOpacity(0.1);
        textColor = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

List<Booking> _getMockBookings() {
  return [
    // Accommodation booking
    Booking(
      id: '1',
      listingId: 'l1',
      businessId: 'b1',
      customerId: 'c1',
      customerName: 'John Doe',
      customerEmail: 'john@email.com',
      customerPhone: '+250788123456',
      type: BookingType.accommodation,
      status: BookingStatus.pending,
      totalAmount: 300000,
      currency: 'RWF',
      paymentMethod: PaymentMethod.momo,
      paymentStatus: PaymentStatus.paid,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      updatedAt: DateTime.now(),
      listingName: 'Deluxe Room',
      businessName: 'Kigali Heights Hotel',
      specialRequests: 'Late check-in around 10 PM',
      accommodationDetails: AccommodationBookingDetails(
        checkInDate: DateTime.now().add(const Duration(days: 1)),
        checkOutDate: DateTime.now().add(const Duration(days: 3)),
        nights: 2,
        roomCount: 1,
        guestCount: 2,
        roomType: 'Deluxe Room',
      ),
    ),
    // Dining booking
    Booking(
      id: '2',
      listingId: 'l3',
      businessId: 'b2',
      customerId: 'c2',
      customerName: 'Jane Smith',
      customerEmail: 'jane@email.com',
      type: BookingType.dining,
      status: BookingStatus.confirmed,
      totalAmount: 0,
      currency: 'RWF',
      paymentMethod: PaymentMethod.cash,
      paymentStatus: PaymentStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      updatedAt: DateTime.now(),
      listingName: 'Terrace Table',
      businessName: 'Ubumwe Restaurant',
      diningDetails: DiningBookingDetails(
        reservationDate: DateTime.now().add(const Duration(days: 2)),
        timeSlot: '19:00',
        partySize: 4,
        tablePreference: 'Terrace with view',
        occasion: 'Birthday dinner',
      ),
    ),
    // Tour booking
    Booking(
      id: '3',
      listingId: 'l4',
      businessId: 'b3',
      customerId: 'c3',
      customerName: 'Mike Johnson',
      customerEmail: 'mike@email.com',
      customerPhone: '+1234567890',
      type: BookingType.tour,
      status: BookingStatus.confirmed,
      totalAmount: 3000,
      currency: 'USD',
      paymentMethod: PaymentMethod.card,
      paymentStatus: PaymentStatus.paid,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now(),
      listingName: 'Gorilla Trekking Experience',
      businessName: 'Rwanda Adventures',
      tourDetails: TourBookingDetails(
        tourDate: DateTime.now().add(const Duration(days: 7)),
        participants: 2,
        pickupLocation: 'Kigali Serena Hotel',
        pickupTime: '05:00',
        participantNames: ['Mike Johnson', 'Sarah Johnson'],
      ),
    ),
    // Event booking
    Booking(
      id: '4',
      listingId: 'l5',
      businessId: 'b4',
      customerId: 'c4',
      customerName: 'Sarah Williams',
      type: BookingType.event,
      status: BookingStatus.completed,
      totalAmount: 150000,
      currency: 'RWF',
      paymentMethod: PaymentMethod.zoeaCard,
      paymentStatus: PaymentStatus.paid,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      listingName: 'Jazz Night',
      businessName: 'Kigali Convention Centre',
      eventDetails: EventBookingDetails(
        eventDate: DateTime.now().subtract(const Duration(days: 5)),
        ticketType: 'VIP',
        ticketCount: 2,
        attendeeNames: ['Sarah Williams', 'Tom Williams'],
      ),
    ),
  ];
}
