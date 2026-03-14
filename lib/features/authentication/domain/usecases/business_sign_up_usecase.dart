import 'package:mobile_app/core/usecase/usecase.dart';
import 'package:mobile_app/features/authentication/data/models/auth_response_model.dart';
import 'package:mobile_app/features/authentication/domain/repository/auth_repo.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile_app/core/error/failure.dart';
import 'package:mobile_app/features/authentication/domain/entities/business_sign_up_entity.dart';

class BusinessSignUpUseCase
    extends UseCase<AuthResponseModel, BusinessSignupParams> {
  final AuthRepository authRepository;

  BusinessSignUpUseCase({required this.authRepository});
  @override
  Future<Either<Failure, AuthResponseModel>> call(BusinessSignupParams params) {
    return authRepository.registerBusinessOwner(params.businessSignupEntity);
  }
}

class BusinessSignupParams extends Equatable {
  final BusinessSignupEntity businessSignupEntity;

  const BusinessSignupParams({required this.businessSignupEntity});

  @override
  List<Object?> get props => [businessSignupEntity];
}
