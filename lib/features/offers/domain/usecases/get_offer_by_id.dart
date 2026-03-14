import 'package:dartz/dartz.dart';
import 'package:mobile_app/core/error/failure.dart';
import 'package:mobile_app/features/offers/domain/entities/received_offer_entity.dart';
import 'package:mobile_app/features/offers/domain/repositories/offers_repository.dart';

class GetOfferById {
  final OffersRepository repository;

  GetOfferById(this.repository);

  Future<Either<Failure, ReceivedOfferEntity>> call(String offerId) async {
    return await repository.getOfferById(offerId);
  }
}
