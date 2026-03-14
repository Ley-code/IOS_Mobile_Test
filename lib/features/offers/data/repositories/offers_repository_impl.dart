import 'package:dartz/dartz.dart';
import 'package:mobile_app/core/error/failure.dart';
import 'package:mobile_app/core/error/exception.dart';
import 'package:mobile_app/features/offers/data/datasources/offers_remote_data_source.dart';
import 'package:mobile_app/features/offers/domain/entities/received_offer_entity.dart';
import 'package:mobile_app/features/offers/domain/repositories/offers_repository.dart';

class OffersRepositoryImpl implements OffersRepository {
  final OffersRemoteDataSource remoteDataSource;

  OffersRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<ReceivedOfferEntity>>> getOffers() async {
    try {
      final offers = await remoteDataSource.getOffers();
      return Right(offers);
    } catch (e) {
      if (e is ServerException) {
        return Left(ServerFailure(e.message ?? 'Failed to load offers'));
      }
      return Left(const ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, ReceivedOfferEntity>> getOfferById(
    String offerId,
  ) async {
    try {
      final offer = await remoteDataSource.getOfferById(offerId);
      return Right(offer);
    } catch (e) {
      if (e is ServerException) {
        return Left(ServerFailure(e.message ?? 'Failed to load offer'));
      }
      return Left(const ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, void>> acceptOffer({
    required String offerId,
    required String contractTerms,
    required List<String> payoutTypes,
    required Map<String, dynamic> payoutRates,
  }) async {
    try {
      await remoteDataSource.acceptOffer(
        offerId: offerId,
        contractTerms: contractTerms,
        payoutTypes: payoutTypes,
        payoutRates: payoutRates,
      );
      return const Right(null);
    } catch (e) {
      if (e is ServerException) {
        return Left(ServerFailure(e.message ?? 'Failed to accept offer'));
      }
      return Left(const ServerFailure('An unexpected error occurred'));
    }
  }
}
