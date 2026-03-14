import 'package:equatable/equatable.dart';

abstract class OffersEvent extends Equatable {
  const OffersEvent();

  @override
  List<Object?> get props => [];
}

class LoadOffers extends OffersEvent {
  const LoadOffers();
}

class RefreshOffers extends OffersEvent {
  const RefreshOffers();
}

class LoadOfferById extends OffersEvent {
  final String offerId;

  const LoadOfferById(this.offerId);

  @override
  List<Object?> get props => [offerId];
}

class AcceptOffer extends OffersEvent {
  final String offerId;
  final String contractTerms;
  final List<String> payoutTypes;
  final Map<String, dynamic> payoutRates;

  const AcceptOffer({
    required this.offerId,
    required this.contractTerms,
    required this.payoutTypes,
    required this.payoutRates,
  });

  @override
  List<Object?> get props => [offerId, contractTerms, payoutTypes, payoutRates];
}
