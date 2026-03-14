class NetworkStatsModel {
  final int followers;
  final int following;

  NetworkStatsModel({
    required this.followers,
    required this.following,
  });

  factory NetworkStatsModel.fromJson(Map<String, dynamic> json) {
    final networkStatsModel = NetworkStatsModel(
      followers: (json['followers'] as num?)?.toInt() ?? 0,
      following: (json['following'] as num?)?.toInt() ?? 0,
    );
    print('----------------networkStatsModel: ${networkStatsModel.toJson()}');
    return networkStatsModel;
  }

  Map<String, dynamic> toJson() {
    return {
      'followers': followers,
      'following': following,
    };
  }
}

class FollowStatusModel {
  final bool isFollowing;

  FollowStatusModel({required this.isFollowing});

  factory FollowStatusModel.fromJson(Map<String, dynamic> json) {
    return FollowStatusModel(
      isFollowing: json['is_following'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_following': isFollowing,
    };
  }
}

class NetworkUserModel {
  final String id;
  final String userName;
  final String firstName;
  final String lastName;
  final String? profilePictureUrl;
  final String? email;

  NetworkUserModel({
    required this.id,
    required this.userName,
    required this.firstName,
    required this.lastName,
    this.profilePictureUrl,
    this.email,
  });

  factory NetworkUserModel.fromJson(Map<String, dynamic> json) {
    return NetworkUserModel(
      id: json['id']?.toString() ?? json['user_id']?.toString() ?? '',
      userName: json['user_name'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      profilePictureUrl: json['profile_picture_url'] as String?,
      email: json['email'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_name': userName,
      'first_name': firstName,
      'last_name': lastName,
      'profile_picture_url': profilePictureUrl,
      'email': email,
    };
  }

  String get fullName => '$firstName $lastName'.trim();
}
