import 'package:equatable/equatable.dart';

enum StripeAccountStatus { notConnected, pending, active, restricted }

class StripeAccountEntity extends Equatable {
  final String? accountId;
  final StripeAccountStatus status;
  final bool payoutsEnabled;
  final bool chargesEnabled;
  final String? dashboardUrl;
  final String? onboardingUrl;
  final BankAccountEntity? defaultBankAccount;

  const StripeAccountEntity({
    this.accountId,
    this.status = StripeAccountStatus.notConnected,
    this.payoutsEnabled = false,
    this.chargesEnabled = false,
    this.dashboardUrl,
    this.onboardingUrl,
    this.defaultBankAccount,
  });

  bool get isConnected => status == StripeAccountStatus.active;
  bool get needsOnboarding =>
      status == StripeAccountStatus.notConnected ||
      status == StripeAccountStatus.pending;

  @override
  List<Object?> get props => [
    accountId,
    status,
    payoutsEnabled,
    chargesEnabled,
    dashboardUrl,
    onboardingUrl,
    defaultBankAccount,
  ];
}

class BankAccountEntity extends Equatable {
  final String id;
  final String bankName;
  final String last4;
  final String currency;
  final bool isDefault;

  const BankAccountEntity({
    required this.id,
    required this.bankName,
    required this.last4,
    this.currency = 'usd',
    this.isDefault = false,
  });

  String get maskedNumber => '••••$last4';

  @override
  List<Object?> get props => [id, bankName, last4, currency, isDefault];
}

class PayoutEntity extends Equatable {
  final String id;
  final double amount;
  final String currency;
  final String status;
  final DateTime createdAt;
  final DateTime? arrivedAt;

  const PayoutEntity({
    required this.id,
    required this.amount,
    this.currency = 'usd',
    required this.status,
    required this.createdAt,
    this.arrivedAt,
  });

  bool get isPending => status == 'pending';
  bool get isCompleted => status == 'paid';
  bool get isFailed => status == 'failed';

  @override
  List<Object?> get props => [
    id,
    amount,
    currency,
    status,
    createdAt,
    arrivedAt,
  ];
}
