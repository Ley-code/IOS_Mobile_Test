import 'package:dartz/dartz.dart';
import 'package:mobile_app/core/error/failure.dart';
import 'package:mobile_app/core/usecase/usecase.dart';
import 'package:mobile_app/features/proposals/domain/entities/offer_entity.dart';
import 'package:mobile_app/features/proposals/domain/repositories/proposals_repository.dart';

class SubmitOffer implements UseCase<void, OfferEntity> {
  final ProposalsRepository repository;

  SubmitOffer(this.repository);

  @override
  Future<Either<Failure, void>> call(OfferEntity offer) async {
    return await repository.submitOffer(offer);
  }
}














