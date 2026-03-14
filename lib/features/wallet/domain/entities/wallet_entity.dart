import 'package:equatable/equatable.dart';

class WalletEntity extends Equatable {
  final double availableBalance;
  final double fundsInEscrow;
  final List<TransactionEntity> recentTransactions;

  const WalletEntity({
    required this.availableBalance,
    required this.fundsInEscrow,
    this.recentTransactions = const [],
  });

  double get totalBalance => availableBalance + fundsInEscrow;

  @override
  List<Object?> get props => [availableBalance, fundsInEscrow, recentTransactions];
}

class TransactionEntity extends Equatable {
  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final DateTime date;
  final String? projectName;
  final String? transactionId;
  final String? paymentMethod;

  const TransactionEntity({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.date,
    this.projectName,
    this.transactionId,
    this.paymentMethod,
  });

  bool get isPositive => amount > 0;
  String get formattedAmount => isPositive ? '+\$${amount.toStringAsFixed(2)}' : '-\$${amount.abs().toStringAsFixed(2)}';

  @override
  List<Object?> get props => [
        id,
        title,
        amount,
        type,
        date,
        projectName,
        transactionId,
        paymentMethod,
      ];
}

enum TransactionType {
  deposit,
  withdrawal,
  escrowRelease,
  payout,
  fee,
  payment,
}

extension TransactionTypeExtension on TransactionType {
  String get displayName {
    switch (this) {
      case TransactionType.deposit:
        return 'Deposit';
      case TransactionType.withdrawal:
        return 'Withdrawal';
      case TransactionType.escrowRelease:
        return 'Escrow Release';
      case TransactionType.payout:
        return 'Payout';
      case TransactionType.fee:
        return 'Fee';
      case TransactionType.payment:
        return 'Payment';
    }
  }
}














