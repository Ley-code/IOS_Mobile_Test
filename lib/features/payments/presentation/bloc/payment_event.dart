import 'package:equatable/equatable.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object?> get props => [];
}

class LoadStripeAccountStatus extends PaymentEvent {
  const LoadStripeAccountStatus();
}

class StartStripeOnboarding extends PaymentEvent {
  const StartStripeOnboarding();
}

class OpenStripeDashboard extends PaymentEvent {
  const OpenStripeDashboard();
}

class LoadPayoutHistory extends PaymentEvent {
  const LoadPayoutHistory();
}

class RequestPayout extends PaymentEvent {
  final double amount;

  const RequestPayout(this.amount);

  @override
  List<Object?> get props => [amount];
}

class RefreshPaymentData extends PaymentEvent {
  const RefreshPaymentData();
}














