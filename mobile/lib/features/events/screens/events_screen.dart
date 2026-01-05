import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/theme/text_theme_extensions.dart';
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
  bool _hasAutoOpenedCalendar = false;

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

    // Auto-open calendar after 2 seconds if events are loaded and not already shown
    if (!_hasAutoOpenedCalendar && 
        eventsState.events.isNotEmpty && 
        !eventsState.isLoading &&
        mounted) {
      _hasAutoOpenedCalendar = true;
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && context.mounted) {
          _showCalendarSheet(context);
        }
      });
    }

    return Scaffold(
      backgroundColor: context.grey50,
      appBar: AppBar(
        backgroundColor: context.backgroundColor,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Events',
            style: context.titleLarge.copyWith(
              color: context.primaryTextColor,
            ),
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
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              context.push('/profile');
            },
          ),
        ],
                bottom: TabBar(
                  controller: _tabController,
                  indicatorColor: context.primaryColorTheme,
                  labelColor: context.primaryColorTheme,
                  unselectedLabelColor: context.secondaryTextColor,
                  labelStyle: context.bodySmall.copyWith(fontWeight: FontWeight.w600),
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 16),
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
    
    return RefreshIndicator(
      color: context.primaryColorTheme,
      backgroundColor: context.cardColor,
      onRefresh: () async {
        // MICE events are mock data, just refresh the UI
        setState(() {});
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: miceEvents.length,
        itemBuilder: (context, index) {
          final event = miceEvents[index];
          return _buildMiceEventCard(event);
        },
      ),
    );
  }

  Widget _buildMiceEventCard(Map<String, dynamic> event) {
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
                color: context.grey200,
                child: Center(
                  child: CircularProgressIndicator(color: context.primaryColorTheme),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                height: 200,
                color: context.grey200,
                child: const Icon(Icons.event, size: 50),
              ),
            ),
          ),
          // Event content
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        event['name'],
                        style: context.headlineSmall.copyWith(
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
                        color: context.primaryColorTheme.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        event['category'],
                        style: context.bodySmall.copyWith(
                          color: context.primaryColorTheme,
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
                      color: context.secondaryTextColor,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        event['location'],
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
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: context.secondaryTextColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      event['date'],
                      style: context.bodyMedium.copyWith(
                        color: context.secondaryTextColor,
                      ),
                    ),
                    const Spacer(),
                    // No pricing information for MICE events
                  ],
                ),
                if (event['description'] != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    event['description'],
                    style: context.bodyMedium.copyWith(
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
        padding: const EdgeInsets.all(12),
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
            Icon(
              Icons.error_outline,
              size: 64,
              color: context.errorColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading events',
              style: context.headlineSmall.copyWith(
                color: context.primaryTextColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              eventsState.error!,
              style: context.bodyMedium.copyWith(
                color: context.secondaryTextColor,
              ),
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
            Icon(
              Icons.event_available,
              size: 64,
              color: context.secondaryTextColor,
            ),
            const SizedBox(height: 16),
            Text(
              'No events found',
              style: context.headlineSmall.copyWith(
                color: context.primaryTextColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for new events',
              style: context.bodyMedium.copyWith(
                color: context.secondaryTextColor,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: context.primaryColorTheme,
      backgroundColor: context.cardColor,
      onRefresh: () async {
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
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: eventsState.events.length,
        itemBuilder: (context, index) {
          final event = eventsState.events[index];
          return _buildEventCard(event);
        },
      ),
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
              color: context.grey300,
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
                );
              },
            ),
          ),
          // Skeleton Content
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event Name skeleton
                Container(
                  height: 24,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: context.grey400,
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
                        color: context.grey400,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: 16,
                      width: 100,
                      decoration: BoxDecoration(
                        color: context.grey400,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      height: 16,
                      width: 16,
                      decoration: BoxDecoration(
                        color: context.grey400,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: 16,
                      width: 80,
                      decoration: BoxDecoration(
                        color: context.grey400,
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
                        color: context.grey400,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: 16,
                      width: 150,
                      decoration: BoxDecoration(
                        color: context.grey400,
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
                        color: context.grey400,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: 16,
                      width: 100,
                      decoration: BoxDecoration(
                        color: context.grey400,
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
                        color: context.grey400,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Container(
                      height: 16,
                      width: 100,
                      decoration: BoxDecoration(
                        color: context.grey400,
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
                  Icons.event,
                  size: 64,
                  color: context.secondaryTextColor,
                ),
              ),
            ),
          ),
          // Event Details
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event Name
                Text(
                  eventDetails.name,
                  style: context.titleLarge.copyWith(
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
                    Text(
                      dateFormat.format(startDate),
                      style: context.bodyMedium.copyWith(
                        color: context.primaryTextColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: context.secondaryTextColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${timeFormat.format(startDate)} - ${timeFormat.format(endDate)}',
                      style: context.bodyMedium.copyWith(
                        color: context.primaryTextColor,
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
                      color: context.secondaryTextColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        eventDetails.locationName,
                        style: context.bodyMedium.copyWith(
                          color: context.primaryTextColor,
                        ),
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
                        style: context.bodySmall.copyWith(
                          color: context.primaryTextColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (event.owner.isVerified)
                      Icon(
                        Icons.verified,
                        size: 16,
                        color: context.primaryColorTheme,
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
                        Icon(
                          Icons.people,
                          size: 16,
                          color: context.secondaryTextColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${eventDetails.attending}/${eventDetails.maxAttendance}',
                          style: context.bodySmall.copyWith(
                            color: context.primaryTextColor,
                          ),
                        ),
                      ],
                    ),
                    // Price Range
                    if (eventDetails.tickets.isNotEmpty)
                      Text(
                        'From ${_formatPrice(eventDetails.tickets.first.price)} ${eventDetails.tickets.first.currency}',
                        style: context.bodySmall.copyWith(
                          color: context.primaryColorTheme,
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
    final TextEditingController searchController = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.backgroundColor,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.grey300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Title
            Text(
              'Search Events',
              style: context.headlineSmall.copyWith(
                fontWeight: FontWeight.w600,
                color: context.primaryTextColor,
              ),
            ),
            const SizedBox(height: 20),
            
            // Search field
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search for events...',
                hintStyle: context.bodyMedium.copyWith(
                  color: context.grey500,
                ),
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
                  borderSide: BorderSide(color: context.primaryColorTheme, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                prefixIcon: Icon(
                  Icons.search,
                  color: context.grey500,
                ),
              ),
              onSubmitted: (query) {
                if (query.isNotEmpty) {
                  ref.read(eventsProvider.notifier).searchEvents(query);
                  Navigator.pop(context);
                }
              },
            ),
            const SizedBox(height: 24),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: context.primaryColorTheme),
                    ),
                    child: Text(
                      'Cancel',
                      style: context.bodyMedium.copyWith(
                        color: context.primaryColorTheme,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final query = searchController.text.trim();
                      if (query.isNotEmpty) {
                        ref.read(eventsProvider.notifier).searchEvents(query);
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.primaryColorTheme,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'Search',
                      style: context.bodyMedium.copyWith(
                        color: context.primaryTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            // Add bottom padding for safe area
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getMockMiceEvents() {
    // KCC (Kigali Convention Centre) image for all MICE events
    // TODO: Replace with actual KCC image URL from desktop/uploaded media
    const String kccImage = 'https://res.cloudinary.com/dzcvbnvh3/image/upload/v1/kcc.jpg'; // Update this URL with the actual KCC image
    
    return [
      // 2026 Events
      {
        'name': '2026 African Men\'s Handball Championship',
        'location': 'Kigali Arena, Kigali',
        'date': 'January 21-31, 2026',
        'category': 'Championship',
        'image': kccImage,
        'price': null,
        'isFree': null,
        'description': 'The first time Rwanda will host this prestigious event, serving as a qualifier for the 2027 World Men\'s Handball Championship. This championship brings together top African handball teams competing for continental glory.',
      },
      {
        'name': 'Certified International Convention Specialist (CICS) Course',
        'location': 'Kigali Convention Centre, Kigali',
        'date': 'March 16-18, 2026',
        'category': 'Workshop',
        'image': kccImage,
        'price': null,
        'isFree': null,
        'description': 'Organized by ICCASkills, this course is designed for professionals seeking to enhance their expertise in the convention industry. Learn best practices, industry standards, and advanced techniques for managing successful conventions.',
      },
      {
        'name': 'Rwanda Investment Summit 2026',
        'location': 'Kigali Convention Centre, Kigali',
        'date': 'May 15-17, 2026',
        'category': 'Summit',
        'image': kccImage,
        'price': null,
        'isFree': null,
        'description': 'Annual summit bringing together investors, entrepreneurs, and policymakers to explore investment opportunities in Rwanda and the East African region.',
      },
      {
        'name': 'Africa Tech Innovation Conference 2026',
        'location': 'Kigali Convention Centre, Kigali',
        'date': 'June 10-12, 2026',
        'category': 'Conference',
        'image': kccImage,
        'price': null,
        'isFree': null,
        'description': 'Premier technology conference showcasing innovations, startups, and digital transformation across Africa. Features keynote speakers, panel discussions, and networking opportunities.',
      },
      {
        'name': 'Rwanda Tourism Expo 2026',
        'location': 'Kigali Convention Centre, Kigali',
        'date': 'July 20-22, 2026',
        'category': 'Exhibition',
        'image': kccImage,
        'price': null,
        'isFree': null,
        'description': 'Annual tourism exhibition showcasing Rwanda\'s attractions, hospitality services, and travel packages. Connect with tour operators, hotels, and travel agencies.',
      },
      {
        'name': 'Certified International Convention Executive (CICE) Course',
        'location': 'Kigali Convention Centre, Kigali',
        'date': 'August 31 - September 2, 2026',
        'category': 'Workshop',
        'image': kccImage,
        'price': null,
        'isFree': null,
        'description': 'Advanced course by ICCASkills targeting senior professionals in the MICE sector. This executive-level program covers strategic planning, leadership, and advanced convention management techniques.',
      },
      {
        'name': 'East African Business Forum 2026',
        'location': 'Kigali Convention Centre, Kigali',
        'date': 'September 25-27, 2026',
        'category': 'Conference',
        'image': kccImage,
        'price': null,
        'isFree': null,
        'description': 'Regional business forum promoting trade, investment, and economic cooperation across East Africa. Features B2B meetings, trade exhibitions, and policy discussions.',
      },
      {
        'name': 'Rwanda Health & Wellness Expo 2026',
        'location': 'Kigali Convention Centre, Kigali',
        'date': 'October 15-17, 2026',
        'category': 'Exhibition',
        'image': kccImage,
        'price': null,
        'isFree': null,
        'description': 'Comprehensive health and wellness exhibition featuring medical equipment, pharmaceuticals, wellness products, and healthcare services.',
      },
      {
        'name': 'Africa Agriculture Summit 2026',
        'location': 'Kigali Convention Centre, Kigali',
        'date': 'November 5-7, 2026',
        'category': 'Summit',
        'image': kccImage,
        'price': null,
        'isFree': null,
        'description': 'International summit focusing on sustainable agriculture, food security, and agricultural innovation in Africa. Brings together farmers, researchers, and policymakers.',
      },
      // 2027 Events
      {
        'name': 'Rwanda Innovation Week 2027',
        'location': 'Kigali Convention Centre, Kigali',
        'date': 'February 10-16, 2027',
        'category': 'Conference',
        'image': kccImage,
        'price': null,
        'isFree': null,
        'description': 'Week-long celebration of innovation, entrepreneurship, and technology in Rwanda. Features startup pitches, innovation showcases, and networking events.',
      },
      {
        'name': 'Africa Energy Summit 2027',
        'location': 'Kigali Convention Centre, Kigali',
        'date': 'April 18-20, 2027',
        'category': 'Summit',
        'image': kccImage,
        'price': null,
        'isFree': null,
        'description': 'Regional energy summit addressing renewable energy, power infrastructure, and energy security across Africa. Features exhibitions, technical sessions, and policy forums.',
      },
      {
        'name': 'Rwanda Fashion Week 2027',
        'location': 'Kigali Convention Centre, Kigali',
        'date': 'May 25-27, 2027',
        'category': 'Exhibition',
        'image': kccImage,
        'price': null,
        'isFree': null,
        'description': 'Premier fashion event showcasing African designers, textiles, and fashion trends. Features runway shows, exhibitions, and networking opportunities.',
      },
    ];
  }
}
