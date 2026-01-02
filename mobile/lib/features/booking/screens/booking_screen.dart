import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme_extensions.dart';
import '../../../core/providers/listings_provider.dart';

/// BookingScreen - Routes to appropriate booking screen based on listing type
/// This is a router screen that detects the listing type and redirects accordingly
class BookingScreen extends ConsumerWidget {
  final String listingId;

  const BookingScreen({
    super.key,
    required this.listingId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingAsync = ref.watch(listingByIdProvider(listingId));

    return listingAsync.when(
      data: (listing) {
        final listingType = listing['type']?.toString().toLowerCase() ?? '';
        final category = listing['category'] as Map<String, dynamic>?;
        final categorySlug = category?['slug'] as String? ?? '';
        final categoryName = category?['name'] as String? ?? '';
        
        // Check if it's a dining-related category
        final isDiningCategory = categorySlug.toLowerCase().contains('dining') ||
            categorySlug.toLowerCase().contains('restaurant') ||
            categorySlug.toLowerCase().contains('cafe') ||
            categorySlug.toLowerCase().contains('fastfood') ||
            categoryName.toLowerCase().contains('dining') ||
            categoryName.toLowerCase().contains('restaurant') ||
            categoryName.toLowerCase().contains('cafe') ||
            categoryName.toLowerCase().contains('fast food');
        
        // Redirect based on listing type or category
        if (listingType == 'restaurant' || isDiningCategory) {
          // Extract data for dining booking
          final images = listing['images'] as List? ?? [];
          final primaryImage = images.isNotEmpty && images[0]['media'] != null
              ? images[0]['media']['url']
              : null;
          final name = listing['name'] ?? 'Restaurant';
          final address = listing['address'] ?? '';
          final city = listing['city'] as Map<String, dynamic>?;
          final cityName = city?['name'] as String? ?? '';
          final location = address.isNotEmpty 
              ? '$address${cityName.isNotEmpty ? ', $cityName' : ''}'
              : cityName.isNotEmpty ? cityName : 'Location not available';
          final rating = listing['rating'] != null
              ? (listing['rating'] is String
                  ? double.tryParse(listing['rating'])
                  : listing['rating']?.toDouble())
              : 0.0;
          final minPrice = listing['minPrice'];
          final maxPrice = listing['maxPrice'];
          final currency = listing['currency'] ?? 'RWF';
          String priceRange = 'Price not available';
          if (minPrice != null) {
            final min = minPrice is String ? double.tryParse(minPrice) : minPrice?.toDouble();
            final max = maxPrice != null 
                ? (maxPrice is String ? double.tryParse(maxPrice) : maxPrice?.toDouble())
                : null;
            if (min != null) {
              priceRange = max != null && max > min
                  ? '$currency ${min.toStringAsFixed(0)} - ${max.toStringAsFixed(0)}'
                  : '$currency ${min.toStringAsFixed(0)}';
            }
          }
          
          // Navigate to dining booking screen
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.pushReplacement('/dining-booking', extra: {
              'placeId': listingId,
              'placeName': name,
              'placeLocation': location,
              'placeImage': primaryImage ?? '',
              'placeRating': rating ?? 0.0,
              'priceRange': priceRange,
            });
          });
        } else if (listingType == 'hotel') {
          // Navigate to accommodation booking screen
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.pushReplacement('/accommodation/$listingId/book');
          });
        } else if (listingType == 'tour') {
          // Navigate to tour booking screen
          final images = listing['images'] as List? ?? [];
          final primaryImage = images.isNotEmpty && images[0]['media'] != null
              ? images[0]['media']['url']
              : null;
          final name = listing['name'] ?? 'Tour';
          final address = listing['address'] ?? '';
          final city = listing['city'] as Map<String, dynamic>?;
          final cityName = city?['name'] as String? ?? '';
          final location = address.isNotEmpty 
              ? '$address${cityName.isNotEmpty ? ', $cityName' : ''}'
              : cityName.isNotEmpty ? cityName : 'Location not available';
          final rating = listing['rating'] != null
              ? (listing['rating'] is String
                  ? double.tryParse(listing['rating'])
                  : listing['rating']?.toDouble())
              : 0.0;
          
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.pushReplacement('/tour-booking', extra: {
              'listingId': listingId,
              'tourName': name,
              'tourLocation': location,
              'tourImage': primaryImage ?? '',
              'tourRating': rating ?? 0.0,
            });
          });
        } else {
          // Unsupported listing type - show error
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Booking is not available for this listing type'),
                backgroundColor: context.errorColor,
              ),
            );
          });
        }
        
        // Show loading while redirecting
        return Scaffold(
          backgroundColor: context.backgroundColor,
          body: Center(
            child: CircularProgressIndicator(
              color: context.primaryColorTheme,
            ),
          ),
        );
      },
      loading: () => Scaffold(
        backgroundColor: context.backgroundColor,
        body: Center(
          child: CircularProgressIndicator(
            color: context.primaryColorTheme,
          ),
        ),
      ),
      error: (error, stack) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to load listing: ${error.toString()}'),
              backgroundColor: context.errorColor,
            ),
          );
        });
        return Scaffold(
          backgroundColor: context.backgroundColor,
          body: Center(
            child: CircularProgressIndicator(
              color: context.primaryColorTheme,
            ),
          ),
        );
      },
    );
  }
}
