import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/subscription.dart';

class ManageSubscriptionScreen extends StatefulWidget {
  const ManageSubscriptionScreen({super.key});

  @override
  State<ManageSubscriptionScreen> createState() => _ManageSubscriptionScreenState();
}

class _ManageSubscriptionScreenState extends State<ManageSubscriptionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock data
  final _subscription = Subscription(
    id: 'sub_1',
    merchantId: 'm1',
    planId: 'professional',
    plan: const SubscriptionPlan(
      id: 'professional',
      name: 'Professional',
      description: 'For growing businesses',
      tier: PlanTier.professional,
      monthlyPrice: 79000,
      yearlyPrice: 790000,
      currency: 'RWF',
      maxListings: 25,
      maxBusinesses: 3,
      commissionRate: 10.0,
      hasAnalytics: true,
      hasPrioritySupport: true,
      features: [],
    ),
    status: SubscriptionStatus.active,
    billingCycle: BillingCycle.yearly,
    startDate: DateTime.now().subtract(const Duration(days: 30)),
    endDate: DateTime.now().add(const Duration(days: 335)),
    autoRenew: true,
    payments: [
      SubscriptionPayment(
        id: 'pay_1',
        subscriptionId: 'sub_1',
        amount: 790000,
        currency: 'RWF',
        method: PaymentMethod.momo,
        status: PaymentStatus.completed,
        paidAt: DateTime.now().subtract(const Duration(days: 30)),
        transactionRef: 'TXN123456789',
        receiptUrl: 'https://example.com/receipt.pdf',
        tinNumber: '123456789',
        ebmReceiptUrl: 'https://example.com/ebm-receipt.pdf',
        periodStart: DateTime.now().subtract(const Duration(days: 30)),
        periodEnd: DateTime.now().add(const Duration(days: 335)),
      ),
    ],
    contract: Contract(
      id: 'contract_1',
      subscriptionId: 'sub_1',
      merchantId: 'm1',
      merchantName: 'Kigali Heights Hotel',
      planName: 'Professional',
      status: ContractStatus.signed,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      signedAt: DateTime.now().subtract(const Duration(days: 30)),
      contractPdfUrl: 'https://example.com/contract.pdf',
      terms: ContractTerms(
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        endDate: DateTime.now().add(const Duration(days: 335)),
        totalAmount: 790000,
        currency: 'RWF',
        billingCycle: BillingCycle.yearly,
        commissionRate: 10.0,
        services: ['Booking Management', 'Analytics', 'Priority Support'],
        categories: [BusinessCategory.accommodation, BusinessCategory.restaurant],
        maxListings: 25,
        maxBusinesses: 3,
      ),
    ),
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
          'Subscription',
          style: AppTheme.headlineSmall.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Current plan card
          _buildCurrentPlanCard(),
          
          // Tabs
          TabBar(
            controller: _tabController,
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: AppTheme.secondaryTextColor,
            indicatorColor: AppTheme.primaryColor,
            tabs: const [
              Tab(text: 'Overview'),
              Tab(text: 'Payments'),
              Tab(text: 'Contract'),
            ],
          ),
          
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildPaymentsTab(),
                _buildContractTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentPlanCard() {
    final daysLeft = _subscription.daysRemaining;
    final primaryDark = HSLColor.fromColor(AppTheme.primaryColor).withLightness(0.25).toColor();
    final primaryLight = HSLColor.fromColor(AppTheme.primaryColor).withLightness(0.35).toColor();
    
    return Container(
      margin: const EdgeInsets.all(AppTheme.spacing16),
      padding: const EdgeInsets.all(AppTheme.spacing20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryDark, primaryLight],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                _subscription.plan.tier.icon,
                style: const TextStyle(fontSize: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_subscription.plan.name} Plan',
                      style: AppTheme.titleLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _subscription.billingCycle.displayName,
                      style: AppTheme.bodySmall.copyWith(color: Colors.white60),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(_subscription.status),
            ],
          ),
          const SizedBox(height: AppTheme.spacing20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$daysLeft days left',
                      style: AppTheme.titleMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Renews ${DateFormat('MMM dd, yyyy').format(_subscription.endDate)}',
                      style: AppTheme.labelSmall.copyWith(color: Colors.white60),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => context.push('/subscription/plans'),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.15),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Text('Upgrade'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 1 - (daysLeft / 365),
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(SubscriptionStatus status) {
    Color color;
    switch (status) {
      case SubscriptionStatus.active:
        color = AppTheme.successColor;
        break;
      case SubscriptionStatus.pendingPayment:
        color = Colors.orange;
        break;
      default:
        color = AppTheme.errorColor;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.displayName,
        style: AppTheme.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Usage stats
          Text(
            'Usage',
            style: AppTheme.titleMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _UsageCard(
                  title: 'Businesses',
                  current: 2,
                  max: _subscription.plan.maxBusinesses,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _UsageCard(
                  title: 'Listings',
                  current: 8,
                  max: _subscription.plan.maxListings,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing24),
          
          // Plan details
          Text(
            'Plan Details',
            style: AppTheme.titleMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildDetailCard([
            _buildDetailRow('Commission Rate', '${_subscription.plan.commissionRate}%'),
            _buildDetailRow('Analytics', _subscription.plan.hasAnalytics ? 'Included' : 'Not included'),
            _buildDetailRow('Priority Support', _subscription.plan.hasPrioritySupport ? 'Included' : 'Not included'),
            _buildDetailRow('Auto-Renew', _subscription.autoRenew ? 'Enabled' : 'Disabled'),
          ]),
          const SizedBox(height: AppTheme.spacing24),
          
          // Actions
          Text(
            'Manage',
            style: AppTheme.titleMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildActionTile(
            icon: Icons.sync,
            title: 'Auto-Renewal',
            subtitle: _subscription.autoRenew ? 'Enabled' : 'Disabled',
            trailing: Switch(
              value: _subscription.autoRenew,
              onChanged: (v) {},
              activeColor: AppTheme.primaryColor,
            ),
          ),
          _buildActionTile(
            icon: Icons.cancel_outlined,
            title: 'Cancel Subscription',
            subtitle: 'Cancel at end of billing period',
            onTap: _showCancelDialog,
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      itemCount: _subscription.payments.length,
      itemBuilder: (context, index) {
        final payment = _subscription.payments[index];
        return _PaymentCard(
          payment: payment,
          onDownloadReceipt: () => _downloadReceipt(payment),
          onDownloadEbm: payment.ebmReceiptUrl != null 
              ? () => _downloadEbmReceipt(payment) 
              : null,
        );
      },
    );
  }

  Widget _buildContractTab() {
    final contract = _subscription.contract;
    if (contract == null) {
      return const Center(child: Text('No contract available'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Contract status card
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing20),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.dividerColor),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.successColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.verified,
                        color: AppTheme.successColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Contract ${contract.status.displayName}',
                            style: AppTheme.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (contract.signedAt != null)
                            Text(
                              'Signed on ${DateFormat('MMM dd, yyyy').format(contract.signedAt!)}',
                              style: AppTheme.bodySmall.copyWith(
                                color: AppTheme.secondaryTextColor,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacing16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _downloadContract(contract),
                    icon: const Icon(Icons.download),
                    label: const Text('Download Contract PDF'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacing24),
          
          // Contract terms
          Text(
            'Contract Terms',
            style: AppTheme.titleMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildDetailCard([
            _buildDetailRow('Contract Period', 
              '${DateFormat('MMM dd, yyyy').format(contract.terms.startDate)} - ${DateFormat('MMM dd, yyyy').format(contract.terms.endDate)}'),
            _buildDetailRow('Total Value', 
              '${contract.terms.currency} ${NumberFormat('#,###').format(contract.terms.totalAmount)}'),
            _buildDetailRow('Commission Rate', '${contract.terms.commissionRate}%'),
            _buildDetailRow('Cancellation Notice', '${contract.terms.noticePeriodDays} days'),
          ]),
          const SizedBox(height: AppTheme.spacing16),
          
          // Services
          Text(
            'Included Services',
            style: AppTheme.titleMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: contract.terms.services.map((service) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                service,
                style: AppTheme.labelSmall.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTheme.bodySmall.copyWith(color: AppTheme.secondaryTextColor)),
          Text(value, style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDestructive ? AppTheme.errorColor.withOpacity(0.3) : AppTheme.dividerColor,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? AppTheme.errorColor : AppTheme.secondaryTextColor,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDestructive ? AppTheme.errorColor : null,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTheme.labelSmall.copyWith(color: AppTheme.secondaryTextColor),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Subscription'),
        content: const Text(
          'Are you sure you want to cancel your subscription? '
          'You will continue to have access until the end of your current billing period.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep Subscription'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                AppTheme.successSnackBar(message: 'Subscription cancelled'),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Cancel Subscription'),
          ),
        ],
      ),
    );
  }

  void _downloadReceipt(SubscriptionPayment payment) {
    ScaffoldMessenger.of(context).showSnackBar(
      AppTheme.successSnackBar(message: 'Receipt downloaded'),
    );
  }

  void _downloadEbmReceipt(SubscriptionPayment payment) {
    ScaffoldMessenger.of(context).showSnackBar(
      AppTheme.successSnackBar(message: 'EBM Receipt downloaded'),
    );
  }

  void _downloadContract(Contract contract) {
    ScaffoldMessenger.of(context).showSnackBar(
      AppTheme.successSnackBar(message: 'Contract PDF downloaded'),
    );
  }
}

class _UsageCard extends StatelessWidget {
  final String title;
  final int current;
  final int max;

  const _UsageCard({
    required this.title,
    required this.current,
    required this.max,
  });

  @override
  Widget build(BuildContext context) {
    final isUnlimited = max == -1;
    final progress = isUnlimited ? 0.3 : current / max;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTheme.bodySmall.copyWith(color: AppTheme.secondaryTextColor)),
          const SizedBox(height: 8),
          Text(
            isUnlimited ? '$current' : '$current / $max',
            style: AppTheme.titleMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppTheme.dividerColor,
              valueColor: AlwaysStoppedAnimation(
                progress > 0.8 ? AppTheme.errorColor : AppTheme.primaryColor,
              ),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  final SubscriptionPayment payment;
  final VoidCallback onDownloadReceipt;
  final VoidCallback? onDownloadEbm;

  const _PaymentCard({
    required this.payment,
    required this.onDownloadReceipt,
    this.onDownloadEbm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.check_circle, color: AppTheme.successColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${payment.currency} ${NumberFormat('#,###').format(payment.amount)}',
                      style: AppTheme.titleMedium.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      DateFormat('MMM dd, yyyy').format(payment.paidAt),
                      style: AppTheme.bodySmall.copyWith(color: AppTheme.secondaryTextColor),
                    ),
                  ],
                ),
              ),
              Text(
                payment.method.icon,
                style: const TextStyle(fontSize: 24),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onDownloadReceipt,
                  icon: const Icon(Icons.receipt_long, size: 18),
                  label: const Text('Receipt'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              if (onDownloadEbm != null) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onDownloadEbm,
                    icon: const Icon(Icons.receipt, size: 18),
                    label: const Text('EBM'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

