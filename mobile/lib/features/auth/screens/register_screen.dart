import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/models/user.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _agreeToTerms = false;
  UserRole _selectedUserRole = UserRole.explorer;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        AppTheme.errorSnackBar(
          message: 'Please agree to the Terms and Conditions',
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = ref.read(authServiceProvider);
      final user = await authService.signUpWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _fullNameController.text.trim(),
      );

      if (user != null && mounted) {
        context.go('/explore');
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          AppTheme.errorSnackBar(
            message: 'Registration failed. Please try again.',
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = e.toString().replaceFirst('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          AppTheme.errorSnackBar(
            message: errorMessage.isNotEmpty ? errorMessage : 'An error occurred. Please try again.',
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
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 32),
          onPressed: () => context.pop(),
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
                // Header
                Column(
                  children: [
                    Text(
                      'Create Account',
                      style: Theme.of(context).textTheme.displayMedium,
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(
                      duration: 600.ms,
                    ),
                    const SizedBox(height: AppTheme.spacing8),
                    Text(
                      'Join the Zoea Africa community',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.secondaryTextColor,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(
                      duration: 600.ms,
                      delay: 200.ms,
                    ),
                  ],
                ),
                
                const SizedBox(height: AppTheme.spacing32),
                
                // Full Name Field
                TextFormField(
                  controller: _fullNameController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    hintText: 'Enter your full name',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ).animate().slideX(
                  begin: -1,
                  duration: 600.ms,
                  delay: 400.ms,
                  curve: Curves.easeOut,
                ),
                
                const SizedBox(height: AppTheme.spacing16),
                
                // Email Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your email address',
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ).animate().slideX(
                  begin: -1,
                  duration: 600.ms,
                  delay: 500.ms,
                  curve: Curves.easeOut,
                ),
                
                const SizedBox(height: AppTheme.spacing16),
                
                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Create a strong password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
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
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ).animate().slideX(
                  begin: -1,
                  duration: 600.ms,
                  delay: 600.ms,
                  curve: Curves.easeOut,
                ),
                
                const SizedBox(height: AppTheme.spacing16),
                
                // Confirm Password Field
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: !_isConfirmPasswordVisible,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _handleRegister(),
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    hintText: 'Confirm your password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                        icon: Icon(
                          _isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
                        ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ).animate().slideX(
                  begin: -1,
                  duration: 600.ms,
                  delay: 700.ms,
                  curve: Curves.easeOut,
                ),
                
                const SizedBox(height: AppTheme.spacing16),
                
                // User Type Selection
                Text(
                  'Select your account type',
                  style: AppTheme.titleMedium,
                ).animate().slideX(
                  begin: -1,
                  duration: 600.ms,
                  delay: 800.ms,
                  curve: Curves.easeOut,
                ),
                
                const SizedBox(height: AppTheme.spacing12),
                
                // User Type Cards
                ...UserRole.values.where((role) => role != UserRole.admin).map((role) {
                  final isSelected = _selectedUserRole == role;
                  return Container(
                    margin: const EdgeInsets.only(bottom: AppTheme.spacing12),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedUserRole = role;
                        });
                      },
                      borderRadius: BorderRadius.circular(AppTheme.borderRadius16),
                      child: Container(
                        padding: const EdgeInsets.all(AppTheme.spacing16),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.transparent,
                          border: Border.all(
                            color: isSelected ? AppTheme.primaryColor : AppTheme.dividerColor,
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(AppTheme.borderRadius16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? AppTheme.primaryColor : AppTheme.dividerColor,
                                  width: 2,
                                ),
                                color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                              ),
                              child: isSelected
                                  ? const Icon(
                                      Icons.check,
                                      size: 12,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: AppTheme.spacing12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    role.displayName,
                                    style: AppTheme.titleMedium.copyWith(
                                      color: isSelected ? AppTheme.primaryColor : AppTheme.primaryTextColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: AppTheme.spacing4),
                                  Text(
                                    role.description,
                                    style: AppTheme.bodySmall.copyWith(
                                      color: isSelected ? AppTheme.primaryColor : AppTheme.secondaryTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ).animate().slideX(
                    begin: -1,
                    duration: 600.ms,
                    delay: (900 + (UserRole.values.indexOf(role) * 100)).ms,
                    curve: Curves.easeOut,
                  );
                }),
                
                const SizedBox(height: AppTheme.spacing16),
                
                // Terms and Conditions
                Row(
                  children: [
                    Checkbox(
                      value: _agreeToTerms,
                      onChanged: (value) {
                        setState(() {
                          _agreeToTerms = value ?? false;
                        });
                      },
                      activeColor: AppTheme.primaryColor,
                    ),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.bodySmall,
                          children: const [
                            TextSpan(text: 'I agree to the '),
                            TextSpan(
                              text: 'Terms and Conditions',
                              style: TextStyle(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: TextStyle(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(
                  duration: 600.ms,
                  delay: 800.ms,
                ),
                
                const SizedBox(height: AppTheme.spacing24),
                
                // Register Button
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Create Account'),
                  ),
                ).animate().slideY(
                  begin: 1,
                  duration: 600.ms,
                  delay: 900.ms,
                  curve: Curves.easeOutBack,
                ),
                
                const SizedBox(height: AppTheme.spacing24),
                
                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(
                        color: AppTheme.secondaryTextColor,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: const Text('Sign In'),
                    ),
                  ],
                ).animate().fadeIn(
                  duration: 600.ms,
                  delay: 1000.ms,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
