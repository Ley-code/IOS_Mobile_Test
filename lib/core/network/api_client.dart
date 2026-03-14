import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_app/core/config/api_config.dart';
import 'package:mobile_app/core/storage/token_storage.dart';

class ApiClient {
  final http.Client _client;
  final TokenStorage _tokenStorage;

  ApiClient({required http.Client client, required TokenStorage tokenStorage})
    : _client = client,
      _tokenStorage = tokenStorage;

  // Get headers with authentication token
  Future<Map<String, String>> _getHeaders({bool includeAuth = true}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuth) {
      final token = await _tokenStorage.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // GET request
  Future<http.Response> get(String endpoint, {bool requireAuth = true}) async {
    final url = ApiConfig.buildUrl(endpoint);
    final headers = await _getHeaders(includeAuth: requireAuth);

    try {
      final response = await _client.get(Uri.parse(url), headers: headers);
      return response;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // POST request
  Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool requireAuth = false,
  }) async {
    final url = ApiConfig.buildUrl(endpoint);
    final headers = await _getHeaders(includeAuth: requireAuth);

    try {
      final response = await _client.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );
      return response;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // PUT request
  Future<http.Response> put(
    String endpoint,
    Map<String, dynamic> body, {
    bool requireAuth = true,
  }) async {
    final url = ApiConfig.buildUrl(endpoint);
    final headers = await _getHeaders(includeAuth: requireAuth);

    try {
      final response = await _client.put(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );
      return response;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // DELETE request
  Future<http.Response> delete(
    String endpoint, {
    bool requireAuth = true,
  }) async {
    final url = ApiConfig.buildUrl(endpoint);
    final headers = await _getHeaders(includeAuth: requireAuth);

    try {
      final response = await _client.delete(Uri.parse(url), headers: headers);
      return response;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
