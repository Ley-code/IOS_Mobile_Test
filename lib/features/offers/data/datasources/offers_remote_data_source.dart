import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_app/core/config/api_config.dart';
import 'package:mobile_app/core/error/exception.dart';
import 'package:mobile_app/core/storage/token_storage.dart';
import 'package:mobile_app/features/offers/data/models/received_offer_model.dart';

abstract class OffersRemoteDataSource {
  Future<List<ReceivedOfferModel>> getOffers();
  Future<ReceivedOfferModel> getOfferById(String offerId);
  Future<void> acceptOffer({
    required String offerId,
    required String contractTerms,
    required List<String> payoutTypes,
    required Map<String, dynamic> payoutRates,
  });
}

class OffersRemoteDataSourceImpl implements OffersRemoteDataSource {
  final http.Client client;
  final TokenStorage tokenStorage;

  OffersRemoteDataSourceImpl({
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
  Future<List<ReceivedOfferModel>> getOffers() async {
    final headers = await _getHeaders();
    final url = Uri.parse(ApiConfig.buildUrl('/offers'));

    final response = await client.get(url, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<dynamic> offers = [];

      if (data is List) {
        offers = data;
      } else if (data is Map && data['data'] is List) {
        offers = data['data'] as List;
      } else if (data is Map && data['offers'] is List) {
        offers = data['offers'] as List;
      }

      return offers
          .map(
            (json) => ReceivedOfferModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } else {
      String errorMessage = 'Failed to load offers';
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
  Future<ReceivedOfferModel> getOfferById(String offerId) async {
    final headers = await _getHeaders();
    final url = Uri.parse(ApiConfig.buildUrl('/offers/$offerId'));

    final response = await client.get(url, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ReceivedOfferModel.fromJson(data as Map<String, dynamic>);
    } else {
      String errorMessage = 'Failed to load offer';
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
  Future<void> acceptOffer({
    required String offerId,
    required String contractTerms,
    required List<String> payoutTypes,
    required Map<String, dynamic> payoutRates,
  }) async {
    final headers = await _getHeaders();
    final url = Uri.parse(ApiConfig.buildUrl('/contracts'));

    final body = jsonEncode({
      'offer_id': offerId,
      'contract_terms': contractTerms,
      'payout_types': payoutTypes,
      'payout_rates': payoutRates,
    });

    final response = await client.post(url, headers: headers, body: body);

    if (response.statusCode != 200 && response.statusCode != 201) {
      String errorMessage = 'Failed to accept offer';
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
