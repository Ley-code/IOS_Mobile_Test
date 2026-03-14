import 'package:equatable/equatable.dart';

class OfferEntity extends Equatable {
  final String proposalId;
  final String offerMessage;
  final Map<String, dynamic> payoutRates;

  const OfferEntity({
    required this.proposalId,
    required this.offerMessage,
    required this.payoutRates,
  });

  @override
  List<Object?> get props => [proposalId, offerMessage, payoutRates];
}
