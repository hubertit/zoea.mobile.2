/// Subscription Plan model
class SubscriptionPlan {
  final String id;
  final String name;
  final String description;
  final PlanTier tier;
  final double monthlyPrice;
  final double yearlyPrice;
  final String currency;
  final List<PlanFeature> features;
  final List<BusinessCategory> allowedCategories;
  final int maxListings;
  final int maxBusinesses;
  final double commissionRate; // Platform commission percentage
  final bool hasAnalytics;
  final bool hasPrioritySupport;
  final bool hasCustomBranding;
  final bool isPopular;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.tier,
    required this.monthlyPrice,
    required this.yearlyPrice,
    required this.currency,
    required this.features,
    this.allowedCategories = const [],
    this.maxListings = 5,
    this.maxBusinesses = 1,
    this.commissionRate = 15.0,
    this.hasAnalytics = false,
    this.hasPrioritySupport = false,
    this.hasCustomBranding = false,
    this.isPopular = false,
  });

  double getPrice(BillingCycle cycle) {
    return cycle == BillingCycle.yearly ? yearlyPrice : monthlyPrice;
  }

  double getSavings() {
    return (monthlyPrice * 12) - yearlyPrice;
  }
}

class PlanFeature {
  final String title;
  final String? description;
  final bool isIncluded;

  const PlanFeature({
    required this.title,
    this.description,
    this.isIncluded = true,
  });
}

enum PlanTier {
  free,
  starter,
  professional,
  enterprise,
}

extension PlanTierExtension on PlanTier {
  String get displayName {
    switch (this) {
      case PlanTier.free:
        return 'Free';
      case PlanTier.starter:
        return 'Starter';
      case PlanTier.professional:
        return 'Professional';
      case PlanTier.enterprise:
        return 'Enterprise';
    }
  }

  String get icon {
    switch (this) {
      case PlanTier.free:
        return '🆓';
      case PlanTier.starter:
        return '🚀';
      case PlanTier.professional:
        return '⭐';
      case PlanTier.enterprise:
        return '👑';
    }
  }
}

enum BillingCycle {
  monthly,
  yearly,
}

extension BillingCycleExtension on BillingCycle {
  String get displayName {
    switch (this) {
      case BillingCycle.monthly:
        return 'Monthly';
      case BillingCycle.yearly:
        return 'Yearly';
    }
  }
}

enum BusinessCategory {
  accommodation,
  restaurant,
  tourOperator,
  eventVenue,
  attraction,
  transportation,
}

extension BusinessCategoryExtension on BusinessCategory {
  String get displayName {
    switch (this) {
      case BusinessCategory.accommodation:
        return 'Accommodation';
      case BusinessCategory.restaurant:
        return 'Restaurant & Dining';
      case BusinessCategory.tourOperator:
        return 'Tour Operator';
      case BusinessCategory.eventVenue:
        return 'Event Venue';
      case BusinessCategory.attraction:
        return 'Attraction';
      case BusinessCategory.transportation:
        return 'Transportation';
    }
  }
}

/// Active Subscription model
class Subscription {
  final String id;
  final String merchantId;
  final String planId;
  final SubscriptionPlan plan;
  final SubscriptionStatus status;
  final BillingCycle billingCycle;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime? cancelledAt;
  final bool autoRenew;
  final List<SubscriptionPayment> payments;
  final Contract? contract;

  const Subscription({
    required this.id,
    required this.merchantId,
    required this.planId,
    required this.plan,
    required this.status,
    required this.billingCycle,
    required this.startDate,
    required this.endDate,
    this.cancelledAt,
    this.autoRenew = true,
    this.payments = const [],
    this.contract,
  });

  bool get isActive => status == SubscriptionStatus.active;
  
  int get daysRemaining => endDate.difference(DateTime.now()).inDays;
  
  bool get isExpiringSoon => daysRemaining <= 7 && daysRemaining > 0;
}

enum SubscriptionStatus {
  active,
  expired,
  cancelled,
  suspended,
  pendingPayment,
}

extension SubscriptionStatusExtension on SubscriptionStatus {
  String get displayName {
    switch (this) {
      case SubscriptionStatus.active:
        return 'Active';
      case SubscriptionStatus.expired:
        return 'Expired';
      case SubscriptionStatus.cancelled:
        return 'Cancelled';
      case SubscriptionStatus.suspended:
        return 'Suspended';
      case SubscriptionStatus.pendingPayment:
        return 'Pending Payment';
    }
  }
}

/// Payment record for subscription
class SubscriptionPayment {
  final String id;
  final String subscriptionId;
  final double amount;
  final String currency;
  final PaymentMethod method;
  final PaymentStatus status;
  final DateTime paidAt;
  final String? transactionRef;
  final String? receiptUrl;
  final String? ebmReceiptUrl; // EBM receipt if TIN provided
  final String? tinNumber;
  final DateTime periodStart;
  final DateTime periodEnd;

  const SubscriptionPayment({
    required this.id,
    required this.subscriptionId,
    required this.amount,
    required this.currency,
    required this.method,
    required this.status,
    required this.paidAt,
    this.transactionRef,
    this.receiptUrl,
    this.ebmReceiptUrl,
    this.tinNumber,
    required this.periodStart,
    required this.periodEnd,
  });
}

enum PaymentMethod {
  momo,
  bankTransfer,
  card,
  zoeaWallet,
}

extension PaymentMethodExtension on PaymentMethod {
  String get displayName {
    switch (this) {
      case PaymentMethod.momo:
        return 'Mobile Money';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
      case PaymentMethod.card:
        return 'Card';
      case PaymentMethod.zoeaWallet:
        return 'Zoea Wallet';
    }
  }

  String get icon {
    switch (this) {
      case PaymentMethod.momo:
        return '📱';
      case PaymentMethod.bankTransfer:
        return '🏦';
      case PaymentMethod.card:
        return '💳';
      case PaymentMethod.zoeaWallet:
        return '👛';
    }
  }
}

enum PaymentStatus {
  pending,
  completed,
  failed,
  refunded,
}

/// Digital Contract model
class Contract {
  final String id;
  final String subscriptionId;
  final String merchantId;
  final String merchantName;
  final String planName;
  final ContractStatus status;
  final DateTime createdAt;
  final DateTime? signedAt;
  final String? signatureData; // Base64 signature or digital signature hash
  final String? contractPdfUrl;
  final List<ContractClause> clauses;
  final ContractTerms terms;

  const Contract({
    required this.id,
    required this.subscriptionId,
    required this.merchantId,
    required this.merchantName,
    required this.planName,
    required this.status,
    required this.createdAt,
    this.signedAt,
    this.signatureData,
    this.contractPdfUrl,
    this.clauses = const [],
    required this.terms,
  });

  bool get isSigned => status == ContractStatus.signed;
}

enum ContractStatus {
  draft,
  pendingSignature,
  signed,
  expired,
  terminated,
}

extension ContractStatusExtension on ContractStatus {
  String get displayName {
    switch (this) {
      case ContractStatus.draft:
        return 'Draft';
      case ContractStatus.pendingSignature:
        return 'Pending Signature';
      case ContractStatus.signed:
        return 'Signed';
      case ContractStatus.expired:
        return 'Expired';
      case ContractStatus.terminated:
        return 'Terminated';
    }
  }
}

class ContractClause {
  final String title;
  final String content;
  final bool isRequired;

  const ContractClause({
    required this.title,
    required this.content,
    this.isRequired = true,
  });
}

class ContractTerms {
  final DateTime startDate;
  final DateTime endDate;
  final double totalAmount;
  final String currency;
  final BillingCycle billingCycle;
  final double commissionRate;
  final List<String> services;
  final List<BusinessCategory> categories;
  final int maxListings;
  final int maxBusinesses;
  final String cancellationPolicy;
  final int noticePeriodDays;

  const ContractTerms({
    required this.startDate,
    required this.endDate,
    required this.totalAmount,
    required this.currency,
    required this.billingCycle,
    required this.commissionRate,
    required this.services,
    required this.categories,
    required this.maxListings,
    required this.maxBusinesses,
    this.cancellationPolicy = '30 days notice required',
    this.noticePeriodDays = 30,
  });
}

/// Terms and Conditions
class TermsAndConditions {
  final String version;
  final DateTime effectiveDate;
  final String content;
  final List<TermsSection> sections;

  const TermsAndConditions({
    required this.version,
    required this.effectiveDate,
    required this.content,
    required this.sections,
  });
}

class TermsSection {
  final String title;
  final String content;
  final List<String> bulletPoints;

  const TermsSection({
    required this.title,
    required this.content,
    this.bulletPoints = const [],
  });
}

