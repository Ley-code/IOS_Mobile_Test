import 'dart:convert';
import 'package:mobile_app/core/config/api_config.dart';
import 'package:mobile_app/core/error/exception.dart';
import 'package:mobile_app/core/network/api_client.dart';
import 'package:mobile_app/features/job_creation/data/models/create_job_model.dart';

abstract class JobCreationRemoteDataSource {
  Future<Map<String, dynamic>> createJob(CreateJobModel jobModel);
}

class JobCreationRemoteDataSourceImpl implements JobCreationRemoteDataSource {
  final ApiClient apiClient;

  JobCreationRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Map<String, dynamic>> createJob(CreateJobModel jobModel) async {
    try {
      final response = await apiClient.post(
        ApiConfig.createJobEndpoint,
        jobModel.toJson(),
        requireAuth: true,
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        final errorBody = response.body;
        String errorMessage = 'Failed to create job.';
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
