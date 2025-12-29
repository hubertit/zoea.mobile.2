import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/event.dart';

class EventDetailScreen extends ConsumerWidget {
  final Event event;

  const EventDetailScreen({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventDetails = event.event;
    final startDate = eventDetails.startDate;
    final endDate = eventDetails.endDate;
    final dateFormat = DateFormat('EEEE, MMMM dd, yyyy');
    final timeFormat = DateFormat('HH:mm');

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          // App Bar with image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppTheme.backgroundColor,
            leading: IconButton(
              icon: const Icon(Icons.chevron_left, color: Colors.white, size: 32),
              onPressed: () => context.go('/events'),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: () async {
                  final eventName = eventDetails.name;
                  final location = eventDetails.locationName.isNotEmpty 
                      ? eventDetails.locationName 
                      : '';
                  final dateText = dateFormat.format(startDate);
                  
                  // Share Sinc link instead of Zoea link
                  final sincUrl = 'https://www.sinc.events/${event.slug}';
                  final shareText = 'Check out "$eventName"${location.isNotEmpty ? ' in $location' : ''} on $dateText!';
                  
                  await SharePlus.instance.share(ShareParams(text: '$shareText\n$sincUrl'));
                },
              ),
              IconButton(
                icon: const Icon(Icons.favorite_border, color: Colors.white),
                onPressed: () {
                  // TODO: Implement favorite functionality
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: eventDetails.flyer,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppTheme.dividerColor,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppTheme.dividerColor,
                      child: const Icon(
                        Icons.event,
                        size: 64,
                        color: AppTheme.secondaryTextColor,
                      ),
                    ),
                  ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Event content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event title
                  Text(
                    eventDetails.name,
                    style: AppTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  
                  // Date and time
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 20,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        dateFormat.format(startDate),
                        style: AppTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 20,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${timeFormat.format(startDate)} - ${timeFormat.format(endDate)}',
                        style: AppTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Location
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 20,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          eventDetails.locationName,
                          style: AppTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Organizer
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: CachedNetworkImageProvider(event.owner.imageUrl),
                        onBackgroundImageError: (exception, stackTrace) {
                          // Handle image error
                        },
                        child: const Icon(Icons.person, color: AppTheme.primaryColor),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Organized by',
                              style: AppTheme.bodySmall,
                            ),
                            Row(
                              children: [
                                Text(
                                  event.owner.name,
                                  style: AppTheme.titleMedium,
                                ),
                                if (event.owner.isVerified) ...[
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.verified,
                                    size: 16,
                                    color: AppTheme.primaryColor,
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Description
                  Text(
                    'About this event',
                    style: AppTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    eventDetails.description,
                    style: AppTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  
                  // Event context/category
                  if (eventDetails.eventContext?.name.isNotEmpty == true) ...[
                    Text(
                      'Category',
                      style: AppTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        eventDetails.eventContext!.name,
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                  // Attendance info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.dividerColor),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildInfoItem(
                          icon: Icons.people,
                          label: 'Attending',
                          value: '${eventDetails.attending}',
                        ),
                        _buildInfoItem(
                          icon: Icons.group,
                          label: 'Capacity',
                          value: '${eventDetails.maxAttendance}',
                        ),
                        _buildInfoItem(
                          icon: Icons.event_available,
                          label: 'Status',
                          value: eventDetails.ongoing ? 'Ongoing' : 'Upcoming',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Tickets section
                  if (eventDetails.tickets.isNotEmpty) ...[
                    Text(
                      'Tickets',
                      style: AppTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    ...eventDetails.tickets.map((ticket) => _buildTicketCard(context, ticket, eventDetails.name)),
                    const SizedBox(height: 24),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTheme.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: AppTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildTicketCard(BuildContext context, EventTicket ticket, String eventName) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ticket.name,
                    style: AppTheme.titleMedium,
                  ),
                  if (ticket.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      ticket.description!,
                      style: AppTheme.bodySmall,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '${_formatPrice(ticket.price)} ${ticket.currency}',
                        style: AppTheme.titleLarge.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (ticket.disabled) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.errorColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Sold Out',
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.errorColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: ticket.disabled ? null : () {
                // Open Sinc page in webview
                final sincUrl = 'https://www.sinc.events/${event.slug}';
                context.push(
                  '/webview?url=${Uri.encodeComponent(sincUrl)}&title=${Uri.encodeComponent(eventName)}',
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                ticket.disabled ? 'Sold Out' : 'Buy Ticket',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final eventDetails = event.event;
    final hasTickets = eventDetails.tickets.isNotEmpty;
    final cheapestTicket = hasTickets 
        ? eventDetails.tickets.where((t) => !t.disabled).fold<EventTicket?>(
            null, (cheapest, ticket) => cheapest == null || ticket.price < cheapest.price ? ticket : cheapest)
        : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppTheme.backgroundColor,
        border: Border(
          top: BorderSide(color: AppTheme.dividerColor),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (cheapestTicket != null) ...[
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'From ${_formatPrice(cheapestTicket.price)} ${cheapestTicket.currency}',
                      style: AppTheme.titleMedium.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'per person',
                      style: AppTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
            ],
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () {
                  // Open Sinc page in webview for both ticket selection and free events
                  final sincUrl = 'https://www.sinc.events/${event.slug}';
                  context.push(
                    '/webview?url=${Uri.encodeComponent(sincUrl)}&title=${Uri.encodeComponent(eventDetails.name)}',
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  hasTickets ? 'Select Tickets' : 'Join Event',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
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

}

