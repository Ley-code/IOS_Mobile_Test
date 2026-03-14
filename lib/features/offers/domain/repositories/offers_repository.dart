import 'package:dartz/dartz.dart';
import 'package:mobile_app/core/error/failure.dart';
import 'package:mobile_app/features/offers/domain/entities/received_offer_entity.dart';

abstract class OffersRepository {
  Future<Either<Failure, List<ReceivedOfferEntity>>> getOffers();
  Future<Either<Failure, ReceivedOfferEntity>> getOfferById(String offerId);
  Future<Either<Failure, void>> acceptOffer({
    required String offerId,
    required String contractTerms,
    required List<String> payoutTypes,
    required Map<String, dynamic> payoutRates,
  });
}
