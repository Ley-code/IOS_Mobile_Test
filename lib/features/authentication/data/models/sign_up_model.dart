import 'package:mobile_app/features/authentication/domain/entities/business_sign_up_entity.dart';
import 'package:mobile_app/features/authentication/domain/entities/user_entity.dart';

class BusinessSignUpModel extends BusinessSignupEntity {

  const BusinessSignUpModel({
    required super.firstName,
    required super.lastName,
    required super.businessName,
    required super.businessEmail,
    required super.businessPhone,
    required super.businessDescription,
    required super.companyWebsite,
    required super.preferredLanguage,
    required super.socialMediaLinks,
    required super.password,
    required super.phoneNumber,
    required super.selectedRole,
    required super.servicesRequired,
  });

  /// Maps to backend API format
  /// Backend expects: user_name, email, first_name, last_name, location, phone, password, role
  Map<String, dynamic> toJson() {
    // Map role: businessOwner -> "client", influencer/photographer/videographer/designer -> "freelancer"
    String role;
    if (selectedRole == UserRole.businessOwner) {
      role = 'client';
    } else {
      // All other roles (influencer, photographer, videographer, designer) map to freelancer
      role = 'freelancer';
    }
    
    // Use businessName as user_name, or generate from email if empty
    final userName = businessName.trim().isNotEmpty 
        ? businessName.trim() 
        : businessEmail.split('@').first;
    
    // Use phoneNumber as phone, fallback to businessPhone
    final phone = phoneNumber.trim().isNotEmpty 
        ? phoneNumber.trim() 
        : businessPhone.trim();
    
    // Use businessName or default for location
    final location = businessName.trim().isNotEmpty 
        ? businessName.trim() 
        : 'Not specified';
    
    return {
      'user_name': userName,
      'email': businessEmail.trim(),
      'first_name': firstName.trim(),
      'last_name': lastName.trim(),
      'location': location,
      'phone': phone,
      'password': password,
      'role': role,
      // Note: businessDescription, companyWebsite, preferredLanguage, 
      // socialMediaLinks, servicesRequired are kept in UI but not sent to backend
    };
  }
}