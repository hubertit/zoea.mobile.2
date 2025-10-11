import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/events_provider.dart';
import '../../../core/models/event.dart';
import '../../../core/models/event_filter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../widgets/event_filter_sheet.dart';
import '../widgets/event_calendar_sheet.dart';

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  EventFilter _currentFilter = const EventFilter();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      final eventsNotifier = ref.read(eventsProvider.notifier);
      switch (_tabController.index) {
        case 0:
          eventsNotifier.loadTrendingEvents();
          break;
        case 1:
          // For now, load trending events as we don't have location
          eventsNotifier.loadTrendingEvents();
          break;
        case 2:
          eventsNotifier.loadThisWeekEvents();
          break;
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eventsState = ref.watch(eventsProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Events',
            style: AppTheme.titleLarge,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {
              _showCalendarSheet(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterBottomSheet(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              _showSearchDialog(context);
            },
          ),
        ],
                bottom: TabBar(
                  controller: _tabController,
                  indicatorColor: AppTheme.primaryColor,
                  labelColor: AppTheme.primaryColor,
                  unselectedLabelColor: AppTheme.secondaryTextColor,
                  labelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  tabAlignment: TabAlignment.start,
                  isScrollable: true,
                  tabs: const [
                    Tab(text: 'Trending'),
                    Tab(text: 'Near Me'),
                    Tab(text: 'This Week'),
                  ],
                ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildEventsList(eventsState),
          _buildEventsList(eventsState),
          _buildEventsList(eventsState),
        ],
      ),
    );
  }

  Widget _buildEventsList(EventsState eventsState) {
    if (eventsState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppTheme.primaryColor,
        ),
      );
    }

    if (eventsState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.errorColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading events',
              style: AppTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              eventsState.error!,
              style: AppTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final eventsNotifier = ref.read(eventsProvider.notifier);
                switch (eventsState.currentTab) {
                  case EventsTab.trending:
                    eventsNotifier.loadTrendingEvents();
                    break;
                  case EventsTab.nearMe:
                    eventsNotifier.loadTrendingEvents();
                    break;
                  case EventsTab.thisWeek:
                    eventsNotifier.loadThisWeekEvents();
                    break;
                }
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (eventsState.events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.event_available,
              size: 64,
              color: AppTheme.secondaryTextColor,
            ),
            const SizedBox(height: 16),
            Text(
              'No events found',
              style: AppTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for new events',
              style: AppTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: eventsState.events.length,
      itemBuilder: (context, index) {
        final event = eventsState.events[index];
        return _buildEventCard(event);
      },
    );
  }

  Widget _buildEventCard(Event event) {
    final eventDetails = event.event;
    final startDate = eventDetails.startDate;
    final endDate = eventDetails.endDate;
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('HH:mm');

    return GestureDetector(
      onTap: () {
        context.go('/event/${event.id}', extra: event);
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: CachedNetworkImage(
              imageUrl: eventDetails.flyer,
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
          ),
          // Event Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event Name
                Text(
                  eventDetails.name,
                  style: AppTheme.titleLarge,
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
                    Text(
                      dateFormat.format(startDate),
                      style: AppTheme.bodyMedium,
                    ),
                    const SizedBox(width: 16),
                    const Icon(
                      Icons.access_time,
                      size: 16,
                      color: AppTheme.secondaryTextColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${timeFormat.format(startDate)} - ${timeFormat.format(endDate)}',
                      style: AppTheme.bodyMedium,
                    ),
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
                        eventDetails.locationName,
                        style: AppTheme.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Organizer
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundImage: CachedNetworkImageProvider(event.owner.imageUrl),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        event.owner.name,
                        style: AppTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (event.owner.isVerified)
                      const Icon(
                        Icons.verified,
                        size: 16,
                        color: AppTheme.primaryColor,
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                // Tickets and Attendance
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Attendance
                    Row(
                      children: [
                        const Icon(
                          Icons.people,
                          size: 16,
                          color: AppTheme.secondaryTextColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${eventDetails.attending}/${eventDetails.maxAttendance}',
                          style: AppTheme.bodySmall,
                        ),
                      ],
                    ),
                    // Price Range
                    if (eventDetails.tickets.isNotEmpty)
                      Text(
                        'From ${_formatPrice(eventDetails.tickets.first.price)} ${eventDetails.tickets.first.currency}',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
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

  String _formatPrice(int price) {
    if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(0)}K';
    }
    return price.toString();
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EventFilterSheet(
        currentFilter: _currentFilter,
        onFilterChanged: (filter) {
          setState(() {
            _currentFilter = filter;
          });
          // Apply filters to events
          _applyFilters();
        },
        onClearFilters: () {
          setState(() {
            _currentFilter = const EventFilter();
          });
          // Reload events without filters
          _reloadCurrentTab();
        },
      ),
    );
  }

  void _showCalendarSheet(BuildContext context) {
    final eventsState = ref.watch(eventsProvider);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EventCalendarSheet(
        events: eventsState.events,
        onDateSelected: (date) {
          // Filter events by selected date
          _filterByDate(date);
        },
      ),
    );
  }

  void _applyFilters() {
    final eventsNotifier = ref.read(eventsProvider.notifier);
    // Apply filters based on current tab
    switch (_tabController.index) {
      case 0:
        eventsNotifier.loadTrendingEvents();
        break;
      case 1:
        eventsNotifier.loadTrendingEvents(); // For now, same as trending
        break;
      case 2:
        eventsNotifier.loadThisWeekEvents();
        break;
    }
  }

  void _filterByDate(DateTime date) {
    // This would filter events by the selected date
    // For now, we'll just reload the current tab
    _reloadCurrentTab();
  }

  void _reloadCurrentTab() {
    final eventsNotifier = ref.read(eventsProvider.notifier);
    switch (_tabController.index) {
      case 0:
        eventsNotifier.loadTrendingEvents();
        break;
      case 1:
        eventsNotifier.loadTrendingEvents();
        break;
      case 2:
        eventsNotifier.loadThisWeekEvents();
        break;
    }
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Events'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'Search for events...',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (query) {
            if (query.isNotEmpty) {
              ref.read(eventsProvider.notifier).searchEvents(query);
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Handle search
              Navigator.pop(context);
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }
}
