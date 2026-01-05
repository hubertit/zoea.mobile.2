import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/theme/text_theme_extensions.dart';
import '../../../core/providers/tours_provider.dart';
import '../../../core/providers/favorites_provider.dart';

class TourDetailScreen extends ConsumerStatefulWidget {
  final String tourId;

  const TourDetailScreen({
    super.key,
    required this.tourId,
  });

  @override
  ConsumerState<TourDetailScreen> createState() => _TourDetailScreenState();
}

class _TourDetailScreenState extends ConsumerState<TourDetailScreen> {
  @override
  Widget build(BuildContext context) {
    // Try to load by ID first (for UUIDs), fallback to slug if it fails
    final tourAsync = ref.watch(tourByIdProvider(widget.tourId));

    return tourAsync.when(
      data: (tour) => _buildTourDetail(tour),
      loading: () => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.chevron_left, size: 32),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: CircularProgressIndicator(
            color: context.primaryColorTheme,
          ),
        ),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.chevron_left, size: 32),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
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
                'Failed to load tour details',
                style: context.bodyLarge.copyWith(
                  color: context.secondaryTextColor,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTourDetail(Map<String, dynamic> tour) {
    final name = tour['name'] as String? ?? 'Tour';
    final description = tour['description'] as String? ?? '';
    final shortDescription = tour['shortDescription'] as String? ?? '';
    
    final images = tour['images'] as List? ?? [];
    String? imageUrl;
    if (images.isNotEmpty && images[0] != null) {
      if (images[0] is Map) {
        final imageMap = images[0] as Map<String, dynamic>;
        imageUrl = imageMap['media']?['url'] as String?;
      }
    }

    final city = tour['city'] as Map<String, dynamic>?;
    final cityName = city?['name'] as String? ?? '';
    final startLocationName = tour['startLocationName'] as String? ?? '';
    final location = startLocationName.isNotEmpty 
        ? '$startLocationName${cityName.isNotEmpty ? ', $cityName' : ''}'
        : cityName;

    // Parse rating safely - handle both String and num types
    double rating = 0.0;
    final ratingValue = tour['rating'];
    if (ratingValue != null) {
      if (ratingValue is num) {
        rating = ratingValue.toDouble();
      } else if (ratingValue is String) {
        rating = double.tryParse(ratingValue) ?? 0.0;
      }
    }
    
    // Parse reviewCount safely - handle both String and num types
    int reviewCount = 0;
    final reviewCountValue = tour['reviewCount'] ?? tour['review_count'];
    if (reviewCountValue != null) {
      if (reviewCountValue is num) {
        reviewCount = reviewCountValue.toInt();
      } else if (reviewCountValue is String) {
        reviewCount = int.tryParse(reviewCountValue) ?? 0;
      }
    }
    
    // Parse price safely - handle both String and num types
    double? pricePerPerson;
    final priceValue = tour['pricePerPerson'];
    if (priceValue != null) {
      if (priceValue is num) {
        pricePerPerson = priceValue.toDouble();
      } else if (priceValue is String) {
        pricePerPerson = double.tryParse(priceValue);
      }
    }
    final currency = tour['currency'] as String? ?? 'USD';
    
    // Parse duration safely - handle both String and num types
    int? durationDays;
    final durationDaysValue = tour['durationDays'];
    if (durationDaysValue != null) {
      if (durationDaysValue is num) {
        durationDays = durationDaysValue.toInt();
      } else if (durationDaysValue is String) {
        durationDays = int.tryParse(durationDaysValue);
      }
    }
    
    double? durationHours;
    final durationHoursValue = tour['durationHours'];
    if (durationHoursValue != null) {
      if (durationHoursValue is num) {
        durationHours = durationHoursValue.toDouble();
      } else if (durationHoursValue is String) {
        durationHours = double.tryParse(durationHoursValue);
      }
    }
    
    // Parse group sizes safely - handle both String and num types
    int minGroupSize = 1;
    final minGroupSizeValue = tour['minGroupSize'];
    if (minGroupSizeValue != null) {
      if (minGroupSizeValue is num) {
        minGroupSize = minGroupSizeValue.toInt();
      } else if (minGroupSizeValue is String) {
        minGroupSize = int.tryParse(minGroupSizeValue) ?? 1;
      }
    }
    
    int maxGroupSize = 20;
    final maxGroupSizeValue = tour['maxGroupSize'];
    if (maxGroupSizeValue != null) {
      if (maxGroupSizeValue is num) {
        maxGroupSize = maxGroupSizeValue.toInt();
      } else if (maxGroupSizeValue is String) {
        maxGroupSize = int.tryParse(maxGroupSizeValue) ?? 20;
      }
    }
    
    final includes = (tour['includes'] as List?)?.cast<String>() ?? [];
    final excludes = (tour['excludes'] as List?)?.cast<String>() ?? [];
    final requirements = (tour['requirements'] as List?)?.cast<String>() ?? [];
    
    final difficultyLevel = tour['difficultyLevel'] as String?;
    final languages = (tour['languages'] as List?)?.cast<String>() ?? ['en'];

    // Get actual tour ID (not slug)
    final actualTourId = tour['id'] as String? ?? '';

    // Check if favorite
    final favoritesAsync = ref.watch(favoritesProvider(const FavoritesParams(page: 1, limit: 1000)));
    final isFavorite = favoritesAsync.maybeWhen(
      data: (favoritesData) {
        final favorites = (favoritesData['data'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        return favorites.any((fav) => fav['tourId'] == actualTourId || fav['tour_id'] == actualTourId);
      },
      orElse: () => false,
    );

    return Scaffold(
      backgroundColor: context.grey50,
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.chevron_left, color: Colors.white),
              ),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.white,
                  ),
                ),
                onPressed: () async {
                  if (actualTourId.isEmpty) return;
                  
                  final favoritesService = ref.read(favoritesServiceProvider);
                  if (isFavorite) {
                    await favoritesService.removeFromFavorites(tourId: actualTourId);
                  } else {
                    await favoritesService.addTourToFavorites(actualTourId);
                  }
                  ref.invalidate(favoritesProvider(const FavoritesParams(page: 1, limit: 1000)));
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: context.dividerColor,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: context.primaryColorTheme,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: context.dividerColor,
                        child: const Icon(Icons.tour, size: 64),
                      ),
                    )
                  : Container(
                      color: context.dividerColor,
                      child: const Icon(Icons.tour, size: 64),
                    ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Basic Info
                Container(
                  padding: const EdgeInsets.all(12),
                  color: context.backgroundColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: context.headlineMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.primaryTextColor,
                        ),
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
                              location,
                              style: context.bodyMedium.copyWith(
                                color: context.secondaryTextColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          // Rating
                          if (rating > 0) ...[
                            Icon(
                              Icons.star,
                              size: 18,
                              color: Colors.amber[700],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              rating.toStringAsFixed(1),
                              style: context.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: context.primaryTextColor,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '($reviewCount reviews)',
                              style: context.bodySmall.copyWith(
                                color: context.secondaryTextColor,
                              ),
                            ),
                            const SizedBox(width: 16),
                          ],
                          // Duration
                          if (durationDays != null || durationHours != null) ...[
                            Icon(
                              Icons.schedule,
                              size: 18,
                              color: context.secondaryTextColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              durationDays != null
                                  ? '$durationDays day${durationDays > 1 ? 's' : ''}'
                                  : '${durationHours}h',
                              style: context.bodyMedium.copyWith(
                                color: context.primaryTextColor,
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (difficultyLevel != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getDifficultyColor(difficultyLevel).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            difficultyLevel.toUpperCase(),
                            style: context.bodySmall.copyWith(
                              color: _getDifficultyColor(difficultyLevel),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Short Description
                if (shortDescription.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    color: context.backgroundColor,
                    child: Text(
                      shortDescription,
                      style: context.bodyLarge.copyWith(
                        color: context.primaryTextColor,
                        height: 1.5,
                      ),
                    ),
                  ),

                const SizedBox(height: 8),

                // Price Section
                if (pricePerPerson != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    color: context.backgroundColor,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Price per person',
                              style: context.bodySmall.copyWith(
                                color: context.secondaryTextColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              pricePerPerson != null
                                  ? '${NumberFormat('#,##0').format(pricePerPerson)} $currency'
                                  : '0 $currency',
                              style: context.headlineSmall.copyWith(
                                fontWeight: FontWeight.bold,
                                color: context.primaryColorTheme,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Group: $minGroupSize-$maxGroupSize people',
                          style: context.bodySmall.copyWith(
                            color: context.secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 8),

                // Description
                if (description.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    color: context.backgroundColor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'About this tour',
                          style: context.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.primaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          description,
                          style: context.bodyMedium.copyWith(
                            color: context.primaryTextColor,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 8),

                // What's Included
                if (includes.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    color: context.backgroundColor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'What\'s included',
                          style: context.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.primaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...includes.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 20,
                                color: context.successColor,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  item,
                                  style: context.bodyMedium.copyWith(
                                    color: context.primaryTextColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),

                const SizedBox(height: 8),

                // What's Not Included
                if (excludes.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    color: context.backgroundColor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'What\'s not included',
                          style: context.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.primaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...excludes.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.cancel,
                                size: 20,
                                color: context.errorColor,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  item,
                                  style: context.bodyMedium.copyWith(
                                    color: context.primaryTextColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),

                const SizedBox(height: 8),

                // Requirements
                if (requirements.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    color: context.backgroundColor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Requirements',
                          style: context.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.primaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...requirements.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 20,
                                color: context.primaryColorTheme,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  item,
                                  style: context.bodyMedium.copyWith(
                                    color: context.primaryTextColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),

                const SizedBox(height: 8),

                // Languages
                if (languages.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    color: context.backgroundColor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Available languages',
                          style: context.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.primaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: languages.map((lang) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: context.primaryColorTheme.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _getLanguageName(lang),
                              style: context.bodySmall.copyWith(
                                color: context.primaryColorTheme,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )).toList(),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 100), // Space for bottom button
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.backgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () {
              context.push('/tour-booking', extra: {
                'tourId': actualTourId,
                'tourName': name,
                'tourLocation': location,
                'tourImage': imageUrl ?? '',
                'tourRating': rating,
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Book Now',
              style: context.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'moderate':
        return Colors.orange;
      case 'hard':
      case 'challenging':
        return Colors.red;
      default:
        return context.primaryColorTheme;
    }
  }

  String _getLanguageName(String code) {
    switch (code.toLowerCase()) {
      case 'en':
        return 'English';
      case 'fr':
        return 'French';
      case 'rw':
      case 'kin':
        return 'Kinyarwanda';
      case 'sw':
        return 'Swahili';
      default:
        return code.toUpperCase();
    }
  }
}

