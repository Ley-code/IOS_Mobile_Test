import 'package:mobile_app/features/offers/domain/entities/offer_received_entity.dart';

class OfferReceivedModel extends OfferReceivedEntity {
  const OfferReceivedModel({
    required super.offerId,
    required super.proposalId,
    super.offerStatusId,
    required super.offerMessage,
    required super.payoutRates,
    super.deliverables,
    required super.createdAt,
    required super.updatedAt,
  });

  factory OfferReceivedModel.fromJson(Map<String, dynamic> json) {
    return OfferReceivedModel(
      offerId: json['offer_id'] as String,
      proposalId: json['proposal_id'] as String,
      offerStatusId: json['offer_status_id'] as String?,
      offerMessage: json['offer_message'] as String? ?? '',
      payoutRates: json['payout_rates'] as Map<String, dynamic>,
      deliverables: json['deliverables'] as List<dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'offer_id': offerId,
      'proposal_id': proposalId,
      'offer_status_id': offerStatusId,
      'offer_message': offerMessage,
      'payout_rates': payoutRates,
      'deliverables': deliverables,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

