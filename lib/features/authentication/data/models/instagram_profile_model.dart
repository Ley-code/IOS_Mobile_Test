import 'package:mobile_app/features/authentication/domain/entities/instagram_profile.dart';

/// Model for Instagram profile data from API responses.
class InstagramProfileModel extends InstagramProfile {
  const InstagramProfileModel({
    required super.username,
    required super.followersCount,
    super.profilePictureUrl,
    super.instagramId,
  });

  /// Create from JSON response
  factory InstagramProfileModel.fromJson(Map<String, dynamic> json) {
    return InstagramProfileModel(
      username: json['username'] as String? ?? '',
      followersCount:
          json['followers_count'] as int? ??
          json['followersCount'] as int? ??
          0,
      profilePictureUrl:
          json['profile_picture_url'] as String? ??
          json['profilePictureUrl'] as String?,
      instagramId:
          json['instagram_id'] as String? ??
          json['instagramId'] as String? ??
          json['id'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'followers_count': followersCount,
      'profile_picture_url': profilePictureUrl,
      'instagram_id': instagramId,
    };
  }
}
