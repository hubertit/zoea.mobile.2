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
              final itemId = favorite['id'] as String? ?? '';
              final type = favorite['type'] as String? ?? 'listing';
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
    final name = favorite['name'] as String? ?? favorite['title'] as String? ?? 'Unknown';
    final imageUrl = _getImageUrl(favorite);
    final location = _getLocation(favorite);

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

  String? _getImageUrl(Map<String, dynamic> favorite) {
    if (favorite['images'] != null && favorite['images'] is List) {
      final images = favorite['images'] as List;
      if (images.isNotEmpty) {
        final firstImage = images.first;
        if (firstImage is Map && firstImage['media'] != null) {
          return firstImage['media']['url'] ?? firstImage['media']['thumbnailUrl'];
        } else if (firstImage is String) {
          return firstImage;
        }
      }
    }
    if (favorite['image'] != null) {
      return favorite['image'] as String;
    }
    if (favorite['flyer'] != null) {
      return favorite['flyer'] as String;
    }
    return null;
  }

  String? _getLocation(Map<String, dynamic> favorite) {
    if (favorite['location'] != null) {
      return favorite['location'] as String;
    }
    if (favorite['address'] != null) {
      return favorite['address'] as String;
    }
    if (favorite['city'] != null) {
      final city = favorite['city'];
      if (city is Map) {
        return city['name'] as String?;
      } else if (city is String) {
        return city;
      }
    }
    if (favorite['venueName'] != null) {
      return favorite['venueName'] as String;
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
        final itemId = favorite['id'] as String? ?? '';
        return _selectedItems.contains(itemId);
      }).toList();

      final results = selectedFavorites.map((favorite) {
        final itemId = favorite['id'] as String? ?? '';
        final type = favorite['type'] as String? ?? 'listing';
        final name = favorite['name'] as String? ?? favorite['title'] as String? ?? 'Unknown';
        
        return {
          'id': itemId,
          'type': type,
          'name': name,
          'metadata': favorite,
        };
      }).toList();

      context.pop(results);
    });
  }
}

