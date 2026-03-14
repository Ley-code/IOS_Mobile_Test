import 'package:mobile_app/features/chat/domain/entities/participant_profile.dart';

class ParticipantProfileModel extends ParticipantProfile {
  const ParticipantProfileModel({
    required super.id,
    required super.name,
    super.profilePictureUrl,
  });

  factory ParticipantProfileModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? json;
    final firstName = user['first_name'] as String? ?? '';
    final lastName = user['last_name'] as String? ?? '';
    final userName = user['user_name'] as String? ?? '';
    final userId = user['id'] as String? ?? '';

    final name = firstName.isNotEmpty || lastName.isNotEmpty
        ? '$firstName $lastName'.trim()
        : (userName.isNotEmpty ? userName : 'User');

    return ParticipantProfileModel(
      id: userId,
      name: name,
      profilePictureUrl: user['profile_picture_url'] as String?,
    );
  }
}
