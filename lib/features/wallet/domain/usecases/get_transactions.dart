import 'package:dartz/dartz.dart';
import 'package:mobile_app/core/error/failure.dart';
import 'package:mobile_app/core/usecase/usecase.dart';
import 'package:mobile_app/features/wallet/domain/entities/wallet_entity.dart';
import 'package:mobile_app/features/wallet/domain/repositories/wallet_repository.dart';

class GetTransactions implements UseCase<List<TransactionEntity>, GetTransactionsParams> {
  final WalletRepository repository;

  GetTransactions(this.repository);

  @override
  Future<Either<Failure, List<TransactionEntity>>> call(GetTransactionsParams params) async {
    return await repository.getTransactions(
      limit: params.limit,
      offset: params.offset,
    );
  }
}

class GetTransactionsParams {
  final int? limit;
  final int? offset;

  const GetTransactionsParams({this.limit, this.offset});
}














