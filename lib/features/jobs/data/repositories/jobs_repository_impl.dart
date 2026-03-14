import 'package:dartz/dartz.dart';
import 'package:mobile_app/core/error/exception.dart';
import 'package:mobile_app/core/error/failure.dart';
import 'package:mobile_app/features/jobs/data/datasources/jobs_remote_data_source.dart';
import 'package:mobile_app/features/jobs/data/models/proposal_model.dart';
import 'package:mobile_app/features/jobs/domain/entities/job_entity.dart';
import 'package:mobile_app/features/jobs/domain/entities/proposal_entity.dart';
import 'package:mobile_app/features/jobs/domain/repositories/jobs_repository.dart';

class JobsRepositoryImpl implements JobsRepository {
  final JobsRemoteDataSource remoteDataSource;

  JobsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<JobEntity>>> getJobs() async {
    try {
      final jobs = await remoteDataSource.getJobs();
      return Right(jobs);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to load jobs'));
    } catch (e) {
      return Left(const ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, JobEntity>> getJobById(String jobId) async {
    try {
      final job = await remoteDataSource.getJobById(jobId);
      return Right(job);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to load job details'));
    } catch (e) {
      return Left(const ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, void>> submitProposal(ProposalEntity proposal) async {
    try {
      final proposalModel = ProposalModel.fromEntity(proposal);
      await remoteDataSource.submitProposal(proposalModel);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to submit proposal'));
    } catch (e) {
      return Left(const ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, List<JobEntity>>> getMyJobs() async {
    try {
      final jobs = await remoteDataSource.getMyJobs();
      return Right(jobs);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to load your jobs'));
    } catch (e) {
      return Left(const ServerFailure('An unexpected error occurred'));
    }
  }
}
