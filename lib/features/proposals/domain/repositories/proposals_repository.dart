import 'package:dartz/dartz.dart';
import 'package:mobile_app/core/error/failure.dart';
import 'package:mobile_app/features/proposals/domain/entities/offer_entity.dart';
import 'package:mobile_app/features/proposals/domain/entities/proposal_with_user_entity.dart';

abstract class ProposalsRepository {
  /// Get all proposals for a specific job
  Future<Either<Failure, List<ProposalWithUserEntity>>> getJobProposals(
      String jobId);

  /// Submit an offer for a proposal
  Future<Either<Failure, void>> submitOffer(OfferEntity offer);
}














