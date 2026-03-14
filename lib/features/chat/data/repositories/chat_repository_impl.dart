import 'package:dartz/dartz.dart';
import 'package:mobile_app/core/error/exception.dart';
import 'package:mobile_app/core/error/failure.dart';
import 'package:mobile_app/features/chat/data/datasources/chat_local_data_source.dart';
import 'package:mobile_app/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:mobile_app/features/chat/data/models/conversation_model.dart';
import 'package:mobile_app/features/chat/data/models/participant_profile_model.dart';
import 'package:mobile_app/features/chat/domain/entities/conversation.dart';
import 'package:mobile_app/features/chat/domain/entities/participant_profile.dart';
import 'package:mobile_app/features/chat/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;
  final ChatLocalDataSource localDataSource;

  ChatRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  Conversation _toEntity(ConversationModel model) {
    return Conversation(
      id: model.id,
      clientId: model.clientId,
      freelancerId: model.freelancerId,
      jobId: model.jobId,
      proposalId: model.proposalId,
      rocketChatRoomId: model.rocketChatRoomId,
      rocketChatRoomName: model.rocketChatRoomName,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      lastMessageAt: model.lastMessageAt,
    );
  }

  @override
  Future<Either<Failure, Conversation>> createOrGetConversation({
    required String clientId,
    required String freelancerId,
    String? jobId,
    String? proposalId,
  }) async {
    try {
      final model = await remoteDataSource.createOrGetConversation(
        clientId: clientId,
        freelancerId: freelancerId,
        jobId: jobId,
        proposalId: proposalId,
      );
      return Right(_toEntity(model));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> createRoom(String conversationId) async {
    try {
      await remoteDataSource.createRoom(conversationId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getRocketChatInfo(
    String conversationId,
  ) async {
    try {
      final info = await remoteDataSource.getRocketChatInfo(conversationId);
      return Right(info);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> loginToRocketChat(
    String user,
    String password,
  ) async {
    try {
      final result = await remoteDataSource.loginToRocketChat(user, password);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Conversation>>> getUserConversations(
    String userId,
    String role,
  ) async {
    try {
      // Try to get from cache first
      final cachedModels = await localDataSource.getCachedConversations(
        userId,
        role,
      );

      // Always fetch from remote to get latest data
      try {
        final models = await remoteDataSource.getUserConversations(
          userId,
          role,
        );
        // Cache the fresh data
        await localDataSource.cacheConversations(userId, role, models);
        final entities = models.map((model) => _toEntity(model)).toList();
        return Right(entities);
      } on ServerException catch (e) {
        // If remote fails, return cached data if available
        if (cachedModels.isNotEmpty) {
          final entities = cachedModels
              .map((model) => _toEntity(model))
              .toList();
          return Right(entities);
        }
        return Left(ServerFailure(e.message ?? 'Server error'));
      }
    } catch (e) {
      // Try to return cached data as fallback
      try {
        final cachedModels = await localDataSource.getCachedConversations(
          userId,
          role,
        );
        if (cachedModels.isNotEmpty) {
          final entities = cachedModels
              .map((model) => _toEntity(model))
              .toList();
          return Right(entities);
        }
      } catch (_) {}
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ParticipantProfile>> getParticipantProfile(
    String userId,
  ) async {
    try {
      final json = await remoteDataSource.getParticipantProfile(userId);
      final model = ParticipantProfileModel.fromJson(json);
      return Right(model);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }
}
