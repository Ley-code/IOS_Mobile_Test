import 'package:dartz/dartz.dart';
import 'package:mobile_app/core/error/exception.dart';
import 'package:mobile_app/core/error/failure.dart';
import 'package:mobile_app/features/proposals/data/datasources/proposals_remote_data_source.dart';
import 'package:mobile_app/features/proposals/data/models/offer_model.dart';
import 'package:mobile_app/features/proposals/domain/entities/offer_entity.dart';
import 'package:mobile_app/features/proposals/domain/entities/proposal_with_user_entity.dart';
import 'package:mobile_app/features/proposals/domain/repositories/proposals_repository.dart';

class ProposalsRepositoryImpl implements ProposalsRepository {
  final ProposalsRemoteDataSource remoteDataSource;

  ProposalsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<ProposalWithUserEntity>>> getJobProposals(
      String jobId) async {
    try {
      final proposals = await remoteDataSource.getJobProposals(jobId);
      return Right(proposals);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to load proposals'));
    } catch (e) {
      return Left(const ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, void>> submitOffer(OfferEntity offer) async {
    try {
      final offerModel = OfferModel.fromEntity(offer);
      await remoteDataSource.submitOffer(offerModel);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to submit offer'));
    } catch (e) {
      return Left(const ServerFailure('An unexpected error occurred'));
    }
  }
}














