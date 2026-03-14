import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_app/core/config/api_config.dart';
import 'package:mobile_app/core/error/exception.dart';
import 'package:mobile_app/core/storage/token_storage.dart';
import 'package:mobile_app/features/wallet/data/models/wallet_model.dart';

abstract class WalletRemoteDataSource {
  Future<WalletModel> getWalletBalance();
  Future<List<TransactionModel>> getTransactions({int? limit, int? offset});
  Future<TransactionModel> requestWithdrawal(double amount);
  Future<String> createDepositPaymentIntent(double amount, String currency);
}

class WalletRemoteDataSourceImpl implements WalletRemoteDataSource {
  final http.Client client;
  final TokenStorage tokenStorage;

  WalletRemoteDataSourceImpl({
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
  Future<WalletModel> getWalletBalance() async {
    final headers = await _getHeaders();
    final url = Uri.parse(ApiConfig.buildUrl('/wallet/balance'));

    final response = await client.get(url, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return WalletModel.fromJson(data);
    } else {
      throw ServerException(message: 'Failed to load wallet balance');
    }
  }

  @override
  Future<List<TransactionModel>> getTransactions({
    int? limit,
    int? offset,
  }) async {
    final headers = await _getHeaders();
    final queryParams = <String, String>{};
    if (limit != null) queryParams['limit'] = limit.toString();
    if (offset != null) queryParams['offset'] = offset.toString();

    final url = Uri.parse(ApiConfig.buildUrl('/wallet/transactions'))
        .replace(queryParameters: queryParams);

    final response = await client.get(url, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<dynamic> transactions = [];

      if (data is List) {
        transactions = data;
      } else if (data is Map && data['data'] is List) {
        transactions = data['data'] as List;
      } else if (data is Map && data['transactions'] is List) {
        transactions = data['transactions'] as List;
      }

      return transactions
          .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw ServerException(message: 'Failed to load transactions');
    }
  }

  @override
  Future<TransactionModel> requestWithdrawal(double amount) async {
    final headers = await _getHeaders();
    final url = Uri.parse(ApiConfig.buildUrl('/wallet/withdraw'));

    final response = await client.post(
      url,
      headers: headers,
      body: jsonEncode({'amount': amount}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return TransactionModel.fromJson(data);
    } else {
      String message = 'Failed to request withdrawal';
      try {
        final errorData = jsonDecode(response.body);
        if (errorData['message'] != null) {
          message = errorData['message'] as String;
        }
      } catch (_) {}
      throw ServerException(message: message);
    }
  }

  @override
  Future<String> createDepositPaymentIntent(double amount, String currency) async {
    final headers = await _getHeaders();
    final url = Uri.parse(ApiConfig.buildUrl(ApiConfig.depositEndpoint));

    final response = await client.post(
      url,
      headers: headers,
      body: jsonEncode({
        'amount': amount,
        'currency': currency,
        'metadata': {
          'source': 'mobile_app',
          'timestamp': DateTime.now().toIso8601String(),
        },
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      // Backend returns: {"message": "...", "payment_intent": "pi_xxx_secret_xxx", "client_secret": "pi_xxx_secret_xxx"}
      final paymentIntent = data['client_secret'] as String? ?? 
                           data['payment_intent'] as String?;
      if (paymentIntent == null || paymentIntent.isEmpty) {
        throw ServerException(message: 'Payment intent not received from server');
      }
      return paymentIntent;
    } else {
      String message = 'Failed to create payment intent';
      try {
        final errorData = jsonDecode(response.body);
        if (errorData['message'] != null) {
          message = errorData['message'] as String;
        } else if (errorData['error'] != null) {
          message = errorData['error'] as String;
        }
      } catch (_) {}
      throw ServerException(message: message);
    }
  }
}














