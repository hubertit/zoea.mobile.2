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
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
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
                    // No pricing information for MICE events
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
        'name': 'ChampionHer Global CyberSecurity Summit',
        'location': 'Kigali Convention Centre, Kigali',
        'date': 'October 2-3, 2025',
        'category': 'Summit',
        'image': 'https://images.unsplash.com/photo-1563013544-824ae1b704d3?w=500',
        'price': null,
        'isFree': null,
        'description': 'The inaugural Championing Women in Cybersecurity Conference is a pivotal step towards advancing women in cybersecurity.',
      },
      {
        'name': '2025 ISO Annual Meeting',
        'location': 'Kigali Convention Centre, Kigali',
        'date': 'October 5-9, 2025',
        'category': 'Conference',
        'image': 'https://images.unsplash.com/photo-1515187029135-18ee286d815b?w=500',
        'price': null,
        'isFree': null,
        'description': 'The ISO Annual Meeting is a unique convening opportunity for timely discussion on emerging trends in international standards.',
      },
      {
        'name': 'Genomic Frontiers: Rwanda 2025',
        'location': 'The Retreat by Hemingways, Kigali',
        'date': 'October 15-17, 2025',
        'category': 'Symposium',
        'image': 'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=500',
        'price': null,
        'isFree': null,
        'description': 'Symposium on Genomics in Africa bringing together researchers, students, and professionals in genomics.',
      },
      {
        'name': '6th World Congress on Agroforestry 2025',
        'location': 'Kigali Convention Centre, Kigali',
        'date': 'October 20-24, 2025',
        'category': 'Congress',
        'image': 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=500',
        'price': null,
        'isFree': null,
        'description': 'The World Congress on Agroforestry is an international event that brings together agroforestry experts from around the world.',
      },
      {
        'name': 'Mobile World Congress (MWC) Kigali 2025',
        'location': 'Kigali Convention Centre, Kigali',
        'date': 'October 21-23, 2025',
        'category': 'Congress',
        'image': 'https://images.unsplash.com/photo-1512941937669-90a1b58e7e9c?w=500',
        'price': null,
        'isFree': null,
        'description': 'With 5G connections growing from two million in 2022, to a predicted 358 million by 2030, MWC Kigali explores the future of mobile technology.',
      },
      {
        'name': 'IAU 2025 International Conference',
        'location': 'Kigali Conference & Exhibition Village, Kigali',
        'date': 'October 21-23, 2025',
        'category': 'Conference',
        'image': 'https://images.unsplash.com/photo-1523050854058-8df90110c9f1?w=500',
        'price': null,
        'isFree': null,
        'description': 'The International Association of Universities (IAU) International Conference is an annual event bringing together university leaders globally.',
      },
      {
        'name': 'Africa HealthTech Summit (AHTS) 2025',
        'location': 'Kigali Convention Centre, Kigali',
        'date': 'October 13-15, 2025',
        'category': 'Summit',
        'image': 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1f?w=500',
        'price': null,
        'isFree': null,
        'description': 'Now in its fourth edition, the Africa HealthTech Summit brings together Ministers of Health and technology leaders.',
      },
      {
        'name': 'Inspire Africa Conference',
        'location': 'Kigali Marriott Hotel, Kigali',
        'date': 'October 14-17, 2025',
        'category': 'Conference',
        'image': 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=500',
        'price': null,
        'isFree': null,
        'description': 'This year\'s theme will explore how Africa-led innovation and AI are shaping the next generation of African development.',
      },
      {
        'name': 'Professional Fighters League (PFL)',
        'location': 'BK Arena, Kigali',
        'date': 'October 18, 2025',
        'category': 'Sports',
        'image': 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=500',
        'price': null,
        'isFree': null,
        'description': 'Professional Fighters League (PFL) is a global powerhouse in MMA and the fastest-growing sports league in the world.',
      },
      {
        'name': 'Africa Blockchain Festival',
        'location': 'Kigali Convention Centre, Kigali',
        'date': 'November 7-9, 2025',
        'category': 'Festival',
        'image': 'https://images.unsplash.com/photo-1639762681485-074b7f938ba0?w=500',
        'price': null,
        'isFree': null,
        'description': 'The Africa Blockchain Festival (ABF) is a continent-wide gathering of visionaries, builders, and innovators in blockchain technology.',
      },
      {
        'name': 'Advancing Sign Language Interpretation for Africa',
        'location': 'Sainte Famille Hotel, Kigali',
        'date': 'November 3-5, 2025',
        'category': 'Conference',
        'image': 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=500',
        'price': null,
        'isFree': null,
        'description': 'The African Federation of Sign Language Interpreters (AFSLI) is a Pan-African organization advancing sign language interpretation across Africa.',
      },
      {
        'name': '12th ANAPRI Stakeholders Conference',
        'location': 'Ubumwe Grande Hotel, Kigali',
        'date': 'November 4-6, 2025',
        'category': 'Conference',
        'image': 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=500',
        'price': null,
        'isFree': null,
        'description': 'The ANAPRI Stakeholders Conference is an annual event that convenes a diverse range of stakeholders in African development.',
      },
      {
        'name': 'The Lions Club Africa Forum 2025',
        'location': 'Kigali Convention Centre, Kigali',
        'date': 'November 12-15, 2025',
        'category': 'Forum',
        'image': 'https://images.unsplash.com/photo-1521737604893-d14cc237f11d?w=500',
        'price': null,
        'isFree': null,
        'description': 'The Africa Forum represents a fundamental pillar in the ongoing success of our organization across the African continent.',
      },
      {
        'name': 'African Summit on Entrepreneurship and Innovation',
        'location': 'Kigali Convention Centre, Kigali',
        'date': 'November 13-15, 2025',
        'category': 'Summit',
        'image': 'https://images.unsplash.com/photo-1515187029135-18ee286d815b?w=500',
        'price': null,
        'isFree': null,
        'description': 'African Summit on Entrepreneurship and Innovation (ASENTI) is a Pan African annual forum that brings together entrepreneurs and innovators.',
      },
      {
        'name': '46th OIF Ministerial Meeting',
        'location': 'Kigali Convention Centre, Kigali',
        'date': 'November 19-21, 2025',
        'category': 'Meeting',
        'image': 'https://images.unsplash.com/photo-1521737604893-d14cc237f11d?w=500',
        'price': null,
        'isFree': null,
        'description': 'The OIF\'s Ministerial Conference (Conférence Ministérielle de la Francophonie, CMF) is a pivotal gathering of French-speaking nations.',
      },
      {
        'name': 'Africa/Week 2025',
        'location': 'Norrsken House, Kigali',
        'date': 'November 20-21, 2025',
        'category': 'Conference',
        'image': 'https://images.unsplash.com/photo-1512941937669-90a1b58e7e9c?w=500',
        'price': null,
        'isFree': null,
        'description': 'Africa/Week brings together the continent\'s leading stakeholders in technology and innovation.',
      },
      {
        'name': 'Africa Energy Expo 2025',
        'location': 'Kigali Convention Centre, Kigali',
        'date': 'November 25-27, 2025',
        'category': 'Expo',
        'image': 'https://images.unsplash.com/photo-1466611653911-95081537e5b7?w=500',
        'price': null,
        'isFree': null,
        'description': 'Africa Energy Expo features have been carefully designed to bring together experienced industry professionals in the energy sector.',
      },
      {
        'name': '28th African Securities Exchanges Association',
        'location': 'Kigali Serena Hotel, Kigali',
        'date': 'November 26-28, 2025',
        'category': 'Conference',
        'image': 'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=500',
        'price': null,
        'isFree': null,
        'description': 'Theme: Adapting to Global Market Shifts: Strategies for Resilience and Growth in African Capital Markets.',
      },
      {
        'name': 'Africa Global Leadership Summit & Impact Awards',
        'location': 'Kigali Convention Centre, Kigali',
        'date': 'November 14, 2025',
        'category': 'Summit',
        'image': 'https://images.unsplash.com/photo-1521737604893-d14cc237f11d?w=500',
        'price': null,
        'isFree': null,
        'description': 'The Africa Global Leadership Summit & Impact Awards (AGLSIA) is an annual flagship Leadership development and recognition event.',
      },
      {
        'name': '9th Aviation Africa Summit & Exhibition 2025',
        'location': 'Kigali Convention Centre, Kigali',
        'date': 'September 4-5, 2025',
        'category': 'Summit',
        'image': 'https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=500',
        'price': null,
        'isFree': null,
        'description': 'A premier gathering of top executives and officials in the airline industry across Africa.',
      },
    ];
  }
}
