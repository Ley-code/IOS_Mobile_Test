class AuthResponseModel {
  final String token;
  final UserResponseModel user;

  AuthResponseModel({required this.token, required this.user});

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      token: json['token'] as String,
      user: UserResponseModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

class UserResponseModel {
  final String id;
  final String userName;
  final String email;
  final String firstName;
  final String lastName;
  final String location;
  final String phone;
  final String role;
  final bool isOnboarded;

  UserResponseModel({
    required this.id,
    required this.userName,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.location,
    required this.phone,
    required this.role,
    required this.isOnboarded,
  });

  factory UserResponseModel.fromJson(Map<String, dynamic> json) {
    return UserResponseModel(
      id: json['id'].toString(),
      userName: json['user_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      location: json['location'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      role: json['role'] as String? ?? '',
      isOnboarded: json['is_onboarded'] as bool? ?? false,
    );
  }
}
