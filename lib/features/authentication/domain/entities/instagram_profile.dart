import 'package:equatable/equatable.dart';

/// Instagram profile information retrieved after OAuth connection.
class InstagramProfile extends Equatable {
  final String username;
  final int followersCount;
  final String? profilePictureUrl;
  final String? instagramId;

  const InstagramProfile({
    required this.username,
    required this.followersCount,
    this.profilePictureUrl,
    this.instagramId,
  });

  @override
  List<Object?> get props => [
    username,
    followersCount,
    profilePictureUrl,
    instagramId,
  ];

  @override
  String toString() =>
      'InstagramProfile(username: $username, followers: $followersCount)';
}
