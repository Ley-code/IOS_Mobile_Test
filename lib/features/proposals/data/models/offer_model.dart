import 'package:mobile_app/features/proposals/domain/entities/offer_entity.dart';

class OfferModel extends OfferEntity {
  const OfferModel({
    required super.proposalId,
    required super.offerMessage,
    required super.payoutRates,
  });

  factory OfferModel.fromEntity(OfferEntity entity) {
    return OfferModel(
      proposalId: entity.proposalId,
      offerMessage: entity.offerMessage,
      payoutRates: entity.payoutRates,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'proposal_id': proposalId,
      'offer_message': offerMessage,
      'payout_rates': payoutRates,
    };
  }
}














