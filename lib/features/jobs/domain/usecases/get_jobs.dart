import 'package:dartz/dartz.dart';
import 'package:mobile_app/core/error/failure.dart';
import 'package:mobile_app/core/usecase/usecase.dart';
import 'package:mobile_app/features/jobs/domain/entities/job_entity.dart';
import 'package:mobile_app/features/jobs/domain/repositories/jobs_repository.dart';

class GetJobs implements UseCase<List<JobEntity>, NoParams> {
  final JobsRepository repository;

  GetJobs(this.repository);

  @override
  Future<Either<Failure, List<JobEntity>>> call(NoParams params) async {
    return await repository.getJobs();
  }
}













