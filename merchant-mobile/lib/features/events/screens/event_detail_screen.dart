import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/event.dart';
import '../../../core/widgets/status_badge.dart';

class EventDetailScreen extends StatefulWidget {
  final String eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock data
  final Event _event = Event(
    id: 'e1',
    businessId: 'b1',
    name: 'Rwanda Tech Summit 2024',
    description:
        'Annual technology conference bringing together innovators, entrepreneurs, and tech enthusiasts from across Africa. Join us for keynote speeches, panel discussions, workshops, and networking opportunities.',
    flyerUrl: 'https://picsum.photos/400/600',
    startDate: DateTime.now().add(const Duration(days: 7)),
    endDate: DateTime.now().add(const Duration(days: 7, hours: 8)),
    venue: 'Kigali Convention Centre',
    venueAddress: 'KG 2 Roundabout, Kigali',
    status: EventStatus.published,
    category: 'Conference',
    tickets: [
      const EventTicket(
        id: 't1',
        name: 'Early Bird',
        type: TicketType.earlyBird,
        price: 25000,
        quantity: 100,
        sold: 85,
      ),
      const EventTicket(
        id: 't2',
        name: 'Standard',
        type: TicketType.paid,
        price: 35000,
        quantity: 200,
        sold: 120,
      ),
      const EventTicket(
        id: 't3',
        name: 'VIP',
        type: TicketType.vip,
        price: 100000,
        quantity: 50,
        sold: 30,
      ),
    ],
    attendingCount: 235,
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
    updatedAt: DateTime.now(),
  );

  final List<EventAttendee> _attendees = [
    EventAttendee(
      id: 'a1',
      eventId: 'e1',
      ticketId: 't2',
      name: 'John Doe',
      email: 'john@example.com',
      phone: '+250788123456',
      checkedIn: true,
      checkedInAt: DateTime.now().subtract(const Duration(hours: 2)),
      purchasedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    EventAttendee(
      id: 'a2',
      eventId: 'e1',
      ticketId: 't3',
      name: 'Jane Smith',
      email: 'jane@example.com',
      checkedIn: false,
      purchasedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    EventAttendee(
      id: 'a3',
      eventId: 'e1',
      ticketId: 't1',
      name: 'Mike Johnson',
      email: 'mike@example.com',
      phone: '+250788654321',
      checkedIn: true,
      checkedInAt: DateTime.now().subtract(const Duration(hours: 1)),
      purchasedAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildAppBar(),
          SliverToBoxAdapter(child: _buildEventHeader()),
          SliverToBoxAdapter(child: _buildQuickStats()),
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              TabBar(
                controller: _tabController,
                labelColor: AppTheme.primaryColor,
                unselectedLabelColor: AppTheme.secondaryTextColor,
                indicatorColor: AppTheme.primaryColor,
                tabs: const [
                  Tab(text: 'Overview'),
                  Tab(text: 'Tickets'),
                  Tab(text: 'Attendees'),
                ],
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(),
            _buildTicketsTab(),
            _buildAttendeesTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppTheme.backgroundColor,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.arrow_back_ios, size: 16, color: Colors.white),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => context.push('/events/${widget.eventId}/edit'),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.edit_outlined, size: 18, color: Colors.white),
          ),
        ),
        IconButton(
          onPressed: _showMoreOptions,
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.more_vert, size: 18, color: Colors.white),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: _event.flyerUrl != null
            ? Image.network(
                _event.flyerUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppTheme.primaryColor.withOpacity(0.2),
                ),
              )
            : Container(color: AppTheme.primaryColor.withOpacity(0.2)),
      ),
    );
  }

  Widget _buildEventHeader() {
    final dateFormat = DateFormat('EEE, MMM dd, yyyy');
    final timeFormat = DateFormat('HH:mm');

    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StatusBadge(
                label: _event.status.displayName,
                color: _getStatusColor(_event.status),
              ),
              if (_event.category != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryTextColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(_event.category!, style: AppTheme.labelSmall),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _event.name,
            style: AppTheme.headlineSmall.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.calendar_today_outlined,
            dateFormat.format(_event.startDate),
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            Icons.access_time,
            '${timeFormat.format(_event.startDate)} - ${timeFormat.format(_event.endDate)}',
          ),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.location_on_outlined, _event.venue),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.secondaryTextColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: AppTheme.bodyMedium),
        ),
      ],
    );
  }

  Widget _buildQuickStats() {
    final formatter = NumberFormat('#,###', 'en_US');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius12),
        border: Border.all(color: AppTheme.dividerColor.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatColumn(
              label: 'Attendees',
              value: '${_event.attendingCount}',
              icon: Icons.people_outline,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppTheme.dividerColor,
          ),
          Expanded(
            child: _StatColumn(
              label: 'Tickets Sold',
              value: '${_event.totalTicketsSold}',
              icon: Icons.confirmation_number_outlined,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppTheme.dividerColor,
          ),
          Expanded(
            child: _StatColumn(
              label: 'Revenue',
              value: formatter.format(_event.totalRevenue),
              icon: Icons.account_balance_wallet_outlined,
              prefix: 'RWF ',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return ListView(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      children: [
        Text(
          'About',
          style: AppTheme.titleMedium.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(_event.description, style: AppTheme.bodyMedium),
        const SizedBox(height: 24),
        Text(
          'Location',
          style: AppTheme.titleMedium.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(AppTheme.spacing16),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(AppTheme.borderRadius12),
            border: Border.all(color: AppTheme.dividerColor.withOpacity(0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _event.venue,
                style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
              ),
              if (_event.venueAddress != null) ...[
                const SizedBox(height: 4),
                Text(_event.venueAddress!, style: AppTheme.bodySmall),
              ],
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _openMaps,
                icon: const Icon(Icons.map_outlined, size: 18),
                label: const Text('View on Map'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTicketsTab() {
    final formatter = NumberFormat('#,###', 'en_US');

    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      itemCount: _event.tickets.length,
      itemBuilder: (context, index) {
        final ticket = _event.tickets[index];
        final soldPercentage = ticket.quantity > 0
            ? (ticket.sold / ticket.quantity * 100).round()
            : 0;

        return Container(
          margin: const EdgeInsets.only(bottom: AppTheme.spacing12),
          padding: const EdgeInsets.all(AppTheme.spacing16),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(AppTheme.borderRadius12),
            border: Border.all(color: AppTheme.dividerColor.withOpacity(0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ticket.name,
                          style: AppTheme.titleSmall.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          ticket.type.displayName,
                          style: AppTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    ticket.price > 0
                        ? 'RWF ${formatter.format(ticket.price)}'
                        : 'Free',
                    style: AppTheme.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: ticket.quantity > 0
                                ? ticket.sold / ticket.quantity
                                : 0,
                            backgroundColor: AppTheme.dividerColor,
                            valueColor: AlwaysStoppedAnimation(
                              soldPercentage >= 90
                                  ? AppTheme.errorColor
                                  : AppTheme.successColor,
                            ),
                            minHeight: 6,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${ticket.sold} sold • ${ticket.available} available',
                          style: AppTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '$soldPercentage%',
                    style: AppTheme.titleSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: soldPercentage >= 90
                          ? AppTheme.errorColor
                          : AppTheme.successColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAttendeesTab() {
    return Column(
      children: [
        // Search & Filter
        Padding(
          padding: const EdgeInsets.all(AppTheme.spacing16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search attendees...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                onPressed: () {
                  // TODO: QR Scanner for check-in
                },
                icon: const Icon(Icons.qr_code_scanner),
              ),
            ),
          ),
        ),
        // Attendees List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
            itemCount: _attendees.length,
            itemBuilder: (context, index) {
              final attendee = _attendees[index];
              final ticket = _event.tickets.firstWhere(
                (t) => t.id == attendee.ticketId,
                orElse: () => const EventTicket(
                  id: '',
                  name: 'Unknown',
                  type: TicketType.paid,
                  price: 0,
                  quantity: 0,
                ),
              );

              return Container(
                margin: const EdgeInsets.only(bottom: AppTheme.spacing12),
                padding: const EdgeInsets.all(AppTheme.spacing12),
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(AppTheme.borderRadius12),
                  border: Border.all(color: AppTheme.dividerColor.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                      child: Text(
                        attendee.name[0].toUpperCase(),
                        style: AppTheme.titleSmall.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            attendee.name,
                            style: AppTheme.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${ticket.name} ticket',
                            style: AppTheme.labelSmall,
                          ),
                        ],
                      ),
                    ),
                    if (attendee.checkedIn)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.successColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_circle,
                              size: 14,
                              color: AppTheme.successColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Checked in',
                              style: AppTheme.labelSmall.copyWith(
                                color: AppTheme.successColor,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      OutlinedButton(
                        onPressed: () => _checkInAttendee(attendee),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        child: const Text('Check in'),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _checkInAttendee(EventAttendee attendee) {
    setState(() {
      final index = _attendees.indexWhere((a) => a.id == attendee.id);
      if (index != -1) {
        _attendees[index] = EventAttendee(
          id: attendee.id,
          eventId: attendee.eventId,
          ticketId: attendee.ticketId,
          name: attendee.name,
          email: attendee.email,
          phone: attendee.phone,
          checkedIn: true,
          checkedInAt: DateTime.now(),
          purchasedAt: attendee.purchasedAt,
        );
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      AppTheme.successSnackBar(message: '${attendee.name} checked in successfully'),
    );
  }

  Future<void> _openMaps() async {
    final address = _event.venueAddress ?? _event.venue;
    final encodedAddress = Uri.encodeComponent(address);
    final googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=$encodedAddress';
    
    final uri = Uri.parse(googleMapsUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          AppTheme.errorSnackBar(message: 'Could not open maps'),
        );
      }
    }
  }

  void _shareEvent() {
    // In production, use share_plus package
    ScaffoldMessenger.of(context).showSnackBar(
      AppTheme.successSnackBar(message: 'Share link copied to clipboard'),
    );
  }

  void _duplicateEvent() {
    // Navigate to form with pre-filled data
    ScaffoldMessenger.of(context).showSnackBar(
      AppTheme.successSnackBar(message: 'Event duplicated. Edit the new event.'),
    );
    context.push('/events/new');
  }

  void _cancelEvent() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Event'),
        content: const Text(
          'Are you sure you want to cancel this event? '
          'All attendees will be notified and refunds will be processed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('No, Keep Event'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                AppTheme.successSnackBar(message: 'Event cancelled. Refunds are being processed.'),
              );
              context.pop();
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Yes, Cancel Event'),
          ),
        ],
      ),
    );
  }

  void _deleteEvent() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Event'),
        content: const Text(
          'Are you sure you want to delete this event? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                AppTheme.successSnackBar(message: 'Event deleted'),
              );
              context.pop();
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showMoreOptions() {
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
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: const Text('Share Event'),
              onTap: () {
                Navigator.pop(context);
                _shareEvent();
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy_outlined),
              title: const Text('Duplicate Event'),
              onTap: () {
                Navigator.pop(context);
                _duplicateEvent();
              },
            ),
            if (_event.status == EventStatus.published)
              ListTile(
                leading: const Icon(Icons.cancel_outlined, color: AppTheme.errorColor),
                title: const Text('Cancel Event', style: TextStyle(color: AppTheme.errorColor)),
                onTap: () {
                  Navigator.pop(context);
                  _cancelEvent();
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppTheme.errorColor),
              title: const Text('Delete Event', style: TextStyle(color: AppTheme.errorColor)),
              onTap: () {
                Navigator.pop(context);
                _deleteEvent();
              },
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(EventStatus status) {
    switch (status) {
      case EventStatus.published:
        return AppTheme.successColor;
      case EventStatus.draft:
        return Colors.orange;
      case EventStatus.cancelled:
        return AppTheme.errorColor;
      case EventStatus.completed:
        return Colors.blue;
    }
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final String? prefix;

  const _StatColumn({
    required this.label,
    required this.value,
    required this.icon,
    this.prefix,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppTheme.secondaryTextColor),
        const SizedBox(height: 8),
        Text(
          prefix != null ? '$prefix$value' : value,
          style: AppTheme.titleSmall.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(label, style: AppTheme.labelSmall),
      ],
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate(this.tabBar);

  @override
  Widget build(context, shrinkOffset, overlapsContent) {
    return Container(
      color: AppTheme.backgroundColor,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) => false;
}

