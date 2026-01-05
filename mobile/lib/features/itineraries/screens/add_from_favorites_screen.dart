import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme_extensions.dart';
import '../../../core/theme/text_theme_extensions.dart';
import '../../../core/providers/favorites_provider.dart';
import '../../../core/widgets/fade_in_image.dart' show FadeInNetworkImage;

class AddFromFavoritesScreen extends ConsumerStatefulWidget {
  const AddFromFavoritesScreen({super.key});

  @override
  ConsumerState<AddFromFavoritesScreen> createState() => _AddFromFavoritesScreenState();
}

class _AddFromFavoritesScreenState extends ConsumerState<AddFromFavoritesScreen> {
  final Set<String> _selectedItems = {};

  @override
  Widget build(BuildContext context) {
    final favoritesAsync = ref.watch(favoritesProvider(const FavoritesParams(page: 1, limit: 100)));

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: const Text('Add from Favorites'),
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
      body: favoritesAsync.when(
        data: (response) {
          final favorites = response['data'] as List? ?? [];
          
          if (favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: context.secondaryTextColor.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Favorites',
                    style: context.headlineSmall.copyWith(
                      color: context.primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You don\'t have any favorites yet',
                    style: context.bodyMedium.copyWith(
                      color: context.secondaryTextColor,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final favorite = favorites[index] as Map<String, dynamic>;
              
              // Extract the actual item and determine type
              final item = _extractItem(favorite);
              final itemId = item['id'] as String? ?? '';
              
              // Determine type based on which nested object exists
              String type = 'listing';
              if (favorite['event'] != null) {
                type = 'event';
              } else if (favorite['tour'] != null) {
                type = 'tour';
              }
              
              final isSelected = _selectedItems.contains(itemId);

              return _buildFavoriteCard(favorite, itemId, type, isSelected);
            },
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
                'Failed to load favorites',
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

  Widget _buildFavoriteCard(Map<String, dynamic> favorite, String itemId, String type, bool isSelected) {
    // Extract the actual item from the favorite object
    final item = _extractItem(favorite);
    final name = item['name'] as String? ?? item['title'] as String? ?? 'Unknown';
    final imageUrl = _getImageUrl(item);
    final location = _getLocation(item);

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
                            _getTypeIcon(type),
                            color: context.secondaryTextColor,
                          ),
                        ),
                      )
                    : Container(
                        width: 60,
                        height: 60,
                        color: context.grey200,
                        child: Icon(
                          _getTypeIcon(type),
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

  /// Extract the actual item (listing, event, or tour) from the favorite object
  Map<String, dynamic> _extractItem(Map<String, dynamic> favorite) {
    // Favorites API returns: { listing: {...}, event: {...}, tour: {...} }
    if (favorite['listing'] != null) {
      return favorite['listing'] as Map<String, dynamic>;
    }
    if (favorite['event'] != null) {
      return favorite['event'] as Map<String, dynamic>;
    }
    if (favorite['tour'] != null) {
      return favorite['tour'] as Map<String, dynamic>;
    }
    // Fallback to the favorite object itself (shouldn't happen)
    return favorite;
  }

  String? _getImageUrl(Map<String, dynamic> item) {
    // For listings and tours - check images array
    if (item['images'] != null && item['images'] is List) {
      final images = item['images'] as List;
      if (images.isNotEmpty) {
        final firstImage = images.first;
        if (firstImage is Map && firstImage['media'] != null) {
          return firstImage['media']['url'] ?? firstImage['media']['thumbnailUrl'];
        } else if (firstImage is String) {
          return firstImage;
        }
      }
    }
    // For events - check attachments array
    if (item['attachments'] != null && item['attachments'] is List) {
      final attachments = item['attachments'] as List;
      if (attachments.isNotEmpty) {
        final firstAttachment = attachments.first;
        if (firstAttachment is Map && firstAttachment['media'] != null) {
          return firstAttachment['media']['url'] ?? firstAttachment['media']['thumbnailUrl'];
        }
      }
    }
    // Fallback to single image or flyer field
    if (item['image'] != null) {
      return item['image'] as String;
    }
    if (item['flyer'] != null) {
      return item['flyer'] as String;
    }
    return null;
  }

  String? _getLocation(Map<String, dynamic> item) {
    // For listings - check address and city
    if (item['address'] != null) {
      return item['address'] as String;
    }
    // For events - check locationName
    if (item['locationName'] != null) {
      return item['locationName'] as String;
    }
    // Check generic location field
    if (item['location'] != null) {
      return item['location'] as String;
    }
    // Check city
    if (item['city'] != null) {
      final city = item['city'];
      if (city is Map) {
        return city['name'] as String?;
      } else if (city is String) {
        return city;
      }
    }
    // For events - check venueName
    if (item['venueName'] != null) {
      return item['venueName'] as String;
    }
    return null;
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'listing':
      case 'place':
        return Icons.place;
      case 'event':
        return Icons.event;
      case 'tour':
        return Icons.tour;
      default:
        return Icons.favorite;
    }
  }

  void _addSelectedItems() {
    final favoritesAsync = ref.read(favoritesProvider(const FavoritesParams(page: 1, limit: 100)));
    
    favoritesAsync.whenData((response) {
      final favorites = response['data'] as List? ?? [];
      final selectedFavorites = favorites.where((favorite) {
        final item = _extractItem(favorite as Map<String, dynamic>);
        final itemId = item['id'] as String? ?? '';
        return _selectedItems.contains(itemId);
      }).toList();

      final results = selectedFavorites.map((favorite) {
        final favoriteMap = favorite as Map<String, dynamic>;
        final item = _extractItem(favoriteMap);
        final itemId = item['id'] as String? ?? '';
        
        // Determine type
        String type = 'listing';
        if (favoriteMap['event'] != null) {
          type = 'event';
        } else if (favoriteMap['tour'] != null) {
          type = 'tour';
        }
        
        final name = item['name'] as String? ?? item['title'] as String? ?? 'Unknown';
        
        return {
          'id': itemId,
          'type': type,
          'name': name,
          'metadata': item,  // Return the actual item, not the favorite wrapper
        };
      }).toList();

      context.pop(results);
    });
  }
}

