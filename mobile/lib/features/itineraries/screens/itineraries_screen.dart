import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/theme/text_theme_extensions.dart';
import '../../../core/providers/itinerary_provider.dart';
import '../../../core/models/itinerary.dart';

class ItinerariesScreen extends ConsumerStatefulWidget {
  const ItinerariesScreen({super.key});

  @override
  ConsumerState<ItinerariesScreen> createState() => _ItinerariesScreenState();
}

class _ItinerariesScreenState extends ConsumerState<ItinerariesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: Text(
          'My Itineraries',
          style: context.titleLarge,
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
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              context.push('/itineraries/create');
            },
            tooltip: 'Create Itinerary',
          ),
        ],
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final itinerariesAsync = ref.watch(myItinerariesProvider);

          return itinerariesAsync.when(
            data: (itineraries) {
              if (itineraries.isEmpty) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                color: context.primaryColorTheme,
                backgroundColor: context.cardColor,
                onRefresh: () async {
                  ref.invalidate(myItinerariesProvider);
                  await Future.delayed(const Duration(milliseconds: 500));
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: itineraries.length,
                  itemBuilder: (context, index) {
                    return _buildItineraryCard(itineraries[index]);
                  },
                ),
              );
            },
            loading: () => ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: 5,
              itemBuilder: (context, index) {
                return _buildSkeletonCard();
              },
            ),
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
                    'Failed to load itineraries',
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
                      ref.invalidate(myItinerariesProvider);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.primaryColorTheme,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildItineraryCard(Itinerary itinerary) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final daysCount = itinerary.daysCount;
    final itemsCount = itinerary.items.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: InkWell(
        onTap: () {
          context.push('/itineraries/${itinerary.id}');
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                          itinerary.title,
                          style: context.titleLarge.copyWith(
                            fontWeight: FontWeight.w600,
                            color: context.primaryTextColor,
                          ),
                        ),
                        if (itinerary.description != null && itinerary.description!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            itinerary.description!,
                            style: context.bodySmall.copyWith(
                              color: context.secondaryTextColor,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
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
              const SizedBox(height: 12),
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
                    '$daysCount ${daysCount == 1 ? 'day' : 'days'}',
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              if (itemsCount > 0) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.list,
                      size: 16,
                      color: context.secondaryTextColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$itemsCount ${itemsCount == 1 ? 'item' : 'items'}',
                      style: context.bodySmall.copyWith(
                        color: context.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 20,
            width: double.infinity,
            decoration: BoxDecoration(
              color: context.grey200,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 16,
            width: 200,
            decoration: BoxDecoration(
              color: context.grey200,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.route,
            size: 80,
            color: context.secondaryTextColor.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'No Itineraries Yet',
            style: context.headlineSmall.copyWith(
              color: context.primaryTextColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Plan your perfect trip by creating an itinerary. Add places, events, and tours to organize your journey.',
              style: context.bodyMedium.copyWith(
                color: context.secondaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              context.push('/itineraries/create');
            },
            icon: const Icon(Icons.add),
            label: const Text('Create Itinerary'),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.primaryColorTheme,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

