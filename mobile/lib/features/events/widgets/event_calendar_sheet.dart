import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/theme/text_theme_extensions.dart';
import '../../../core/models/event.dart';
import 'package:intl/intl.dart';

class EventCalendarSheet extends StatefulWidget {
  final List<Event> events;
  final Function(DateTime) onDateSelected;

  const EventCalendarSheet({
    super.key,
    required this.events,
    required this.onDateSelected,
  });

  @override
  State<EventCalendarSheet> createState() => _EventCalendarSheetState();
}

class _EventCalendarSheetState extends State<EventCalendarSheet> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
  }

  Map<DateTime, List<Event>> get _eventsByDate {
    final Map<DateTime, List<Event>> eventsMap = {};
    
    for (final event in widget.events) {
      final eventDate = DateTime(
        event.event.startDate.year,
        event.event.startDate.month,
        event.event.startDate.day,
      );
      
      if (eventsMap.containsKey(eventDate)) {
        eventsMap[eventDate]!.add(event);
      } else {
        eventsMap[eventDate] = [event];
      }
    }
    
    return eventsMap;
  }

  List<Event> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    final dayEvents = _eventsByDate[normalizedDay] ?? [];
    return dayEvents;
  }

  @override
  Widget build(BuildContext context) {
    // Debug: Events count available for debugging if needed
    
    // Calculate content height dynamically
    final hasEvents = _selectedDay != null && _getEventsForDay(_selectedDay!).isNotEmpty;
    final contentHeight = (20.0 + // Handle (4 + 8*2 margins)
        44.0 + // Header (text height + padding)
        360.0 + // Calendar (increased to prevent overflow)
        20.0 + // Spacing between calendar and events
        (hasEvents ? (12.0 + 20.0 + 6.0 + 90.0 + 16.0) : 0.0)).clamp(450.0, MediaQuery.of(context).size.height * 0.9); // Events section if present
    
    return Container(
      height: contentHeight,
      decoration: BoxDecoration(
        color: context.backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: context.dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Text(
              'Event Calendar',
              style: context.titleLarge.copyWith(
                color: context.primaryTextColor,
              ),
            ),
          ),
          // Calendar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: 360, // Increased height for calendar to prevent overflow
              child: TableCalendar<Event>(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              eventLoader: _getEventsForDay,
              startingDayOfWeek: StartingDayOfWeek.monday,
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                weekendTextStyle: TextStyle(
                  color: context.primaryTextColor,
                ),
                defaultTextStyle: TextStyle(
                  color: context.primaryTextColor,
                ),
                selectedDecoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: context.isDarkMode
                        ? [
                            const Color(0xFFFF6B35), // Vibrant orange
                            const Color(0xFFF7931E), // Golden orange
                            const Color(0xFFFFB627), // Warm gold
                          ]
                        : [
                            const Color(0xFFFF8C42), // Lighter orange
                            const Color(0xFFFFB347), // Peach orange
                            const Color(0xFFFFC837), // Bright gold
                          ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: context.isDarkMode
                          ? const Color(0xFFFF6B35).withOpacity(0.4)
                          : const Color(0xFFFF8C42).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                selectedTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                todayDecoration: BoxDecoration(
                  color: context.primaryColorTheme.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: context.primaryColorTheme,
                    width: 2,
                  ),
                ),
                todayTextStyle: TextStyle(
                  color: context.primaryColorTheme,
                  fontWeight: FontWeight.w600,
                ),
                markersMaxCount: 5,
                markerDecoration: BoxDecoration(
                  color: context.primaryColorTheme,
                  shape: BoxShape.circle,
                ),
                markerMargin: const EdgeInsets.symmetric(horizontal: 1),
                markerSize: 6,
                holidayTextStyle: TextStyle(
                  color: context.primaryColorTheme,
                ),
                holidayDecoration: BoxDecoration(
                  color: context.primaryColorTheme.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  if (events.isNotEmpty) {
                    if (events.length > 3) {
                      // Show fire emoji for more than 3 events
                      return const Positioned(
                        right: 1,
                        bottom: 1,
                        child: Text(
                          '🔥',
                          style: TextStyle(fontSize: 12),
                        ),
                      );
                    }
                    // Return null to use default dots for 3 or fewer events
                  }
                  return null;
                },
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: context.titleLarge.copyWith(
                  color: context.primaryColorTheme,
                  fontWeight: FontWeight.w600,
                ),
                leftChevronIcon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: context.primaryColorTheme.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.chevron_left,
                    color: context.primaryColorTheme,
                    size: 20,
                  ),
                ),
                rightChevronIcon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: context.primaryColorTheme.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.chevron_right,
                    color: context.primaryColorTheme,
                    size: 20,
                  ),
                ),
                headerPadding: const EdgeInsets.symmetric(vertical: 8),
                headerMargin: const EdgeInsets.only(bottom: 8),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: context.bodySmall.copyWith(
                  color: context.secondaryTextColor,
                  fontWeight: FontWeight.w500,
                ),
                weekendStyle: context.bodySmall.copyWith(
                  color: context.primaryColorTheme,
                  fontWeight: FontWeight.w600,
                ),
                decoration: BoxDecoration(
                  color: context.primaryColorTheme.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onDaySelected: (selectedDay, focusedDay) {
                if (!isSameDay(_selectedDay, selectedDay)) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                  
                  // Show events for selected day
                  final dayEvents = _getEventsForDay(selectedDay);
                  if (dayEvents.isNotEmpty) {
                    _showDayEvents(selectedDay, dayEvents);
                  }
                }
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
            ),
            ),
          ),
          const SizedBox(height: 20),
          // Selected day events preview
          if (_selectedDay != null && _getEventsForDay(_selectedDay!).isNotEmpty)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                color: context.primaryColorTheme.withOpacity(0.05),
                border: Border(
                  top: BorderSide(color: context.dividerColor),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Events on ${DateFormat('MMM dd, yyyy').format(_selectedDay!)}',
                    style: context.titleSmall.copyWith(
                      color: context.primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    height: 90,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _getEventsForDay(_selectedDay!).length,
                      itemBuilder: (context, index) {
                        final event = _getEventsForDay(_selectedDay!)[index];
                        return Container(
                          width: 200,
                          margin: const EdgeInsets.only(right: 6),
                          child: _buildEventPreview(event),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
  }

  Widget _buildEventPreview(Event event) {
    return InkWell(
      onTap: () {
        Navigator.pop(context); // Close the calendar sheet
        context.go('/event/${event.id}', extra: event);
      },
      child: Container(
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: context.dividerColor),
          boxShadow: [
            BoxShadow(
              color: context.isDarkMode ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Event poster
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(6)),
              child: CachedNetworkImage(
                imageUrl: event.event.flyer,
                width: 70,
                height: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 70,
                  color: context.dividerColor,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: context.primaryColorTheme,
                      strokeWidth: 1.5,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 70,
                  color: context.dividerColor,
                  child: Icon(
                    Icons.event,
                    size: 16,
                    color: context.secondaryTextColor,
                  ),
                ),
              ),
            ),
            // Event details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        event.event.name,
                        style: context.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 9,
                          color: context.primaryTextColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 8,
                          color: context.secondaryTextColor,
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            event.event.locationName,
                            style: context.bodySmall.copyWith(
                              color: context.secondaryTextColor,
                              fontSize: 7,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 8,
                          color: context.secondaryTextColor,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          DateFormat('HH:mm').format(event.event.startDate),
                          style: context.bodySmall.copyWith(
                            color: context.secondaryTextColor,
                            fontSize: 7,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDayEvents(DateTime day, List<Event> events) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: context.backgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: context.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Events on ${DateFormat('MMM dd, yyyy').format(day)}',
                    style: context.titleLarge.copyWith(
                      color: context.primaryTextColor,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  return _buildEventCard(event);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(Event event) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pop(context); // Close the day events bottom sheet
          context.go('/event/${event.id}', extra: event);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Time
              Container(
                width: 60,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: context.primaryColorTheme.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      DateFormat('HH:mm').format(event.event.startDate),
                      style: context.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.primaryColorTheme,
                      ),
                    ),
                    Text(
                      DateFormat('HH:mm').format(event.event.endDate),
                      style: context.bodySmall.copyWith(
                        color: context.primaryColorTheme,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Event details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.event.name,
                      style: context.titleSmall.copyWith(
                        color: context.primaryTextColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: context.secondaryTextColor,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.event.locationName,
                            style: context.bodySmall.copyWith(
                              color: context.secondaryTextColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (event.event.tickets.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'From ${_formatPrice(event.event.tickets.first.price)} ${event.event.tickets.first.currency}',
                        style: context.bodySmall.copyWith(
                          color: context.primaryColorTheme,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: context.secondaryTextColor,
              ),
            ],
          ),
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
}
