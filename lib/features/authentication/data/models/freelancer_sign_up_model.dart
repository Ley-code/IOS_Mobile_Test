import 'package:mobile_app/features/authentication/domain/entities/freelancer_sign_up_entity.dart';

class FreelancerSignUpModel extends FreelancerSignupEntity {
  const FreelancerSignUpModel({
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.phoneNumber,
    required super.password,
    required super.about,
    required super.selectedRole,
    required super.preferredLanguage,
    super.socialMediaLinks,
    required super.specialities,
    required super.languages,
  });

  factory FreelancerSignUpModel.fromEntity(FreelancerSignupEntity entity) {
    return FreelancerSignUpModel(
      firstName: entity.firstName,
      lastName: entity.lastName,
      email: entity.email,
      phoneNumber: entity.phoneNumber,
      password: entity.password,
      about: entity.about,
      selectedRole: entity.selectedRole,
      preferredLanguage: entity.preferredLanguage,
      socialMediaLinks: entity.socialMediaLinks,
      specialities: entity.specialities,
      languages: entity.languages,
    );
  }

  /// Maps to backend API format
  /// Backend expects: user_name, email, first_name, last_name, location, phone, password, role
  Map<String, dynamic> toJson() {
    // Map role: always 'freelancer' for these personas
    const role = 'freelancer';

    // Generate user_name from email or combine names
    final userName = (firstName + lastName).replaceAll(' ', '').isNotEmpty
        ? (firstName + lastName).replaceAll(' ', '')
        : email.split('@').first;

    // Use "Not specified" for location as it's not in the form
    const location = 'Not specified';

    return {
      'user_name': userName,
      'email': email.trim(),
      'first_name': firstName.trim(),
      'last_name': lastName.trim(),
      'location': location,
      'phone': phoneNumber.trim(),
      'password': password,
      'role': role,
      // Note: about, specialities, languages, preferredLanguage,
      // socialMediaLinks are kept in UI but not sent to backend in this MVP call
    };
  }
}
