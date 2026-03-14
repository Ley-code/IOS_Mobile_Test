import 'dart:convert';
import 'package:mobile_app/core/config/api_config.dart';
import 'package:mobile_app/core/error/exception.dart';
import 'package:mobile_app/core/network/api_client.dart';
import 'package:mobile_app/features/authentication/data/data_sources/remote/auth_remote_data_source.dart';
import 'package:mobile_app/features/authentication/data/models/auth_response_model.dart';
import 'package:mobile_app/features/authentication/data/models/log_in_model.dart';
import 'package:mobile_app/features/authentication/data/models/sign_up_model.dart';
import 'package:mobile_app/features/authentication/data/models/freelancer_sign_up_model.dart';
import 'package:mobile_app/features/authentication/data/models/instagram_profile_model.dart';

/// Implementation of [AuthRemoteDataSource] that communicates with the backend API.
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<AuthResponseModel> logIn(LogInModel logInModel) async {
    return _executeAuthRequest(
      endpoint: ApiConfig.loginEndpoint,
      body: logInModel.toJson(),
      successStatusCode: 200,
      errorMessage: 'Login failed. Please check your credentials.',
    );
  }

  @override
  Future<AuthResponseModel> registerBusinessOwner(
    BusinessSignUpModel businessSignupModel,
  ) async {
    return _executeAuthRequest(
      endpoint: ApiConfig.signupEndpoint,
      body: businessSignupModel.toJson(),
      successStatusCode: 201,
      errorMessage: 'Business registration failed.',
    );
  }

  @override
  Future<AuthResponseModel> registerFreelancer(
    FreelancerSignUpModel freelancerSignUpModel,
  ) async {
    return _executeAuthRequest(
      endpoint: ApiConfig.signupEndpoint,
      body: freelancerSignUpModel.toJson(),
      successStatusCode: 201,
      errorMessage: 'Freelancer registration failed.',
    );
  }

  @override
  Future<void> connectInstagram(String code, String state) async {
    try {
      final response = await apiClient.post(
        ApiConfig.instagramCallbackEndpoint,
        {'code': code, 'state': state},
        requireAuth: true,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return; // Success
      }

      // Handle error responses
      final errorMessage = _extractErrorMessage(
        response.body,
        'Failed to connect Instagram account.',
      );
      throw ServerException(message: errorMessage);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: 'Network error while connecting Instagram: ${e.toString()}',
      );
    }
  }

  /// Executes an authentication request and returns the parsed response.
  ///
  /// This method handles common error cases and response parsing for
  /// login and registration endpoints.
  Future<AuthResponseModel> _executeAuthRequest({
    required String endpoint,
    required Map<String, dynamic> body,
    required int successStatusCode,
    required String errorMessage,
  }) async {
    try {
      final response = await apiClient.post(endpoint, body, requireAuth: false);
      print("-------------------------------------$endpoint");
      print("-------------------------------------${response.body}");

      if (response.statusCode == successStatusCode) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        return AuthResponseModel.fromJson(jsonResponse);
      }

      final extractedMessage = _extractErrorMessage(
        response.body,
        errorMessage,
      );
      throw ServerException(message: extractedMessage);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Network error: ${e.toString()}');
    }
  }

  @override
  Future<InstagramProfileModel> consumeInstagramSession(String code) async {
    try {
      // 1. Exchange code for connection
      final response = await apiClient.post('/instagram/callback', {
        'code': code,
        'state': 'mobile_app_auth',
      }, requireAuth: true);

      print("-------------------------------------${response.body}");
      if (response.statusCode != 200 && response.statusCode != 201) {
        final errorMessage = _extractErrorMessage(
          response.body,
          'Failed to connect Instagram account.',
        );
        throw ServerException(message: errorMessage);
      }

      // 2. Fetch updated profile to get the Instagram details
      final profileResponse = await apiClient.get(
        '/freelancers/me/',
        requireAuth: true,
      );

      if (profileResponse.statusCode == 200) {
        final jsonResponse =
            jsonDecode(profileResponse.body) as Map<String, dynamic>;

        // Find Instagram account in social_accounts list
        final socialAccounts =
            jsonResponse['social_accounts'] as List<dynamic>?;
        if (socialAccounts != null) {
          final instagramAccount = socialAccounts.firstWhere(
            (acc) => acc['platform_name'] == 'Instagram',
            orElse: () => null,
          );

          if (instagramAccount != null) {
            return InstagramProfileModel(
              username: instagramAccount['username'] ?? '',
              followersCount: instagramAccount['follower_count'] ?? 0,
              profilePictureUrl: instagramAccount['profile_picture_url'] ?? '',
              instagramId: instagramAccount['platform_user_id'] ?? '',
            );
          }
        }

        // Fallback if not found immediately (shouldn't happen if connected)
        return const InstagramProfileModel(
          username: 'Connected',
          followersCount: 0,
          profilePictureUrl: '',
          instagramId: '',
        );
      }

      throw ServerException(message: 'Failed to fetch updated profile.');
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: 'Network error while verifying session: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> finalizeInstagramSession(String sessionId) async {
    try {
      final response = await apiClient.post(
        ApiConfig.instagramFinalizeEndpoint,
        {'session_id': sessionId},
        requireAuth: true,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return; // Success
      }

      // Handle error responses
      final errorMessage = _extractErrorMessage(
        response.body,
        'Failed to finalize Instagram connection.',
      );
      throw ServerException(message: errorMessage);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: 'Network error while finalizing Instagram: ${e.toString()}',
      );
    }
  }

  /// Extracts a user-friendly error message from the API response body.
  String _extractErrorMessage(String responseBody, String fallbackMessage) {
    if (responseBody.isEmpty) {
      return fallbackMessage;
    }

    try {
      final errorJson = jsonDecode(responseBody) as Map<String, dynamic>;

      // Try common error message field names (check capital M first for backend format)
      return errorJson['Message'] as String? ??
          errorJson['message'] as String? ??
          errorJson['error'] as String? ??
          errorJson['error_description'] as String? ??
          fallbackMessage;
    } catch (_) {
      // If JSON parsing fails, return the raw body if it's short enough
      return responseBody.length <= 200 ? responseBody : fallbackMessage;
    }
  }
}
