class NetworkStats {
  final int followers;
  final int following;

  NetworkStats({
    required this.followers,
    required this.following,
  });
}

class NetworkUser {
  final String id;
  final String userName;
  final String firstName;
  final String lastName;
  final String? profilePictureUrl;
  final String? email;

  NetworkUser({
    required this.id,
    required this.userName,
    required this.firstName,
    required this.lastName,
    this.profilePictureUrl,
    this.email,
  });

  String get fullName => '$firstName $lastName'.trim();
}
