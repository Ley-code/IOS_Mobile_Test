import 'package:mobile_app/core/error/exception.dart';
import 'package:mobile_app/core/network/api_client.dart';
import 'package:mobile_app/core/config/api_config.dart';
import 'package:mobile_app/core/storage/token_storage.dart';
import 'package:mobile_app/features/business_owner/dashboard/data/models/job_model.dart';
import 'package:mobile_app/features/business_owner/dashboard/data/models/user_profile_model.dart';
import 'package:mobile_app/features/business_owner/dashboard/data/models/update_profile_params.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

abstract class DashboardRemoteDataSource {
  Future<UserProfileModel> getUserProfile();
  Future<List<JobModel>> getClientJobs();
  Future<String> uploadProfilePicture(File imageFile);
  Future<void> deleteProfilePicture();
  Future<void> updateClientProfile(UpdateClientParams params);
  Future<int> getProfileCompletionPercentage();
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final ApiClient apiClient;
  final TokenStorage tokenStorage;
  final http.Client client;

  DashboardRemoteDataSourceImpl({
    required this.apiClient,
    required this.tokenStorage,
    required this.client,
  });

  @override
  Future<UserProfileModel> getUserProfile() async {
    try {
      final response = await apiClient.get(
        ApiConfig.userProfileEndpoint,
        requireAuth: true,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        return UserProfileModel.fromJson(jsonResponse);
      } else {
        final errorBody = response.body;
        String errorMessage = 'Failed to fetch user profile.';

        try {
          final errorJson = jsonDecode(errorBody) as Map<String, dynamic>;
          errorMessage = errorJson['message'] as String? ?? errorMessage;
        } catch (_) {
          if (errorBody.isNotEmpty) {
            errorMessage = errorBody;
          }
        }

        throw ServerException(message: errorMessage);
      }
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException(message: 'Network error: ${e.toString()}');
    }
  }

  @override
  Future<List<JobModel>> getClientJobs() async {
    try {
      final response = await apiClient.get(
        ApiConfig.clientJobsEndpoint,
        requireAuth: true,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as List<dynamic>;
        return jsonResponse
            .map((job) => JobModel.fromJson(job as Map<String, dynamic>))
            .toList();
      } else {
        final errorBody = response.body;
        String errorMessage = 'Failed to fetch client jobs.';

        try {
          final errorJson = jsonDecode(errorBody) as Map<String, dynamic>;
          errorMessage = errorJson['message'] as String? ?? errorMessage;
        } catch (_) {
          if (errorBody.isNotEmpty) {
            errorMessage = errorBody;
          }
        }

        throw ServerException(message: errorMessage);
      }
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException(message: 'Network error: ${e.toString()}');
    }
  }

  @override
  Future<String> uploadProfilePicture(File imageFile) async {
    final token = await tokenStorage.getToken();
    if (token == null) {
      throw ServerException(message: 'Not authenticated');
    }

    final url = Uri.parse(ApiConfig.buildUrl('/upload/profile-picture'));

    // Create multipart request
    final request = http.MultipartRequest('PUT', url);
    request.headers['Authorization'] = 'Bearer $token';

    // Add file to request
    final fileStream = http.ByteStream(imageFile.openRead());
    final fileLength = await imageFile.length();
    final multipartFile = http.MultipartFile(
      'file',
      fileStream,
      fileLength,
      filename: imageFile.path.split('/').last,
    );
    request.files.add(multipartFile);

    // Send request
    final streamedResponse = await client.send(request);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      final profilePictureUrl = responseData['profile_picture_url'] as String?;
      if (profilePictureUrl != null) {
        return profilePictureUrl;
      }
      throw ServerException(
        message: 'Failed to get profile picture URL from response',
      );
    } else {
      String errorMessage = 'Failed to upload profile picture';
      try {
        final errorData = jsonDecode(response.body);
        if (errorData['message'] != null) {
          errorMessage = errorData['message'] as String;
        }
      } catch (_) {}
      throw ServerException(message: errorMessage);
    }
  }

  @override
  Future<void> deleteProfilePicture() async {
    final token = await tokenStorage.getToken();
    if (token == null) {
      throw ServerException(message: 'Not authenticated');
    }

    final url = Uri.parse(ApiConfig.buildUrl('/upload/profile-picture'));

    final response = await client.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      String errorMessage = 'Failed to delete profile picture';
      try {
        final errorData = jsonDecode(response.body);
        if (errorData['message'] != null) {
          errorMessage = errorData['message'] as String;
        }
      } catch (_) {}
      throw ServerException(message: errorMessage);
    }
  }

  @override
  Future<void> updateClientProfile(UpdateClientParams params) async {
    final token = await tokenStorage.getToken();
    if (token == null) {
      throw ServerException(message: 'Not authenticated');
    }

    final url = Uri.parse(
      ApiConfig.buildUrl(ApiConfig.updateClientProfileEndpoint),
    );

    final response = await client.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(params.toJson()),
    );
    print("-----------------------update response: ${response.body}");
    if (response.statusCode != 200) {
      String errorMessage = 'Failed to update client profile';
      try {
        final errorData = jsonDecode(response.body);
        if (errorData['message'] != null) {
          errorMessage = errorData['message'] as String;
        }
      } catch (_) {}
      throw ServerException(message: errorMessage);
    }
  }

  @override
  Future<int> getProfileCompletionPercentage() async {
    try {
      final response = await apiClient.get(
        '${ApiConfig.profileCompletionEndpoint}?role=client',
        requireAuth: true,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        return jsonResponse['percentage'] as int;
      } else {
        throw ServerException(message: 'Failed to get profile completion');
      }
    } catch (e) {
      throw ServerException(message: 'Failed to get profile completion');
    }
  }
}
