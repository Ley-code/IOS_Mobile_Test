import 'package:mobile_app/features/wallet/domain/entities/wallet_entity.dart';

class WalletModel extends WalletEntity {
  const WalletModel({
    required super.availableBalance,
    required super.fundsInEscrow,
    super.recentTransactions,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    List<TransactionEntity> transactions = [];
    if (json['recent_transactions'] != null) {
      transactions = (json['recent_transactions'] as List)
          .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (json['transactions'] != null) {
      transactions = (json['transactions'] as List)
          .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return WalletModel(
      availableBalance: (json['available_balance'] as num?)?.toDouble() ?? 0.0,
      fundsInEscrow: (json['funds_in_escrow'] as num?)?.toDouble() ?? 0.0,
      recentTransactions: transactions,
    );
  }
}

class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    required super.title,
    required super.amount,
    required super.type,
    required super.date,
    super.projectName,
    super.transactionId,
    super.paymentMethod,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    // Parse transaction type
    TransactionType type = TransactionType.payment;
    final typeStr = (json['type'] as String? ?? '').toLowerCase();
    if (typeStr.contains('deposit')) {
      type = TransactionType.deposit;
    } else if (typeStr.contains('withdrawal') || typeStr.contains('withdraw')) {
      type = TransactionType.withdrawal;
    } else if (typeStr.contains('escrow')) {
      type = TransactionType.escrowRelease;
    } else if (typeStr.contains('payout')) {
      type = TransactionType.payout;
    } else if (typeStr.contains('fee')) {
      type = TransactionType.fee;
    }

    // Parse date
    DateTime date;
    try {
      date = DateTime.parse(json['date'] as String? ?? json['created_at'] as String? ?? DateTime.now().toIso8601String());
    } catch (e) {
      date = DateTime.now();
    }

    return TransactionModel(
      id: json['id'] as String? ?? json['transaction_id'] as String? ?? '',
      title: json['title'] as String? ?? json['description'] as String? ?? 'Transaction',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      type: type,
      date: date,
      projectName: json['project_name'] as String?,
      transactionId: json['transaction_id'] as String?,
      paymentMethod: json['payment_method'] as String?,
    );
  }
}














