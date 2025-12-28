import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/subscription.dart';

class SubscriptionSuccessScreen extends StatelessWidget {
  final SubscriptionPlan plan;
  final BillingCycle billingCycle;
  final bool hasTin;

  const SubscriptionSuccessScreen({
    super.key,
    required this.plan,
    required this.billingCycle,
    required this.hasTin,
  });

  @override
  Widget build(BuildContext context) {
    final startDate = DateTime.now();
    final endDate = billingCycle == BillingCycle.yearly
        ? startDate.add(const Duration(days: 365))
        : startDate.add(const Duration(days: 30));

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacing24),
          child: Column(
            children: [
              const Spacer(),
              
              // Success icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 60,
                  color: AppTheme.successColor,
                ),
              ),
              const SizedBox(height: AppTheme.spacing24),
              
              Text(
                'Subscription Activated!',
                style: AppTheme.headlineMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Your ${plan.name} plan is now active',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.secondaryTextColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacing32),
              
              // Summary card
              Container(
                padding: const EdgeInsets.all(AppTheme.spacing20),
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.dividerColor),
                ),
                child: Column(
                  children: [
                    _buildRow('Plan', '${plan.tier.icon} ${plan.name}'),
                    _buildRow('Billing', billingCycle.displayName),
                    _buildRow('Valid Until', DateFormat('MMM dd, yyyy').format(endDate)),
                    _buildRow('Contract', 'Digitally Signed ✓'),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spacing24),
              
              // Download options
              Text(
                'Download Documents',
                style: AppTheme.titleMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppTheme.spacing16),
              
              Row(
                children: [
                  Expanded(
                    child: _DownloadCard(
                      icon: Icons.receipt_long,
                      title: 'Receipt',
                      onTap: () => _downloadReceipt(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DownloadCard(
                      icon: Icons.description,
                      title: 'Contract',
                      onTap: () => _downloadContract(context),
                    ),
                  ),
                ],
              ),
              if (hasTin) ...[
                const SizedBox(height: 12),
                _DownloadCard(
                  icon: Icons.receipt,
                  title: 'EBM Receipt',
                  subtitle: 'Tax invoice',
                  onTap: () => _downloadEbmReceipt(context),
                  isFullWidth: true,
                ),
              ],
              
              const Spacer(),
              
              // CTA
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go('/dashboard'),
                  child: const Text('Go to Dashboard'),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.push('/subscription/manage'),
                child: const Text('View Subscription Details'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTheme.bodySmall.copyWith(color: AppTheme.secondaryTextColor),
          ),
          Text(
            value,
            style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  void _downloadReceipt(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      AppTheme.successSnackBar(message: 'Receipt downloaded'),
    );
  }

  void _downloadContract(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      AppTheme.successSnackBar(message: 'Contract PDF downloaded'),
    );
  }

  void _downloadEbmReceipt(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      AppTheme.successSnackBar(message: 'EBM Receipt downloaded'),
    );
  }
}

class _DownloadCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool isFullWidth;

  const _DownloadCard({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.dividerColor),
        ),
        child: Row(
          mainAxisAlignment: isFullWidth ? MainAxisAlignment.start : MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppTheme.primaryColor, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: AppTheme.labelSmall.copyWith(color: AppTheme.secondaryTextColor),
                  ),
              ],
            ),
            if (isFullWidth) ...[
              const Spacer(),
              const Icon(Icons.download, color: AppTheme.primaryColor, size: 20),
            ],
          ],
        ),
      ),
    );
  }
}

