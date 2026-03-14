import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mobile_app/core/config/api_config.dart';
import 'package:mobile_app/core/error/exception.dart';
import 'package:mobile_app/core/storage/token_storage.dart';
import 'package:mobile_app/features/content_creator/dashboard/data/models/portfolio_item_model.dart';
import 'package:mobile_app/features/business_owner/dashboard/data/models/user_profile_model.dart';
import 'package:mobile_app/features/business_owner/dashboard/data/models/update_profile_params.dart';

abstract class InfluencerRemoteDataSource {
  Future<List<PortfolioItemModel>> getPortfolioItems();
  Future<void> addPortfolioItem(PortfolioItemModel item, {File? coverImage});
  Future<UserProfileModel> getUserProfile();
  Future<String> uploadProfilePicture(File imageFile);
  Future<void> deleteProfilePicture();
  Future<void> updateFreelancerProfile(UpdateFreelancerParams params);
  Future<void> updatePortfolioItem(PortfolioItemModel item);
  Future<void> deletePortfolioItem(String portfolioId);
  Future<int> getProfileCompletionPercentage();
}

class InfluencerRemoteDataSourceImpl implements InfluencerRemoteDataSource {
  final http.Client client;
  final TokenStorage tokenStorage;

  InfluencerRemoteDataSourceImpl({
    required this.client,
    required this.tokenStorage,
  });

  // Helper method to get and cache freelancer_id
  Future<String?> _getFreelancerId() async {
    // Try to get from cache first
    String? freelancerId = await tokenStorage.getFreelancerId();
    if (freelancerId != null && freelancerId.isNotEmpty) {
      return freelancerId;
    }

    // If not cached, fetch from API
    final token = await tokenStorage.getToken();
    if (token == null) {
      throw ServerException();
    }

    // Try /freelancers/me/ first
    final profileUrl = Uri.parse(
      '${ApiConfig.buildUrl(ApiConfig.freelancerMeEndpoint)}/',
    );
    final profileResponse = await client.get(
      profileUrl,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (profileResponse.statusCode == 200) {
      final profileData = jsonDecode(profileResponse.body);
      freelancerId = profileData['freelancer_id'] as String?;

      if (freelancerId != null && freelancerId.isNotEmpty) {
        // Cache it for future use
        await tokenStorage.saveFreelancerId(freelancerId);
        return freelancerId;
      }
    }

    // Fallback to /users/profile
    final userProfileUrl = Uri.parse(
      ApiConfig.buildUrl(ApiConfig.userProfileEndpoint),
    );
    final userProfileResponse = await client.get(
      userProfileUrl,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (userProfileResponse.statusCode == 200) {
      final userProfileData = jsonDecode(userProfileResponse.body);
      freelancerId = userProfileData['freelancer']?['freelancer_id'] as String?;

      if (freelancerId != null && freelancerId.isNotEmpty) {
        // Cache it for future use
        await tokenStorage.saveFreelancerId(freelancerId);
        return freelancerId;
      }
    }

    return null;
  }

  @override
  Future<List<PortfolioItemModel>> getPortfolioItems() async {
    final token = await tokenStorage.getToken();
    if (token == null) {
      throw ServerException();
    }

    // Get freelancer_id (from cache or API)
    final freelancerId = await _getFreelancerId();

    if (freelancerId == null) {
      return []; // No freelancer profile found
    }

    // Get portfolios for this freelancer
    final portfoliosUrl = Uri.parse(
      '${ApiConfig.buildUrl('/freelancers')}/$freelancerId/portfolios',
    );

    final response = await client.get(
      portfoliosUrl,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Handle new response structure: {portfolios: [...], pagination: {...}}
      List<dynamic> portfoliosList = [];
      if (data is Map<String, dynamic>) {
        if (data['portfolios'] is List) {
          portfoliosList = data['portfolios'] as List;
        } else if (data['data'] is List) {
          portfoliosList = data['data'] as List;
        }
      } else if (data is List) {
        portfoliosList = data;
      }

      // Map backend portfolio structure to frontend model
      return portfoliosList.map((e) {
        final portfolioData = e as Map<String, dynamic>;
        final id = portfolioData['portfolio_id'] as String?;
        final title = portfolioData['portfolio_title'] as String? ?? '';
        final description =
            portfolioData['portfolio_description'] as String? ?? '';
        final type = portfolioData['portfolio_type'] as String? ?? 'image';
        final thumbnailUrl = portfolioData['thumbnail_url'] as String?;

        // Capitalize first letter of type for display
        final displayType = type.isNotEmpty
            ? type[0].toUpperCase() + type.substring(1)
            : 'Image';

        return PortfolioItemModel(
          id: id,
          title: title.isNotEmpty
              ? title
              : (description.isNotEmpty
                    ? (description.length > 50
                          ? '${description.substring(0, 50)}...'
                          : description)
                    : 'Portfolio Item'),
          description: description,
          type: displayType == 'Image'
              ? 'Images'
              : (displayType == 'Video' ? 'Videos' : 'Audios'),
          link: thumbnailUrl,
        );
      }).toList();
    } else {
      throw ServerException();
    }
  }

  @override
  Future<void> addPortfolioItem(
    PortfolioItemModel item, {
    File? coverImage,
  }) async {
    final token = await tokenStorage.getToken();

    if (token == null) {
      throw ServerException();
    }

    // Get freelancer_id (from cache or API) - needed for URL and request body
    final freelancerId = await _getFreelancerId();
    if (freelancerId == null) {
      throw ServerException();
    }

    // Create portfolio using /freelancers/me/portfolios endpoint
    final url = Uri.parse(
      ApiConfig.buildUrl(ApiConfig.freelancerMePortfoliosEndpoint),
    );

    // Map to backend format
    final requestBody = {
      'freelancer_id': freelancerId,
      'portfolio_title': item.title,
      'portfolio_description': item.description,
      'portfolio_type': item.type.toLowerCase(), // 'image', 'video', 'audio'
      'thumbnail_url': '', // Will be set after upload
    };

    final response = await client.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      String errorMessage = 'Failed to create portfolio';
      try {
        final errorData = jsonDecode(response.body);
        if (errorData['message'] != null) {
          errorMessage = errorData['message'] as String;
        }
      } catch (_) {}
      throw ServerException(message: errorMessage);
    }

    // Parse response to get portfolio_id
    final responseData = jsonDecode(response.body) as Map<String, dynamic>;
    final portfolioId =
        responseData['portfolio_id'] as String? ??
        responseData['portfolio']?['portfolio_id'] as String?;

    if (portfolioId == null) {
      throw ServerException(
        message: 'Failed to get portfolio ID from response',
      );
    }

    // If cover image is provided, upload it
    if (coverImage != null) {
      await _uploadThumbnail(portfolioId, coverImage, token);
    }
  }

  Future<void> _uploadThumbnail(
    String portfolioId,
    File imageFile,
    String token,
  ) async {
    final url = Uri.parse(
      '${ApiConfig.buildUrl('/upload/portfolios')}/$portfolioId/thumbnail',
    );

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

    if (response.statusCode != 200 && response.statusCode != 201) {
      String errorMessage = 'Failed to upload thumbnail';
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
  Future<UserProfileModel> getUserProfile() async {
    final token = await tokenStorage.getToken();
    if (token == null) {
      throw ServerException();
    }

    final url = Uri.parse(ApiConfig.buildUrl(ApiConfig.userProfileEndpoint));
    final response = await client.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      return UserProfileModel.fromJson(jsonResponse);
    } else {
      throw ServerException();
    }
  }

  @override
  Future<String> uploadProfilePicture(File imageFile) async {
    final token = await tokenStorage.getToken();
    if (token == null) {
      throw ServerException();
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
      throw ServerException();
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
  Future<void> updateFreelancerProfile(UpdateFreelancerParams params) async {
    final token = await tokenStorage.getToken();
    if (token == null) {
      throw ServerException();
    }

    final url = Uri.parse(
      ApiConfig.buildUrl(ApiConfig.updateFreelancerProfileEndpoint),
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
      String errorMessage = 'Failed to update freelancer profile';
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
  Future<void> updatePortfolioItem(PortfolioItemModel item) async {
    final token = await tokenStorage.getToken();
    if (token == null) {
      throw ServerException();
    }

    final url = Uri.parse(
      '${ApiConfig.buildUrl(ApiConfig.freelancerMeEndpoint)}/portfolios/${item.id}',
    );

    final requestBody = item.toJson();
    print(
      "-----------------------update request body: ${jsonEncode(requestBody)}",
    );

    final response = await client.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(requestBody),
    );

    print("-----------------------update response: ${response.body}");

    if (response.statusCode != 200) {
      throw ServerException();
    }
  }

  @override
  Future<void> deletePortfolioItem(String portfolioId) async {
    final token = await tokenStorage.getToken();
    if (token == null) {
      throw ServerException();
    }

    final url = Uri.parse(
      '${ApiConfig.buildUrl(ApiConfig.freelancerMeEndpoint)}/portfolios/$portfolioId',
    );

    final response = await client.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw ServerException();
    }
  }

  @override
  Future<int> getProfileCompletionPercentage() async {
    final token = await tokenStorage.getToken();
    if (token == null) {
      throw ServerException();
    }

    final url = Uri.parse(
      '${ApiConfig.buildUrl(ApiConfig.profileCompletionEndpoint)}?role=freelancer',
    );

    final response = await client.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      return jsonResponse['percentage'] as int;
    } else {
      throw ServerException();
    }
  }
}
