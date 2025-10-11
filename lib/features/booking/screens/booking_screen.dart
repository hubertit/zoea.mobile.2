import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';

class BookingScreen extends ConsumerStatefulWidget {
  final String listingId;

  const BookingScreen({
    super.key,
    required this.listingId,
  });

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Booking'),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.event,
              size: 64,
              color: AppTheme.primaryColor,
            ),
            SizedBox(height: AppTheme.spacing16),
            Text(
              'Booking',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            SizedBox(height: AppTheme.spacing8),
            Text(
              'Listing ID: ${widget.listingId}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.secondaryTextColor,
              ),
            ),
            SizedBox(height: AppTheme.spacing8),
            const Text(
              'Booking form and payment integration will be implemented here',
              style: const TextStyle(
                color: AppTheme.secondaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
