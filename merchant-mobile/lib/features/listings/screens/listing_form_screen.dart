import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/listing.dart';
import '../../../core/models/business.dart';

class ListingFormScreen extends ConsumerStatefulWidget {
  final String? listingId;

  const ListingFormScreen({super.key, this.listingId});

  @override
  ConsumerState<ListingFormScreen> createState() => _ListingFormScreenState();
}

class _ListingFormScreenState extends ConsumerState<ListingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();

  ListingType _selectedType = ListingType.room;
  PriceUnit _selectedPriceUnit = PriceUnit.perNight;
  String? _selectedBusinessId;
  bool _isActive = true;
  bool _isLoading = false;

  final List<String> _selectedAmenities = [];
  final List<String> _availableAmenities = [
    'WiFi',
    'AC',
    'TV',
    'Mini Bar',
    'Parking',
    'Pool',
    'Gym',
    'Breakfast',
    'Room Service',
    'Balcony',
  ];

  // Mock businesses for dropdown
  final List<Business> _businesses = [
    Business(
      id: 'b1',
      ownerId: '1',
      name: 'Kigali Heights Hotel',
      description: '',
      category: BusinessCategory.hotel,
      location: const BusinessLocation(
        latitude: 0,
        longitude: 0,
        address: '',
        city: 'Kigali',
        country: 'Rwanda',
      ),
      contact: const BusinessContact(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Business(
      id: 'b2',
      ownerId: '1',
      name: 'Ubumwe Restaurant',
      description: '',
      category: BusinessCategory.restaurant,
      location: const BusinessLocation(
        latitude: 0,
        longitude: 0,
        address: '',
        city: 'Kigali',
        country: 'Rwanda',
      ),
      contact: const BusinessContact(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  bool get isEditing => widget.listingId != null;

  @override
  void initState() {
    super.initState();
    if (_businesses.isNotEmpty) {
      _selectedBusinessId = _businesses.first.id;
    }
    if (isEditing) {
      _loadListingData();
    }
  }

  void _loadListingData() {
    // TODO: Load listing data from provider
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.close),
        ),
        title: Text(
          isEditing ? 'Edit Listing' : 'New Listing',
          style: AppTheme.headlineSmall.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveListing,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Select Business'),
              const SizedBox(height: AppTheme.spacing12),
              _buildBusinessSelector(),
              const SizedBox(height: AppTheme.spacing24),
              _buildSectionTitle('Listing Information'),
              const SizedBox(height: AppTheme.spacing16),
              _buildNameField(),
              const SizedBox(height: AppTheme.spacing16),
              _buildTypeSelector(),
              const SizedBox(height: AppTheme.spacing16),
              _buildDescriptionField(),
              const SizedBox(height: AppTheme.spacing24),
              _buildSectionTitle('Pricing'),
              const SizedBox(height: AppTheme.spacing16),
              _buildPriceFields(),
              const SizedBox(height: AppTheme.spacing16),
              _buildPriceUnitSelector(),
              const SizedBox(height: AppTheme.spacing24),
              _buildSectionTitle('Amenities'),
              const SizedBox(height: AppTheme.spacing12),
              _buildAmenitiesSelector(),
              const SizedBox(height: AppTheme.spacing24),
              _buildActiveSwitch(),
              const SizedBox(height: AppTheme.spacing32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTheme.titleMedium.copyWith(
        fontWeight: FontWeight.bold,
        color: AppTheme.primaryTextColor,
      ),
    );
  }

  Widget _buildBusinessSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.dividerColor),
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedBusinessId,
          isExpanded: true,
          hint: const Text('Select a business'),
          items: _businesses.map((business) {
            return DropdownMenuItem(
              value: business.id,
              child: Row(
                children: [
                  Text(business.category.icon),
                  const SizedBox(width: 12),
                  Text(business.name),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() => _selectedBusinessId = value);
          },
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: const InputDecoration(
        labelText: 'Listing Name',
        hintText: 'e.g., Deluxe Room, Family Table',
        prefixIcon: Icon(Icons.edit_outlined),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a listing name';
        }
        return null;
      },
    );
  }

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Type',
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.secondaryTextColor,
          ),
        ),
        const SizedBox(height: AppTheme.spacing8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ListingType.values.map((type) {
            final isSelected = _selectedType == type;
            return InkWell(
              onTap: () => setState(() => _selectedType = type),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryColor : AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppTheme.primaryColor : AppTheme.dividerColor,
                  ),
                ),
                child: Text(
                  type.displayName,
                  style: AppTheme.bodySmall.copyWith(
                    color: isSelected ? Colors.white : AppTheme.primaryTextColor,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      maxLines: 3,
      decoration: const InputDecoration(
        labelText: 'Description',
        hintText: 'Describe your listing',
        alignLabelWithHint: true,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a description';
        }
        return null;
      },
    );
  }

  Widget _buildPriceFields() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _minPriceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Min Price (RWF)',
              hintText: '0',
              prefixIcon: Icon(Icons.attach_money),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Required';
              }
              return null;
            },
          ),
        ),
        const SizedBox(width: AppTheme.spacing12),
        Expanded(
          child: TextFormField(
            controller: _maxPriceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Max Price (RWF)',
              hintText: '0',
              prefixIcon: Icon(Icons.attach_money),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceUnitSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Price Unit',
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.secondaryTextColor,
          ),
        ),
        const SizedBox(height: AppTheme.spacing8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: PriceUnit.values.map((unit) {
            final isSelected = _selectedPriceUnit == unit;
            return InkWell(
              onTap: () => setState(() => _selectedPriceUnit = unit),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryColor : AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppTheme.primaryColor : AppTheme.dividerColor,
                  ),
                ),
                child: Text(
                  unit.displayName,
                  style: AppTheme.bodySmall.copyWith(
                    color: isSelected ? Colors.white : AppTheme.primaryTextColor,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAmenitiesSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _availableAmenities.map((amenity) {
        final isSelected = _selectedAmenities.contains(amenity);
        return InkWell(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedAmenities.remove(amenity);
              } else {
                _selectedAmenities.add(amenity);
              }
            });
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primaryColor.withOpacity(0.1)
                  : AppTheme.cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppTheme.primaryColor : AppTheme.dividerColor,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected)
                  const Padding(
                    padding: EdgeInsets.only(right: 4),
                    child: Icon(
                      Icons.check,
                      size: 14,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                Text(
                  amenity,
                  style: AppTheme.bodySmall.copyWith(
                    color: isSelected
                        ? AppTheme.primaryColor
                        : AppTheme.primaryTextColor,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActiveSwitch() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius12),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Row(
        children: [
          const Icon(Icons.visibility_outlined, color: AppTheme.secondaryTextColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Active Listing',
                  style: AppTheme.titleSmall.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  'Make this listing visible to customers',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isActive,
            onChanged: (value) => setState(() => _isActive = value),
            activeColor: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  Future<void> _saveListing() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBusinessId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        AppTheme.errorSnackBar(message: 'Please select a business'),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Create listing object
      final listing = Listing(
        id: widget.listingId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        businessId: _selectedBusinessId!,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        type: _selectedType,
        images: [], // Would be populated via image picker
        priceRange: PriceRange(
          minPrice: double.tryParse(_minPriceController.text) ?? 0,
          maxPrice: double.tryParse(_maxPriceController.text) ?? 0,
          currency: 'RWF',
          unit: _selectedPriceUnit,
        ),
        amenities: _selectedAmenities.toList(),
        isActive: _isActive,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 800));

      // In production, this would call a service/provider to save
      debugPrint('Saving listing: ${listing.name}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          AppTheme.successSnackBar(
            message: isEditing
                ? 'Listing updated successfully'
                : 'Listing created successfully',
          ),
        );
        context.pop(listing); // Return the created listing
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          AppTheme.errorSnackBar(message: 'Failed to save listing'),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

