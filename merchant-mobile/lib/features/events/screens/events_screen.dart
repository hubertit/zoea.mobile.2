import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/event.dart';
import '../../../core/widgets/status_badge.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Event> _events = [
    Event(
      id: 'e1',
      businessId: 'b1',
      name: 'Rwanda Tech Summit 2024',
      description: 'Annual technology conference bringing together innovators',
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
    ),
    Event(
      id: 'e2',
      businessId: 'b1',
      name: 'Kigali Jazz Night',
      description: 'An evening of smooth jazz and fine dining',
      flyerUrl: 'https://picsum.photos/400/601',
      startDate: DateTime.now().add(const Duration(days: 3)),
      endDate: DateTime.now().add(const Duration(days: 3, hours: 4)),
      venue: 'Serena Hotel',
      status: EventStatus.published,
      category: 'Music',
      tickets: [
        const EventTicket(
          id: 't4',
          name: 'General Admission',
          type: TicketType.paid,
          price: 15000,
          quantity: 150,
          sold: 80,
        ),
      ],
      attendingCount: 80,
      createdAt: DateTime.now().subtract(const Duration(days: 14)),
      updatedAt: DateTime.now(),
    ),
    Event(
      id: 'e3',
      businessId: 'b1',
      name: 'Startup Pitch Night',
      description: 'Watch promising startups pitch to investors',
      startDate: DateTime.now().subtract(const Duration(days: 5)),
      endDate: DateTime.now().subtract(const Duration(days: 5)).add(const Duration(hours: 3)),
      venue: 'Impact Hub Kigali',
      status: EventStatus.completed,
      category: 'Business',
      tickets: [
        const EventTicket(
          id: 't5',
          name: 'Free Entry',
          type: TicketType.free,
          price: 0,
          quantity: 100,
          sold: 95,
        ),
      ],
      attendingCount: 95,
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Event(
      id: 'e4',
      businessId: 'b1',
      name: 'Art Exhibition Opening',
      description: 'Contemporary African art showcase',
      startDate: DateTime.now().add(const Duration(days: 14)),
      endDate: DateTime.now().add(const Duration(days: 14, hours: 6)),
      venue: 'Inema Arts Center',
      status: EventStatus.draft,
      category: 'Art',
      tickets: [],
      attendingCount: 0,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now(),
    ),
  ];

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

  List<Event> _getFilteredEvents(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return _events;
      case 1:
        return _events.where((e) => e.isUpcoming && e.status == EventStatus.published).toList();
      case 2:
        return _events.where((e) => e.isPast || e.status == EventStatus.completed).toList();
      case 3:
        return _events.where((e) => e.status == EventStatus.draft).toList();
      default:
        return _events;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        title: Text(
          'Events',
          style: AppTheme.headlineSmall.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () => context.push('/events/new'),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.secondaryTextColor,
          indicatorColor: AppTheme.primaryColor,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Upcoming'),
            Tab(text: 'Past'),
            Tab(text: 'Drafts'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: List.generate(4, (index) {
          final events = _getFilteredEvents(index);
          if (events.isEmpty) {
            return _buildEmptyState(index);
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            itemCount: events.length,
            itemBuilder: (context, i) => _EventCard(
              event: events[i],
              onTap: () => context.push('/events/${events[i].id}'),
            ),
          );
        }),
      ),
      );
  }

  Widget _buildEmptyState(int tabIndex) {
    String message;
    switch (tabIndex) {
      case 1:
        message = 'No upcoming events';
        break;
      case 2:
        message = 'No past events';
        break;
      case 3:
        message = 'No draft events';
        break;
      default:
        message = 'No events yet';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_outlined,
            size: 64,
            color: AppTheme.secondaryTextColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppTheme.titleMedium.copyWith(
              color: AppTheme.secondaryTextColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first event to get started',
            style: AppTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onTap;

  const _EventCard({
    required this.event,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('HH:mm');
    final formatter = NumberFormat('#,###', 'en_US');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppTheme.spacing16),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(AppTheme.borderRadius16),
          border: Border.all(color: AppTheme.dividerColor.withOpacity(0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Flyer
            if (event.flyerUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppTheme.borderRadius16),
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    event.flyerUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      child: const Icon(Icons.image, size: 48),
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status & Category
                  Row(
                    children: [
                      StatusBadge(
                        label: event.status.displayName,
                        color: _getStatusColor(event.status),
                      ),
                      if (event.category != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.secondaryTextColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            event.category!,
                            style: AppTheme.labelSmall,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Title
                  Text(
                    event.name,
                    style: AppTheme.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Date & Time
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 14,
                        color: AppTheme.secondaryTextColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        dateFormat.format(event.startDate),
                        style: AppTheme.bodySmall,
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.access_time,
                        size: 14,
                        color: AppTheme.secondaryTextColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        timeFormat.format(event.startDate),
                        style: AppTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Venue
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: AppTheme.secondaryTextColor,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          event.venue,
                          style: AppTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Stats
                  Row(
                    children: [
                      _StatItem(
                        icon: Icons.people_outline,
                        value: '${event.attendingCount}',
                        label: 'Attendees',
                      ),
                      const SizedBox(width: 24),
                      _StatItem(
                        icon: Icons.confirmation_number_outlined,
                        value: '${event.totalTicketsSold}/${event.totalCapacity}',
                        label: 'Tickets',
                      ),
                      const Spacer(),
                      if (event.totalRevenue > 0)
                        Text(
                          'RWF ${formatter.format(event.totalRevenue)}',
                          style: AppTheme.titleSmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.successColor,
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

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.secondaryTextColor),
        const SizedBox(width: 4),
        Text(
          value,
          style: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

