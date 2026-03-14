import 'package:equatable/equatable.dart';
import 'package:mobile_app/features/chat/domain/entities/participant_profile.dart';

abstract class ParticipantState extends Equatable {
  const ParticipantState();

  @override
  List<Object?> get props => [];
}

class ParticipantInitial extends ParticipantState {}

class ParticipantLoading extends ParticipantState {
  final String userId;

  const ParticipantLoading(this.userId);

  @override
  List<Object?> get props => [userId];
}

class ParticipantLoaded extends ParticipantState {
  final ParticipantProfile profile;

  const ParticipantLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}

class ParticipantError extends ParticipantState {
  final String userId;
  final String message;

  const ParticipantError(this.userId, this.message);

  @override
  List<Object?> get props => [userId, message];
}
