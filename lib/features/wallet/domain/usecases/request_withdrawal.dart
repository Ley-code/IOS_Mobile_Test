import 'package:dartz/dartz.dart';
import 'package:mobile_app/core/error/failure.dart';
import 'package:mobile_app/core/usecase/usecase.dart';
import 'package:mobile_app/features/wallet/domain/entities/wallet_entity.dart';
import 'package:mobile_app/features/wallet/domain/repositories/wallet_repository.dart';

class RequestWithdrawal implements UseCase<TransactionEntity, double> {
  final WalletRepository repository;

  RequestWithdrawal(this.repository);

  @override
  Future<Either<Failure, TransactionEntity>> call(double amount) async {
    return await repository.requestWithdrawal(amount);
  }
}













