import 'package:dartz/dartz.dart';
import 'package:mobile_app/core/error/failure.dart';
import 'package:mobile_app/core/usecase/usecase.dart';
import 'package:mobile_app/features/wallet/domain/repositories/wallet_repository.dart';

class CreateDepositPaymentIntentParams {
  final double amount;
  final String currency;

  const CreateDepositPaymentIntentParams({
    required this.amount,
    this.currency = 'usd',
  });
}

class CreateDepositPaymentIntent implements UseCase<String, CreateDepositPaymentIntentParams> {
  final WalletRepository repository;

  CreateDepositPaymentIntent(this.repository);

  @override
  Future<Either<Failure, String>> call(CreateDepositPaymentIntentParams params) async {
    return await repository.createDepositPaymentIntent(params.amount, params.currency);
  }
}














