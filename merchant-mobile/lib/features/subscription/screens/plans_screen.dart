import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/subscription.dart';

class PlansScreen extends StatefulWidget {
  const PlansScreen({super.key});

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  BillingCycle _selectedCycle = BillingCycle.yearly;
  
  final List<SubscriptionPlan> _plans = [
    const SubscriptionPlan(
      id: 'free',
      name: 'Free',
      description: 'Try Zoea Partner with limited features',
      tier: PlanTier.free,
      monthlyPrice: 0,
      yearlyPrice: 0,
      currency: 'RWF',
      maxListings: 2,
      maxBusinesses: 1,
      commissionRate: 20.0,
      features: [
        PlanFeature(title: '1 business profile'),
        PlanFeature(title: 'Up to 2 listings'),
        PlanFeature(title: 'Basic booking management'),
        PlanFeature(title: '20% platform commission'),
        PlanFeature(title: 'Email support'),
        PlanFeature(title: 'Analytics', isIncluded: false),
        PlanFeature(title: 'Push notifications', isIncluded: false),
      ],
    ),
    const SubscriptionPlan(
      id: 'starter',
      name: 'Starter',
      description: 'Perfect for small businesses and startups',
      tier: PlanTier.starter,
      monthlyPrice: 30000,
      yearlyPrice: 300000,
      currency: 'RWF',
      maxListings: 50,
      maxBusinesses: 1,
      commissionRate: 15.0,
      features: [
        PlanFeature(title: 'Business profile listing'),
        PlanFeature(title: 'Basic analytics dashboard'),
        PlanFeature(title: 'Customer reviews management'),
        PlanFeature(title: 'Up to 50 listings/month'),
        PlanFeature(title: 'Basic booking management'),
        PlanFeature(title: '10 app push notifications/month'),
        PlanFeature(title: '2 WhatsApp community posts/month'),
        PlanFeature(title: '2 WhatsApp events alerts/month'),
      ],
    ),
    const SubscriptionPlan(
      id: 'professional',
      name: 'Professional',
      description: 'Ideal for growing businesses',
      tier: PlanTier.professional,
      monthlyPrice: 50000,
      yearlyPrice: 500000,
      currency: 'RWF',
      maxListings: -1, // Unlimited
      maxBusinesses: 3,
      commissionRate: 10.0,
      hasAnalytics: true,
      hasPrioritySupport: true,
      hasCustomBranding: true,
      isPopular: true,
      features: [
        PlanFeature(title: 'All Starter features'),
        PlanFeature(title: 'Priority listing placement'),
        PlanFeature(title: 'Advanced analytics'),
        PlanFeature(title: 'Custom branding options'),
        PlanFeature(title: 'Unlimited listings'),
        PlanFeature(title: 'Priority support'),
        PlanFeature(title: 'Promotional tools'),
        PlanFeature(title: 'API access'),
        PlanFeature(title: '50 app push notifications/month'),
        PlanFeature(title: '10 WhatsApp community posts/month'),
        PlanFeature(title: '10 WhatsApp events alerts/month'),
      ],
    ),
    const SubscriptionPlan(
      id: 'enterprise',
      name: 'Enterprise',
      description: 'For large businesses and chains',
      tier: PlanTier.enterprise,
      monthlyPrice: 150000,
      yearlyPrice: 1500000,
      currency: 'RWF',
      maxListings: -1,
      maxBusinesses: -1,
      commissionRate: 5.0,
      hasAnalytics: true,
      hasPrioritySupport: true,
      hasCustomBranding: true,
      features: [
        PlanFeature(title: 'All Professional features'),
        PlanFeature(title: 'Multiple locations support'),
        PlanFeature(title: 'Dedicated account manager'),
        PlanFeature(title: 'Custom integration options'),
        PlanFeature(title: 'Advanced API access'),
        PlanFeature(title: '24/7 priority support'),
        PlanFeature(title: 'Custom analytics'),
        PlanFeature(title: 'Staff management tools'),
        PlanFeature(title: 'Unlimited app push notifications'),
        PlanFeature(title: 'Unlimited WhatsApp community posts'),
        PlanFeature(title: 'Unlimited WhatsApp events alerts'),
      ],
    ),
  ];

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
          'Choose a Plan',
          style: AppTheme.headlineSmall.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Billing cycle toggle
          _buildCycleToggle(),
          
          // Plans list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              itemCount: _plans.length,
              itemBuilder: (context, index) {
                return _PlanCard(
                  plan: _plans[index],
                  billingCycle: _selectedCycle,
                  onSelect: () => _selectPlan(_plans[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCycleToggle() {
    return Container(
      margin: const EdgeInsets.all(AppTheme.spacing16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Row(
        children: BillingCycle.values.map((cycle) {
          final isSelected = cycle == _selectedCycle;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedCycle = cycle),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text(
                      cycle.displayName,
                      style: AppTheme.bodyMedium.copyWith(
                        color: isSelected ? Colors.white : AppTheme.primaryTextColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (cycle == BillingCycle.yearly)
                      Text(
                        'Save 17%',
                        style: AppTheme.labelSmall.copyWith(
                          color: isSelected ? Colors.white70 : AppTheme.successColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _selectPlan(SubscriptionPlan plan) {
    context.push('/subscription/checkout', extra: {
      'plan': plan,
      'billingCycle': _selectedCycle,
    });
  }
}

class _PlanCard extends StatelessWidget {
  final SubscriptionPlan plan;
  final BillingCycle billingCycle;
  final VoidCallback onSelect;

  const _PlanCard({
    required this.plan,
    required this.billingCycle,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final price = plan.getPrice(billingCycle);
    final formatter = NumberFormat('#,###', 'en_US');

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacing16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius16),
        border: Border.all(
          color: plan.isPopular 
              ? AppTheme.primaryColor 
              : AppTheme.dividerColor,
          width: plan.isPopular ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          // Popular badge
          if (plan.isPopular)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: const BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star_rounded, size: 14, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    'Most Popular',
                    style: AppTheme.labelSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacing20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _getTierIcon(plan.tier),
                        size: 24,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plan.name,
                            style: AppTheme.headlineSmall.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            plan.description,
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacing20),
                
                // Price
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      price == 0 ? 'Free' : '${plan.currency} ${formatter.format(price)}',
                      style: AppTheme.displaySmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    if (price > 0) ...[
                      const SizedBox(width: 4),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '/month',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.secondaryTextColor,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (billingCycle == BillingCycle.yearly && price > 0)
                  Text(
                    'Save ${plan.currency} ${formatter.format(plan.getSavings())}',
                    style: AppTheme.labelSmall.copyWith(
                      color: AppTheme.successColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                const SizedBox(height: AppTheme.spacing20),
                
                // Features
                ...plan.features.map((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(
                        feature.isIncluded ? Icons.check_circle : Icons.cancel,
                        size: 18,
                        color: feature.isIncluded
                            ? AppTheme.successColor
                            : AppTheme.secondaryTextColor.withOpacity(0.5),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        feature.title,
                        style: AppTheme.bodySmall.copyWith(
                          color: feature.isIncluded
                              ? AppTheme.primaryTextColor
                              : AppTheme.secondaryTextColor.withOpacity(0.5),
                          decoration: feature.isIncluded
                              ? null
                              : TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ),
                )),
                const SizedBox(height: AppTheme.spacing16),
                
                // CTA Button
                SizedBox(
                  width: double.infinity,
                  child: _buildButton(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(BuildContext context) {
    if (plan.tier == PlanTier.enterprise) {
      return OutlinedButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            AppTheme.successSnackBar(message: 'Our team will contact you shortly'),
          );
        },
        child: const Text('Contact Sales'),
      );
    }
    
    if (plan.tier == PlanTier.free) {
      return OutlinedButton(
        onPressed: onSelect,
        child: const Text('Get Started'),
      );
    }
    
    if (plan.isPopular) {
      return ElevatedButton(
        onPressed: onSelect,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryTextColor,
        ),
        child: const Text('Go Pro'),
      );
    }
    
    return OutlinedButton(
      onPressed: onSelect,
      child: const Text('Get Started'),
    );
  }

  IconData _getTierIcon(PlanTier tier) {
    switch (tier) {
      case PlanTier.free:
        return Icons.card_giftcard_outlined;
      case PlanTier.starter:
        return Icons.rocket_launch_outlined;
      case PlanTier.professional:
        return Icons.workspace_premium_outlined;
      case PlanTier.enterprise:
        return Icons.business_outlined;
    }
  }
}

