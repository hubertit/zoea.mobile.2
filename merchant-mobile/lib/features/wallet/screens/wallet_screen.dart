import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/wallet.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  final _wallet = Wallet(
    id: 'w1',
    merchantId: '1',
    balance: 2450000,
    pendingBalance: 350000,
    currency: 'RWF',
    updatedAt: DateTime.now(),
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
          'Wallet',
          style: AppTheme.headlineSmall.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Wallet settings
            },
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverToBoxAdapter(child: _buildBalanceCard()),
          const SliverToBoxAdapter(child: SizedBox(height: AppTheme.spacing16)),
          SliverToBoxAdapter(child: _buildActionButtons()),
          const SliverToBoxAdapter(child: SizedBox(height: AppTheme.spacing24)),
          SliverToBoxAdapter(child: _buildTransactionTabs()),
        ],
        body: _buildTransactionsList(),
      ),
    );
  }

  Widget _buildBalanceCard() {
    // Soft grayish tones based on primary color (like Apple Pay card)
    const cardBaseColor = Color(0xFFE8E8ED);
    const cardAccentColor = Color(0xFFD1D1D6);
    final primaryTint = AppTheme.primaryColor.withOpacity(0.08);
    
    return Container(
      margin: const EdgeInsets.all(AppTheme.spacing16),
      padding: const EdgeInsets.all(AppTheme.spacing24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cardBaseColor,
            cardAccentColor,
            cardBaseColor.withBlue(240),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(AppTheme.borderRadius24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: primaryTint,
            blurRadius: 40,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Available Balance',
            style: AppTheme.bodyMedium.copyWith(
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_wallet.currency} ${_formatNumber(_wallet.balance)}',
            style: AppTheme.displayLarge.copyWith(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.schedule,
                  color: Colors.black54,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Pending: ${_wallet.currency} ${_formatNumber(_wallet.pendingBalance)}',
                  style: AppTheme.bodySmall.copyWith(
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
      child: Row(
        children: [
          Expanded(
            child: _ActionButton(
              icon: Icons.add,
              label: 'Deposit',
              onTap: () => _showDepositSheet(),
            ),
          ),
          const SizedBox(width: AppTheme.spacing12),
          Expanded(
            child: _ActionButton(
              icon: Icons.arrow_upward,
              label: 'Withdraw',
              onTap: () => _showWithdrawSheet(),
            ),
          ),
          const SizedBox(width: AppTheme.spacing12),
          Expanded(
            child: _ActionButton(
              icon: Icons.history,
              label: 'History',
              onTap: () {
                // Already on history
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
      decoration: BoxDecoration(
        color: AppTheme.dividerColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: AppTheme.primaryTextColor,
        unselectedLabelColor: AppTheme.secondaryTextColor,
        labelStyle: AppTheme.labelLarge,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'All'),
          Tab(text: 'In'),
          Tab(text: 'Out'),
        ],
      ),
    );
  }

  Widget _buildTransactionsList() {
    final transactions = _getMockTransactions();
    
    return TabBarView(
      controller: _tabController,
      children: [
        _TransactionList(transactions: transactions),
        _TransactionList(
          transactions: transactions.where((t) => t.isCredit).toList(),
        ),
        _TransactionList(
          transactions: transactions.where((t) => !t.isCredit).toList(),
        ),
      ],
    );
  }

  void _showDepositSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DepositWithdrawSheet(
        title: 'Deposit Funds',
        buttonLabel: 'Deposit',
        onSubmit: (amount) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            AppTheme.successSnackBar(message: 'Deposit initiated'),
          );
        },
      ),
    );
  }

  void _showWithdrawSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DepositWithdrawSheet(
        title: 'Withdraw Funds',
        buttonLabel: 'Withdraw',
        balance: _wallet.balance,
        onSubmit: (amount) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            AppTheme.successSnackBar(message: 'Withdrawal initiated'),
          );
        },
      ),
    );
  }

  String _formatNumber(double number) {
    final formatter = NumberFormat('#,###', 'en_US');
    return formatter.format(number);
  }

  List<WalletTransaction> _getMockTransactions() {
    return [
      WalletTransaction(
        id: 't1',
        walletId: 'w1',
        type: TransactionType.booking,
        amount: 150000,
        currency: 'RWF',
        status: TransactionStatus.completed,
        description: 'Deluxe Room booking',
        customerName: 'John Doe',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      WalletTransaction(
        id: 't2',
        walletId: 'w1',
        type: TransactionType.commission,
        amount: 15000,
        currency: 'RWF',
        status: TransactionStatus.completed,
        description: 'Platform fee (10%)',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      WalletTransaction(
        id: 't3',
        walletId: 'w1',
        type: TransactionType.withdrawal,
        amount: 500000,
        currency: 'RWF',
        status: TransactionStatus.completed,
        description: 'Bank transfer',
        reference: 'WD-2024-001',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      WalletTransaction(
        id: 't4',
        walletId: 'w1',
        type: TransactionType.booking,
        amount: 80000,
        currency: 'RWF',
        status: TransactionStatus.completed,
        description: 'Table reservation',
        customerName: 'Jane Smith',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      WalletTransaction(
        id: 't5',
        walletId: 'w1',
        type: TransactionType.refund,
        amount: 50000,
        currency: 'RWF',
        status: TransactionStatus.completed,
        description: 'Booking cancelled',
        customerName: 'Mike Johnson',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      WalletTransaction(
        id: 't6',
        walletId: 'w1',
        type: TransactionType.booking,
        amount: 3000000,
        currency: 'RWF',
        status: TransactionStatus.pending,
        description: 'Gorilla trekking tour',
        customerName: 'Sarah Williams',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.borderRadius12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing16),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(AppTheme.borderRadius12),
          border: Border.all(color: AppTheme.dividerColor.withOpacity(0.5)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppTheme.primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTheme.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionList extends StatelessWidget {
  final List<WalletTransaction> transactions;

  const _TransactionList({required this.transactions});

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: AppTheme.secondaryTextColor.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No transactions',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.secondaryTextColor,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        return _TransactionItem(transaction: transactions[index]);
      },
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final WalletTransaction transaction;

  const _TransactionItem({required this.transaction});

  void _showTransactionDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TransactionDetailsSheet(transaction: transaction),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.isCredit;
    final formatter = NumberFormat('#,###', 'en_US');

    return GestureDetector(
      onTap: () => _showTransactionDetails(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppTheme.spacing12),
        padding: const EdgeInsets.all(AppTheme.spacing16),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(AppTheme.borderRadius12),
          border: Border.all(color: AppTheme.dividerColor.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isCredit
                    ? AppTheme.successColor.withOpacity(0.1)
                    : AppTheme.errorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                  color: isCredit ? AppTheme.successColor : AppTheme.errorColor,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.type.displayName,
                    style: AppTheme.titleSmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    transaction.description ?? '',
                    style: AppTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isCredit ? '+' : '-'} ${formatter.format(transaction.amount)}',
                  style: AppTheme.titleSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isCredit ? AppTheme.successColor : AppTheme.errorColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDate(transaction.createdAt),
                  style: AppTheme.labelSmall,
                ),
              ],
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right,
              color: AppTheme.secondaryTextColor.withOpacity(0.5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return DateFormat('HH:mm').format(date);
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return DateFormat('EEEE').format(date);
    } else {
      return DateFormat('MMM dd').format(date);
    }
  }
}

class _TransactionDetailsSheet extends StatelessWidget {
  final WalletTransaction transaction;

  const _TransactionDetailsSheet({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.isCredit;
    final formatter = NumberFormat('#,###', 'en_US');

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(AppTheme.spacing20),
            child: Column(
              children: [
                // Drag Handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: AppTheme.spacing20),
                
                // Header with type and status
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isCredit
                            ? AppTheme.successColor.withOpacity(0.1)
                            : AppTheme.errorColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                        color: isCredit ? AppTheme.successColor : AppTheme.errorColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            transaction.type.displayName,
                            style: AppTheme.headlineSmall.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            transaction.description ?? '',
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(transaction.status),
                  ],
                ),
                const SizedBox(height: AppTheme.spacing24),
                
                // Amount Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppTheme.spacing20),
                  decoration: BoxDecoration(
                    color: isCredit
                        ? AppTheme.successColor.withOpacity(0.08)
                        : AppTheme.errorColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isCredit
                          ? AppTheme.successColor.withOpacity(0.2)
                          : AppTheme.errorColor.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        isCredit ? 'Amount Received' : 'Amount Sent',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.secondaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${isCredit ? '+' : '-'} RWF ${formatter.format(transaction.amount)}',
                        style: AppTheme.displayMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isCredit ? AppTheme.successColor : AppTheme.errorColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.spacing24),
                
                // Transaction Details Section
                _buildSection('Transaction Details', [
                  if (transaction.customerName != null)
                    _buildDetailRow('Customer', transaction.customerName!),
                  _buildDetailRow('Date', DateFormat('EEEE, MMM dd, yyyy').format(transaction.createdAt)),
                  _buildDetailRow('Time', DateFormat('HH:mm').format(transaction.createdAt)),
                  if (transaction.reference != null)
                    _buildDetailRow('Reference', transaction.reference!),
                ]),
                const SizedBox(height: AppTheme.spacing16),
                
                // ID Section
                _buildSection('Transaction ID', [
                  SelectableText(
                    transaction.id,
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.secondaryTextColor,
                      fontFamily: 'monospace',
                    ),
                  ),
                ]),
                const SizedBox(height: AppTheme.spacing24),
                
                // Actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            AppTheme.successSnackBar(message: 'Receipt downloaded'),
                          );
                        },
                        icon: const Icon(Icons.download_outlined, size: 18),
                        label: const Text('Receipt'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            AppTheme.successSnackBar(message: 'Support ticket created'),
                          );
                        },
                        icon: const Icon(Icons.help_outline, size: 18),
                        label: const Text('Support'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacing16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(TransactionStatus status) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.name[0].toUpperCase() + status.name.substring(1),
        style: AppTheme.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.dividerColor.withOpacity(0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.secondaryTextColor,
            ),
          ),
          Text(
            value,
            style: AppTheme.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.completed:
        return AppTheme.successColor;
      case TransactionStatus.pending:
        return Colors.orange;
      case TransactionStatus.failed:
      case TransactionStatus.cancelled:
        return AppTheme.errorColor;
    }
  }
}

class _DepositWithdrawSheet extends StatefulWidget {
  final String title;
  final String buttonLabel;
  final double? balance;
  final Function(double) onSubmit;

  const _DepositWithdrawSheet({
    required this.title,
    required this.buttonLabel,
    this.balance,
    required this.onSubmit,
  });

  @override
  State<_DepositWithdrawSheet> createState() => _DepositWithdrawSheetState();
}

class _DepositWithdrawSheetState extends State<_DepositWithdrawSheet> {
  final _amountController = TextEditingController();
  final _quickAmounts = [50000, 100000, 250000, 500000];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacing20),
            Text(
              widget.title,
              style: AppTheme.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (widget.balance != null) ...[
              const SizedBox(height: 8),
              Text(
                'Available: RWF ${NumberFormat('#,###').format(widget.balance)}',
                style: AppTheme.bodySmall,
              ),
            ],
            const SizedBox(height: AppTheme.spacing24),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: AppTheme.headlineMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                hintText: '0',
                prefixText: 'RWF ',
                prefixStyle: AppTheme.headlineMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.secondaryTextColor,
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacing16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _quickAmounts.map((amount) {
                return InkWell(
                  onTap: () {
                    _amountController.text = amount.toString();
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      NumberFormat('#,###').format(amount),
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppTheme.spacing24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final amount = double.tryParse(_amountController.text) ?? 0;
                  if (amount > 0) {
                    widget.onSubmit(amount);
                  }
                },
                child: Text(widget.buttonLabel),
              ),
            ),
            const SizedBox(height: AppTheme.spacing16),
          ],
        ),
      ),
    );
  }
}


