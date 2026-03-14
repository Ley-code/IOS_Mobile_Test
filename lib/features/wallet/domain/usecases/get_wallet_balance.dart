import 'package:dartz/dartz.dart';
import 'package:mobile_app/core/error/failure.dart';
import 'package:mobile_app/core/usecase/usecase.dart';
import 'package:mobile_app/features/wallet/domain/entities/wallet_entity.dart';
import 'package:mobile_app/features/wallet/domain/repositories/wallet_repository.dart';

class GetWalletBalance implements UseCase<WalletEntity, NoParams> {
  final WalletRepository repository;

  GetWalletBalance(this.repository);

  @override
  Future<Either<Failure, WalletEntity>> call(NoParams params) async {
    return await repository.getWalletBalance();
  }
}














