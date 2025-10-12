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
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;
  EventFilter _currentFilter = const EventFilter();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);
    
    // Shimmer animation controller
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // Shimmer animation
    _shimmerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));
    
    // Start shimmer animation
    _shimmerController.repeat();
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
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eventsState = ref.watch(eventsProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
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
                  labelColor: AppTheme.primaryColor,
                  unselectedLabelColor: AppTheme.secondaryTextColor,
                  indicatorColor: AppTheme.primaryColor,
                  tabs: const [
                    Tab(text: 'Trending'),
                    Tab(text: 'Near Me'),
                    Tab(text: 'This Week'),
                    Tab(text: 'MICE'),
                  ],
                ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildEventsList(eventsState),
          _buildEventsList(eventsState),
          _buildEventsList(eventsState),
          _buildMiceEventsList(),
        ],
      ),
    );
  }

  Widget _buildMiceEventsList() {
    final miceEvents = _getMockMiceEvents();
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: miceEvents.length,
      itemBuilder: (context, index) {
        final event = miceEvents[index];
        return _buildMiceEventCard(event);
      },
    );
  }

  Widget _buildMiceEventCard(Map<String, dynamic> event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryTextColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: CachedNetworkImage(
              imageUrl: event['image'],
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 200,
                color: Colors.grey[200],
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                height: 200,
                color: Colors.grey[200],
                child: const Icon(Icons.event, size: 50),
              ),
            ),
          ),
          // Event content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        event['name'],
                        style: AppTheme.headlineSmall.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        event['category'],
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: AppTheme.secondaryTextColor,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        event['location'],
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.secondaryTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: AppTheme.secondaryTextColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      event['date'],
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.secondaryTextColor,
                      ),
                    ),
                    const Spacer(),
                    if (event['isFree'] == true)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'FREE',
                          style: AppTheme.bodySmall.copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    else
                      Text(
                        event['price'],
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
                if (event['description'] != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    event['description'],
                    style: AppTheme.bodyMedium.copyWith(
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsList(EventsState eventsState) {
    if (eventsState.isLoading) {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5, // Show 5 skeleton cards
        itemBuilder: (context, index) {
          return _buildSkeletonEventCard();
        },
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

  Widget _buildSkeletonEventCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Skeleton Image
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: AnimatedBuilder(
              animation: _shimmerAnimation,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.grey[300]!,
                        Colors.grey[200]!,
                        Colors.grey[300]!,
                      ],
                      stops: [
                        0.0,
                        _shimmerAnimation.value,
                        1.0,
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Skeleton Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event Name skeleton
                Container(
                  height: 24,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                // Date and Time skeleton
                Row(
                  children: [
                    Container(
                      height: 16,
                      width: 16,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: 16,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      height: 16,
                      width: 16,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: 16,
                      width: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(4),
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
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: 16,
                      width: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Organizer skeleton
                Row(
                  children: [
                    Container(
                      height: 24,
                      width: 24,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: 16,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Bottom row skeleton
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 16,
                      width: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Container(
                      height: 16,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(4),
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

  List<Map<String, dynamic>> _getMockMiceEvents() {
    return [
      {
        'name': 'Rwanda Investment Summit 2024',
        'location': 'Kigali Convention Centre, Kigali',
        'date': 'March 15-17, 2024',
        'category': 'Conference',
        'image': 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=500',
        'price': 'RWF 500,000',
        'isFree': false,
        'description': 'Join leading investors and entrepreneurs for Rwanda\'s premier investment conference.',
      },
      {
        'name': 'East Africa Business Expo',
        'location': 'Intare Conference Arena, Kigali',
        'date': 'April 8-10, 2024',
        'category': 'Exhibition',
        'image': 'https://images.unsplash.com/photo-1556761175-4b46a572b786?w=500',
        'price': 'RWF 200,000',
        'isFree': false,
        'description': 'Showcase your business to East African markets and connect with regional partners.',
      },
      {
        'name': 'Rwanda Tech Innovation Summit',
        'location': 'Kigali Marriott Hotel, Kigali',
        'date': 'May 20-22, 2024',
        'category': 'Conference',
        'image': 'https://images.unsplash.com/photo-1515187029135-18ee286d815b?w=500',
        'price': 'FREE',
        'isFree': true,
        'description': 'Explore the latest in technology and innovation shaping Rwanda\'s digital future.',
      },
      {
        'name': 'African Tourism Investment Forum',
        'location': 'Radisson Blu Hotel, Kigali',
        'date': 'June 12-14, 2024',
        'category': 'Forum',
        'image': 'https://images.unsplash.com/photo-1488646953014-85cb44e25828?w=500',
        'price': 'RWF 300,000',
        'isFree': false,
        'description': 'Connect with tourism industry leaders and explore investment opportunities in African tourism.',
      },
      {
        'name': 'Rwanda Healthcare Conference',
        'location': 'Kigali Convention Centre, Kigali',
        'date': 'July 25-27, 2024',
        'category': 'Conference',
        'image': 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1f?w=500',
        'price': 'RWF 150,000',
        'isFree': false,
        'description': 'Advancing healthcare solutions and medical innovation across Africa.',
      },
      {
        'name': 'Rwanda Agriculture & Food Security Summit',
        'location': 'Intare Conference Arena, Kigali',
        'date': 'August 15-17, 2024',
        'category': 'Summit',
        'image': 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=500',
        'price': 'FREE',
        'isFree': true,
        'description': 'Addressing food security challenges and sustainable agriculture practices.',
      },
      {
        'name': 'Rwanda Energy & Infrastructure Forum',
        'location': 'Kigali Marriott Hotel, Kigali',
        'date': 'September 10-12, 2024',
        'category': 'Forum',
        'image': 'https://images.unsplash.com/photo-1466611653911-95081537e5b7?w=500',
        'price': 'RWF 400,000',
        'isFree': false,
        'description': 'Exploring sustainable energy solutions and infrastructure development in Rwanda.',
      },
      {
        'name': 'Rwanda Women in Business Conference',
        'location': 'Radisson Blu Hotel, Kigali',
        'date': 'October 5-7, 2024',
        'category': 'Conference',
        'image': 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=500',
        'price': 'RWF 100,000',
        'isFree': false,
        'description': 'Empowering women entrepreneurs and business leaders across Rwanda and East Africa.',
      },
    ];
  }
}
