import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/models/user.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../user_data_collection/widgets/age_range_selector.dart';
import '../../user_data_collection/widgets/gender_selector.dart';
import '../../user_data_collection/widgets/length_of_stay_selector.dart';
import '../../user_data_collection/widgets/interests_chips.dart';
import '../../user_data_collection/widgets/travel_party_selector.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  final int? initialTab; // 0 = Basic Info, 1 = Preferences

  const EditProfileScreen({super.key, this.initialTab});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLoading = false;
  bool _isSaving = false;
  bool _hasLoadedInitialData = false;

  // Preferences state
  AgeRange? _selectedAgeRange;
  Gender? _selectedGender;
  LengthOfStay? _selectedLengthOfStay;
  List<String> _selectedInterests = [];
  TravelParty? _selectedTravelParty;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab ?? 0,
    );
    // Add animation listener for smooth tab transitions
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        // Tab animation completed
      }
    });
    
    // Load user data initially
    _loadUserData();
  }

  void _loadUserData({bool force = false}) {
    // Prevent multiple simultaneous loads
    if (_hasLoadedInitialData && !force) {
      return;
    }
    
    final user = ref.read(currentUserProvider);
    if (user != null) {
      // Only update if controllers are empty or if data has changed
      if (_nameController.text.isEmpty || _nameController.text != user.fullName) {
        _nameController.text = user.fullName;
      }
      if (_emailController.text.isEmpty || _emailController.text != user.email) {
        _emailController.text = user.email;
      }
      if (_phoneController.text.isEmpty || _phoneController.text != (user.phoneNumber ?? '')) {
        _phoneController.text = user.phoneNumber ?? '';
      }
      
      // Load preferences - only if not already loaded or forced
      if (user.preferences != null) {
        final prefs = user.preferences!;
        final newInterests = List<String>.from(prefs.interests);
        
        // Only update state if values actually changed or this is first load
        final needsUpdate = 
            _selectedAgeRange != prefs.ageRange ||
            _selectedGender != prefs.gender ||
            _selectedLengthOfStay != prefs.lengthOfStay ||
            !_listEquals(_selectedInterests, newInterests) ||
            _selectedTravelParty != prefs.travelParty ||
            !_hasLoadedInitialData;
        
        if (needsUpdate) {
          setState(() {
            _selectedAgeRange = prefs.ageRange;
            _selectedGender = prefs.gender;
            _selectedLengthOfStay = prefs.lengthOfStay;
            
            // Load interests - ensure they match the widget's expected format (IDs)
            // The API returns interests as IDs (e.g., 'nature', 'food')
            _selectedInterests = newInterests;
            
            _selectedTravelParty = prefs.travelParty;
            
            _hasLoadedInitialData = true;
          });
        } else {
          _hasLoadedInitialData = true;
        }
      } else {
        _hasLoadedInitialData = true;
      }
    }
  }
  

  /// Check if there are unsaved changes
  bool _checkForUnsavedChanges() {
    final user = ref.read(currentUserProvider);
    if (user == null) return false;

    // Check basic info changes
    final nameChanged = _nameController.text.trim() != user.fullName;
    final emailChanged = _emailController.text.trim() != user.email;
    final phoneChanged = _phoneController.text.trim() != (user.phoneNumber ?? '');
    
    // Check preferences changes
    final prefs = user.preferences;
    final ageChanged = _selectedAgeRange != prefs?.ageRange;
    final genderChanged = _selectedGender != prefs?.gender;
    final lengthOfStayChanged = _selectedLengthOfStay != prefs?.lengthOfStay;
    final interestsChanged = !_listEquals(_selectedInterests, prefs?.interests ?? []);
    final travelPartyChanged = _selectedTravelParty != prefs?.travelParty;

    return nameChanged || emailChanged || phoneChanged || 
           ageChanged || genderChanged || lengthOfStayChanged || 
           interestsChanged || travelPartyChanged;
  }

  /// Helper to compare lists
  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  /// Show confirmation dialog before navigating away
  Future<bool> _showUnsavedChangesDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.backgroundColor,
        title: Text(
          'Unsaved Changes',
          style: AppTheme.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'You have unsaved changes. Are you sure you want to leave?',
          style: AppTheme.bodyMedium,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadius12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.secondaryTextColor,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Discard',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.errorColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Only watch for completion percentage, not the entire user object
    // This prevents unnecessary rebuilds when user data changes
    final user = ref.read(currentUserProvider);
    final completionPercentage = user?.preferences?.profileCompletionPercentage ?? 0;
    
    // Load user data once when it becomes available (only if not already loaded)
    if (user != null && !_hasLoadedInitialData) {
      // Use a one-time callback to avoid reloading on every rebuild
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_hasLoadedInitialData) {
          _loadUserData();
        }
      });
    }

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
          onPressed: () async {
            // Check for unsaved changes before navigating away
            if (_checkForUnsavedChanges()) {
              final shouldLeave = await _showUnsavedChangesDialog();
              if (shouldLeave && mounted) {
                context.go('/profile');
              }
            } else {
              context.go('/profile');
            }
          },
          icon: const Icon(Icons.chevron_left, size: 32),
          style: IconButton.styleFrom(
            foregroundColor: AppTheme.primaryTextColor,
          ),
        ),
        actions: [
          TextButton(
            onPressed: (_isLoading || _isSaving) ? null : _saveAll,
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
      body: Column(
        children: [
          // Completion Badge (above tabs)
          _buildCompletionBadge(completionPercentage),
          
          // TabBar (below completion badge)
          TabBar(
            controller: _tabController,
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: AppTheme.secondaryTextColor,
            indicatorColor: AppTheme.primaryColor,
            indicatorSize: TabBarIndicatorSize.tab,
            labelStyle: AppTheme.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: AppTheme.bodyMedium,
            tabs: const [
              Tab(text: 'Basic Info'),
              Tab(text: 'Preferences'),
            ],
          ),
          
          // Tab Content with animation
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const BouncingScrollPhysics(), // Smooth scrolling animation
              children: [
                _buildBasicInfoTab(),
                _buildPreferencesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionBadge(int percentage) {
    Color badgeColor;
    if (percentage >= 80) {
      badgeColor = AppTheme.successColor;
    } else if (percentage >= 50) {
      badgeColor = Colors.orange;
    } else {
      badgeColor = AppTheme.secondaryTextColor;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing16,
        vertical: AppTheme.spacing12,
      ),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: badgeColor,
            size: 20,
          ),
          const SizedBox(width: AppTheme.spacing8),
          Expanded(
            child: Text(
              'Profile Completion: $percentage%',
              style: AppTheme.bodyMedium.copyWith(
                color: badgeColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            width: 100,
            height: 8,
            decoration: BoxDecoration(
              color: AppTheme.dividerColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoTab() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
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
        ],
      ),
    );
  }

  Widget _buildPreferencesTab() {
    final user = ref.watch(currentUserProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacing24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Age Range
          _buildPreferencesSection(
            title: 'Age Range',
            subtitle: 'Help us personalize content for you',
            isComplete: _selectedAgeRange != null,
            child: AgeRangeSelector(
              selectedRange: _selectedAgeRange,
              onRangeSelected: (range) {
                setState(() {
                  _selectedAgeRange = range;
                });
              },
            ),
          ),
          const SizedBox(height: AppTheme.spacing24),

          // Gender
          _buildPreferencesSection(
            title: 'Gender',
            subtitle: 'Optional - helps with personalization',
            isComplete: _selectedGender != null,
            child: GenderSelector(
              selectedGender: _selectedGender,
              onGenderSelected: (gender) {
                setState(() {
                  _selectedGender = gender;
                });
              },
            ),
          ),
          const SizedBox(height: AppTheme.spacing24),

          // Length of Stay (only for visitors)
          if (user?.preferences?.userType == UserType.visitor) ...[
            _buildPreferencesSection(
              title: 'Length of Stay',
              subtitle: 'How long are you staying in Rwanda?',
              isComplete: _selectedLengthOfStay != null,
              child: LengthOfStaySelector(
                selectedLength: _selectedLengthOfStay,
                onLengthSelected: (length) {
                  setState(() {
                    _selectedLengthOfStay = length;
                  });
                },
              ),
            ),
            const SizedBox(height: AppTheme.spacing24),
          ],

          // Interests
          _buildPreferencesSection(
            title: 'Interests',
            subtitle: 'Select all that apply',
            isComplete: _selectedInterests.isNotEmpty,
            child: InterestsChips(
              selectedInterests: _selectedInterests,
              onInterestsChanged: (interests) {
                setState(() {
                  _selectedInterests = interests;
                });
              },
            ),
          ),
          const SizedBox(height: AppTheme.spacing24),

          // Travel Party
          _buildPreferencesSection(
            title: 'Travel Party',
            subtitle: 'Who are you traveling with?',
            isComplete: _selectedTravelParty != null,
            child: TravelPartySelector(
              selectedParty: _selectedTravelParty,
              onPartySelected: (party) {
                setState(() {
                  _selectedTravelParty = party;
                });
              },
            ),
          ),
          const SizedBox(height: AppTheme.spacing32),
        ],
      ),
    );
  }

  Widget _buildPreferencesSection({
    required String title,
    required String subtitle,
    required bool isComplete,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing4),
                  Text(
                    subtitle,
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
            if (isComplete)
              Container(
                padding: const EdgeInsets.all(AppTheme.spacing8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.green,
                  size: 16,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppTheme.spacing16),
        child,
      ],
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
              borderSide: const BorderSide(
                color: AppTheme.primaryColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 2,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
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

  Future<void> _saveAll() async {
    // Validate basic info form
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) {
      // Switch to basic info tab if validation fails
      _tabController.animateTo(0);
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final userService = ref.read(userServiceProvider);
      final currentUser = ref.read(currentUserProvider);
      
      if (currentUser == null) {
        throw Exception('User not found. Please login again.');
      }

      // Save basic info
      final nameChanged = _nameController.text.trim() != currentUser.fullName;
      final emailChanged = _emailController.text.trim() != currentUser.email;
      final phoneChanged = _phoneController.text.trim() != (currentUser.phoneNumber ?? '');

      if (nameChanged || phoneChanged) {
        await userService.updateProfile(
          fullName: nameChanged ? _nameController.text.trim() : null,
          phoneNumber: phoneChanged ? _phoneController.text.trim() : null,
        );
      }

      if (emailChanged) {
        // Show password dialog for email update
        final password = await _showPasswordDialog();
        if (password == null) {
          // User cancelled password dialog
          setState(() {
            _isSaving = false;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              AppTheme.errorSnackBar(
                message: 'Password is required to update email address.',
              ),
            );
          }
          return;
        }
        await userService.updateEmail(_emailController.text.trim(), password: password);
      }

      // Save preferences in a single API call
      final userType = currentUser.preferences?.userType;
      final existingFlags = currentUser.preferences?.dataCollectionFlags ?? {};
      final updatedFlags = <String, bool>{...existingFlags};
      
      // Build flags for fields that are being set
      if (_selectedAgeRange != null) updatedFlags['ageAsked'] = true;
      if (_selectedGender != null) updatedFlags['genderAsked'] = true;
      if (userType == UserType.visitor && _selectedLengthOfStay != null) {
        updatedFlags['lengthOfStayAsked'] = true;
      }
      if (_selectedInterests.isNotEmpty) updatedFlags['interestsAsked'] = true;
      if (_selectedTravelParty != null) updatedFlags['travelPartyAsked'] = true;

      // Prepare preferences data
      final preferencesData = <String, dynamic>{
        'dataCollectionFlags': updatedFlags,
      };
      
      if (_selectedAgeRange != null) {
        preferencesData['ageRange'] = _selectedAgeRange!.apiValue;
      }
      if (_selectedGender != null) {
        preferencesData['gender'] = _selectedGender!.apiValue;
      }
      
      // Handle lengthOfStay based on user type
      if (userType == UserType.visitor) {
        if (_selectedLengthOfStay != null) {
          preferencesData['lengthOfStay'] = _selectedLengthOfStay!.apiValue;
        }
      } else {
        // Clear lengthOfStay for residents
        preferencesData['lengthOfStay'] = null;
      }
      
      if (_selectedInterests.isNotEmpty) {
        preferencesData['interests'] = _selectedInterests;
      }
      if (_selectedTravelParty != null) {
        preferencesData['travelParty'] = _selectedTravelParty!.apiValue;
      }

      // Save all preferences in one API call
      if (preferencesData.isNotEmpty) {
        await userService.updatePreferences(
          ageRange: _selectedAgeRange,
          gender: _selectedGender,
          lengthOfStay: userType == UserType.visitor ? _selectedLengthOfStay : null,
          interests: _selectedInterests.isNotEmpty ? _selectedInterests : null,
          travelParty: _selectedTravelParty,
          dataCollectionFlags: updatedFlags,
        );
      }

      // Refresh user data from API
      final authService = ref.read(authServiceProvider);
      await authService.getCurrentUser();
      
      // Also invalidate providers to ensure UI updates
      ref.invalidate(currentUserProvider);
      ref.invalidate(currentUserProfileProvider);
      ref.invalidate(authProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          AppTheme.successSnackBar(
            message: 'Profile updated successfully!',
          ),
        );
        
        // Small delay to ensure data is refreshed before navigation
        await Future.delayed(const Duration(milliseconds: 300));
        
        // Navigate back to profile
        if (mounted) {
          context.go('/profile');
        }
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = e.toString().replaceFirst('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          AppTheme.errorSnackBar(
            message: errorMessage.isNotEmpty 
                ? errorMessage 
                : 'Failed to update profile. Please try again.',
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<String?> _showPasswordDialog() async {
    final passwordController = TextEditingController();
    bool obscurePassword = true;
    bool isLoading = false;

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.backgroundColor,
          title: Text(
            'Enter Password',
            style: AppTheme.titleLarge,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Please enter your current password to update your email address.',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.secondaryTextColor,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: obscurePassword,
                enabled: !isLoading,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setDialogState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                  ),
                  filled: true,
                  fillColor: AppTheme.dividerColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.secondaryTextColor,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: isLoading ? null : () async {
                final password = passwordController.text.trim();
                if (password.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    AppTheme.errorSnackBar(
                      message: 'Please enter your password',
                    ),
                  );
                  return;
                }
                
                setDialogState(() {
                  isLoading = true;
                });
                
                // Small delay to show loading state
                await Future.delayed(const Duration(milliseconds: 100));
                
                if (context.mounted) {
                  Navigator.of(context).pop(password);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Confirm'),
            ),
          ],
        ),
      ),
    );
  }
}
