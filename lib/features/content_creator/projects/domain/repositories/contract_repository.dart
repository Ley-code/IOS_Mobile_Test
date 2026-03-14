import 'package:dartz/dartz.dart';
import 'package:mobile_app/core/error/failure.dart';
import 'package:mobile_app/features/content_creator/projects/domain/entities/contract_entity.dart';

abstract class ContractRepository {
  Future<Either<Failure, List<ContractEntity>>> getMyContracts({
    bool activeOnly = false,
  });
  
  Future<Either<Failure, ContractEntity>> getContractById(String contractId);
}





