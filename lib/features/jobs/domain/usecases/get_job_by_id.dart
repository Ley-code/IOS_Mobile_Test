import 'package:dartz/dartz.dart';
import 'package:mobile_app/core/error/failure.dart';
import 'package:mobile_app/core/usecase/usecase.dart';
import 'package:mobile_app/features/jobs/domain/entities/job_entity.dart';
import 'package:mobile_app/features/jobs/domain/repositories/jobs_repository.dart';

class GetJobById implements UseCase<JobEntity, String> {
  final JobsRepository repository;

  GetJobById(this.repository);

  @override
  Future<Either<Failure, JobEntity>> call(String jobId) async {
    return await repository.getJobById(jobId);
  }
}
