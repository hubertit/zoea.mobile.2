import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/business.dart';

class BusinessFormScreen extends ConsumerStatefulWidget {
  final String? businessId;

  const BusinessFormScreen({super.key, this.businessId});

  @override
  ConsumerState<BusinessFormScreen> createState() => _BusinessFormScreenState();
}

class _BusinessFormScreenState extends ConsumerState<BusinessFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController(text: 'Kigali');
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _websiteController = TextEditingController();

  BusinessCategory _selectedCategory = BusinessCategory.hotel;
  bool _isLoading = false;

  bool get isEditing => widget.businessId != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _loadBusinessData();
    }
  }

  void _loadBusinessData() {
    // TODO: Load business data from provider
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
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
          isEditing ? 'Edit Business' : 'New Business',
          style: AppTheme.headlineSmall.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveBusiness,
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
              _buildSectionTitle('Business Information'),
              const SizedBox(height: AppTheme.spacing16),
              _buildNameField(),
              const SizedBox(height: AppTheme.spacing16),
              _buildCategorySelector(),
              const SizedBox(height: AppTheme.spacing16),
              _buildDescriptionField(),
              const SizedBox(height: AppTheme.spacing24),
              _buildSectionTitle('Location'),
              const SizedBox(height: AppTheme.spacing16),
              _buildAddressField(),
              const SizedBox(height: AppTheme.spacing16),
              _buildCityField(),
              const SizedBox(height: AppTheme.spacing24),
              _buildSectionTitle('Contact Information'),
              const SizedBox(height: AppTheme.spacing16),
              _buildPhoneField(),
              const SizedBox(height: AppTheme.spacing16),
              _buildEmailField(),
              const SizedBox(height: AppTheme.spacing16),
              _buildWebsiteField(),
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

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: const InputDecoration(
        labelText: 'Business Name',
        hintText: 'Enter your business name',
        prefixIcon: Icon(Icons.store_outlined),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a business name';
        }
        return null;
      },
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.secondaryTextColor,
          ),
        ),
        const SizedBox(height: AppTheme.spacing8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: BusinessCategory.values.map((category) {
            final isSelected = _selectedCategory == category;
            return InkWell(
              onTap: () => setState(() => _selectedCategory = category),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryColor
                      : AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryColor
                        : AppTheme.dividerColor,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      category.icon,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      category.displayName,
                      style: AppTheme.bodySmall.copyWith(
                        color: isSelected
                            ? Colors.white
                            : AppTheme.primaryTextColor,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
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
      maxLines: 4,
      decoration: const InputDecoration(
        labelText: 'Description',
        hintText: 'Describe your business',
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

  Widget _buildAddressField() {
    return TextFormField(
      controller: _addressController,
      decoration: const InputDecoration(
        labelText: 'Address',
        hintText: 'Street address',
        prefixIcon: Icon(Icons.location_on_outlined),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter an address';
        }
        return null;
      },
    );
  }

  Widget _buildCityField() {
    return TextFormField(
      controller: _cityController,
      decoration: const InputDecoration(
        labelText: 'City',
        hintText: 'City',
        prefixIcon: Icon(Icons.location_city_outlined),
      ),
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      decoration: const InputDecoration(
        labelText: 'Phone Number',
        hintText: '+250 7XX XXX XXX',
        prefixIcon: Icon(Icons.phone_outlined),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(
        labelText: 'Email',
        hintText: 'business@example.com',
        prefixIcon: Icon(Icons.email_outlined),
      ),
    );
  }

  Widget _buildWebsiteField() {
    return TextFormField(
      controller: _websiteController,
      keyboardType: TextInputType.url,
      decoration: const InputDecoration(
        labelText: 'Website (optional)',
        hintText: 'https://www.example.com',
        prefixIcon: Icon(Icons.language_outlined),
      ),
    );
  }

  Future<void> _saveBusiness() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Create business object
      final business = Business(
        id: widget.businessId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        ownerId: 'current_user_id', // Would come from auth provider
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        location: BusinessLocation(
          latitude: 0, // Would be set via map picker
          longitude: 0,
          address: _addressController.text.trim(),
          city: _cityController.text.trim(),
          country: 'Rwanda',
        ),
        contact: BusinessContact(
          phone: _phoneController.text.trim().isNotEmpty 
              ? _phoneController.text.trim() 
              : null,
          email: _emailController.text.trim().isNotEmpty 
              ? _emailController.text.trim() 
              : null,
          website: _websiteController.text.trim().isNotEmpty 
              ? _websiteController.text.trim() 
              : null,
        ),
        isVerified: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 800));

      // In production, this would call a service/provider to save
      debugPrint('Saving business: ${business.name}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          AppTheme.successSnackBar(
            message: isEditing
                ? 'Business updated successfully'
                : 'Business created successfully',
          ),
        );
        context.pop(business); // Return the created business
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          AppTheme.errorSnackBar(message: 'Failed to save business'),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

