import 'package:dartz/dartz.dart';
import 'package:mobile_app/core/error/failure.dart';
import 'package:mobile_app/core/usecase/usecase.dart';
import 'package:mobile_app/features/content_creator/projects/domain/entities/contract_entity.dart';
import 'package:mobile_app/features/content_creator/projects/domain/repositories/contract_repository.dart';

class GetMyContracts implements UseCase<List<ContractEntity>, GetMyContractsParams> {
  final ContractRepository repository;

  GetMyContracts(this.repository);

  @override
  Future<Either<Failure, List<ContractEntity>>> call(GetMyContractsParams params) async {
    return await repository.getMyContracts(activeOnly: params.activeOnly);
  }
}

class GetMyContractsParams {
  final bool activeOnly;

  GetMyContractsParams({this.activeOnly = false});
}









