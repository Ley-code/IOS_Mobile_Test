import 'package:equatable/equatable.dart';

abstract class WalletEvent extends Equatable {
  const WalletEvent();

  @override
  List<Object?> get props => [];
}

class LoadWalletBalance extends WalletEvent {
  const LoadWalletBalance();
}

class LoadTransactions extends WalletEvent {
  final int? limit;
  final int? offset;

  const LoadTransactions({this.limit, this.offset});

  @override
  List<Object?> get props => [limit, offset];
}

class RequestWithdrawal extends WalletEvent {
  final double amount;

  const RequestWithdrawal(this.amount);

  @override
  List<Object?> get props => [amount];
}

class DepositFunds extends WalletEvent {
  final double amount;
  final String currency;

  const DepositFunds(this.amount, {this.currency = 'usd'});

  @override
  List<Object?> get props => [amount, currency];
}

// Removed ConfirmDepositPayment - payment confirmation is now handled directly in the UI

class RefreshWallet extends WalletEvent {
  const RefreshWallet();
}













