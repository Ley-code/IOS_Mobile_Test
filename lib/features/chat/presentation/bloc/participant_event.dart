import 'package:equatable/equatable.dart';

abstract class ParticipantEvent extends Equatable {
  const ParticipantEvent();

  @override
  List<Object?> get props => [];
}

class LoadParticipantProfile extends ParticipantEvent {
  final String userId;

  const LoadParticipantProfile(this.userId);

  @override
  List<Object?> get props => [userId];
}
