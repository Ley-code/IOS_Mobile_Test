import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_app/core/config/api_config.dart';
import 'package:mobile_app/core/error/exception.dart';
import 'package:mobile_app/core/storage/token_storage.dart';
import 'package:mobile_app/features/proposals/data/models/offer_model.dart';
import 'package:mobile_app/features/proposals/data/models/proposal_with_user_model.dart';

abstract class ProposalsRemoteDataSource {
  Future<List<ProposalWithUserModel>> getJobProposals(String jobId);
  Future<void> submitOffer(OfferModel offer);
}

class ProposalsRemoteDataSourceImpl implements ProposalsRemoteDataSource {
  final http.Client client;
  final TokenStorage tokenStorage;

  ProposalsRemoteDataSourceImpl({
    required this.client,
    required this.tokenStorage,
  });

  Future<Map<String, String>> _getHeaders() async {
    final token = await tokenStorage.getToken();
    if (token == null) {
      throw ServerException(message: 'Not authenticated');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<List<ProposalWithUserModel>> getJobProposals(String jobId) async {
    final headers = await _getHeaders();
    final url = Uri.parse(ApiConfig.buildUrl('/jobs/$jobId/proposals'));

    final response = await client.get(url, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<dynamic> proposals = [];

      if (data is List) {
        proposals = data;
      } else if (data is Map && data['data'] is List) {
        proposals = data['data'] as List;
      } else if (data is Map && data['proposals'] is List) {
        proposals = data['proposals'] as List;
      }

      return proposals
          .map((json) => ProposalWithUserModel.fromJson(
              json as Map<String, dynamic>))
          .toList();
    } else {
      throw ServerException(message: 'Failed to load proposals');
    }
  }

  @override
  Future<void> submitOffer(OfferModel offer) async {
    final headers = await _getHeaders();
    final url = Uri.parse(ApiConfig.buildUrl('/offers'));

    final response = await client.post(
      url,
      headers: headers,
      body: jsonEncode(offer.toJson()),
    );
    print("-------------------------------------${response.body}");

    if (response.statusCode != 200 && response.statusCode != 201) {
      String errorMessage = 'Failed to submit offer';
      try {
        final errorData = jsonDecode(response.body);
        if (errorData['message'] != null) {
          errorMessage = errorData['message'] as String;
        }
      } catch (_) {}
      throw ServerException(message: errorMessage);
    }
  }
}














