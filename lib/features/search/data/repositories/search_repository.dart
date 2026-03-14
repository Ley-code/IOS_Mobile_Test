import 'package:dartz/dartz.dart';
import 'package:mobile_app/core/error/failure.dart';
import 'package:mobile_app/features/search/data/data_sources/remote/search_remote_data_source.dart';

abstract class SearchRepository {
  Future<Either<Failure, Map<String, dynamic>>> searchJobs({
    String? searchTerm,
    int page = 1,
    int pageSize = 20,
  });
  Future<Either<Failure, Map<String, dynamic>>> searchFreelancers({
    String? searchTerm,
    int page = 1,
    int pageSize = 20,
  });
  Future<Either<Failure, List<Map<String, dynamic>>>> getAllFreelancers();
}

class SearchRepositoryImpl implements SearchRepository {
  final SearchRemoteDataSource remoteDataSource;

  SearchRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> searchJobs({
    String? searchTerm,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final result = await remoteDataSource.searchJobs(
        searchTerm: searchTerm,
        page: page,
        pageSize: pageSize,
      );
      return Right(result);
    } catch (e) {
      String errorMessage = 'Cannot search jobs.';
      if (e.toString().contains('Network error')) {
        errorMessage = 'Network error. Please check your connection.';
      } else if (e.toString().isNotEmpty) {
        errorMessage = e.toString();
      }
      return Left(ServerFailure(errorMessage));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> searchFreelancers({
    String? searchTerm,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final result = await remoteDataSource.searchFreelancers(
        searchTerm: searchTerm,
        page: page,
        pageSize: pageSize,
      );
      return Right(result);
    } catch (e) {
      String errorMessage = 'Cannot search freelancers.';
      if (e.toString().contains('Network error')) {
        errorMessage = 'Network error. Please check your connection.';
      } else if (e.toString().isNotEmpty) {
        errorMessage = e.toString();
      }
      return Left(ServerFailure(errorMessage));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getAllFreelancers() async {
    try {
      final result = await remoteDataSource.getAllFreelancers();
      return Right(result);
    } catch (e) {
      String errorMessage = 'Cannot fetch freelancers.';
      if (e.toString().contains('Network error')) {
        errorMessage = 'Network error. Please check your connection.';
      } else if (e.toString().isNotEmpty) {
        errorMessage = e.toString();
      }
      return Left(ServerFailure(errorMessage));
    }
  }
}

