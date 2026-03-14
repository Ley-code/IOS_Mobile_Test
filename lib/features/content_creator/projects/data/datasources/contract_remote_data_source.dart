import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_app/core/config/api_config.dart';
import 'package:mobile_app/core/error/exception.dart';
import 'package:mobile_app/core/storage/token_storage.dart';
import 'package:mobile_app/features/content_creator/projects/data/models/contract_model.dart';

abstract class ContractRemoteDataSource {
  Future<List<ContractModel>> getMyContracts({bool activeOnly = false});
  Future<ContractModel> getContractById(String contractId);
}

class ContractRemoteDataSourceImpl implements ContractRemoteDataSource {
  final http.Client client;
  final TokenStorage tokenStorage;

  ContractRemoteDataSourceImpl({
    required this.client,
    required this.tokenStorage,
  });

  @override
  Future<List<ContractModel>> getMyContracts({bool activeOnly = false}) async {
    final token = await tokenStorage.getToken();
    if (token == null) {
      throw ServerException();
    }

    final queryParam = activeOnly ? '?active=true' : '';
    final url = Uri.parse(
      '${ApiConfig.buildUrl(ApiConfig.myContractsEndpoint)}$queryParam',
    );

    final response = await client.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final list = (data is List) ? data : (data['data'] is List ? data['data'] : []);
      return (list as List)
          .map((e) => ContractModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw ServerException();
    }
  }

  @override
  Future<ContractModel> getContractById(String contractId) async {
    final token = await tokenStorage.getToken();
    if (token == null) {
      throw ServerException();
    }

    final url = Uri.parse(
      '${ApiConfig.buildUrl(ApiConfig.contractByIdEndpoint)}/$contractId',
    );

    final response = await client.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ContractModel.fromJson(data as Map<String, dynamic>);
    } else {
      throw ServerException();
    }
  }
}





