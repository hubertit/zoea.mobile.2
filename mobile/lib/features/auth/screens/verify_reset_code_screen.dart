import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/theme/text_theme_extensions.dart';
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
  final List<TextEditingController> _codeControllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  bool _isLoading = false;

  @override
  void dispose() {
    for (var controller in _codeControllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _onCodeChanged(int index, String value) {
    // Only allow single digit
    if (value.length > 1) {
      _codeControllers[index].text = value.substring(0, 1);
    }
    
    // Move to next field if digit entered
    if (value.isNotEmpty && index < 3) {
      _focusNodes[index + 1].requestFocus();
    }
    
    // Auto-submit if all 4 digits entered
    if (_getCode().length == 4) {
      _handleVerifyCode();
    }
  }


  String _getCode() {
    return _codeControllers.map((c) => c.text).join();
  }

  Future<void> _handleVerifyCode() async {
    final code = _getCode();
    if (code.length != 4) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = ref.read(authServiceProvider);
      await authService.verifyResetCode(
        widget.identifier,
        code,
      );

      if (mounted) {
        // Navigate to new password screen
        context.push('/auth/reset-password/new-password', extra: {
          'identifier': widget.identifier,
          'code': code,
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          AppTheme.errorSnackBar(
            message: e.toString().replaceFirst('Exception: ', ''),
          ),
        );
        // Clear code on error
        for (var controller in _codeControllers) {
          controller.clear();
        }
        _focusNodes[0].requestFocus();
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
          'Verify Code',
          style: context.titleLarge,
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
                  Icons.verified_user,
                  size: 80,
                  color: context.primaryColorTheme,
                ),
                
                const SizedBox(height: AppTheme.spacing24),
                
                // Title
                Text(
                  'Enter Reset Code',
                  style: context.displaySmall,
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: AppTheme.spacing8),
                
                // Description
                Text(
                  'We sent a reset code to ${widget.identifier}',
                  style: context.bodyLarge.copyWith(
                    color: context.secondaryTextColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: AppTheme.spacing32),
                
                // Code Input - 4 separate fields
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    return Container(
                      width: 60,
                      margin: EdgeInsets.only(
                        right: index < 3 ? AppTheme.spacing12 : 0,
                      ),
                      child: TextField(
                        controller: _codeControllers[index],
                        focusNode: _focusNodes[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        style: context.headlineMedium.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppTheme.borderRadius8),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppTheme.borderRadius8),
                            borderSide: BorderSide(
                              color: context.dividerColor,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppTheme.borderRadius8),
                            borderSide: BorderSide(
                              color: context.primaryColorTheme,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: context.backgroundColor,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (value) => _onCodeChanged(index, value),
                        onTap: () {
                          // Select all text when tapping
                          _codeControllers[index].selection = TextSelection(
                            baseOffset: 0,
                            extentOffset: _codeControllers[index].text.length,
                          );
                        },
                        onSubmitted: (_) {
                          if (index < 3) {
                            _focusNodes[index + 1].requestFocus();
                          } else {
                            _handleVerifyCode();
                          }
                        },
                      ),
                    );
                  }),
                ),
                
                const SizedBox(height: AppTheme.spacing32),
                
                // Info Box
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
                          'Use code: 0000 for testing',
                          style: context.bodySmall.copyWith(
                            color: context.primaryColorTheme,
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
                          'Verify Code',
                          style: context.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                            color: context.primaryTextColor,
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
                    style: context.bodyMedium.copyWith(
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

