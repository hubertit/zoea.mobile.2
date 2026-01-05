import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/theme/text_theme_extensions.dart';
import '../../../core/providers/itinerary_provider.dart';
import '../../../core/services/itinerary_service.dart';
import '../../../core/models/itinerary.dart';
import '../../../core/config/app_config.dart';

class ItineraryDetailScreen extends ConsumerStatefulWidget {
  final String itineraryId;

  const ItineraryDetailScreen({super.key, required this.itineraryId});

  @override
  ConsumerState<ItineraryDetailScreen> createState() => _ItineraryDetailScreenState();
}

class _ItineraryDetailScreenState extends ConsumerState<ItineraryDetailScreen> {
  bool _isSharing = false;

  @override
  Widget build(BuildContext context) {
    final itineraryAsync = ref.watch(itineraryByIdProvider(widget.itineraryId));

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: itineraryAsync.when(
          data: (itinerary) => Text(
            itinerary.title,
            style: context.titleLarge,
          ),
          loading: () => const Text('Itinerary'),
          error: (_, __) => const Text('Itinerary'),
        ),
        backgroundColor: context.backgroundColor,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.chevron_left, size: 32),
          style: IconButton.styleFrom(
            foregroundColor: context.primaryTextColor,
          ),
        ),
        actions: [
          itineraryAsync.when(
            data: (itinerary) => IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                context.push('/itineraries/create', extra: itinerary).then((_) {
                  ref.invalidate(itineraryByIdProvider(widget.itineraryId));
                });
              },
              tooltip: 'Edit',
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          itineraryAsync.when(
            data: (itinerary) => IconButton(
              icon: _isSharing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.share),
              onPressed: () => _shareItinerary(itinerary),
              tooltip: 'Share',
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: itineraryAsync.when(
        data: (itinerary) => _buildItineraryContent(itinerary),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
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
                'Failed to load itinerary',
                style: context.headlineSmall.copyWith(
                  color: context.errorColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: context.bodySmall.copyWith(
                  color: context.secondaryTextColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(itineraryByIdProvider(widget.itineraryId));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.primaryColorTheme,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItineraryContent(Itinerary itinerary) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');
    final sortedItems = itinerary.sortedItems;

    return RefreshIndicator(
      color: context.primaryColorTheme,
      backgroundColor: context.cardColor,
      onRefresh: () async {
        ref.invalidate(itineraryByIdProvider(widget.itineraryId));
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: context.isDarkMode
                        ? Colors.black.withOpacity(0.3)
                        : Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          itinerary.title,
                          style: context.headlineSmall.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (itinerary.isShared)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: context.primaryColorTheme.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.share,
                                size: 14,
                                color: context.primaryColorTheme,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Shared',
                                style: context.bodySmall.copyWith(
                                  color: context.primaryColorTheme,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  if (itinerary.description != null && itinerary.description!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      itinerary.description!,
                      style: context.bodyMedium.copyWith(
                        color: context.secondaryTextColor,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: context.secondaryTextColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${dateFormat.format(itinerary.startDate)} - ${dateFormat.format(itinerary.endDate)}',
                        style: context.bodySmall.copyWith(
                          color: context.secondaryTextColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: context.secondaryTextColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${itinerary.daysCount} ${itinerary.daysCount == 1 ? 'day' : 'days'}',
                        style: context.bodySmall.copyWith(
                          color: context.secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                  if (itinerary.location != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: context.secondaryTextColor,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            itinerary.location!,
                            style: context.bodySmall.copyWith(
                              color: context.secondaryTextColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Items Section
            Text(
              'Itinerary Items (${sortedItems.length})',
              style: context.titleLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            
            if (sortedItems.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: context.cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.list,
                        size: 48,
                        color: context.secondaryTextColor.withOpacity(0.5),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No items in this itinerary',
                        style: context.bodyMedium.copyWith(
                          color: context.secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...sortedItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return _buildItemCard(item, index);
              }),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(ItineraryItem item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Item type icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getItemTypeColor(item.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getItemTypeIcon(item.type),
                  color: _getItemTypeColor(item.type),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getItemName(item),
                      style: context.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: context.secondaryTextColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('MMM d, h:mm a').format(item.startTime),
                          style: context.bodySmall.copyWith(
                            color: context.secondaryTextColor,
                          ),
                        ),
                        if (item.durationMinutes != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            '• ${item.durationMinutes} min',
                            style: context.bodySmall.copyWith(
                              color: context.secondaryTextColor,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (item.customDescription != null && item.customDescription!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              item.customDescription!,
              style: context.bodySmall.copyWith(
                color: context.secondaryTextColor,
              ),
            ),
          ],
          if (item.customLocation != null && item.customLocation!.isNotEmpty) ...[
            const SizedBox(height: 8),
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
                    item.customLocation!,
                    style: context.bodySmall.copyWith(
                      color: context.secondaryTextColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (item.notes != null && item.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: context.grey50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.note,
                    size: 16,
                    color: context.secondaryTextColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.notes!,
                      style: context.bodySmall.copyWith(
                        color: context.secondaryTextColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),
          // Action buttons
          Row(
            children: [
              if (item.listingId != null)
                TextButton.icon(
                  onPressed: () {
                    context.push('/listing/${item.listingId}');
                  },
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text('View'),
                  style: TextButton.styleFrom(
                    foregroundColor: context.primaryColorTheme,
                  ),
                ),
              if (item.eventId != null)
                TextButton.icon(
                  onPressed: () {
                    // Navigate to events screen - event detail uses Event object
                    context.push('/events');
                  },
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text('View'),
                  style: TextButton.styleFrom(
                    foregroundColor: context.primaryColorTheme,
                  ),
                ),
              if (item.tourId != null)
                TextButton.icon(
                  onPressed: () {
                    context.push('/tour-packages');
                  },
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text('View'),
                  style: TextButton.styleFrom(
                    foregroundColor: context.primaryColorTheme,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _getItemName(ItineraryItem item) {
    switch (item.type) {
      case ItineraryItemType.listing:
        return item.metadata?['name'] ?? 'Place';
      case ItineraryItemType.event:
        return item.metadata?['name'] ?? 'Event';
      case ItineraryItemType.tour:
        return item.metadata?['name'] ?? 'Tour';
      case ItineraryItemType.custom:
        return item.customName ?? 'Custom Item';
    }
  }

  IconData _getItemTypeIcon(ItineraryItemType type) {
    switch (type) {
      case ItineraryItemType.listing:
        return Icons.place;
      case ItineraryItemType.event:
        return Icons.event;
      case ItineraryItemType.tour:
        return Icons.tour;
      case ItineraryItemType.custom:
        return Icons.add_location_alt;
    }
  }

  Color _getItemTypeColor(ItineraryItemType type) {
    switch (type) {
      case ItineraryItemType.listing:
        return Colors.blue;
      case ItineraryItemType.event:
        return Colors.purple;
      case ItineraryItemType.tour:
        return Colors.green;
      case ItineraryItemType.custom:
        return Colors.orange;
    }
  }

  Future<void> _shareItinerary(Itinerary itinerary) async {
    setState(() {
      _isSharing = true;
    });

    try {
      final itineraryService = ref.read(itineraryServiceProvider);
      String shareToken;
      
      if (itinerary.shareToken != null) {
        shareToken = itinerary.shareToken!;
      } else {
        shareToken = await itineraryService.shareItinerary(itinerary.id);
      }

      final shareUrl = '${AppConfig.apiBaseUrl.replaceAll('/api', '')}/itineraries/shared/$shareToken';
      final shareText = 'Check out my itinerary: ${itinerary.title}\n\n$shareUrl';

      await Share.share(
        shareText,
        subject: itinerary.title,
      );

      // Refresh to get updated share token
      ref.invalidate(itineraryByIdProvider(widget.itineraryId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
  }
}

