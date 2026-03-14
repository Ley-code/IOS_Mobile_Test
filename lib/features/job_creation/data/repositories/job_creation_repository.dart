import 'package:dartz/dartz.dart';
import 'package:mobile_app/core/error/failure.dart';
import 'package:mobile_app/features/job_creation/data/data_sources/remote/job_creation_remote_data_source.dart';
import 'package:mobile_app/features/job_creation/data/models/create_job_model.dart';

abstract class JobCreationRepository {
  Future<Either<Failure, Map<String, dynamic>>> createJob(CreateJobModel jobModel);
}

class JobCreationRepositoryImpl implements JobCreationRepository {
  final JobCreationRemoteDataSource remoteDataSource;

  JobCreationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> createJob(CreateJobModel jobModel) async {
    try {
      final result = await remoteDataSource.createJob(jobModel);
      return Right(result);
    } catch (e) {
      String errorMessage = 'Cannot create job.';
      if (e.toString().contains('Network error')) {
        errorMessage = 'Network error. Please check your connection.';
      } else if (e.toString().isNotEmpty) {
        errorMessage = e.toString();
      }
      return Left(ServerFailure(errorMessage));
    }
  }
}

