import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:country_picker/country_picker.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/utils/phone_validator.dart';
import '../../../core/utils/phone_input_formatter.dart';

class RequestPasswordResetScreen extends ConsumerStatefulWidget {
  const RequestPasswordResetScreen({super.key});

  @override
  ConsumerState<RequestPasswordResetScreen> createState() => _RequestPasswordResetScreenState();
}

class _RequestPasswordResetScreenState extends ConsumerState<RequestPasswordResetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  bool _isPhoneReset = true; // Toggle between email and phone reset (default to phone)
  
  // Country picker for phone reset
  Country _selectedCountry = Country(
    phoneCode: '250',
    countryCode: 'RW',
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: 'Rwanda',
    example: '250123456789',
    displayName: 'Rwanda (RW) [+250]',
    displayNameNoCountryCode: 'Rwanda (RW)',
    e164Key: '250-RW-0',
  );

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _showCountryPicker() {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      countryListTheme: CountryListThemeData(
        flagSize: 25,
        backgroundColor: context.surfaceColor,
        textStyle: Theme.of(context).textTheme.bodyLarge!,
        bottomSheetHeight: 500,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
        inputDecoration: InputDecoration(
          labelText: 'Search',
          hintText: 'Start typing to search',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: context.dividerColor.withOpacity(0.2),
            ),
          ),
        ),
      ),
      onSelect: (Country country) {
        setState(() {
          _selectedCountry = country;
        });
      },
    );
  }

  Future<void> _handleRequestReset() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = ref.read(authServiceProvider);
      
      // Get identifier based on selected method
      String identifier;
      if (_isPhoneReset) {
        // Clean phone number: remove spaces, +, and special characters
        final phoneNumber = '${_selectedCountry.phoneCode}${_phoneController.text.trim()}';
        identifier = PhoneValidator.cleanPhoneNumber(phoneNumber);
      } else {
        // Use email
        identifier = _emailController.text.trim();
      }
      
      final result = await authService.requestPasswordReset(identifier);

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Reset code sent successfully'),
            backgroundColor: AppTheme.successColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadius8),
            ),
          ),
        );

        // Navigate to verify code screen
        context.push('/auth/reset-password/verify', extra: {
          'identifier': identifier,
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          AppTheme.errorSnackBar(
            message: e.toString().replaceFirst('Exception: ', ''),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        backgroundColor: context.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left,
            color: context.primaryTextColor,
            size: 32,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Reset Password',
          style: AppTheme.titleLarge,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacing24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppTheme.spacing32),
                
                // Icon
                Icon(
                  Icons.lock_reset,
                  size: 80,
                  color: context.primaryColorTheme,
                ),
                
                const SizedBox(height: AppTheme.spacing24),
                
                // Title
                Text(
                  'Forgot Password?',
                  style: AppTheme.displaySmall,
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: AppTheme.spacing8),
                
                // Description
                Text(
                  'Choose how you want to reset your password',
                  style: AppTheme.bodyLarge.copyWith(
                    color: context.secondaryTextColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: AppTheme.spacing32),
                
                // Reset Method Toggle
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacing4),
                  decoration: BoxDecoration(
                    color: context.backgroundColor,
                    borderRadius: BorderRadius.circular(AppTheme.borderRadius12),
                    border: Border.all(
                      color: context.dividerColor,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _isPhoneReset = true;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppTheme.spacing12,
                              horizontal: AppTheme.spacing16,
                            ),
                            decoration: BoxDecoration(
                              color: _isPhoneReset 
                                  ? context.grey300 
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(AppTheme.borderRadius8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.phone,
                                  size: 20,
                                  color: _isPhoneReset 
                                      ? context.primaryTextColor 
                                      : context.secondaryTextColor,
                                ),
                                const SizedBox(width: AppTheme.spacing8),
                                Text(
                                  'Phone',
                                  style: AppTheme.bodyMedium.copyWith(
                                    color: _isPhoneReset 
                                        ? context.primaryTextColor 
                                        : context.secondaryTextColor,
                                    fontWeight: _isPhoneReset 
                                        ? FontWeight.w600 
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _isPhoneReset = false;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppTheme.spacing12,
                              horizontal: AppTheme.spacing16,
                            ),
                            decoration: BoxDecoration(
                              color: !_isPhoneReset 
                                  ? context.grey300 
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(AppTheme.borderRadius8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.email,
                                  size: 20,
                                  color: !_isPhoneReset 
                                      ? context.primaryTextColor 
                                      : context.secondaryTextColor,
                                ),
                                const SizedBox(width: AppTheme.spacing8),
                                Text(
                                  'Email',
                                  style: AppTheme.bodyMedium.copyWith(
                                    color: !_isPhoneReset 
                                        ? context.primaryTextColor 
                                        : context.secondaryTextColor,
                                    fontWeight: !_isPhoneReset 
                                        ? FontWeight.w600 
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: AppTheme.spacing24),
                
                // Input Field (Phone or Email)
                if (_isPhoneReset) ...[
                  // Phone Field with Country Code
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        // Country Code Picker
                        InkWell(
                          onTap: _showCountryPicker,
                          borderRadius: BorderRadius.circular(AppTheme.borderRadius8),
                          child: Container(
                            height: 56, // Match TextFormField height
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.spacing12,
                            ),
                            decoration: BoxDecoration(
                              color: context.backgroundColor,
                              borderRadius: BorderRadius.circular(AppTheme.borderRadius8),
                              border: Border.all(
                                color: context.dividerColor,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  _selectedCountry.flagEmoji,
                                  style: AppTheme.bodyLarge,
                                ),
                                const SizedBox(width: AppTheme.spacing4),
                                Text(
                                  '+${_selectedCountry.phoneCode}',
                                  style: AppTheme.bodyLarge,
                                ),
                                const SizedBox(width: AppTheme.spacing4),
                                Icon(
                                  Icons.arrow_drop_down,
                                  color: context.secondaryTextColor,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacing8),
                        // Phone Number Input
                        Expanded(
                          child: TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.done,
                            inputFormatters: [
                              PhoneInputFormatter(),
                            ],
                            onFieldSubmitted: (_) => _handleRequestReset(),
                            decoration: InputDecoration(
                              labelText: 'Phone Number',
                              prefixIcon: const Icon(Icons.phone_outlined),
                              hintText: '788606765',
                              hintStyle: AppTheme.bodySmall.copyWith(color: context.secondaryTextColor),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppTheme.borderRadius8),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppTheme.borderRadius8),
                                borderSide: BorderSide(color: context.dividerColor),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppTheme.borderRadius8),
                                borderSide: BorderSide(color: context.primaryColorTheme, width: 2),
                              ),
                            ),
                            validator: PhoneValidator.validateInternationalPhone,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _handleRequestReset(),
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      hintText: 'your.email@example.com',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.borderRadius8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.borderRadius8),
                        borderSide: BorderSide(color: context.dividerColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.borderRadius8),
                        borderSide: BorderSide(color: context.primaryColorTheme, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email address';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                ],
                
                const SizedBox(height: AppTheme.spacing32),
                
                // Info Box (placeholder code)
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacing16),
                  decoration: BoxDecoration(
                    color: context.primaryColorTheme.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.borderRadius12),
                    border: Border.all(
                      color: context.primaryColorTheme.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: context.primaryColorTheme,
                        size: 20,
                      ),
                      const SizedBox(width: AppTheme.spacing12),
                      Expanded(
                        child: Text(
                          'For testing, use reset code: 0000',
                          style: AppTheme.bodySmall.copyWith(
                            color: context.primaryColorTheme,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: AppTheme.spacing32),
                
                // Submit Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleRequestReset,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.primaryColorTheme,
                    foregroundColor: context.primaryTextColor,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppTheme.spacing16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.borderRadius8),
                    ),
                    elevation: _isLoading ? 0 : 2,
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
                          'Send Reset Code',
                          style: AppTheme.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                            color: context.primaryTextColor,
                          ),
                        ),
                ),
                
                const SizedBox(height: AppTheme.spacing16),
                
                // Back to Login
                TextButton(
                  onPressed: () => context.pop(),
                  child: Text(
                    'Back to Login',
                    style: AppTheme.bodyMedium.copyWith(
                      color: context.primaryColorTheme,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

