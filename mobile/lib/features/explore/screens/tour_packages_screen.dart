import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/theme/text_theme_extensions.dart';
import '../../../core/providers/tours_provider.dart';

class TourPackagesScreen extends ConsumerStatefulWidget {
  const TourPackagesScreen({super.key});

  @override
  ConsumerState<TourPackagesScreen> createState() => _TourPackagesScreenState();
}

class _TourPackagesScreenState extends ConsumerState<TourPackagesScreen>
    with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    
    // Shimmer animation controller
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // Start shimmer animation
    _shimmerController.repeat();
    
    // Shimmer animation
    _shimmerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final toursAsync = ref.watch(toursProvider(const ToursParams(
      page: 1,
      limit: 100,
      status: 'active',
    )));

    return Scaffold(
      backgroundColor: context.grey50,
      appBar: AppBar(
        backgroundColor: context.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left,
            color: context.primaryTextColor,
            size: 32,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Tour Packages',
          style: context.headlineMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: toursAsync.when(
        loading: () => ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: 5,
          itemBuilder: (context, index) {
            return _buildTourCardSkeleton(context);
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
                'Failed to load tour packages',
                style: context.bodyLarge.copyWith(
                  color: context.secondaryTextColor,
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
        data: (response) {
          final tours = (response['data'] as List?)?.cast<Map<String, dynamic>>() ?? [];
          
          if (tours.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.tour_outlined,
                    size: 64,
                    color: context.secondaryTextColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No tour packages available',
                    style: context.bodyLarge.copyWith(
                      color: context.secondaryTextColor,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: tours.length,
            itemBuilder: (context, index) {
              final tour = tours[index];
              return _buildTourCard(context, tour);
            },
          );
        },
      ),
    );
  }

  Widget _buildTourCard(BuildContext context, Map<String, dynamic> tour) {
    final String title = tour['name'] ?? 'Untitled Tour';
    final String description = tour['description'] ?? '';
    
    // Parse price safely
    double? priceFrom;
    try {
      final priceValue = tour['pricePerPerson'];
      if (priceValue != null) {
        if (priceValue is num) {
          priceFrom = priceValue.toDouble();
        } else if (priceValue is String) {
          priceFrom = double.tryParse(priceValue);
        }
      }
    } catch (e) {
      priceFrom = null;
    }
    
    final String? coverImageUrl = tour['images']?[0]?['media']?['url'];
    final String? difficulty = tour['difficultyLevel'];
    
    // Parse duration safely - handle both String and num types
    int? duration;
    final durationDaysValue = tour['durationDays'];
    final durationHoursValue = tour['durationHours'];
    
    if (durationDaysValue != null) {
      if (durationDaysValue is num) {
        duration = durationDaysValue.toInt();
      } else if (durationDaysValue is String) {
        duration = int.tryParse(durationDaysValue);
      }
    } else if (durationHoursValue != null) {
      if (durationHoursValue is num) {
        duration = durationHoursValue.toInt();
      } else if (durationHoursValue is String) {
        duration = int.tryParse(durationHoursValue);
      }
    }
    
    final String? durationType = tour['durationDays'] != null ? 'day' : (tour['durationHours'] != null ? 'hour' : null);
    final bool isFeatured = tour['isFeatured'] ?? false;

    // Determine badge
    String badge = 'TOUR PACKAGE';
    if (isFeatured) {
      badge = 'FEATURED';
    } else if (difficulty != null) {
      badge = difficulty.toUpperCase();
    }

    // Format price
    final formatter = NumberFormat('#,###', 'en_US');
    String priceText = 'Price on request';
    if (priceFrom != null) {
      priceText = 'From RWF ${formatter.format(priceFrom)}';
    }

    // Format duration
    String durationText = '';
    if (duration != null && durationType != null) {
      durationText = '$duration ${durationType}${duration > 1 ? 's' : ''}';
    }

    return GestureDetector(
      onTap: () {
        // Navigate to tour detail screen
        final slug = tour['slug'];
        if (slug != null) {
          context.push('/tour/$slug');
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: context.backgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: context.isDarkMode 
                  ? Colors.black.withOpacity(0.3)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left content
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: context.primaryColorTheme.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        badge,
                        style: context.labelSmall.copyWith(
                          color: context.primaryColorTheme,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Title
                    Text(
                      title,
                      style: context.headlineSmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: context.primaryTextColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    
                    // Description
                    Text(
                      description,
                      style: context.bodyMedium.copyWith(
                        color: context.secondaryTextColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    
                    // Duration (if available)
                    if (durationText.isNotEmpty) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.schedule_outlined,
                            size: 16,
                            color: context.secondaryTextColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            durationText,
                            style: context.bodySmall.copyWith(
                              color: context.secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                    
                    // Price
                    Text(
                      priceText,
                      style: context.titleMedium.copyWith(
                        color: context.primaryColorTheme,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Right content - Image
            Expanded(
              flex: 1,
              child: Container(
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.horizontal(right: Radius.circular(16)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.horizontal(right: Radius.circular(16)),
                  child: coverImageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: coverImageUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: context.dividerColor,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: context.primaryColorTheme,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: context.dividerColor,
                            child: Icon(
                              Icons.tour_outlined,
                              color: context.secondaryTextColor,
                              size: 32,
                            ),
                          ),
                        )
                      : Container(
                          color: context.dividerColor,
                          child: Icon(
                            Icons.tour_outlined,
                            color: context.secondaryTextColor,
                            size: 32,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTourCardSkeleton(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: context.backgroundColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: context.isDarkMode 
                    ? Colors.black.withOpacity(0.3)
                    : Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Left content skeleton
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge skeleton
                      Container(
                        height: 20,
                        width: 60,
                        decoration: BoxDecoration(
                          color: context.grey300,
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              context.grey300,
                              context.grey200,
                              context.grey300,
                            ],
                            stops: [
                              0.0,
                              _shimmerAnimation.value,
                              1.0,
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Title skeleton
                      Container(
                        height: 18,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: context.grey300,
                          borderRadius: BorderRadius.circular(4),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              context.grey300,
                              context.grey200,
                              context.grey300,
                            ],
                            stops: [
                              0.0,
                              _shimmerAnimation.value,
                              1.0,
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 18,
                        width: 200,
                        decoration: BoxDecoration(
                          color: context.grey300,
                          borderRadius: BorderRadius.circular(4),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              context.grey300,
                              context.grey200,
                              context.grey300,
                            ],
                            stops: [
                              0.0,
                              _shimmerAnimation.value,
                              1.0,
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Description skeleton
                      Container(
                        height: 14,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: context.grey200,
                          borderRadius: BorderRadius.circular(4),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              context.grey200,
                              context.grey100,
                              context.grey200,
                            ],
                            stops: [
                              0.0,
                              _shimmerAnimation.value,
                              1.0,
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 14,
                        width: 150,
                        decoration: BoxDecoration(
                          color: context.grey200,
                          borderRadius: BorderRadius.circular(4),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              context.grey200,
                              context.grey100,
                              context.grey200,
                            ],
                            stops: [
                              0.0,
                              _shimmerAnimation.value,
                              1.0,
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Duration skeleton
                      Row(
                        children: [
                          Container(
                            height: 16,
                            width: 16,
                            decoration: BoxDecoration(
                              color: context.grey200,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            height: 12,
                            width: 60,
                            decoration: BoxDecoration(
                              color: context.grey200,
                              borderRadius: BorderRadius.circular(4),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  context.grey200,
                                  context.grey100,
                                  context.grey200,
                                ],
                                stops: [
                                  0.0,
                                  _shimmerAnimation.value,
                                  1.0,
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      // Price skeleton
                      Container(
                        height: 20,
                        width: 120,
                        decoration: BoxDecoration(
                          color: context.grey300,
                          borderRadius: BorderRadius.circular(4),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              context.grey300,
                              context.grey200,
                              context.grey300,
                            ],
                            stops: [
                              0.0,
                              _shimmerAnimation.value,
                              1.0,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Right content - Image skeleton
              Expanded(
                flex: 1,
                child: Container(
                  height: 160,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.horizontal(right: Radius.circular(16)),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        context.grey300,
                        context.grey200,
                        context.grey300,
                      ],
                      stops: [
                        0.0,
                        _shimmerAnimation.value,
                        1.0,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

