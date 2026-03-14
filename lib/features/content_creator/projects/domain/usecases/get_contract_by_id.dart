import 'package:dartz/dartz.dart';
import 'package:mobile_app/core/error/failure.dart';
import 'package:mobile_app/core/usecase/usecase.dart';
import 'package:mobile_app/features/content_creator/projects/domain/entities/contract_entity.dart';
import 'package:mobile_app/features/content_creator/projects/domain/repositories/contract_repository.dart';

class GetContractById implements UseCase<ContractEntity, String> {
  final ContractRepository repository;

  GetContractById(this.repository);

  @override
  Future<Either<Failure, ContractEntity>> call(String contractId) async {
    return await repository.getContractById(contractId);
  }
}





