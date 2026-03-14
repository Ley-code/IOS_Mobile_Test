import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_app/core/config/api_config.dart';
import 'package:mobile_app/core/error/exception.dart';
import 'package:mobile_app/core/storage/token_storage.dart';
import 'package:mobile_app/features/jobs/data/models/job_model.dart';
import 'package:mobile_app/features/jobs/data/models/proposal_model.dart';

abstract class JobsRemoteDataSource {
  Future<List<JobModel>> getJobs();
  Future<JobModel> getJobById(String jobId);
  Future<void> submitProposal(ProposalModel proposal);
  Future<List<JobModel>> getMyJobs();
}

class JobsRemoteDataSourceImpl implements JobsRemoteDataSource {
  final http.Client client;
  final TokenStorage tokenStorage;

  JobsRemoteDataSourceImpl({required this.client, required this.tokenStorage});

  Future<Map<String, String>> _getHeaders({bool requireAuth = true}) async {
    final headers = <String, String>{'Content-Type': 'application/json'};

    if (requireAuth) {
      final token = await tokenStorage.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  @override
  Future<List<JobModel>> getJobs() async {
    final url = Uri.parse(ApiConfig.buildUrl('/jobs'));
    final headers = await _getHeaders(requireAuth: false);

    final response = await client.get(url, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is List) {
        return data
            .map((json) => JobModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else if (data is Map && data['data'] is List) {
        return (data['data'] as List)
            .map((json) => JobModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      return [];
    } else {
      throw ServerException(message: 'Failed to load jobs');
    }
  }

  @override
  Future<JobModel> getJobById(String jobId) async {
    final url = Uri.parse(ApiConfig.buildUrl('/jobs/$jobId'));
    final headers = await _getHeaders(requireAuth: false);

    final response = await client.get(url, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return JobModel.fromJson(data);
    } else {
      throw ServerException(message: 'Failed to load job details');
    }
  }

  @override
  Future<void> submitProposal(ProposalModel proposal) async {
    final url = Uri.parse(ApiConfig.buildUrl('/proposals'));
    final headers = await _getHeaders();

    final response = await client.post(
      url,
      headers: headers,
      body: jsonEncode(proposal.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      String errorMessage = 'Failed to submit proposal';
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
  Future<List<JobModel>> getMyJobs() async {
    final url = Uri.parse(ApiConfig.buildUrl(ApiConfig.clientJobsEndpoint));
    final headers = await _getHeaders();

    final response = await client.get(url, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is List) {
        return data
            .map((json) => JobModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else if (data is Map && data['data'] is List) {
        return (data['data'] as List)
            .map((json) => JobModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else if (data is Map && data['jobs'] is List) {
        return (data['jobs'] as List)
            .map((json) => JobModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      return [];
    } else {
      throw ServerException(message: 'Failed to load your jobs');
    }
  }
}
