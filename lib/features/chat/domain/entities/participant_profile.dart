import 'package:equatable/equatable.dart';

class ParticipantProfile extends Equatable {
  final String id;
  final String name;
  final String? profilePictureUrl;

  const ParticipantProfile({
    required this.id,
    required this.name,
    this.profilePictureUrl,
  });

  @override
  List<Object?> get props => [id, name, profilePictureUrl];
}
