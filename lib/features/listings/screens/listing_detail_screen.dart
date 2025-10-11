import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';

class ListingDetailScreen extends ConsumerStatefulWidget {
  final String listingId;

  const ListingDetailScreen({
    super.key,
    required this.listingId,
  });

  @override
  ConsumerState<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends ConsumerState<ListingDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Listing Details'),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.info,
              size: 64,
              color: AppTheme.primaryColor,
            ),
            SizedBox(height: AppTheme.spacing16),
            Text(
              'Listing Details',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            SizedBox(height: AppTheme.spacing8),
            Text(
              'ID: ${widget.listingId}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.secondaryTextColor,
              ),
            ),
            SizedBox(height: AppTheme.spacing8),
            const Text(
              'Detailed listing information will be displayed here',
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
