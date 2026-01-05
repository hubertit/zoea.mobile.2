import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme_extensions.dart';
import '../../../core/theme/text_theme_extensions.dart';
import '../../../core/providers/listings_provider.dart';
import '../../../core/providers/country_provider.dart';
import '../../../core/widgets/fade_in_image.dart' show FadeInNetworkImage;

class AddFromRecommendationsScreen extends ConsumerStatefulWidget {
  const AddFromRecommendationsScreen({super.key});

  @override
  ConsumerState<AddFromRecommendationsScreen> createState() => _AddFromRecommendationsScreenState();
}

class _AddFromRecommendationsScreenState extends ConsumerState<AddFromRecommendationsScreen> {
  final Set<String> _selectedItems = {};

  @override
  Widget build(BuildContext context) {
    final selectedCountry = ref.watch(selectedCountryProvider).value;
    final featuredAsync = ref.watch(featuredListingsProvider(selectedCountry?.id));

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: const Text('Add from Recommendations'),
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
          if (_selectedItems.isNotEmpty)
            TextButton(
              onPressed: () {
                _addSelectedItems();
              },
              child: Text(
                'Add (${_selectedItems.length})',
                style: TextStyle(
                  color: context.primaryColorTheme,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: featuredAsync.when(
        data: (listings) {
          if (listings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.recommend,
                    size: 64,
                    color: context.secondaryTextColor.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Recommendations',
                    style: context.headlineSmall.copyWith(
                      color: context.primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No recommended listings available',
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
              ref.invalidate(featuredListingsProvider(selectedCountry?.id));
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: listings.length,
              itemBuilder: (context, index) {
                final listing = listings[index];
                final itemId = listing['id'] as String? ?? '';
                final isSelected = _selectedItems.contains(itemId);

                return _buildRecommendationCard(listing, itemId, isSelected);
              },
            ),
          );
        },
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
                'Failed to load recommendations',
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendationCard(Map<String, dynamic> listing, String itemId, bool isSelected) {
    final name = listing['name'] as String? ?? 'Unknown';
    
    // Extract image URL
    String? imageUrl;
    if (listing['images'] != null && listing['images'] is List && (listing['images'] as List).isNotEmpty) {
      final firstImage = (listing['images'] as List).first;
      if (firstImage is Map && firstImage['media'] != null) {
        imageUrl = firstImage['media']['url'] ?? firstImage['media']['thumbnailUrl'];
      }
    }
    
    // Extract location
    final address = listing['address'] as String? ?? '';
    String cityName = '';
    final city = listing['city'];
    if (city is Map) {
      cityName = (city as Map<String, dynamic>)['name'] as String? ?? '';
    } else if (city is String) {
      cityName = city;
    }
    final location = address.isNotEmpty && cityName.isNotEmpty
        ? '$address, $cityName'
        : address.isNotEmpty
            ? address
            : cityName.isNotEmpty
                ? cityName
                : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? context.primaryColorTheme : context.grey200,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            if (isSelected) {
              _selectedItems.remove(itemId);
            } else {
              _selectedItems.add(itemId);
            }
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Checkbox
              Checkbox(
                value: isSelected,
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedItems.add(itemId);
                    } else {
                      _selectedItems.remove(itemId);
                    }
                  });
                },
                activeColor: context.primaryColorTheme,
              ),
              const SizedBox(width: 8),
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: imageUrl != null
                    ? FadeInNetworkImage(
                        imageUrl: imageUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorWidget: Container(
                          width: 60,
                          height: 60,
                          color: context.grey200,
                          child: Icon(
                            Icons.place,
                            color: context.secondaryTextColor,
                          ),
                        ),
                      )
                    : Container(
                        width: 60,
                        height: 60,
                        color: context.grey200,
                        child: Icon(
                          Icons.place,
                          color: context.secondaryTextColor,
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: context.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (location != null) ...[
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
                              location,
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addSelectedItems() {
    final selectedCountry = ref.read(selectedCountryProvider).value;
    final featuredAsync = ref.read(featuredListingsProvider(selectedCountry?.id));
    
    featuredAsync.whenData((listings) {
      final selectedListings = listings.where((listing) {
        final itemId = listing['id'] as String? ?? '';
        return _selectedItems.contains(itemId);
      }).toList();

      final results = selectedListings.map((listing) {
        final itemId = listing['id'] as String? ?? '';
        final name = listing['name'] as String? ?? 'Unknown';
        
        return {
          'id': itemId,
          'type': 'listing',
          'name': name,
          'metadata': listing,
        };
      }).toList();

      context.pop(results);
    });
  }
}

