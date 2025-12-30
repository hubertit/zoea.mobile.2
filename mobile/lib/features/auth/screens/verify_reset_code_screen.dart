import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/auth_provider.dart';

class VerifyResetCodeScreen extends ConsumerStatefulWidget {
  final String identifier;
  
  const VerifyResetCodeScreen({
    super.key,
    required this.identifier,
  });

  @override
  ConsumerState<VerifyResetCodeScreen> createState() => _VerifyResetCodeScreenState();
}

class _VerifyResetCodeScreenState extends ConsumerState<VerifyResetCodeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _handleVerifyCode() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = ref.read(authServiceProvider);
      await authService.verifyResetCode(
        widget.identifier,
        _codeController.text.trim(),
      );

      if (mounted) {
        // Navigate to new password screen
        context.push('/auth/reset-password/new-password', extra: {
          'identifier': widget.identifier,
          'code': _codeController.text.trim(),
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
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left,
            color: AppTheme.primaryTextColor,
            size: 32,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Verify Code',
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
                const Icon(
                  Icons.verified_user,
                  size: 80,
                  color: AppTheme.primaryColor,
                ),
                
                const SizedBox(height: AppTheme.spacing24),
                
                // Title
                Text(
                  'Enter Reset Code',
                  style: AppTheme.displaySmall,
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: AppTheme.spacing8),
                
                // Description
                Text(
                  'We sent a reset code to ${widget.identifier}',
                  style: AppTheme.bodyLarge.copyWith(
                    color: AppTheme.secondaryTextColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: AppTheme.spacing32),
                
                // Code Input
                TextFormField(
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  onFieldSubmitted: (_) => _handleVerifyCode(),
                  textAlign: TextAlign.center,
                  style: AppTheme.headlineMedium.copyWith(
                    letterSpacing: 8,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Reset Code',
                    hintText: '0000',
                    prefixIcon: const Icon(Icons.pin),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.borderRadius8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.borderRadius8),
                      borderSide: const BorderSide(color: AppTheme.dividerColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.borderRadius8),
                      borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the reset code';
                    }
                    if (value.length != 4) {
                      return 'Code must be 4 digits';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: AppTheme.spacing32),
                
                // Info Box
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacing16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.borderRadius12),
                    border: Border.all(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: AppTheme.spacing12),
                      Expanded(
                        child: Text(
                          'Use code: 0000 for testing',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: AppTheme.spacing32),
                
                // Verify Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleVerifyCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppTheme.spacing16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.borderRadius8),
                    ),
                    elevation: _isLoading ? 0 : 2,
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
                      : Text(
                          'Verify Code',
                          style: AppTheme.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
                
                const SizedBox(height: AppTheme.spacing16),
                
                // Resend Code
                TextButton(
                  onPressed: () {
                    // Navigate back to request screen
                    context.pop();
                  },
                  child: Text(
                    'Resend Code',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.primaryColor,
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

