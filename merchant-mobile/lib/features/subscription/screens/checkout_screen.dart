import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/subscription.dart';

class CheckoutScreen extends StatefulWidget {
  final SubscriptionPlan plan;
  final BillingCycle billingCycle;

  const CheckoutScreen({
    super.key,
    required this.plan,
    required this.billingCycle,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _currentStep = 0;
  PaymentMethod? _selectedPaymentMethod;
  bool _agreedToTerms = false;
  bool _isProcessing = false;
  final _tinController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _tinController.dispose();
    _phoneController.dispose();
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
          icon: const Icon(Icons.arrow_back_ios, size: 20),
        ),
        title: Text(
          'Checkout',
          style: AppTheme.headlineSmall.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Progress indicator
          _buildProgressIndicator(),
          
          // Content with bottom actions scrollable
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCurrentStep(),
                  const SizedBox(height: AppTheme.spacing24),
                  _buildBottomActions(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final steps = ['Review', 'Terms', 'Payment'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: List.generate(steps.length, (index) {
          final isCompleted = index < _currentStep;
          final isCurrent = index == _currentStep;
          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isCompleted || isCurrent
                        ? AppTheme.primaryColor
                        : AppTheme.dividerColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : Text(
                            '${index + 1}',
                            style: AppTheme.labelSmall.copyWith(
                              color: isCurrent ? Colors.white : AppTheme.secondaryTextColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  steps[index],
                  style: AppTheme.labelSmall.copyWith(
                    color: isCurrent ? AppTheme.primaryColor : AppTheme.secondaryTextColor,
                    fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                if (index < steps.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      color: isCompleted ? AppTheme.primaryColor : AppTheme.dividerColor,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildReviewStep();
      case 1:
        return _buildTermsStep();
      case 2:
        return _buildPaymentStep();
      default:
        return const SizedBox();
    }
  }

  Widget _buildReviewStep() {
    final price = widget.plan.getPrice(widget.billingCycle);
    final formatter = NumberFormat('#,###', 'en_US');
    final startDate = DateTime.now();
    final endDate = widget.billingCycle == BillingCycle.yearly
        ? startDate.add(const Duration(days: 365))
        : startDate.add(const Duration(days: 30));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Plan summary card
        Container(
          padding: const EdgeInsets.all(AppTheme.spacing20),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(widget.plan.tier.icon, style: const TextStyle(fontSize: 32)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.plan.name} Plan',
                          style: AppTheme.headlineSmall.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.billingCycle.displayName,
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 32),
              _buildDetailRow('Subscription Period', 
                '${DateFormat('MMM dd, yyyy').format(startDate)} - ${DateFormat('MMM dd, yyyy').format(endDate)}'),
              _buildDetailRow('Max Businesses', 
                widget.plan.maxBusinesses == -1 ? 'Unlimited' : '${widget.plan.maxBusinesses}'),
              _buildDetailRow('Max Listings', 
                widget.plan.maxListings == -1 ? 'Unlimited' : '${widget.plan.maxListings}'),
              _buildDetailRow('Platform Commission', '${widget.plan.commissionRate}%'),
              const Divider(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: AppTheme.titleMedium.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${widget.plan.currency} ${formatter.format(price)}',
                    style: AppTheme.headlineSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.spacing24),
        
        // TIN Number (optional)
        Text(
          'Tax Information (Optional)',
          style: AppTheme.titleMedium.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Provide your TIN number to receive an EBM receipt',
          style: AppTheme.bodySmall.copyWith(color: AppTheme.secondaryTextColor),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _tinController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'TIN Number',
            hintText: 'Enter your TIN number',
            prefixIcon: Icon(Icons.receipt_long_outlined),
          ),
        ),
      ],
    );
  }

  Widget _buildTermsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Terms & Conditions',
          style: AppTheme.headlineSmall.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Please read and accept our terms to continue',
          style: AppTheme.bodySmall.copyWith(color: AppTheme.secondaryTextColor),
        ),
        const SizedBox(height: AppTheme.spacing20),
        
        // Terms content
        Container(
          padding: const EdgeInsets.all(AppTheme.spacing16),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                  _buildTermsSection(
                    '1. Service Agreement',
                    'By subscribing to Zoea Partner services, you agree to comply with all terms and conditions outlined in this agreement. This contract is legally binding upon digital acceptance.',
                  ),
                  _buildTermsSection(
                    '2. Subscription Terms',
                    'Your subscription begins on the date of payment confirmation and continues for the selected billing period. Auto-renewal is enabled by default and can be disabled in your account settings.',
                  ),
                  _buildTermsSection(
                    '3. Platform Commission',
                    'Zoea charges a platform commission on each successful booking made through the platform. The commission rate is determined by your subscription plan and is deducted automatically from booking payments.',
                  ),
                  _buildTermsSection(
                    '4. Content & Listings',
                    'You are responsible for the accuracy of all content, images, and information provided in your listings. Zoea reserves the right to remove content that violates our community guidelines.',
                  ),
                  _buildTermsSection(
                    '5. Payment Terms',
                    'Subscription fees are charged in advance. Booking payouts are processed within 24-48 hours after guest check-out or service completion, minus the applicable platform commission.',
                  ),
                  _buildTermsSection(
                    '6. Cancellation Policy',
                    'You may cancel your subscription at any time. Cancellation takes effect at the end of the current billing period. No refunds are provided for partial periods.',
                  ),
                  _buildTermsSection(
                    '7. Data Protection',
                    'We are committed to protecting your data in accordance with Rwanda\'s data protection laws. Your information will not be shared with third parties without your consent.',
                  ),
                  _buildTermsSection(
                    '8. Dispute Resolution',
                    'Any disputes arising from this agreement shall be resolved through arbitration in Kigali, Rwanda, in accordance with Rwandan law.',
                  ),
                ],
              ),
        ),
        const SizedBox(height: AppTheme.spacing16),
        
        // Agreement checkbox - always visible
        Container(
          padding: const EdgeInsets.all(AppTheme.spacing12),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.dividerColor),
          ),
          child: InkWell(
            onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Checkbox(
                  value: _agreedToTerms,
                  onChanged: (v) => setState(() => _agreedToTerms = v ?? false),
                  activeColor: AppTheme.primaryColor,
                ),
                Expanded(
                  child: Text(
                    'I have read and agree to the Terms & Conditions and Privacy Policy.',
                    style: AppTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Method',
          style: AppTheme.headlineSmall.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Select how you want to pay',
          style: AppTheme.bodySmall.copyWith(color: AppTheme.secondaryTextColor),
        ),
        const SizedBox(height: AppTheme.spacing20),
        
        // Payment methods
        ...PaymentMethod.values.map((method) => _buildPaymentOption(method)),
        
        const SizedBox(height: AppTheme.spacing24),
        
        // Phone number for MoMo
        if (_selectedPaymentMethod == PaymentMethod.momo) ...[
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Mobile Money Number',
              hintText: '07X XXX XXXX',
              prefixIcon: Icon(Icons.phone_android),
            ),
          ),
          const SizedBox(height: AppTheme.spacing16),
        ],
        
        // Order summary
        Container(
          padding: const EdgeInsets.all(AppTheme.spacing16),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${widget.plan.name} Plan', style: AppTheme.bodyMedium),
                  Text(
                    '${widget.plan.currency} ${NumberFormat('#,###').format(widget.plan.getPrice(widget.billingCycle))}',
                    style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: AppTheme.titleMedium.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${widget.plan.currency} ${NumberFormat('#,###').format(widget.plan.getPrice(widget.billingCycle))}',
                    style: AppTheme.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentOption(PaymentMethod method) {
    final isSelected = _selectedPaymentMethod == method;
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = method),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : AppTheme.dividerColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(method.icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                method.displayName,
                style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            Radio<PaymentMethod>(
              value: method,
              groupValue: _selectedPaymentMethod,
              onChanged: (v) => setState(() => _selectedPaymentMethod = v),
              activeColor: AppTheme.primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTheme.titleSmall.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.secondaryTextColor,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTheme.bodySmall.copyWith(color: AppTheme.secondaryTextColor),
          ),
          Text(
            value,
            style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppTheme.spacing16,
        AppTheme.spacing16,
        AppTheme.spacing16,
        MediaQuery.of(context).padding.bottom + AppTheme.spacing16,
      ),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep--),
                child: const Text('Back'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: _currentStep == 0 ? 1 : 1,
            child: ElevatedButton(
              onPressed: _canProceed() ? _handleNext : null,
              child: _isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(_currentStep == 2 ? 'Pay Now' : 'Continue'),
            ),
          ),
        ],
      ),
    );
  }

  bool _canProceed() {
    if (_isProcessing) return false;
    switch (_currentStep) {
      case 0:
        return true;
      case 1:
        return _agreedToTerms;
      case 2:
        return _selectedPaymentMethod != null;
      default:
        return false;
    }
  }

  Future<void> _handleNext() async {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    } else {
      await _processPayment();
    }
  }

  Future<void> _processPayment() async {
    setState(() => _isProcessing = true);

    try {
      // Simulate payment processing
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        // Navigate to success screen
        context.go('/subscription/success', extra: {
          'plan': widget.plan,
          'billingCycle': widget.billingCycle,
          'hasTin': _tinController.text.isNotEmpty,
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          AppTheme.errorSnackBar(message: 'Payment failed. Please try again.'),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }
}

