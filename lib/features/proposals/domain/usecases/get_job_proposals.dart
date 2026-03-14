import 'package:dartz/dartz.dart';
import 'package:mobile_app/core/error/failure.dart';
import 'package:mobile_app/core/usecase/usecase.dart';
import 'package:mobile_app/features/proposals/domain/entities/proposal_with_user_entity.dart';
import 'package:mobile_app/features/proposals/domain/repositories/proposals_repository.dart';

class GetJobProposals implements UseCase<List<ProposalWithUserEntity>, String> {
  final ProposalsRepository repository;

  GetJobProposals(this.repository);

  @override
  Future<Either<Failure, List<ProposalWithUserEntity>>> call(String jobId) async {
    return await repository.getJobProposals(jobId);
  }
}














