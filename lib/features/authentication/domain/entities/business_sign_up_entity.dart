import 'package:equatable/equatable.dart';
import 'package:mobile_app/features/authentication/domain/entities/user_entity.dart';

class BusinessSignupEntity extends Equatable {
  final String firstName;
  final String lastName;
  final String businessName;
  final String businessEmail;
  final String businessPhone;
  final String businessDescription;
  final String? companyWebsite;
  final String preferredLanguage;
  final List<String>? socialMediaLinks;
  final String password;
  final String phoneNumber;
  final UserRole selectedRole;
  final List<String> servicesRequired;

  const BusinessSignupEntity({
    required this.firstName,
    required this.lastName,
    required this.businessName,
    required this.businessEmail,
    required this.businessPhone,
    required this.businessDescription,
    required this.companyWebsite,
    required this.preferredLanguage,
    required this.socialMediaLinks,
    required this.password,
    required this.phoneNumber,
    required this.selectedRole,
    required this.servicesRequired,
  });

  @override
  List<Object?> get props => [
    firstName,
    lastName,
    businessName,
    businessEmail,
    businessPhone,
    businessDescription,
    companyWebsite,
    preferredLanguage,
    socialMediaLinks,
    password,
    phoneNumber,
    selectedRole,
    servicesRequired,
  ];
}
