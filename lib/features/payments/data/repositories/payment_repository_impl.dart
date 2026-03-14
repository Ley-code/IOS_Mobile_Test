import 'package:dartz/dartz.dart';
import 'package:mobile_app/core/error/exception.dart';
import 'package:mobile_app/core/error/failure.dart';
import 'package:mobile_app/features/payments/data/datasources/payment_remote_data_source.dart';
import 'package:mobile_app/features/payments/domain/entities/stripe_account_entity.dart';
import 'package:mobile_app/features/payments/domain/repositories/payment_repository.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDataSource remoteDataSource;

  PaymentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, StripeAccountEntity>> getStripeAccountStatus() async {
    try {
      final result = await remoteDataSource.getStripeAccountStatus();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to get account status'));
    } catch (e) {
      return Left(const ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, String>> createOnboardingLink() async {
    try {
      final result = await remoteDataSource.createOnboardingLink();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to create onboarding link'));
    } catch (e) {
      return Left(const ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, String>> getStripeDashboardLink() async {
    try {
      final result = await remoteDataSource.getStripeDashboardLink();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to get dashboard link'));
    } catch (e) {
      return Left(const ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, List<PayoutEntity>>> getPayoutHistory() async {
    try {
      final result = await remoteDataSource.getPayoutHistory();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to get payout history'));
    } catch (e) {
      return Left(const ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, PayoutEntity>> requestPayout(double amount) async {
    try {
      final result = await remoteDataSource.requestPayout(amount);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to request payout'));
    } catch (e) {
      return Left(const ServerFailure('An unexpected error occurred'));
    }
  }
}














