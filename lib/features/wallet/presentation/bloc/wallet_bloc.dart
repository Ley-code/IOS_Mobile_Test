import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/core/usecase/usecase.dart';
import 'package:mobile_app/features/wallet/domain/usecases/deposit_funds.dart';
import 'package:mobile_app/features/wallet/domain/usecases/get_transactions.dart';
import 'package:mobile_app/features/wallet/domain/usecases/get_wallet_balance.dart';
import 'package:mobile_app/features/wallet/domain/usecases/request_withdrawal.dart'
    as withdrawal_usecase;
import 'package:mobile_app/features/wallet/presentation/bloc/wallet_event.dart';
import 'package:mobile_app/features/wallet/presentation/bloc/wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final GetWalletBalance getWalletBalance;
  final GetTransactions getTransactions;
  final withdrawal_usecase.RequestWithdrawal requestWithdrawal;
  final CreateDepositPaymentIntent createDepositPaymentIntent;

  WalletBloc({
    required this.getWalletBalance,
    required this.getTransactions,
    required this.requestWithdrawal,
    required this.createDepositPaymentIntent,
  }) : super(WalletInitial()) {
    on<LoadWalletBalance>(_onLoadWalletBalance);
    on<LoadTransactions>(_onLoadTransactions);
    on<RequestWithdrawal>(_onRequestWithdrawal);
    on<DepositFunds>(_onDepositFunds);
    on<RefreshWallet>(_onRefreshWallet);
  }

  Future<void> _onLoadWalletBalance(
    LoadWalletBalance event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletLoading());

    final result = await getWalletBalance(NoParams());

    result.fold(
      (failure) => emit(WalletError(failure.message)),
      (wallet) => emit(WalletLoaded(wallet: wallet)),
    );
  }

  Future<void> _onLoadTransactions(
    LoadTransactions event,
    Emitter<WalletState> emit,
  ) async {
    if (state is WalletLoaded) {
      final currentState = state as WalletLoaded;

      final result = await getTransactions(
        GetTransactionsParams(limit: event.limit, offset: event.offset),
      );

      result.fold(
        (failure) => emit(WalletError(failure.message)),
        (transactions) =>
            emit(currentState.copyWith(transactions: transactions)),
      );
    }
  }

  Future<void> _onRequestWithdrawal(
    RequestWithdrawal event,
    Emitter<WalletState> emit,
  ) async {
    emit(WithdrawalRequesting());

    final result = await requestWithdrawal(event.amount);

    result.fold((failure) => emit(WithdrawalError(failure.message)), (
      transaction,
    ) {
      emit(WithdrawalRequested(transaction));
      // Refresh wallet balance
      add(const LoadWalletBalance());
    });
  }

  Future<void> _onDepositFunds(
    DepositFunds event,
    Emitter<WalletState> emit,
  ) async {
    emit(DepositProcessing());

    final result = await createDepositPaymentIntent(
      CreateDepositPaymentIntentParams(
        amount: event.amount,
        currency: event.currency,
      ),
    );

    result.fold((failure) => emit(DepositError(failure.message)), (
      paymentIntentClientSecret,
    ) {
      emit(PaymentIntentCreated(paymentIntentClientSecret));
    });
  }

  Future<void> _onRefreshWallet(
    RefreshWallet event,
    Emitter<WalletState> emit,
  ) async {
    final balanceResult = await getWalletBalance(NoParams());
    final transactionsResult = await getTransactions(
      const GetTransactionsParams(limit: 10),
    );

    balanceResult.fold((failure) => emit(WalletError(failure.message)), (
      wallet,
    ) {
      transactionsResult.fold(
        (failure) => emit(WalletLoaded(wallet: wallet)),
        (transactions) =>
            emit(WalletLoaded(wallet: wallet, transactions: transactions)),
      );
    });
  }
}
