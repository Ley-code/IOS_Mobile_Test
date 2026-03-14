import 'package:equatable/equatable.dart';
import 'package:mobile_app/features/wallet/domain/entities/wallet_entity.dart';

abstract class WalletState extends Equatable {
  const WalletState();

  @override
  List<Object?> get props => [];
}

class WalletInitial extends WalletState {}

class WalletLoading extends WalletState {}

class WalletLoaded extends WalletState {
  final WalletEntity wallet;
  final List<TransactionEntity> transactions;

  const WalletLoaded({required this.wallet, this.transactions = const []});

  @override
  List<Object?> get props => [wallet, transactions];

  WalletLoaded copyWith({
    WalletEntity? wallet,
    List<TransactionEntity>? transactions,
  }) {
    return WalletLoaded(
      wallet: wallet ?? this.wallet,
      transactions: transactions ?? this.transactions,
    );
  }
}

class WalletError extends WalletState {
  final String message;

  const WalletError(this.message);

  @override
  List<Object?> get props => [message];
}

class WithdrawalRequesting extends WalletState {}

class WithdrawalRequested extends WalletState {
  final TransactionEntity transaction;

  const WithdrawalRequested(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class WithdrawalError extends WalletState {
  final String message;

  const WithdrawalError(this.message);

  @override
  List<Object?> get props => [message];
}

class DepositProcessing extends WalletState {}

class PaymentIntentCreated extends WalletState {
  final String paymentIntentClientSecret;

  const PaymentIntentCreated(this.paymentIntentClientSecret);

  @override
  List<Object?> get props => [paymentIntentClientSecret];
}

class DepositProcessed extends WalletState {
  const DepositProcessed();

  @override
  List<Object?> get props => [];
}

class DepositError extends WalletState {
  final String message;

  const DepositError(this.message);

  @override
  List<Object?> get props => [message];
}













