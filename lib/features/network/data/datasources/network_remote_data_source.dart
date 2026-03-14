import 'dart:convert';
import 'package:mobile_app/core/error/exception.dart';
import 'package:mobile_app/core/network/api_client.dart';
import 'package:mobile_app/features/network/data/models/network_model.dart';

abstract class NetworkRemoteDataSource {
  Future<void> followUser(String userId);
  Future<void> unfollowUser(String userId);
  Future<List<NetworkUserModel>> getFollowers(String userId);
  Future<List<NetworkUserModel>> getFollowing(String userId);
  Future<NetworkStatsModel> getNetworkStats(String userId);
  Future<FollowStatusModel> checkFollowStatus(String userId);
}

class NetworkRemoteDataSourceImpl implements NetworkRemoteDataSource {
  final ApiClient apiClient;

  NetworkRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<void> followUser(String userId) async {
    try {
      final response = await apiClient.post(
        '/network/follow/$userId',
        {},
        requireAuth: true,
      );

      print('----------------responsefollow user: ${response.body}');

      if (response.statusCode != 200) {
        final errorBody = response.body;
        String errorMessage = 'Failed to follow user.';
        try {
          final errorJson = jsonDecode(errorBody) as Map<String, dynamic>;
          errorMessage = errorJson['error'] as String? ?? 
                        errorJson['message'] as String? ?? 
                        errorMessage;
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
  Future<void> unfollowUser(String userId) async {
    try {
      final response = await apiClient.delete(
        '/network/follow/$userId',
        requireAuth: true,
      );

      if (response.statusCode != 200) {
        final errorBody = response.body;
        String errorMessage = 'Failed to unfollow user.';
        try {
          final errorJson = jsonDecode(errorBody) as Map<String, dynamic>;
          errorMessage = errorJson['error'] as String? ?? 
                        errorJson['message'] as String? ?? 
                        errorMessage;
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
  Future<List<NetworkUserModel>> getFollowers(String userId) async {
    try {
      final response = await apiClient.get(
        '/network/followers/$userId',
        requireAuth: true,
      );

      print('----------------responseget followers: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data
              .map((e) => NetworkUserModel.fromJson(e as Map<String, dynamic>))
              .toList();
        } else if (data is Map && data['followers'] is List) {
          return (data['followers'] as List)
              .map((e) => NetworkUserModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return [];
      } else {
        throw ServerException(message: 'Failed to fetch followers.');
      }
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException(message: 'Network error: ${e.toString()}');
    }
  }

  @override
  Future<List<NetworkUserModel>> getFollowing(String userId) async {
    try {
      final response = await apiClient.get(
        '/network/following/$userId',
        requireAuth: true,
      );

      print('----------------responseget following: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data
              .map((e) => NetworkUserModel.fromJson(e as Map<String, dynamic>))
              .toList();
        } else if (data is Map && data['following'] is List) {
          return (data['following'] as List)
              .map((e) => NetworkUserModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return [];
      } else {
        throw ServerException(message: 'Failed to fetch following.');
      }
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException(message: 'Network error: ${e.toString()}');
    }
  }

  @override
  Future<NetworkStatsModel> getNetworkStats(String userId) async {
    try {
      final response = await apiClient.get(
        '/network/stats/$userId',
        requireAuth: true,
      );

      print('----------------response get network stats: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return NetworkStatsModel.fromJson(data);
      } else {
        throw ServerException(message: 'Failed to fetch network stats.');
      }
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException(message: 'Network error: ${e.toString()}');
    }
  }

  @override
  Future<FollowStatusModel> checkFollowStatus(String userId) async {
    try {
      final response = await apiClient.get(
        '/network/status/$userId',
        requireAuth: true,
      );

      print('----------------responsecheck follow status: ${response.body}');

        if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return FollowStatusModel.fromJson(data);
      } else {
        throw ServerException(message: 'Failed to check follow status.');
      }
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException(message: 'Network error: ${e.toString()}');
    }
  }
}
