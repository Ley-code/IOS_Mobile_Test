import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_app/core/config/api_config.dart';
import 'package:mobile_app/core/error/exception.dart';
import 'package:mobile_app/core/storage/token_storage.dart';
import 'package:mobile_app/features/payments/data/models/stripe_account_model.dart';

abstract class PaymentRemoteDataSource {
  Future<StripeAccountModel> getStripeAccountStatus();
  Future<String> createOnboardingLink();
  Future<String> getStripeDashboardLink();
  Future<List<PayoutModel>> getPayoutHistory();
  Future<PayoutModel> requestPayout(double amount);
}

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final http.Client client;
  final TokenStorage tokenStorage;

  PaymentRemoteDataSourceImpl({
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
  Future<StripeAccountModel> getStripeAccountStatus() async {
    final headers = await _getHeaders();
    final url = Uri.parse(ApiConfig.buildUrl('/payments/stripe/account'));

    final response = await client.get(url, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return StripeAccountModel.fromJson(data);
    } else if (response.statusCode == 404) {
      // No account connected yet
      return const StripeAccountModel();
    } else {
      throw ServerException(message: 'Failed to get Stripe account status');
    }
  }

  @override
  Future<String> createOnboardingLink() async {
    final headers = await _getHeaders();
    final url = Uri.parse(ApiConfig.buildUrl('/payments/stripe/onboard-user'));

    final response = await client.post(url, headers: headers);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      // Response format: {"message": "url for stripe onboarding", "url": "https://..."}
      final onboardingUrl =
          data['url'] as String? ?? data['onboarding_url'] as String?;

      if (onboardingUrl == null || onboardingUrl.isEmpty) {
        throw ServerException(message: 'Onboarding URL not found in response');
      }

      return onboardingUrl;
    } else {
      String errorMessage = 'Failed to create onboarding link';
      try {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        errorMessage =
            errorData['message'] as String? ??
            errorData['error'] as String? ??
            errorMessage;
      } catch (_) {
        // Use default error message if parsing fails
      }
      throw ServerException(message: errorMessage);
    }
  }

  @override
  Future<String> getStripeDashboardLink() async {
    final headers = await _getHeaders();
    final url = Uri.parse(ApiConfig.buildUrl('/payments/stripe/dashboard'));

    final response = await client.get(url, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['url'] as String? ?? data['dashboard_url'] as String? ?? '';
    } else {
      throw ServerException(message: 'Failed to get dashboard link');
    }
  }

  @override
  Future<List<PayoutModel>> getPayoutHistory() async {
    final headers = await _getHeaders();
    final url = Uri.parse(ApiConfig.buildUrl('/payments/payouts'));

    final response = await client.get(url, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<dynamic> payouts = [];

      if (data is List) {
        payouts = data;
      } else if (data is Map && data['data'] is List) {
        payouts = data['data'] as List;
      } else if (data is Map && data['payouts'] is List) {
        payouts = data['payouts'] as List;
      }

      return payouts
          .map((e) => PayoutModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw ServerException(message: 'Failed to get payout history');
    }
  }

  @override
  Future<PayoutModel> requestPayout(double amount) async {
    final headers = await _getHeaders();
    final url = Uri.parse(ApiConfig.buildUrl('/payments/payouts'));

    final response = await client.post(
      url,
      headers: headers,
      body: jsonEncode({'amount': amount}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return PayoutModel.fromJson(data);
    } else {
      String message = 'Failed to request payout';
      try {
        final errorData = jsonDecode(response.body);
        if (errorData['message'] != null) {
          message = errorData['message'] as String;
        }
      } catch (_) {}
      throw ServerException(message: message);
    }
  }
}
