import 'package:mobile_app/features/offers/domain/entities/accept_offer_entity.dart';

class AcceptOfferModel extends AcceptOfferEntity {
  const AcceptOfferModel({
    required super.offerId,
    required super.contractTerms,
    required super.payoutTypes,
    required super.payoutRates,
  });

  factory AcceptOfferModel.fromEntity(AcceptOfferEntity entity) {
    return AcceptOfferModel(
      offerId: entity.offerId,
      contractTerms: entity.contractTerms,
      payoutTypes: entity.payoutTypes,
      payoutRates: entity.payoutRates,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'offer_id': offerId,
      'contract_terms': contractTerms,
      'payout_types': payoutTypes,
      'payout_rates': payoutRates,
    };
  }
}

