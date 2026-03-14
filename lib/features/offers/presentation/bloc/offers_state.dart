import 'package:equatable/equatable.dart';
import 'package:mobile_app/features/offers/domain/entities/received_offer_entity.dart';

abstract class OffersState extends Equatable {
  const OffersState();

  @override
  List<Object?> get props => [];
}

class OffersInitial extends OffersState {}

class OffersLoading extends OffersState {}

class OffersLoaded extends OffersState {
  final List<ReceivedOfferEntity> offers;

  const OffersLoaded(this.offers);

  @override
  List<Object?> get props => [offers];
}

class OfferDetailLoaded extends OffersState {
  final ReceivedOfferEntity offer;

  const OfferDetailLoaded(this.offer);

  @override
  List<Object?> get props => [offer];
}

class OfferAccepting extends OffersState {}

class OfferAccepted extends OffersState {
  final String message;

  const OfferAccepted(this.message);

  @override
  List<Object?> get props => [message];
}

class OffersError extends OffersState {
  final String message;

  const OffersError(this.message);

  @override
  List<Object?> get props => [message];
}
