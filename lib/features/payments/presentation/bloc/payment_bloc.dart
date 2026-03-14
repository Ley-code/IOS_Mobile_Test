import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/features/payments/domain/repositories/payment_repository.dart';
import 'package:mobile_app/features/payments/presentation/bloc/payment_event.dart';
import 'package:mobile_app/features/payments/presentation/bloc/payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final PaymentRepository repository;
  bool _isLoading = false;

  PaymentBloc({required this.repository}) : super(PaymentInitial()) {
    on<LoadStripeAccountStatus>(_onLoadStripeAccountStatus);
    on<StartStripeOnboarding>(_onStartStripeOnboarding);
    on<OpenStripeDashboard>(_onOpenStripeDashboard);
    on<LoadPayoutHistory>(_onLoadPayoutHistory);
    on<RequestPayout>(_onRequestPayout);
    on<RefreshPaymentData>(_onRefreshPaymentData);
  }

  Future<void> _onLoadStripeAccountStatus(
    LoadStripeAccountStatus event,
    Emitter<PaymentState> emit,
  ) async {
    // Prevent duplicate loads
    if (_isLoading) return;

    _isLoading = true;
    emit(PaymentLoading());

    final result = await repository.getStripeAccountStatus();
    _isLoading = false;

    result.fold(
      (failure) => emit(PaymentError(failure.message)),
      (account) => emit(StripeAccountLoaded(account: account)),
    );
  }

  Future<void> _onStartStripeOnboarding(
    StartStripeOnboarding event,
    Emitter<PaymentState> emit,
  ) async {
    // Don't emit loading - keep current state visible
    final result = await repository.createOnboardingLink();

    result.fold((failure) => emit(PaymentError(failure.message)), (url) {
      if (url.isEmpty) {
        emit(PaymentError('Onboarding URL is empty'));
      } else {
        emit(OnboardingLinkGenerated(url));
      }
    });
  }

  Future<void> _onOpenStripeDashboard(
    OpenStripeDashboard event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentLoading());

    final result = await repository.getStripeDashboardLink();

    result.fold(
      (failure) => emit(PaymentError(failure.message)),
      (url) => emit(DashboardLinkGenerated(url)),
    );
  }

  Future<void> _onLoadPayoutHistory(
    LoadPayoutHistory event,
    Emitter<PaymentState> emit,
  ) async {
    if (state is StripeAccountLoaded) {
      final currentState = state as StripeAccountLoaded;

      final result = await repository.getPayoutHistory();

      result.fold(
        (failure) => emit(PaymentError(failure.message)),
        (payouts) => emit(currentState.copyWith(payouts: payouts)),
      );
    }
  }

  Future<void> _onRequestPayout(
    RequestPayout event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentLoading());

    final result = await repository.requestPayout(event.amount);

    result.fold(
      (failure) => emit(PaymentError(failure.message)),
      (payout) => emit(PayoutRequested(payout)),
    );
  }

  Future<void> _onRefreshPaymentData(
    RefreshPaymentData event,
    Emitter<PaymentState> emit,
  ) async {
    final accountResult = await repository.getStripeAccountStatus();

    await accountResult.fold(
      (failure) async => emit(PaymentError(failure.message)),
      (account) async {
        final payoutsResult = await repository.getPayoutHistory();

        payoutsResult.fold(
          (failure) => emit(StripeAccountLoaded(account: account)),
          (payouts) =>
              emit(StripeAccountLoaded(account: account, payouts: payouts)),
        );
      },
    );
  }
}
