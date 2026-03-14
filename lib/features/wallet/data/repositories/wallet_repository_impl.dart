import 'package:dartz/dartz.dart';
import 'package:mobile_app/core/error/exception.dart';
import 'package:mobile_app/core/error/failure.dart';
import 'package:mobile_app/features/wallet/data/datasources/wallet_remote_data_source.dart';
import 'package:mobile_app/features/wallet/domain/entities/wallet_entity.dart';
import 'package:mobile_app/features/wallet/domain/repositories/wallet_repository.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletRemoteDataSource remoteDataSource;

  WalletRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, WalletEntity>> getWalletBalance() async {
    try {
      final wallet = await remoteDataSource.getWalletBalance();
      return Right(wallet);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to load wallet balance'));
    } catch (e) {
      return Left(const ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> getTransactions({
    int? limit,
    int? offset,
  }) async {
    try {
      final transactions = await remoteDataSource.getTransactions(
        limit: limit,
        offset: offset,
      );
      return Right(transactions);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to load transactions'));
    } catch (e) {
      return Left(const ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, TransactionEntity>> requestWithdrawal(
      double amount) async {
    try {
      final transaction = await remoteDataSource.requestWithdrawal(amount);
      return Right(transaction);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to request withdrawal'));
    } catch (e) {
      return Left(const ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, String>> createDepositPaymentIntent(double amount, String currency) async {
    try {
      final paymentIntent = await remoteDataSource.createDepositPaymentIntent(amount, currency);
      return Right(paymentIntent);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to create payment intent'));
    } catch (e) {
      return Left(const ServerFailure('An unexpected error occurred'));
    }
  }
}














