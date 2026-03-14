import 'package:equatable/equatable.dart';
import 'package:mobile_app/features/payments/domain/entities/stripe_account_entity.dart';

abstract class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object?> get props => [];
}

class PaymentInitial extends PaymentState {}

class PaymentLoading extends PaymentState {}

class StripeAccountLoaded extends PaymentState {
  final StripeAccountEntity account;
  final List<PayoutEntity> payouts;

  const StripeAccountLoaded({
    required this.account,
    this.payouts = const [],
  });

  @override
  List<Object?> get props => [account, payouts];

  StripeAccountLoaded copyWith({
    StripeAccountEntity? account,
    List<PayoutEntity>? payouts,
  }) {
    return StripeAccountLoaded(
      account: account ?? this.account,
      payouts: payouts ?? this.payouts,
    );
  }
}

class OnboardingLinkGenerated extends PaymentState {
  final String url;

  const OnboardingLinkGenerated(this.url);

  @override
  List<Object?> get props => [url];
}

class DashboardLinkGenerated extends PaymentState {
  final String url;

  const DashboardLinkGenerated(this.url);

  @override
  List<Object?> get props => [url];
}

class PayoutRequested extends PaymentState {
  final PayoutEntity payout;

  const PayoutRequested(this.payout);

  @override
  List<Object?> get props => [payout];
}

class PaymentError extends PaymentState {
  final String message;

  const PaymentError(this.message);

  @override
  List<Object?> get props => [message];
}














