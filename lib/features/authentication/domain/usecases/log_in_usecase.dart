import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile_app/core/usecase/usecase.dart';
import 'package:mobile_app/features/authentication/data/models/auth_response_model.dart';
import 'package:mobile_app/features/authentication/domain/entities/login_entity.dart';
import 'package:mobile_app/features/authentication/domain/repository/auth_repo.dart';

import '../../../../core/error/failure.dart';

class LogInUsecase extends UseCase<AuthResponseModel, LogInParams> {
  final AuthRepository authRepository;

  LogInUsecase({required this.authRepository});

  @override
  Future<Either<Failure, AuthResponseModel>> call(LogInParams p) async {
    return await authRepository.loginUser(p.logInEntity);
  }
}

class LogInParams extends Equatable {
  final LoginEntity logInEntity;

  const LogInParams({required this.logInEntity});

  @override
  List<Object?> get props => [logInEntity];
}
