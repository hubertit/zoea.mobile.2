import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/booking.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  // Mock data for dashboard
  final _todayBookings = 12;
  final _pendingBookings = 5;
  final _totalRevenue = 2450000.0;
  final _totalListings = 8;
  final _totalBusinesses = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: () async {
          // TODO: Refresh dashboard data
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppTheme.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRevenueCard(),
              const SizedBox(height: AppTheme.spacing24),
              _buildQuickStats(),
              const SizedBox(height: AppTheme.spacing24),
              _buildRecentBookings(),
              const SizedBox(height: AppTheme.spacing24),
              _buildQuickActions(),
              const SizedBox(height: AppTheme.spacing32),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.backgroundColor,
      elevation: 0,
      centerTitle: false,
      title: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: 'Zoea',
              style: AppTheme.displayMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryTextColor,
              ),
            ),
            TextSpan(
              text: ' Partner',
              style: AppTheme.headlineMedium.copyWith(
                fontWeight: FontWeight.w500,
                color: AppTheme.secondaryTextColor,
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => context.push('/notifications'),
          icon: const Badge(
            smallSize: 8,
            child: Icon(
              Icons.notifications_outlined,
              color: AppTheme.primaryTextColor,
            ),
          ),
        ),
        IconButton(
          onPressed: () => context.push('/profile'),
          icon: const Icon(
            Icons.person_outline,
            color: AppTheme.primaryTextColor,
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'Today\'s Bookings',
            value: _todayBookings.toString(),
            icon: Icons.calendar_today_rounded,
            color: AppTheme.primaryColor,
            onTap: () => context.push('/bookings'),
          ),
        ),
        const SizedBox(width: AppTheme.spacing12),
        Expanded(
          child: _StatCard(
            title: 'Pending',
            value: _pendingBookings.toString(),
            icon: Icons.pending_actions_rounded,
            color: Colors.orange,
            onTap: () => context.push('/bookings'),
          ),
        ),
      ],
    );
  }

  Widget _buildRevenueCard() {
    // Soft grayish tones based on primary color (like Apple Pay card)
    const cardBaseColor = Color(0xFFE8E8ED);
    const cardAccentColor = Color(0xFFD1D1D6);
    final primaryTint = AppTheme.primaryColor.withOpacity(0.08);
    
    return GestureDetector(
      onTap: () => context.push('/wallet'),
      child: Container(
        height: 200,
        padding: const EdgeInsets.all(AppTheme.spacing24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              cardBaseColor,
              cardAccentColor,
              cardBaseColor.withBlue(240),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
          borderRadius: BorderRadius.circular(AppTheme.borderRadius24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: primaryTint,
              blurRadius: 40,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Balance',
                style: AppTheme.bodyMedium.copyWith(
                  color: Colors.black54,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'This Month',
                  style: AppTheme.labelSmall.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'RWF ${_formatNumber(_totalRevenue)}',
            style: AppTheme.displayLarge.copyWith(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              letterSpacing: -1,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              _buildCardMetric(_totalBusinesses.toString(), 'Businesses', dark: true),
              const SizedBox(width: 32),
              _buildCardMetric(_totalListings.toString(), 'Listings', dark: true),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildCardMetric(String value, String label, {bool dark = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: AppTheme.titleLarge.copyWith(
            color: dark ? Colors.black87 : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTheme.labelSmall.copyWith(
            color: dark ? Colors.black54 : Colors.white60,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentBookings() {
    final recentBookings = _getMockRecentBookings();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Bookings',
              style: AppTheme.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                context.go('/bookings');
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacing12),
        ...recentBookings.map((booking) => _BookingCard(booking: booking)),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: AppTheme.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppTheme.spacing12),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.add_business_rounded,
                label: 'Add Business',
                onTap: () => context.push('/businesses/new'),
              ),
            ),
            const SizedBox(width: AppTheme.spacing12),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.add_box_rounded,
                label: 'Add Listing',
                onTap: () => context.push('/listings/new'),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacing12),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.qr_code_scanner_rounded,
                label: 'Scan QR',
                onTap: () {
                  // TODO: Open QR scanner
                },
              ),
            ),
            const SizedBox(width: AppTheme.spacing12),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.analytics_rounded,
                label: 'Analytics',
                onTap: () => context.push('/analytics'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatNumber(double number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(0)}K';
    }
    return number.toStringAsFixed(0);
  }

  List<Booking> _getMockRecentBookings() {
    return [
      Booking(
        id: '1',
        listingId: 'l1',
        businessId: 'b1',
        customerId: 'c1',
        customerName: 'John Doe',
        customerEmail: 'john@email.com',
        type: BookingType.accommodation,
        status: BookingStatus.pending,
        totalAmount: 150000,
        currency: 'RWF',
        paymentMethod: PaymentMethod.momo,
        paymentStatus: PaymentStatus.paid,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        updatedAt: DateTime.now(),
        listingName: 'Deluxe Room',
        businessName: 'Kigali Heights Hotel',
        accommodationDetails: AccommodationBookingDetails(
          checkInDate: DateTime.now().add(const Duration(days: 1)),
          checkOutDate: DateTime.now().add(const Duration(days: 3)),
          nights: 2,
          guestCount: 2,
        ),
      ),
      Booking(
        id: '2',
        listingId: 'l2',
        businessId: 'b1',
        customerId: 'c2',
        customerName: 'Jane Smith',
        type: BookingType.dining,
        status: BookingStatus.confirmed,
        totalAmount: 80000,
        currency: 'RWF',
        paymentMethod: PaymentMethod.zoeaCard,
        paymentStatus: PaymentStatus.paid,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        updatedAt: DateTime.now(),
        listingName: 'Family Table',
        businessName: 'Ubumwe Restaurant',
        diningDetails: DiningBookingDetails(
          reservationDate: DateTime.now().add(const Duration(days: 2)),
          timeSlot: '19:00',
          partySize: 4,
        ),
      ),
    ];
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(AppTheme.borderRadius16),
          border: Border.all(color: AppTheme.dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: AppTheme.headlineMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.secondaryTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Booking booking;

  const _BookingCard({required this.booking});

  void _showBookingDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _BookingDetailsSheet(booking: booking),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showBookingDetails(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppTheme.spacing12),
        padding: const EdgeInsets.all(AppTheme.spacing16),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(AppTheme.borderRadius12),
          border: Border.all(color: AppTheme.dividerColor),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  booking.customerName.substring(0, 1).toUpperCase(),
                  style: AppTheme.titleLarge.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
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
                  const SizedBox(height: 2),
                  Text(
                    '${booking.listingName} • ${booking.guestCount} guests',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildStatusChip(booking.status),
                const SizedBox(height: 4),
                Text(
                  'RWF ${booking.totalAmount.toStringAsFixed(0)}',
                  style: AppTheme.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right,
              color: AppTheme.secondaryTextColor.withOpacity(0.5),
              size: 20,
            ),
          ],
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.borderRadius12),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(AppTheme.borderRadius12),
          border: Border.all(color: AppTheme.dividerColor),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: AppTheme.primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: AppTheme.secondaryTextColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingDetailsSheet extends StatelessWidget {
  final Booking booking;

  const _BookingDetailsSheet({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(AppTheme.spacing20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag Handle
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

                // Header
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          booking.customerName.substring(0, 1).toUpperCase(),
                          style: AppTheme.titleLarge.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.customerName,
                            style: AppTheme.headlineSmall.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${booking.type.icon} ${booking.type.displayName}',
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(booking.status),
                  ],
                ),
                const SizedBox(height: AppTheme.spacing24),

                // Amount Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppTheme.spacing20),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.primaryColor.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Total Amount',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.secondaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${booking.currency} ${NumberFormat('#,###').format(booking.totalAmount)}',
                        style: AppTheme.displayMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.spacing24),

                // Booking Info Section
                _buildSection('Booking Details', [
                  _buildDetailRow('Listing', booking.listingName ?? 'N/A'),
                  _buildDetailRow('Business', booking.businessName ?? 'N/A'),
                  _buildDetailRow('Guests', '${booking.guestCount}'),
                  _buildDetailRow('Created', DateFormat('MMM dd, yyyy').format(booking.createdAt)),
                ]),
                const SizedBox(height: AppTheme.spacing16),

                // Customer Section
                _buildSection('Customer', [
                  _buildDetailRow('Name', booking.customerName),
                  if (booking.customerEmail != null)
                    _buildDetailRow('Email', booking.customerEmail!),
                  if (booking.customerPhone != null)
                    _buildDetailRow('Phone', booking.customerPhone!),
                ]),
                const SizedBox(height: AppTheme.spacing16),

                // Payment Section
                _buildSection('Payment', [
                  _buildDetailRow('Method', booking.paymentMethod.displayName),
                  _buildDetailRow('Status', booking.paymentStatus.displayName),
                ]),
                const SizedBox(height: AppTheme.spacing24),

                // Actions
                if (booking.status == BookingStatus.pending)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
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
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Confirm'),
                        ),
                      ),
                    ],
                  ),
                if (booking.status == BookingStatus.confirmed)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.login_rounded),
                      label: const Text('Check In Guest'),
                    ),
                  ),
                const SizedBox(height: AppTheme.spacing16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(BookingStatus status) {
    Color color;
    switch (status) {
      case BookingStatus.pending:
        color = Colors.orange;
        break;
      case BookingStatus.confirmed:
        color = Colors.blue;
        break;
      case BookingStatus.checkedIn:
        color = Colors.green;
        break;
      case BookingStatus.completed:
        color = Colors.grey;
        break;
      case BookingStatus.cancelled:
      case BookingStatus.noShow:
        color = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.displayName,
        style: AppTheme.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.dividerColor.withOpacity(0.5)),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.secondaryTextColor,
            ),
          ),
          Text(
            value,
            style: AppTheme.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
