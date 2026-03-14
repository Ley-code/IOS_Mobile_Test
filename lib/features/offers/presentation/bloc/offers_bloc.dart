import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/features/offers/domain/usecases/accept_offer.dart'
    as accept_offer_usecase;
import 'package:mobile_app/features/offers/domain/usecases/get_offer_by_id.dart';
import 'package:mobile_app/features/offers/domain/usecases/get_offers.dart';
import 'package:mobile_app/features/offers/presentation/bloc/offers_event.dart';
import 'package:mobile_app/features/offers/presentation/bloc/offers_state.dart';

class OffersBloc extends Bloc<OffersEvent, OffersState> {
  final GetOffers getOffers;
  final GetOfferById getOfferById;
  final accept_offer_usecase.AcceptOffer acceptOffer;

  OffersBloc({
    required this.getOffers,
    required this.getOfferById,
    required this.acceptOffer,
  }) : super(OffersInitial()) {
    on<LoadOffers>(_onLoadOffers);
    on<RefreshOffers>(_onRefreshOffers);
    on<LoadOfferById>(_onLoadOfferById);
    on<AcceptOffer>(_onAcceptOffer);
  }

  Future<void> _onLoadOffers(
    LoadOffers event,
    Emitter<OffersState> emit,
  ) async {
    emit(OffersLoading());

    final result = await getOffers();

    result.fold(
      (failure) => emit(OffersError(failure.message)),
      (offers) => emit(OffersLoaded(offers)),
    );
  }

  Future<void> _onRefreshOffers(
    RefreshOffers event,
    Emitter<OffersState> emit,
  ) async {
    final result = await getOffers();

    result.fold((failure) => emit(OffersError(failure.message)), (offers) {
      if (state is OffersLoaded) {
        emit(OffersLoaded(offers));
      } else {
        emit(OffersLoaded(offers));
      }
    });
  }

  Future<void> _onLoadOfferById(
    LoadOfferById event,
    Emitter<OffersState> emit,
  ) async {
    emit(OffersLoading());

    final result = await getOfferById(event.offerId);

    result.fold(
      (failure) => emit(OffersError(failure.message)),
      (offer) => emit(OfferDetailLoaded(offer)),
    );
  }

  Future<void> _onAcceptOffer(
    AcceptOffer event,
    Emitter<OffersState> emit,
  ) async {
    emit(OfferAccepting());

    final result = await acceptOffer(
      offerId: event.offerId,
      contractTerms: event.contractTerms,
      payoutTypes: event.payoutTypes,
      payoutRates: event.payoutRates,
    );

    result.fold((failure) => emit(OffersError(failure.message)), (_) {
      emit(const OfferAccepted('Offer accepted successfully'));
      // Refresh offers list to remove the accepted offer
      // This will be handled by the UI layer listening to OfferAccepted state
    });
  }
}
