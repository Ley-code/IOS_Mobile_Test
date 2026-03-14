import 'dart:convert';
import 'package:mobile_app/core/config/api_config.dart';
import 'package:mobile_app/core/error/exception.dart';
import 'package:mobile_app/core/network/api_client.dart';

abstract class SearchRemoteDataSource {
  Future<Map<String, dynamic>> searchJobs({
    String? searchTerm,
    int page = 1,
    int pageSize = 20,
  });
  Future<Map<String, dynamic>> searchFreelancers({
    String? searchTerm,
    int page = 1,
    int pageSize = 20,
  });
  Future<List<Map<String, dynamic>>> getAllFreelancers();
}

class SearchRemoteDataSourceImpl implements SearchRemoteDataSource {
  final ApiClient apiClient;

  SearchRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Map<String, dynamic>> searchJobs({
    String? searchTerm,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final body = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
        if (searchTerm != null && searchTerm.isNotEmpty)
          'search_term': searchTerm,
      };

      final response = await apiClient.post(
        ApiConfig.filterJobsEndpoint,
        body,
        requireAuth: true,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        final errorBody = response.body;
        String errorMessage = 'Failed to search jobs.';
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
  Future<Map<String, dynamic>> searchFreelancers({
    String? searchTerm,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final body = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
        if (searchTerm != null && searchTerm.isNotEmpty)
          'search_term': searchTerm,
      };

      final response = await apiClient.post(
        ApiConfig.filterFreelancersEndpoint,
        body,
        requireAuth: true,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        final errorBody = response.body;
        String errorMessage = 'Failed to search freelancers.';
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
  Future<List<Map<String, dynamic>>> getAllFreelancers() async {
    try {
      final response = await apiClient.get(
        '/freelancers/',
        requireAuth: false, // Public endpoint
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data.map((e) => e as Map<String, dynamic>).toList();
        } else if (data is Map && data['data'] is List) {
          return (data['data'] as List).map((e) => e as Map<String, dynamic>).toList();
        }
        return [];
      } else {
        throw ServerException(message: 'Failed to fetch freelancers.');
      }
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException(message: 'Network error: ${e.toString()}');
    }
  }
}

