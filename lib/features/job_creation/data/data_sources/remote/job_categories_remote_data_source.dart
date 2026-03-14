import 'dart:convert';
import 'package:mobile_app/core/config/api_config.dart';
import 'package:mobile_app/core/error/exception.dart';
import 'package:mobile_app/core/network/api_client.dart';
import 'package:mobile_app/features/job_creation/data/models/job_category_model.dart';

abstract class JobCategoriesRemoteDataSource {
  Future<List<JobCategoryModel>> getJobCategories();
}

class JobCategoriesRemoteDataSourceImpl
    implements JobCategoriesRemoteDataSource {
  final ApiClient apiClient;

  JobCategoriesRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<JobCategoryModel>> getJobCategories() async {
    try {
      final response = await apiClient.get(
        ApiConfig.jobCategoriesEndpoint,
        requireAuth: false, // Categories endpoint is public
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList =
            jsonDecode(response.body) as List<dynamic>;
        return jsonList
            .map(
              (json) => JobCategoryModel.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      } else {
        final errorBody = response.body;
        String errorMessage = 'Failed to fetch job categories.';
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
}
