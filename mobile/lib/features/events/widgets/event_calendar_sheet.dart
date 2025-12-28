import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
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
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Event Calendar',
                  style: AppTheme.titleLarge,
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Done'),
                ),
              ],
            ),
          ),
          // Calendar
          Flexible(
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
                weekendTextStyle: const TextStyle(
                  color: AppTheme.primaryTextColor,
                ),
                defaultTextStyle: const TextStyle(
                  color: AppTheme.primaryTextColor,
                ),
                selectedDecoration: const BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                todayDecoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.primaryColor,
                    width: 2,
                  ),
                ),
                todayTextStyle: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
                markersMaxCount: 5,
                markerDecoration: const BoxDecoration(
                  color: Colors.deepOrange,
                  shape: BoxShape.circle,
                ),
                markerMargin: const EdgeInsets.symmetric(horizontal: 1),
                markerSize: 6,
                holidayTextStyle: const TextStyle(
                  color: AppTheme.primaryColor,
                ),
                holidayDecoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: AppTheme.titleLarge.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
                leftChevronIcon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.chevron_left,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                ),
                rightChevronIcon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.chevron_right,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                ),
                headerPadding: const EdgeInsets.symmetric(vertical: 8),
                headerMargin: const EdgeInsets.only(bottom: 8),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: AppTheme.bodySmall.copyWith(
                  color: AppTheme.secondaryTextColor,
                  fontWeight: FontWeight.w500,
                ),
                weekendStyle: AppTheme.bodySmall.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.05),
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
          // Selected day events preview
          if (_selectedDay != null && _getEventsForDay(_selectedDay!).isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.05),
                border: const Border(
                  top: BorderSide(color: AppTheme.dividerColor),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Events on ${DateFormat('MMM dd, yyyy').format(_selectedDay!)}',
                    style: AppTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _getEventsForDay(_selectedDay!).length,
                      itemBuilder: (context, index) {
                        final event = _getEventsForDay(_selectedDay!)[index];
                        return Container(
                          width: 180,
                          margin: const EdgeInsets.only(right: 8),
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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.event.name,
              style: AppTheme.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              event.event.locationName,
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.secondaryTextColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 12,
                  color: AppTheme.secondaryTextColor,
                ),
                const SizedBox(width: 4),
                Text(
                  DateFormat('HH:mm').format(event.event.startDate),
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.secondaryTextColor,
                  ),
                ),
              ],
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
        decoration: const BoxDecoration(
          color: AppTheme.backgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.dividerColor,
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
                    style: AppTheme.titleLarge,
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
          widget.onDateSelected(event.event.startDate);
          Navigator.pop(context);
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
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      DateFormat('HH:mm').format(event.event.startDate),
                      style: AppTheme.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    Text(
                      DateFormat('HH:mm').format(event.event.endDate),
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.primaryColor,
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
                      style: AppTheme.titleSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 14,
                          color: AppTheme.secondaryTextColor,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.event.locationName,
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.secondaryTextColor,
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
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppTheme.secondaryTextColor,
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
