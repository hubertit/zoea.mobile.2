import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/theme/text_theme_extensions.dart';
import '../../../core/models/user.dart';
import '../../../core/providers/user_data_collection_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../widgets/age_range_selector.dart';
import '../widgets/gender_selector.dart';
import '../widgets/length_of_stay_selector.dart';
import '../widgets/interests_chips.dart';
import '../widgets/travel_party_selector.dart';

/// Screen for users to voluntarily complete their profile
/// Shows all optional data fields with progress indicator
class CompleteProfileScreen extends ConsumerStatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  ConsumerState<CompleteProfileScreen> createState() =>
      _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends ConsumerState<CompleteProfileScreen> {
  bool _isLoading = false;
  bool _isSaving = false;

  // State for each field
  AgeRange? _selectedAgeRange;
  Gender? _selectedGender;
  LengthOfStay? _selectedLengthOfStay;
  List<String> _selectedInterests = [];
  TravelParty? _selectedTravelParty;

  @override
  void initState() {
    super.initState();
    _loadCurrentData();
  }

  void _loadCurrentData() {
    final user = ref.read(currentUserProvider);
    if (user?.preferences != null) {
      final prefs = user!.preferences!;
      setState(() {
        _selectedAgeRange = prefs.ageRange;
        _selectedGender = prefs.gender;
        _selectedLengthOfStay = prefs.lengthOfStay;
        _selectedInterests = List<String>.from(prefs.interests);
        _selectedTravelParty = prefs.travelParty;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final completionPercentage = user?.preferences?.profileCompletionPercentage ?? 0;

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: const Text('Complete Profile'),
        backgroundColor: context.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 32),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: context.primaryColorTheme))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacing24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress indicator
                  _buildProgressSection(completionPercentage),
                  const SizedBox(height: AppTheme.spacing32),

                  // Age Range
                  _buildSection(
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
                  _buildSection(
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
                    _buildSection(
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
                  _buildSection(
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
                  _buildSection(
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

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.primaryColorTheme,
                        foregroundColor: Theme.of(context).brightness == Brightness.dark
                            ? AppTheme.primaryColor
                            : Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppTheme.spacing16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.borderRadius16),
                        ),
                        elevation: 0,
                      ),
                      child: _isSaving
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(context.primaryTextColor),
                              ),
                            )
                          : Text(
                              'Save Changes',
                              style: context.labelLarge.copyWith(
                                color: context.backgroundColor,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing16),

                  // Privacy note
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacing16),
                    decoration: BoxDecoration(
                      color: context.primaryColorTheme.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.borderRadius12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.privacy_tip_outlined,
                          color: context.primaryColorTheme,
                          size: 20,
                        ),
                        const SizedBox(width: AppTheme.spacing12),
                        Expanded(
                          child: Text(
                            'Your data is used only to personalize your experience. You can update or remove it anytime.',
                            style: context.bodySmall.copyWith(
                              color: context.secondaryTextColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildProgressSection(int percentage) {
    return Builder(
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppTheme.spacing20),
        decoration: BoxDecoration(
          color: context.primaryColorTheme.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppTheme.borderRadius16),
          border: Border.all(
            color: context.primaryColorTheme.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Profile Completion',
                  style: context.headlineMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$percentage%',
                  style: context.headlineMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.primaryColorTheme,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacing12),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.borderRadius8),
              child: LinearProgressIndicator(
                value: percentage / 100,
                minHeight: 8,
                backgroundColor: context.dividerColor,
                valueColor: AlwaysStoppedAnimation<Color>(context.primaryColorTheme),
              ),
            ),
            const SizedBox(height: AppTheme.spacing8),
            Text(
              'Complete your profile to get better recommendations',
              style: context.bodySmall.copyWith(
                color: context.secondaryTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
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
                  Row(
                    children: [
                      Text(
                        title,
                        style: context.headlineSmall.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (isComplete) ...[
                        const SizedBox(width: AppTheme.spacing8),
                        Icon(
                          Icons.check_circle,
                          size: 20,
                          color: AppTheme.successColor,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacing4),
                  Text(
                    subtitle,
                    style: context.bodySmall.copyWith(
                      color: context.secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacing16),
        child,
      ],
    );
  }

  Future<void> _handleSave() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final service = ref.read(userDataCollectionServiceProvider);

      // Save all fields that have been changed
      if (_selectedAgeRange != null) {
        await service.saveProgressiveData(
          ageRange: _selectedAgeRange,
          flagKey: 'ageAsked',
        );
      }

      if (_selectedGender != null) {
        await service.saveProgressiveData(
          gender: _selectedGender,
          flagKey: 'genderAsked',
        );
      }

      // Only save lengthOfStay for visitors
      final currentUser = ref.read(currentUserProvider);
      final userType = currentUser?.preferences?.userType;
      if (userType == UserType.visitor && _selectedLengthOfStay != null) {
        await service.saveProgressiveData(
          lengthOfStay: _selectedLengthOfStay,
          flagKey: 'lengthOfStayAsked',
        );
      } else if (userType == UserType.resident && _selectedLengthOfStay != null) {
        // Clear lengthOfStay if user is a resident (shouldn't have this)
        await service.saveProgressiveData(
          lengthOfStay: null,
          flagKey: 'lengthOfStayAsked',
        );
      }

      if (_selectedInterests.isNotEmpty) {
        await service.saveProgressiveData(
          interests: _selectedInterests,
          flagKey: 'interestsAsked',
        );
      }

      if (_selectedTravelParty != null) {
        await service.saveProgressiveData(
          travelParty: _selectedTravelParty,
          flagKey: 'travelPartyAsked',
        );
      }

      // Refresh user data
      ref.invalidate(currentUserProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          AppTheme.successSnackBar(
            message: 'Profile updated successfully!',
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          AppTheme.errorSnackBar(
            message: 'Failed to save. Please try again.',
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
}

