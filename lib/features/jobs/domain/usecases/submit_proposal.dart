import 'package:dartz/dartz.dart';
import 'package:mobile_app/core/error/failure.dart';
import 'package:mobile_app/core/usecase/usecase.dart';
import 'package:mobile_app/features/jobs/domain/entities/proposal_entity.dart';
import 'package:mobile_app/features/jobs/domain/repositories/jobs_repository.dart';

class SubmitProposal implements UseCase<void, ProposalEntity> {
  final JobsRepository repository;

  SubmitProposal(this.repository);

  @override
  Future<Either<Failure, void>> call(ProposalEntity proposal) async {
    return await repository.submitProposal(proposal);
  }
}













