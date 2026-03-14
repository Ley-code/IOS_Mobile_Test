import 'package:dartz/dartz.dart';
import 'package:mobile_app/core/error/exception.dart';
import 'package:mobile_app/core/error/failure.dart';
import 'package:mobile_app/features/content_creator/projects/data/datasources/contract_remote_data_source.dart';
import 'package:mobile_app/features/content_creator/projects/domain/entities/contract_entity.dart';
import 'package:mobile_app/features/content_creator/projects/domain/repositories/contract_repository.dart';

class ContractRepositoryImpl implements ContractRepository {
  final ContractRemoteDataSource remoteDataSource;

  ContractRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<ContractEntity>>> getMyContracts({
    bool activeOnly = false,
  }) async {
    try {
      final remoteData = await remoteDataSource.getMyContracts(activeOnly: activeOnly);
      return Right(remoteData);
    } on ServerException {
      return Left(ServerFailure('Failed to get contracts'));
    } catch (e) {
      return Left(ServerFailure('Failed to get contracts: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ContractEntity>> getContractById(String contractId) async {
    try {
      final remoteData = await remoteDataSource.getContractById(contractId);
      return Right(remoteData);
    } on ServerException {
      return Left(ServerFailure('Failed to get contract'));
    } catch (e) {
      return Left(ServerFailure('Failed to get contract: ${e.toString()}'));
    }
  }
}





