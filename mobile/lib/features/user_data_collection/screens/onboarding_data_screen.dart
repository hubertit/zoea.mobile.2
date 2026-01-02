import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/theme/text_theme_extensions.dart';
import '../../../core/models/user.dart';
import '../../../core/providers/user_data_collection_provider.dart';
import '../../../core/services/data_inference_service.dart';
import '../widgets/country_selector.dart';
import '../widgets/visit_purpose_selector.dart';
import '../widgets/language_selector.dart';

/// Mandatory data collection screen (10-15 seconds)
/// Collects: Country, User Type, Visit Purpose, Language, Analytics Consent
class OnboardingDataScreen extends ConsumerStatefulWidget {
  const OnboardingDataScreen({super.key});

  @override
  ConsumerState<OnboardingDataScreen> createState() => _OnboardingDataScreenState();
}

class _OnboardingDataScreenState extends ConsumerState<OnboardingDataScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _isLoading = false;

  // Data collection state
  String? _selectedCountry;
  UserType? _selectedUserType;
  VisitPurpose? _selectedVisitPurpose;
  String? _selectedLanguage;
  bool _analyticsConsent = false;

  // Inferred data
  String? _inferredCountry;
  String? _inferredLanguage;
  UserType? _inferredUserType;

  @override
  void initState() {
    super.initState();
    _loadInferredData();
  }

  Future<void> _loadInferredData() async {
    final inferenceService = DataInferenceService();
    final inferred = await inferenceService.inferAllData();
    
    setState(() {
      _inferredCountry = inferred['countryOfOrigin'] as String?;
      _inferredLanguage = inferred['language'] as String?;
      _inferredUserType = inferred['userType'] as UserType?;
      
      // Pre-select inferred values
      _selectedCountry ??= _inferredCountry;
      _selectedLanguage ??= _inferredLanguage;
      _selectedUserType ??= _inferredUserType;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            _buildProgressIndicator(),
            
            // Content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // Disable swipe
                children: [
                  _buildCountryStep(),
                  _buildUserTypeStep(),
                  _buildVisitPurposeStep(),
                  _buildLanguageStep(),
                  _buildConsentStep(),
                ],
              ),
            ),
            
            // Bottom section with buttons
            _buildBottomSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      child: Row(
        children: List.generate(
          5,
          (index) => Expanded(
            child: Container(
              margin: EdgeInsets.only(
                right: index < 4 ? AppTheme.spacing4 : 0,
              ),
              height: 4,
              decoration: BoxDecoration(
                color: index <= _currentStep
                    ? context.primaryColorTheme
                    : context.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCountryStep() {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacing24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.public,
            size: 64,
            color: context.primaryColorTheme,
          ).animate().scale(
            duration: 400.ms,
            curve: Curves.easeOutBack,
          ),
          const SizedBox(height: AppTheme.spacing24),
          Text(
            'Where are you from?',
            style: context.displayMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ).animate().fadeIn(duration: 300.ms, delay: 100.ms),
          const SizedBox(height: AppTheme.spacing8),
          Text(
            'Help us personalize your experience',
            style: context.bodyMedium.copyWith(
              color: context.secondaryTextColor,
            ),
          ).animate().fadeIn(duration: 300.ms, delay: 200.ms),
          const SizedBox(height: AppTheme.spacing32),
          Expanded(
            child: SingleChildScrollView(
              child: CountrySelector(
                selectedCountry: _selectedCountry,
                autoDetectedCountry: _inferredCountry,
                onCountrySelected: (country) {
                  setState(() {
                    _selectedCountry = country;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTypeStep() {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacing24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.home,
            size: 64,
            color: context.primaryColorTheme,
          ).animate().scale(
            duration: 400.ms,
            curve: Curves.easeOutBack,
          ),
          const SizedBox(height: AppTheme.spacing24),
          Text(
            'Are you a resident or visitor?',
            style: context.displayMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ).animate().fadeIn(duration: 300.ms, delay: 100.ms),
          const SizedBox(height: AppTheme.spacing8),
          Text(
            'This helps us show you relevant content',
            style: context.bodyMedium.copyWith(
              color: context.secondaryTextColor,
            ),
          ).animate().fadeIn(duration: 300.ms, delay: 200.ms),
          const SizedBox(height: AppTheme.spacing32),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildUserTypeCard(
                  type: UserType.resident,
                  icon: Icons.home,
                  title: 'Resident',
                  subtitle: 'I live in Rwanda',
                ),
                const SizedBox(height: AppTheme.spacing16),
                _buildUserTypeCard(
                  type: UserType.visitor,
                  icon: Icons.flight,
                  title: 'Visitor',
                  subtitle: 'I\'m visiting Rwanda',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTypeCard({
    required UserType type,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _selectedUserType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedUserType = type;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppTheme.spacing24),
        decoration: BoxDecoration(
          color: isSelected
              ? context.primaryColorTheme.withOpacity(0.1)
              : context.backgroundColor,
          borderRadius: BorderRadius.circular(AppTheme.borderRadius16),
          border: Border.all(
            color: isSelected ? context.primaryColorTheme : context.dividerColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacing12),
              decoration: BoxDecoration(
                color: context.primaryColorTheme.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.borderRadius12),
              ),
              child: Icon(
                icon,
                color: context.primaryColorTheme,
                size: 32,
              ),
            ),
            const SizedBox(width: AppTheme.spacing16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.headlineMedium.copyWith(
                      color: isSelected
                          ? context.primaryColorTheme
                          : context.primaryTextColor,
                      fontWeight: FontWeight.w600,
                    ),
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
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: context.primaryColorTheme,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisitPurposeStep() {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacing24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.explore,
            size: 64,
            color: context.primaryColorTheme,
          ).animate().scale(
            duration: 400.ms,
            curve: Curves.easeOutBack,
          ),
          const SizedBox(height: AppTheme.spacing24),
          Text(
            'What brings you to Rwanda?',
            style: context.displayMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ).animate().fadeIn(duration: 300.ms, delay: 100.ms),
          const SizedBox(height: AppTheme.spacing8),
          Text(
            'Select your primary purpose',
            style: context.bodyMedium.copyWith(
              color: context.secondaryTextColor,
            ),
          ).animate().fadeIn(duration: 300.ms, delay: 200.ms),
          const SizedBox(height: AppTheme.spacing32),
          Expanded(
            child: SingleChildScrollView(
              child: VisitPurposeSelector(
                selectedPurpose: _selectedVisitPurpose,
                onPurposeSelected: (purpose) {
                  setState(() {
                    _selectedVisitPurpose = purpose;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageStep() {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacing24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.translate,
            size: 64,
            color: context.primaryColorTheme,
          ).animate().scale(
            duration: 400.ms,
            curve: Curves.easeOutBack,
          ),
          const SizedBox(height: AppTheme.spacing24),
          Text(
            'What language do you prefer?',
            style: context.displayMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ).animate().fadeIn(duration: 300.ms, delay: 100.ms),
          const SizedBox(height: AppTheme.spacing8),
          Text(
            'You can change this anytime in settings',
            style: context.bodyMedium.copyWith(
              color: context.secondaryTextColor,
            ),
          ).animate().fadeIn(duration: 300.ms, delay: 200.ms),
          const SizedBox(height: AppTheme.spacing32),
          Expanded(
            child: SingleChildScrollView(
              child: LanguageSelector(
                selectedLanguage: _selectedLanguage,
                autoDetectedLanguage: _inferredLanguage,
                onLanguageSelected: (language) {
                  setState(() {
                    _selectedLanguage = language;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsentStep() {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacing24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.privacy_tip,
            size: 64,
            color: context.primaryColorTheme,
          ).animate().scale(
            duration: 400.ms,
            curve: Curves.easeOutBack,
          ),
          const SizedBox(height: AppTheme.spacing24),
          Text(
            'Help us improve',
            style: context.displayMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ).animate().fadeIn(duration: 300.ms, delay: 100.ms),
          const SizedBox(height: AppTheme.spacing8),
          Text(
            'Allow analytics to help us personalize your experience',
            style: context.bodyMedium.copyWith(
              color: context.secondaryTextColor,
            ),
          ).animate().fadeIn(duration: 300.ms, delay: 200.ms),
          const SizedBox(height: AppTheme.spacing32),
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing20),
            decoration: BoxDecoration(
              color: context.backgroundColor,
              borderRadius: BorderRadius.circular(AppTheme.borderRadius16),
              border: Border.all(
                color: context.dividerColor,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Checkbox(
                  value: _analyticsConsent,
                  onChanged: (value) {
                    setState(() {
                      _analyticsConsent = value ?? false;
                    });
                  },
                  activeColor: context.primaryColorTheme,
                ),
                Expanded(
                  child: Text(
                    'I agree to share analytics data to improve recommendations',
                    style: context.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacing16),
          Text(
            'You can change this anytime in settings',
            style: context.bodySmall.copyWith(
              color: context.secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    final canContinue = _canContinueCurrentStep();

    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacing24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : (canContinue ? _handleContinue : null),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primaryColorTheme,
                foregroundColor: Theme.of(context).brightness == Brightness.dark
                    ? AppTheme.primaryColor
                    : Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacing24,
                  vertical: AppTheme.spacing16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.borderRadius16),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(context.primaryTextColor),
                      ),
                    )
                  : Text(
                      _currentStep == 4 ? 'Complete' : 'Continue',
                      style: context.labelLarge.copyWith(
                        color: context.backgroundColor,
                      ),
                    ),
            ),
          ),
          if (_currentStep > 0)
            TextButton(
              onPressed: _isLoading ? null : _handleBack,
              style: TextButton.styleFrom(
                foregroundColor: context.secondaryTextColor,
              ),
              child: const Text('Back'),
            ),
        ],
      ),
    );
  }

  bool _canContinueCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _selectedCountry != null && _selectedCountry!.isNotEmpty;
      case 1:
        return _selectedUserType != null;
      case 2:
        return _selectedVisitPurpose != null;
      case 3:
        return _selectedLanguage != null && _selectedLanguage!.isNotEmpty;
      case 4:
        return true; // Consent is optional
      default:
        return false;
    }
  }

  void _handleContinue() {
    if (_currentStep < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentStep++;
      });
    } else {
      _saveDataAndComplete();
    }
  }

  void _handleBack() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentStep--;
      });
    }
  }

  Future<void> _saveDataAndComplete() async {
    if (_selectedCountry == null ||
        _selectedUserType == null ||
        _selectedVisitPurpose == null ||
        _selectedLanguage == null) {
      // Should not happen due to validation, but just in case
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final service = ref.read(userDataCollectionServiceProvider);
      
      // Save mandatory data
      await service.saveMandatoryData(
        countryOfOrigin: _selectedCountry!,
        userType: _selectedUserType!,
        visitPurpose: _selectedVisitPurpose!,
        language: _selectedLanguage!,
        analyticsConsent: _analyticsConsent,
      );

      // Set analytics consent
      final analyticsService = ref.read(analyticsServiceProvider);
      await analyticsService.setConsent(_analyticsConsent);

      // Navigate to explore
      if (mounted) {
        context.go('/explore');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          AppTheme.errorSnackBar(
            message: 'Failed to save data. Please try again.',
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

