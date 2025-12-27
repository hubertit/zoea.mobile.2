import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/models/user.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/user_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLoading = false;
  String? _profileImagePath;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = ref.read(currentUserProvider);
    if (user != null) {
      setState(() {
        _nameController.text = user.fullName;
        _emailController.text = user.email;
        _phoneController.text = user.phoneNumber ?? '';
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: AppTheme.titleLarge,
        ),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () => context.go('/profile'),
          icon: const Icon(Icons.chevron_left, size: 32),
          style: IconButton.styleFrom(
            foregroundColor: AppTheme.primaryTextColor,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: Text(
              'Save',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Profile Picture Section
            _buildProfilePictureSection(),
            const SizedBox(height: 24),
            
            // Personal Information
            _buildSectionHeader('Personal Information'),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _nameController,
              label: 'Full Name',
              hint: 'Enter your full name',
              icon: Icons.person,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your full name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _emailController,
              label: 'Email Address',
              hint: 'Enter your email address',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your email address';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _phoneController,
              label: 'Phone Number',
              hint: 'Enter your phone number',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            
            // Save Button
            _buildSaveButton(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePictureSection() {
    final user = ref.watch(currentUserProvider);
    final imageUrl = _profileImagePath != null 
        ? null 
        : user?.profileImage;
    
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.primaryColor,
                    width: 3,
                  ),
                ),
                child: ClipOval(
                  child: _profileImagePath != null
                      ? Image.asset(
                          _profileImagePath!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(user),
                        )
                      : imageUrl != null
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(user),
                            )
                          : _buildPlaceholderImage(user),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.backgroundColor,
                      width: 3,
                    ),
                  ),
                  child: IconButton(
                    onPressed: _changeProfilePicture,
                    icon: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                    style: IconButton.styleFrom(
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Tap to change photo',
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTheme.titleMedium.copyWith(
        fontWeight: FontWeight.w600,
        color: AppTheme.primaryTextColor,
      ),
    );
  }

  Widget _buildPlaceholderImage(User? user) {
    return Container(
      color: AppTheme.dividerColor,
      child: Center(
        child: Text(
          user?.initials ?? 'U',
          style: const TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: AppTheme.secondaryTextColor,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
            color: AppTheme.primaryTextColor,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          style: AppTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTheme.bodyMedium.copyWith(
              color: AppTheme.secondaryTextColor,
            ),
            prefixIcon: Icon(
              icon,
              color: AppTheme.primaryColor,
              size: 20,
            ),
            filled: true,
            fillColor: AppTheme.dividerColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.primaryColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.red,
                width: 2,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.red,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _isLoading ? null : _saveProfile,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: AppTheme.primaryColor,
          side: BorderSide(color: AppTheme.primaryColor),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                'Save Changes',
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  void _changeProfilePicture() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Change Profile Picture',
              style: AppTheme.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      // TODO: Implement camera functionality
                    },
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      backgroundColor: AppTheme.backgroundColor,
                      side: BorderSide(color: AppTheme.primaryColor),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      // TODO: Implement gallery functionality
                    },
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      backgroundColor: AppTheme.backgroundColor,
                      side: BorderSide(color: AppTheme.primaryColor),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userService = ref.read(userServiceProvider);
      final currentUser = ref.read(currentUserProvider);
      
      if (currentUser == null) {
        throw Exception('User not found. Please login again.');
      }

      // Check what changed
      final nameChanged = _nameController.text.trim() != currentUser.fullName;
      final emailChanged = _emailController.text.trim() != currentUser.email;
      final phoneChanged = _phoneController.text.trim() != (currentUser.phoneNumber ?? '');

      // Update profile (name and phone)
      if (nameChanged || phoneChanged) {
        await userService.updateProfile(
          fullName: nameChanged ? _nameController.text.trim() : null,
          phoneNumber: phoneChanged ? _phoneController.text.trim() : null,
        );
      }

      // Update email separately if changed
      if (emailChanged) {
        await userService.updateEmail(_emailController.text.trim());
      }

      // Update profile image if changed
      if (_profileImagePath != null) {
        await userService.updateProfileImage(_profileImagePath!);
      }

      // Refresh user data - invalidate providers to refetch
      ref.invalidate(currentUserProfileProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Profile updated successfully!',
              style: AppTheme.bodyMedium.copyWith(
                color: Colors.white,
              ),
            ),
            backgroundColor: AppTheme.successColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        
        // Navigate back to profile
        context.go('/profile');
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = e.toString().replaceFirst('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorMessage.isNotEmpty 
                  ? errorMessage 
                  : 'Failed to update profile. Please try again.',
              style: AppTheme.bodyMedium.copyWith(
                color: Colors.white,
              ),
            ),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
