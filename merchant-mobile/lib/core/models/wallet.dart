/// Wallet model for merchant earnings and transactions
class Wallet {
  final String id;
  final String merchantId;
  final double balance;
  final double pendingBalance;
  final String currency;
  final DateTime updatedAt;

  const Wallet({
    required this.id,
    required this.merchantId,
    required this.balance,
    this.pendingBalance = 0,
    required this.currency,
    required this.updatedAt,
  });
}

class WalletTransaction {
  final String id;
  final String walletId;
  final TransactionType type;
  final double amount;
  final String currency;
  final TransactionStatus status;
  final String? description;
  final String? reference;
  final DateTime createdAt;
  final String? bookingId;
  final String? customerName;

  const WalletTransaction({
    required this.id,
    required this.walletId,
    required this.type,
    required this.amount,
    required this.currency,
    required this.status,
    this.description,
    this.reference,
    required this.createdAt,
    this.bookingId,
    this.customerName,
  });

  bool get isCredit => type == TransactionType.booking || 
                       type == TransactionType.deposit || 
                       type == TransactionType.refundReceived;
}

enum TransactionType {
  booking,
  withdrawal,
  deposit,
  refund,
  refundReceived,
  commission,
  payout,
}

extension TransactionTypeExtension on TransactionType {
  String get displayName {
    switch (this) {
      case TransactionType.booking:
        return 'Booking Payment';
      case TransactionType.withdrawal:
        return 'Withdrawal';
      case TransactionType.deposit:
        return 'Deposit';
      case TransactionType.refund:
        return 'Refund';
      case TransactionType.refundReceived:
        return 'Refund Received';
      case TransactionType.commission:
        return 'Platform Commission';
      case TransactionType.payout:
        return 'Payout';
    }
  }

  String get icon {
    switch (this) {
      case TransactionType.booking:
        return '💰';
      case TransactionType.withdrawal:
        return '📤';
      case TransactionType.deposit:
        return '📥';
      case TransactionType.refund:
        return '↩️';
      case TransactionType.refundReceived:
        return '↪️';
      case TransactionType.commission:
        return '📊';
      case TransactionType.payout:
        return '🏦';
    }
  }
}

enum TransactionStatus {
  pending,
  completed,
  failed,
  cancelled,
}

extension TransactionStatusExtension on TransactionStatus {
  String get displayName {
    switch (this) {
      case TransactionStatus.pending:
        return 'Pending';
      case TransactionStatus.completed:
        return 'Completed';
      case TransactionStatus.failed:
        return 'Failed';
      case TransactionStatus.cancelled:
        return 'Cancelled';
    }
  }
}

