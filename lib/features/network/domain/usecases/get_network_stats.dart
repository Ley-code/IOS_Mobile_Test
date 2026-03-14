import 'package:dartz/dartz.dart';
import 'package:mobile_app/core/error/failure.dart';
import 'package:mobile_app/features/network/domain/entities/network_entity.dart';
import 'package:mobile_app/features/network/domain/repositories/network_repository.dart';

class GetNetworkStats {
  final NetworkRepository repository;

  GetNetworkStats(this.repository);

  Future<Either<Failure, NetworkStats>> call(String userId) async {
    return await repository.getNetworkStats(userId);
  }
}
