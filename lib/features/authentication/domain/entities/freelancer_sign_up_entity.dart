import 'package:equatable/equatable.dart';
import 'package:mobile_app/features/authentication/domain/entities/user_entity.dart';

class FreelancerSignupEntity extends Equatable {
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String password;
  final String about;
  final UserRole selectedRole;
  final String preferredLanguage;
  final List<String>? socialMediaLinks;
  final List<String> specialities;
  final List<String> languages; // Comma separated "Language:Level" or similar

  const FreelancerSignupEntity({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.password,
    required this.about,
    required this.selectedRole,
    required this.preferredLanguage,
    this.socialMediaLinks,
    required this.specialities,
    required this.languages,
    this.instagramAuthCode,
  });

  final String? instagramAuthCode;

  @override
  List<Object?> get props => [
    firstName,
    lastName,
    email,
    phoneNumber,
    password,
    about,
    selectedRole,
    preferredLanguage,
    socialMediaLinks,
    specialities,
    languages,
  ];
}
