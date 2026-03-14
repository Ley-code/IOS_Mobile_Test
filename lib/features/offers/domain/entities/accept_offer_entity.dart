import 'package:equatable/equatable.dart';

class AcceptOfferEntity extends Equatable {
  final String offerId;
  final String contractTerms;
  final List<String> payoutTypes;
  final Map<String, dynamic> payoutRates;

  const AcceptOfferEntity({
    required this.offerId,
    required this.contractTerms,
    required this.payoutTypes,
    required this.payoutRates,
  });

  @override
  List<Object?> get props => [offerId, contractTerms, payoutTypes, payoutRates];
}

