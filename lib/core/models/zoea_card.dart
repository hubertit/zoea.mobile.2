



// @JsonSerializable()
class ZoeaCard {
  final String id;
  final String userId;
  final double balance;
  final String currency;
  final CardStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? linkedAccountId;
  final List<Transaction> transactions;

  const ZoeaCard({
    required this.id,
    required this.userId,
    required this.balance,
    required this.currency,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.linkedAccountId,
    this.transactions = const [],
  });

  // factory ZoeaCard.fromJson(Map<String, dynamic> json) => _$ZoeaCardFromJson(json);
  // Map<String, dynamic> toJson() => _$ZoeaCardToJson(this);
}

// @JsonSerializable()
class Transaction {
  final String id;
  final String cardId;
  final TransactionType type;
  final double amount;
  final String currency;
  final String description;
  final DateTime timestamp;
  final TransactionStatus status;
  final String? reference;
  final String? merchantId;

  const Transaction({
    required this.id,
    required this.cardId,
    required this.type,
    required this.amount,
    required this.currency,
    required this.description,
    required this.timestamp,
    required this.status,
    this.reference,
    this.merchantId,
  });

  // factory Transaction.fromJson(Map<String, dynamic> json) => _$TransactionFromJson(json);
  // Map<String, dynamic> toJson() => _$TransactionToJson(this);
}

enum CardStatus {
  // @JsonValue('active')
  active,
  // @JsonValue('inactive')
  inactive,
  // @JsonValue('suspended')
  suspended,
  // @JsonValue('blocked')
  blocked,
}

enum TransactionType {
  // @JsonValue('deposit')
  deposit,
  // @JsonValue('withdrawal')
  withdrawal,
  // @JsonValue('payment')
  payment,
  // @JsonValue('refund')
  refund,
  // @JsonValue('commission')
  commission,
  // @JsonValue('bonus')
  bonus,
}

enum TransactionStatus {
  // @JsonValue('pending')
  pending,
  // @JsonValue('completed')
  completed,
  // @JsonValue('failed')
  failed,
  // @JsonValue('cancelled')
  cancelled,
}
