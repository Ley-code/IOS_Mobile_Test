import 'package:dartz/dartz.dart';
import 'package:mobile_app/core/error/failure.dart';
import 'package:mobile_app/features/payments/domain/entities/stripe_account_entity.dart';

abstract class PaymentRepository {
  /// Get the current user's Stripe account status
  Future<Either<Failure, StripeAccountEntity>> getStripeAccountStatus();

  /// Create a Stripe Connect onboarding link
  Future<Either<Failure, String>> createOnboardingLink();

  /// Get the Stripe dashboard link for managing account
  Future<Either<Failure, String>> getStripeDashboardLink();

  /// Get payout history
  Future<Either<Failure, List<PayoutEntity>>> getPayoutHistory();

  /// Request a payout
  Future<Either<Failure, PayoutEntity>> requestPayout(double amount);
}
