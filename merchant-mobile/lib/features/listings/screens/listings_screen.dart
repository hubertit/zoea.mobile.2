import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/listing.dart';

class ListingsScreen extends ConsumerStatefulWidget {
  const ListingsScreen({super.key});

  @override
  ConsumerState<ListingsScreen> createState() => _ListingsScreenState();
}

class _ListingsScreenState extends ConsumerState<ListingsScreen> {
  final List<Listing> _listings = _getMockListings();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        title: Text(
          'My Listings',
          style: AppTheme.headlineSmall.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () => context.push('/listings/new'),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: _listings.isEmpty ? _buildEmptyState() : _buildListingsList(),
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
                Icons.list_alt_outlined,
                size: 64,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: AppTheme.spacing24),
            Text(
              'No Listings Yet',
              style: AppTheme.headlineSmall.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppTheme.spacing8),
            Text(
              'Create listings for your businesses\nto start receiving bookings',
              textAlign: TextAlign.center,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.secondaryTextColor,
              ),
            ),
            const SizedBox(height: AppTheme.spacing24),
            ElevatedButton.icon(
              onPressed: () => context.push('/listings/new'),
              icon: const Icon(Icons.add),
              label: const Text('Create Listing'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListingsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      itemCount: _listings.length,
      itemBuilder: (context, index) {
        final listing = _listings[index];
        return _ListingCard(
          listing: listing,
          onTap: () => context.push('/listings/${listing.id}'),
        );
      },
    );
  }
}

class _ListingCard extends StatelessWidget {
  final Listing listing;
  final VoidCallback onTap;

  const _ListingCard({
    required this.listing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacing12),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius12),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius12),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(AppTheme.borderRadius12),
              ),
              child: Container(
                width: 100,
                height: 100,
                color: AppTheme.primaryColor.withOpacity(0.1),
                child: listing.images.isNotEmpty
                    ? Image.network(listing.images.first, fit: BoxFit.cover)
                    : Center(
                        child: Text(
                          listing.type.icon,
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
              ),
            ),
            // Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacing12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            listing.name,
                            style: AppTheme.titleMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _buildStatusBadge(listing.isActive),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getListingSubtitle(listing),
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.secondaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '${listing.priceRange.currency} ${listing.priceRange.minPrice.toStringAsFixed(0)}',
                          style: AppTheme.titleSmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        Text(
                          ' ${listing.priceRange.unit.displayName}',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (listing.rating > 0) ...[
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                          const SizedBox(width: 2),
                          Text(
                            listing.rating.toStringAsFixed(1),
                            style: AppTheme.bodySmall.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Text(
                          '${listing.bookingsCount} bookings',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getListingSubtitle(Listing listing) {
    switch (listing.type) {
      case ListingType.room:
        final details = listing.roomDetails;
        if (details != null) {
          return '${details.roomType.displayName} • ${details.capacity} guests';
        }
        return listing.type.displayName;
      case ListingType.table:
        final details = listing.tableDetails;
        if (details != null) {
          return '${details.location.displayName} • ${details.capacity} seats';
        }
        return listing.type.displayName;
      case ListingType.tour:
        final details = listing.tourDetails;
        if (details != null) {
          return '${details.duration} • ${details.difficulty.displayName}';
        }
        return listing.type.displayName;
      case ListingType.event:
        final details = listing.eventDetails;
        if (details != null) {
          return '${details.availableSpots} spots available';
        }
        return listing.type.displayName;
      default:
        return listing.type.displayName;
    }
  }

  Widget _buildStatusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isActive
            ? AppTheme.successColor.withOpacity(0.1)
            : AppTheme.secondaryTextColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          color: isActive ? AppTheme.successColor : AppTheme.secondaryTextColor,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

List<Listing> _getMockListings() {
  return [
    Listing(
      id: 'l1',
      businessId: 'b1',
      name: 'Deluxe Room',
      description: 'Spacious room with city view',
      type: ListingType.room,
      images: [],
      priceRange: const PriceRange(
        minPrice: 150000,
        maxPrice: 200000,
        currency: 'RWF',
        unit: PriceUnit.perNight,
      ),
      amenities: ['WiFi', 'AC', 'TV', 'Mini Bar'],
      isActive: true,
      rating: 4.8,
      reviewCount: 45,
      bookingsCount: 128,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now(),
      roomDetails: const RoomDetails(
        roomType: RoomType.deluxe,
        capacity: 2,
        bedCount: 1,
        bedType: BedType.king,
        size: 35,
        hasBalcony: true,
        hasView: true,
        totalRooms: 10,
        availableRooms: 6,
      ),
    ),
    Listing(
      id: 'l2',
      businessId: 'b1',
      name: 'Standard Room',
      description: 'Comfortable room for budget travelers',
      type: ListingType.room,
      images: [],
      priceRange: const PriceRange(
        minPrice: 80000,
        maxPrice: 100000,
        currency: 'RWF',
        unit: PriceUnit.perNight,
      ),
      amenities: ['WiFi', 'AC', 'TV'],
      isActive: true,
      rating: 4.5,
      reviewCount: 67,
      bookingsCount: 234,
      createdAt: DateTime.now().subtract(const Duration(days: 25)),
      updatedAt: DateTime.now(),
      roomDetails: const RoomDetails(
        roomType: RoomType.standard,
        capacity: 2,
        bedCount: 1,
        bedType: BedType.queen,
        size: 25,
        totalRooms: 20,
        availableRooms: 12,
      ),
    ),
    Listing(
      id: 'l3',
      businessId: 'b2',
      name: 'Terrace Table',
      description: 'Beautiful outdoor dining experience',
      type: ListingType.table,
      images: [],
      priceRange: const PriceRange(
        minPrice: 0,
        maxPrice: 0,
        currency: 'RWF',
        unit: PriceUnit.perTable,
      ),
      isActive: true,
      rating: 4.6,
      reviewCount: 23,
      bookingsCount: 89,
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      updatedAt: DateTime.now(),
      tableDetails: const TableDetails(
        capacity: 4,
        location: TableLocation.terrace,
        totalTables: 8,
        availableTables: 5,
        availableTimeSlots: ['12:00', '13:00', '18:00', '19:00', '20:00'],
      ),
    ),
    Listing(
      id: 'l4',
      businessId: 'b3',
      name: 'Gorilla Trekking Experience',
      description: 'Once in a lifetime experience with mountain gorillas',
      type: ListingType.tour,
      images: [],
      priceRange: const PriceRange(
        minPrice: 1500,
        maxPrice: 1500,
        currency: 'USD',
        unit: PriceUnit.perPerson,
      ),
      isActive: true,
      rating: 5.0,
      reviewCount: 156,
      bookingsCount: 312,
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      updatedAt: DateTime.now(),
      tourDetails: const TourDetails(
        duration: 'Full day',
        difficulty: TourDifficulty.challenging,
        minParticipants: 1,
        maxParticipants: 8,
        included: ['Park permit', 'Guide', 'Transport', 'Lunch'],
        notIncluded: ['Tips', 'Personal expenses'],
        pickupLocation: 'Kigali City Center',
      ),
    ),
  ];
}
