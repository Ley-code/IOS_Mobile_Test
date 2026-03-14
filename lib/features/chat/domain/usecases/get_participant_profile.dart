import 'package:dartz/dartz.dart';
import 'package:mobile_app/core/error/failure.dart';
import 'package:mobile_app/core/usecase/usecase.dart';
import 'package:mobile_app/features/chat/domain/entities/participant_profile.dart';
import 'package:mobile_app/features/chat/domain/repositories/chat_repository.dart';

class GetParticipantProfile implements UseCase<ParticipantProfile, String> {
  final ChatRepository repository;

  GetParticipantProfile(this.repository);

  @override
  Future<Either<Failure, ParticipantProfile>> call(String userId) async {
    return await repository.getParticipantProfile(userId);
  }
}
