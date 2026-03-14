import 'package:equatable/equatable.dart';

class OfferReceivedEntity extends Equatable {
  final String offerId;
  final String proposalId;
  final String? offerStatusId;
  final String offerMessage;
  final Map<String, dynamic> payoutRates;
  final List<dynamic>? deliverables;
  final DateTime createdAt;
  final DateTime updatedAt;

  const OfferReceivedEntity({
    required this.offerId,
    required this.proposalId,
    this.offerStatusId,
    required this.offerMessage,
    required this.payoutRates,
    this.deliverables,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        offerId,
        proposalId,
        offerStatusId,
        offerMessage,
        payoutRates,
        deliverables,
        createdAt,
        updatedAt,
      ];
}

