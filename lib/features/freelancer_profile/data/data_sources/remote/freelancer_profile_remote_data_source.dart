import 'dart:convert';
import 'package:mobile_app/core/error/exception.dart';
import 'package:mobile_app/core/network/api_client.dart';

abstract class FreelancerProfileRemoteDataSource {
  Future<Map<String, dynamic>> getFreelancerProfile(String freelancerId);
  Future<List<Map<String, dynamic>>> getFreelancerContracts(String freelancerId);
  Future<List<Map<String, dynamic>>> getFreelancerRatings(String userId);
  Future<List<Map<String, dynamic>>> getFreelancerPortfolios({
    required String freelancerId,
    String? type,
    int page = 1,
    int pageSize = 10,
  });
}

class FreelancerProfileRemoteDataSourceImpl
    implements FreelancerProfileRemoteDataSource {
  final ApiClient apiClient;

  FreelancerProfileRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Map<String, dynamic>> getFreelancerProfile(
    String freelancerId,
  ) async {
    try {
      final response = await apiClient.get(
        '/freelancers/$freelancerId',
        requireAuth: true,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        final errorBody = response.body;
        String errorMessage = 'Failed to fetch freelancer profile.';
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
  Future<List<Map<String, dynamic>>> getFreelancerContracts(
    String freelancerId,
  ) async {
    try {
      final response = await apiClient.get(
        '/contracts/freelancer/$freelancerId',
        requireAuth: true,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data.map((e) => e as Map<String, dynamic>).toList();
        }
        return [];
      } else {
        throw ServerException(message: 'Failed to fetch contracts.');
      }
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException(message: 'Network error: ${e.toString()}');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getFreelancerRatings(
    String userId,
  ) async {
    try {
      final response = await apiClient.get(
        '/ratings/user/$userId',
        requireAuth: true,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data.map((e) => e as Map<String, dynamic>).toList();
        }
        return [];
      } else {
        throw ServerException(message: 'Failed to fetch ratings.');
      }
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException(message: 'Network error: ${e.toString()}');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getFreelancerPortfolios({
    required String freelancerId,
    String? type,
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      String endpoint = '/freelancers/$freelancerId/portfolios?page=$page&page_size=$pageSize';
      if (type != null && type.isNotEmpty && type != 'all') {
        endpoint += '&type=$type';
      }

      final response = await apiClient.get(
        endpoint,
        requireAuth: true,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data['portfolios'] is List) {
          return (data['portfolios'] as List)
              .map((e) => e as Map<String, dynamic>)
              .toList();
        } else if (data is List) {
          return data.map((e) => e as Map<String, dynamic>).toList();
        }
        return [];
      } else {
        throw ServerException(message: 'Failed to fetch portfolios.');
      }
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException(message: 'Network error: ${e.toString()}');
    }
  }
}
