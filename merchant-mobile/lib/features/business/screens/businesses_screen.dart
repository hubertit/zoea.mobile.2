import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/business.dart';

class BusinessesScreen extends ConsumerStatefulWidget {
  const BusinessesScreen({super.key});

  @override
  ConsumerState<BusinessesScreen> createState() => _BusinessesScreenState();
}

class _BusinessesScreenState extends ConsumerState<BusinessesScreen> {
  final List<Business> _businesses = _getMockBusinesses();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        title: Text(
          'My Businesses',
          style: AppTheme.headlineSmall.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () => context.push('/businesses/new'),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: _businesses.isEmpty ? _buildEmptyState() : _buildBusinessList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.store_outlined,
                size: 64,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: AppTheme.spacing24),
            Text(
              'No Businesses Yet',
              style: AppTheme.headlineSmall.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppTheme.spacing8),
            Text(
              'Create your first business to start\nmanaging listings and bookings',
              textAlign: TextAlign.center,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.secondaryTextColor,
              ),
            ),
            const SizedBox(height: AppTheme.spacing24),
            ElevatedButton.icon(
              onPressed: () => context.push('/businesses/new'),
              icon: const Icon(Icons.add),
              label: const Text('Create Business'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessList() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      itemCount: _businesses.length,
      itemBuilder: (context, index) {
        final business = _businesses[index];
        return _BusinessCard(
          business: business,
          onTap: () => context.push('/businesses/${business.id}'),
        );
      },
    );
  }
}

class _BusinessCard extends StatelessWidget {
  final Business business;
  final VoidCallback onTap;

  const _BusinessCard({
    required this.business,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacing16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius16),
        border: Border.all(color: AppTheme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppTheme.borderRadius16),
              ),
              child: Container(
                height: 140,
                width: double.infinity,
                color: AppTheme.primaryColor.withOpacity(0.1),
                child: business.coverImage != null
                    ? Image.network(business.coverImage!, fit: BoxFit.cover)
                    : Center(
                        child: Text(
                          business.category.icon,
                          style: const TextStyle(fontSize: 48),
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          business.name,
                          style: AppTheme.titleLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (business.isVerified)
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppTheme.successColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          business.category.displayName,
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (business.rating > 0) ...[
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          business.rating.toStringAsFixed(1),
                          style: AppTheme.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          ' (${business.reviewCount})',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.secondaryTextColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: AppTheme.secondaryTextColor,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${business.location.address}, ${business.location.city}',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.secondaryTextColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildMetric(
                        Icons.list_alt_rounded,
                        '${business.listingsCount} Listings',
                      ),
                      const SizedBox(width: 16),
                      _buildMetric(
                        Icons.circle,
                        business.isActive ? 'Active' : 'Inactive',
                        color: business.isActive
                            ? AppTheme.successColor
                            : AppTheme.secondaryTextColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(IconData icon, String label, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color ?? AppTheme.secondaryTextColor),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTheme.bodySmall.copyWith(
            color: color ?? AppTheme.secondaryTextColor,
          ),
        ),
      ],
    );
  }
}

List<Business> _getMockBusinesses() {
  return [
    Business(
      id: 'b1',
      ownerId: '1',
      name: 'Kigali Heights Hotel',
      description: 'A luxury hotel in the heart of Kigali',
      category: BusinessCategory.hotel,
      location: const BusinessLocation(
        latitude: -1.9403,
        longitude: 29.8739,
        address: 'KG 7 Ave',
        city: 'Kigali',
        country: 'Rwanda',
        district: 'Gasabo',
      ),
      contact: const BusinessContact(
        phone: '+250788000001',
        email: 'info@kigaliheights.rw',
      ),
      isVerified: true,
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now(),
      listingsCount: 5,
      rating: 4.8,
      reviewCount: 124,
    ),
    Business(
      id: 'b2',
      ownerId: '1',
      name: 'Ubumwe Restaurant',
      description: 'Traditional Rwandan cuisine with a modern twist',
      category: BusinessCategory.restaurant,
      location: const BusinessLocation(
        latitude: -1.9503,
        longitude: 29.8639,
        address: 'KN 4 Ave',
        city: 'Kigali',
        country: 'Rwanda',
        district: 'Nyarugenge',
      ),
      contact: const BusinessContact(
        phone: '+250788000002',
        email: 'info@ubumwe.rw',
      ),
      isVerified: false,
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      updatedAt: DateTime.now(),
      listingsCount: 3,
      rating: 4.5,
      reviewCount: 67,
    ),
  ];
}

