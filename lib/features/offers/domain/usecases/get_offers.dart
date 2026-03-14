import 'package:dartz/dartz.dart';
import 'package:mobile_app/core/error/failure.dart';
import 'package:mobile_app/features/offers/domain/entities/received_offer_entity.dart';
import 'package:mobile_app/features/offers/domain/repositories/offers_repository.dart';

class GetOffers {
  final OffersRepository repository;

  GetOffers(this.repository);

  Future<Either<Failure, List<ReceivedOfferEntity>>> call() async {
    return await repository.getOffers();
  }
}
