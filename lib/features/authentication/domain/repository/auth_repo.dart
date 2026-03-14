import 'package:mobile_app/features/authentication/domain/entities/login_entity.dart';
import 'package:mobile_app/features/authentication/domain/entities/business_sign_up_entity.dart';
import 'package:mobile_app/features/authentication/domain/entities/freelancer_sign_up_entity.dart';
import 'package:mobile_app/features/authentication/domain/entities/instagram_profile.dart';
import 'package:dartz/dartz.dart';
import 'package:mobile_app/core/error/failure.dart';
import 'package:mobile_app/features/authentication/data/models/auth_response_model.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthResponseModel>> registerBusinessOwner(
    BusinessSignupEntity businessSignupEntity,
  );
  Future<Either<Failure, AuthResponseModel>> registerFreelancer(
    FreelancerSignupEntity freelancerSignupEntity,
  );
  Future<Either<Failure, AuthResponseModel>> loginUser(LoginEntity loginEntity);
  Future<Either<Failure, void>> connectInstagram(String code, String state);

  /// Exchange session ID for Instagram profile
  Future<Either<Failure, InstagramProfile>> consumeInstagramSession(
    String sessionId,
  );

  /// Finalize Instagram session by exchanging session_id for connection
  Future<Either<Failure, void>> finalizeInstagramSession(String sessionId);
}
