import 'package:dartz/dartz.dart';
import 'package:mobile_app/core/error/failure.dart';
import 'package:mobile_app/features/jobs/domain/entities/job_entity.dart';
import 'package:mobile_app/features/jobs/domain/entities/proposal_entity.dart';

abstract class JobsRepository {
  /// Get all available jobs
  Future<Either<Failure, List<JobEntity>>> getJobs();

  /// Get a specific job by ID
  Future<Either<Failure, JobEntity>> getJobById(String jobId);

  /// Submit a proposal for a job
  Future<Either<Failure, void>> submitProposal(ProposalEntity proposal);

  /// Get jobs created by the current user (for business owners)
  Future<Either<Failure, List<JobEntity>>> getMyJobs();
}
