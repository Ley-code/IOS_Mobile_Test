import 'package:dartz/dartz.dart';
import 'package:mobile_app/core/storage/token_storage.dart';
import 'package:mobile_app/features/authentication/data/data_sources/remote/auth_remote_data_source.dart';
import 'package:mobile_app/features/authentication/data/models/auth_response_model.dart';
import 'package:mobile_app/features/authentication/data/models/mapper.dart';
import 'package:mobile_app/features/authentication/domain/entities/business_sign_up_entity.dart';
import 'package:mobile_app/features/authentication/domain/entities/freelancer_sign_up_entity.dart';
import 'package:mobile_app/features/authentication/domain/entities/instagram_profile.dart';
import 'package:mobile_app/features/authentication/data/models/freelancer_sign_up_model.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/exception.dart';
import '../../domain/entities/login_entity.dart';
import '../../domain/repository/auth_repo.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource authRemoteDataSource;
  final TokenStorage tokenStorage;

  AuthRepositoryImpl({
    required this.authRemoteDataSource,
    required this.tokenStorage,
  });

  @override
  Future<Either<Failure, AuthResponseModel>> loginUser(
    LoginEntity loginEntity,
  ) async {
    try {
      final response = await authRemoteDataSource.logIn(
        loginEntity.toProductModel(),
      );

      // Store token and user data
      await tokenStorage.saveToken(response.token);
      await tokenStorage.saveUserRole(response.user.role);
      await tokenStorage.saveUserId(response.user.id);

      return Right(response);
    } catch (e) {
      String errorMessage = 'Cannot login. Please check your credentials.';
      if (e is ServerException && e.message != null && e.message!.isNotEmpty) {
        errorMessage = e.message!;
      } else if (e.toString().contains('Network error')) {
        errorMessage = 'Network error. Please check your connection.';
      } else if (e.toString().isNotEmpty) {
        errorMessage = e.toString();
      }
      return Left(ServerFailure(errorMessage));
    }
  }

  @override
  Future<Either<Failure, AuthResponseModel>> registerBusinessOwner(
    BusinessSignupEntity businessSignupEntity,
  ) async {
    try {
      final response = await authRemoteDataSource.registerBusinessOwner(
        businessSignupEntity.toBusinessSignUpModel(),
      );

      // Store token and user data
      await tokenStorage.saveToken(response.token);
      await tokenStorage.saveUserRole(response.user.role);
      await tokenStorage.saveUserId(response.user.id);

      return Right(response);
    } catch (e) {
      String errorMessage = 'Cannot register business owner.';
      if (e is ServerException && e.message != null && e.message!.isNotEmpty) {
        errorMessage = e.message!;
      } else if (e.toString().contains('Network error')) {
        errorMessage = 'Network error. Please check your connection.';
      } else if (e.toString().isNotEmpty) {
        errorMessage = e.toString();
      }
      return Left(ServerFailure(errorMessage));
    }
  }

  @override
  Future<Either<Failure, AuthResponseModel>> registerFreelancer(
    FreelancerSignupEntity freelancerSignupEntity,
  ) async {
    try {
      final response = await authRemoteDataSource.registerFreelancer(
        FreelancerSignUpModel.fromEntity(freelancerSignupEntity),
      );

      // Store token and user data
      await tokenStorage.saveToken(response.token);
      await tokenStorage.saveUserRole(response.user.role);
      await tokenStorage.saveUserId(response.user.id);

      return Right(response);
    } catch (e) {
      String errorMessage = 'Cannot register freelancer.';
      if (e is ServerException && e.message != null && e.message!.isNotEmpty) {
        errorMessage = e.message!;
      } else if (e.toString().contains('Network error')) {
        errorMessage = 'Network error. Please check your connection.';
      } else if (e.toString().isNotEmpty) {
        errorMessage = e.toString();
      }
      return Left(ServerFailure(errorMessage));
    }
  }

  @override
  Future<Either<Failure, void>> connectInstagram(
    String code,
    String state,
  ) async {
    try {
      await authRemoteDataSource.connectInstagram(code, state);
      return const Right(null);
    } catch (e) {
      String errorMessage = 'Cannot connect Instagram.';
      if (e is ServerException && e.message != null && e.message!.isNotEmpty) {
        errorMessage = e.message!;
      } else if (e.toString().contains('Network error')) {
        errorMessage = 'Network error. Please check your connection.';
      } else if (e.toString().isNotEmpty) {
        errorMessage = e.toString();
      }
      return Left(ServerFailure(errorMessage));
    }
  }

  @override
  Future<Either<Failure, InstagramProfile>> consumeInstagramSession(
    String sessionId,
  ) async {
    try {
      final profile = await authRemoteDataSource.consumeInstagramSession(
        sessionId,
      );
      return Right(profile);
    } catch (e) {
      String errorMessage = 'Cannot verify session.';
      if (e is ServerException && e.message != null && e.message!.isNotEmpty) {
        errorMessage = e.message!;
      } else if (e.toString().contains('Network error')) {
        errorMessage = 'Network error. Please check your connection.';
      } else if (e.toString().isNotEmpty) {
        errorMessage = e.toString();
      }
      return Left(ServerFailure(errorMessage));
    }
  }

  @override
  Future<Either<Failure, void>> finalizeInstagramSession(
    String sessionId,
  ) async {
    try {
      await authRemoteDataSource.finalizeInstagramSession(sessionId);
      return const Right(null);
    } catch (e) {
      String errorMessage = 'Cannot finalize Instagram connection.';
      if (e is ServerException && e.message != null && e.message!.isNotEmpty) {
        errorMessage = e.message!;
      } else if (e.toString().contains('Network error')) {
        errorMessage = 'Network error. Please check your connection.';
      } else if (e.toString().isNotEmpty) {
        errorMessage = e.toString();
      }
      return Left(ServerFailure(errorMessage));
    }
  }
}
