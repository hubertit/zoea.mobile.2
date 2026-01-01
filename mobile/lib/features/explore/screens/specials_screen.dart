import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_extensions.dart';

class SpecialsScreen extends StatelessWidget {
  const SpecialsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
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
          'Special Offers',
          style: AppTheme.headlineMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _getAllSpecials().length,
        itemBuilder: (context, index) {
          final special = _getAllSpecials()[index];
          return _buildSpecialCard(context, special);
        },
      ),
    );
  }

  Widget _buildSpecialCard(BuildContext context, Map<String, dynamic> special) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: context.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              padding: const EdgeInsets.all(20),
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
                      special['badge'],
                      style: AppTheme.labelSmall.copyWith(
                        color: context.primaryColorTheme,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Title
                  Text(
                    special['title'],
                    style: AppTheme.headlineSmall.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  
                  // Description
                  Text(
                    special['description'],
                    style: AppTheme.bodyMedium.copyWith(
                      color: context.secondaryTextColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  
                  // Price and discount
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            special['originalPrice'],
                            style: AppTheme.bodySmall.copyWith(
                              color: context.secondaryTextColor,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            special['discountedPrice'],
                            style: AppTheme.titleMedium.copyWith(
                              color: context.primaryColorTheme,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: context.successColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          special['discount'],
                          style: AppTheme.labelSmall.copyWith(
                            color: context.successColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Right content - Image
          Expanded(
            flex: 1,
            child: Container(
              height: 140,
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
                child: CachedNetworkImage(
                  imageUrl: special['image'],
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    color: context.dividerColor,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    color: context.dividerColor,
                    child: const Icon(Icons.image_not_supported),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getAllSpecials() {
    return [
      {
        'title': 'Gorilla Trekking',
        'description': 'Experience the majestic mountain gorillas in their natural habitat',
        'badge': 'LIMITED TIME',
        'originalPrice': 'RWF 1,500',
        'discountedPrice': 'RWF 1,200',
        'discount': '20% OFF',
        'image': 'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=200',
      },
      {
        'title': 'Cultural Village Tour',
        'description': 'Discover Rwanda\'s rich cultural heritage and traditions',
        'badge': 'POPULAR',
        'originalPrice': 'RWF 800',
        'discountedPrice': 'RWF 600',
        'discount': '25% OFF',
        'image': 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=200',
      },
      {
        'title': 'Lake Kivu Boat Trip',
        'description': 'Relax on a scenic boat trip across the beautiful Lake Kivu',
        'badge': 'NEW',
        'originalPrice': 'RWF 1,200',
        'discountedPrice': 'RWF 900',
        'discount': '25% OFF',
        'image': 'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=200',
      },
      {
        'title': 'Volcanoes National Park',
        'description': 'Hike through the stunning volcanic landscape and see golden monkeys',
        'badge': 'LIMITED TIME',
        'originalPrice': 'RWF 2,000',
        'discountedPrice': 'RWF 1,500',
        'discount': '25% OFF',
        'image': 'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=200',
      },
      {
        'title': 'Nyungwe Forest Canopy Walk',
        'description': 'Walk among the treetops in one of Africa\'s oldest rainforests',
        'badge': 'POPULAR',
        'originalPrice': 'RWF 1,800',
        'discountedPrice': 'RWF 1,350',
        'discount': '25% OFF',
        'image': 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=200',
      },
      {
        'title': 'Akagera Safari',
        'description': 'Spot the Big Five in Rwanda\'s only savannah national park',
        'badge': 'NEW',
        'originalPrice': 'RWF 3,000',
        'discountedPrice': 'RWF 2,400',
        'discount': '20% OFF',
        'image': 'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=200',
      },
    ];
  }
}
