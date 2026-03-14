import 'package:dartz/dartz.dart';
import 'package:mobile_app/core/error/failure.dart';
import 'package:mobile_app/features/wallet/domain/entities/wallet_entity.dart';

abstract class WalletRepository {
  /// Get wallet balance and summary
  Future<Either<Failure, WalletEntity>> getWalletBalance();

  /// Get transaction history
  Future<Either<Failure, List<TransactionEntity>>> getTransactions({
    int? limit,
    int? offset,
  });

  /// Request a withdrawal
  Future<Either<Failure, TransactionEntity>> requestWithdrawal(double amount);

  /// Create payment intent for deposit
  Future<Either<Failure, String>> createDepositPaymentIntent(double amount, String currency);
}














