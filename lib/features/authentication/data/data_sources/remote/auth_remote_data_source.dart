import 'package:mobile_app/features/authentication/data/models/auth_response_model.dart';
import 'package:mobile_app/features/authentication/data/models/log_in_model.dart';
import 'package:mobile_app/features/authentication/data/models/sign_up_model.dart';
import 'package:mobile_app/features/authentication/data/models/freelancer_sign_up_model.dart';
import 'package:mobile_app/features/authentication/data/models/instagram_profile_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> logIn(LogInModel logInModel);
  Future<AuthResponseModel> registerBusinessOwner(
    BusinessSignUpModel businessSignupModel,
  );

  Future<AuthResponseModel> registerFreelancer(
    FreelancerSignUpModel freelancerSignUpModel,
  );

  Future<void> connectInstagram(String code, String state);

  /// Consume an Instagram session code to get profile info
  Future<InstagramProfileModel> consumeInstagramSession(String sessionId);

  /// Finalize Instagram session by exchanging session_id for connection
  Future<void> finalizeInstagramSession(String sessionId);
}
