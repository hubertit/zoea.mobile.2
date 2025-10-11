import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:country_picker/country_picker.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/utils/phone_validator.dart';
import '../../../core/utils/phone_input_formatter.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _isPhoneLogin = true; // Toggle between email and phone login (default to phone)
  
  // Country picker for phone login
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
    _passwordController.dispose();
    super.dispose();
  }

  void _showCountryPicker() {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      countryListTheme: CountryListThemeData(
        flagSize: 25,
        backgroundColor: AppTheme.backgroundColor,
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
              color: const Color(0xFF8C98A8).withOpacity(0.2),
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

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      String identifier;
      if (_isPhoneLogin) {
        // Use phone with country code
        identifier = '+${_selectedCountry.phoneCode}${_phoneController.text.trim()}';
      } else {
        // Use email
        identifier = _emailController.text.trim();
      }
      
      final authService = ref.read(authServiceProvider);
      final user = await authService.signInWithEmail(
        identifier,
        _passwordController.text,
      );

      if (user != null && mounted) {
        context.go('/explore');
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          AppTheme.errorSnackBar(
            message: 'Login failed. Please check your credentials.',
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          AppTheme.errorSnackBar(
            message: 'An error occurred. Please try again.',
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
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacing24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo and Title
                  Icon(
                    Icons.explore,
                    size: 80,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(height: AppTheme.spacing24),
                  Text(
                    'Welcome Back',
                    style: AppTheme.displaySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTheme.spacing8),
                  Text(
                    'Sign in to continue',
                    style: AppTheme.bodyLarge.copyWith(
                      color: AppTheme.secondaryTextColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTheme.spacing32),
                  
                  // Login Method Toggle
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacing4),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundColor,
                      borderRadius: BorderRadius.circular(AppTheme.borderRadius12),
                      border: Border.all(
                        color: AppTheme.dividerColor,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _isPhoneLogin = true;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppTheme.spacing12,
                                horizontal: AppTheme.spacing16,
                              ),
                              decoration: BoxDecoration(
                                color: _isPhoneLogin 
                                    ? Colors.grey[300] 
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(AppTheme.borderRadius8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.phone_outlined,
                                    color: _isPhoneLogin 
                                        ? Colors.grey[700] 
                                        : AppTheme.secondaryTextColor,
                                    size: 20,
                                  ),
                                  const SizedBox(width: AppTheme.spacing8),
                                  Text(
                                    'Phone',
                                    style: AppTheme.bodyMedium.copyWith(
                                      color: _isPhoneLogin 
                                          ? Colors.grey[700] 
                                          : AppTheme.secondaryTextColor,
                                      fontWeight: _isPhoneLogin 
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
                                _isPhoneLogin = false;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppTheme.spacing12,
                                horizontal: AppTheme.spacing16,
                              ),
                              decoration: BoxDecoration(
                                color: !_isPhoneLogin 
                                    ? Colors.grey[300] 
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(AppTheme.borderRadius8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.email_outlined,
                                    color: !_isPhoneLogin 
                                        ? Colors.grey[700] 
                                        : AppTheme.secondaryTextColor,
                                    size: 20,
                                  ),
                                  const SizedBox(width: AppTheme.spacing8),
                                  Text(
                                    'Email',
                                    style: AppTheme.bodyMedium.copyWith(
                                      color: !_isPhoneLogin 
                                          ? Colors.grey[700] 
                                          : AppTheme.secondaryTextColor,
                                      fontWeight: !_isPhoneLogin 
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
                  const SizedBox(height: AppTheme.spacing16),
                  
                  // Email or Phone Input Field
                  if (!_isPhoneLogin) ...[
                    // Email Field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                        hintText: 'your.email@example.com',
                        prefixIcon: Icon(Icons.email_outlined),
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
                  ] else ...[
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
                                color: AppTheme.backgroundColor,
                                borderRadius: BorderRadius.circular(AppTheme.borderRadius8),
                                border: Border.all(
                                  color: AppTheme.dividerColor,
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
                                    color: AppTheme.secondaryTextColor,
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
                              textInputAction: TextInputAction.next,
                              inputFormatters: [
                                PhoneInputFormatter(),
                              ],
                              decoration: InputDecoration(
                                labelText: 'Phone Number',
                                prefixIcon: const Icon(Icons.phone_outlined),
                                hintText: '788606765',
                                hintStyle: AppTheme.bodySmall.copyWith(color: AppTheme.secondaryTextColor),
                              ),
                              validator: PhoneValidator.validateInternationalPhone,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: AppTheme.spacing16),
                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.visiblePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppTheme.spacing8),
                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // TODO: Implement forgot password
                      },
                      child: const Text('Forgot Password?'),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing24),
                  // Login Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.borderRadius12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Sign In',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                  const SizedBox(height: AppTheme.spacing16),
                  // Register Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Don\'t have an account?',
                        style: AppTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: () {
                          context.go('/register');
                        },
                        child: const Text('Sign Up'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}