import 'package:dartz/dartz.dart';
import 'package:mobile_app/core/error/failure.dart';
import 'package:mobile_app/features/offers/domain/repositories/offers_repository.dart';

class AcceptOffer {
  final OffersRepository repository;

  AcceptOffer(this.repository);

  Future<Either<Failure, void>> call({
    required String offerId,
    required String contractTerms,
    required List<String> payoutTypes,
    required Map<String, dynamic> payoutRates,
  }) async {
    return await repository.acceptOffer(
      offerId: offerId,
      contractTerms: contractTerms,
      payoutTypes: payoutTypes,
      payoutRates: payoutRates,
    );
  }
}
