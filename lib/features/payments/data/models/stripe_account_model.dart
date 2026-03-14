import 'package:mobile_app/features/payments/domain/entities/stripe_account_entity.dart';

class StripeAccountModel extends StripeAccountEntity {
  const StripeAccountModel({
    super.accountId,
    super.status,
    super.payoutsEnabled,
    super.chargesEnabled,
    super.dashboardUrl,
    super.onboardingUrl,
    super.defaultBankAccount,
  });

  factory StripeAccountModel.fromJson(Map<String, dynamic> json) {
    // Parse status
    StripeAccountStatus status = StripeAccountStatus.notConnected;
    final statusStr = json['status'] as String?;
    if (statusStr != null) {
      switch (statusStr.toLowerCase()) {
        case 'active':
        case 'enabled':
          status = StripeAccountStatus.active;
          break;
        case 'pending':
        case 'incomplete':
          status = StripeAccountStatus.pending;
          break;
        case 'restricted':
          status = StripeAccountStatus.restricted;
          break;
        default:
          status = StripeAccountStatus.notConnected;
      }
    }

    // Parse bank account if present
    BankAccountModel? bankAccount;
    if (json['default_bank_account'] != null) {
      bankAccount = BankAccountModel.fromJson(
        json['default_bank_account'] as Map<String, dynamic>,
      );
    } else if (json['external_accounts'] != null) {
      final accounts = json['external_accounts']['data'] as List?;
      if (accounts != null && accounts.isNotEmpty) {
        bankAccount = BankAccountModel.fromJson(
          accounts.first as Map<String, dynamic>,
        );
      }
    }

    return StripeAccountModel(
      accountId: json['id'] as String? ?? json['account_id'] as String?,
      status: status,
      payoutsEnabled: json['payouts_enabled'] as bool? ?? false,
      chargesEnabled: json['charges_enabled'] as bool? ?? false,
      dashboardUrl: json['dashboard_url'] as String?,
      onboardingUrl: json['onboarding_url'] as String?,
      defaultBankAccount: bankAccount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'account_id': accountId,
      'status': status.name,
      'payouts_enabled': payoutsEnabled,
      'charges_enabled': chargesEnabled,
      'dashboard_url': dashboardUrl,
      'onboarding_url': onboardingUrl,
    };
  }
}

class BankAccountModel extends BankAccountEntity {
  const BankAccountModel({
    required super.id,
    required super.bankName,
    required super.last4,
    super.currency,
    super.isDefault,
  });

  factory BankAccountModel.fromJson(Map<String, dynamic> json) {
    return BankAccountModel(
      id: json['id'] as String? ?? '',
      bankName: json['bank_name'] as String? ?? 'Bank Account',
      last4: json['last4'] as String? ?? '****',
      currency: json['currency'] as String? ?? 'usd',
      isDefault: json['default_for_currency'] as bool? ?? false,
    );
  }
}

class PayoutModel extends PayoutEntity {
  const PayoutModel({
    required super.id,
    required super.amount,
    super.currency,
    required super.status,
    required super.createdAt,
    super.arrivedAt,
  });

  factory PayoutModel.fromJson(Map<String, dynamic> json) {
    return PayoutModel(
      id: json['id'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'usd',
      status: json['status'] as String? ?? 'pending',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      arrivedAt: json['arrival_date'] != null
          ? DateTime.parse(json['arrival_date'] as String)
          : null,
    );
  }
}














