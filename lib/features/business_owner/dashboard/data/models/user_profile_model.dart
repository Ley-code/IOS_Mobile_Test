import 'package:equatable/equatable.dart';
import 'social_account_model.dart';
import 'freelancer_info_model.dart';
import 'client_info_model.dart';
import 'common_models.dart';

class UserProfileModel extends Equatable {
  final String id;
  final String userName;
  final String email;
  final String firstName;
  final String lastName;
  final String location;
  final String phone;
  final String role;
  final bool isOnboarded;
  final String? companyName;
  final double totalWalletBalance;
  final String? freelancerId;
  final List<SocialAccountModel> socialAccounts;
  final String? profilePictureUrl;

  // New fields
  final FreelancerInfoModel? freelancerInfo;
  final ClientInfoModel? clientInfo;
  final List<SkillInfoModel> skills;
  final List<LanguageInfoModel> languages;
  final List<SpecialityInfoModel> specialities;
  // TODO: Add certifications, portfolios, wallets if needed fully mapped

  const UserProfileModel({
    required this.id,
    required this.userName,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.location,
    required this.phone,
    required this.role,
    required this.isOnboarded,
    this.companyName,
    this.totalWalletBalance = 0.0,
    this.freelancerId,
    this.socialAccounts = const [],
    this.profilePictureUrl,
    this.freelancerInfo,
    this.clientInfo,
    this.skills = const [],
    this.languages = const [],
    this.specialities = const [],
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    // Top level fields or nested under 'user' depending on API response structure
    // The current API seems to return { user: {...}, freelancer: {...}, ... }

    final userPart = json['user'] as Map<String, dynamic>? ?? json;

    // Mapping complex nested objects
    final freelancerPart = json['freelancer'] as Map<String, dynamic>?;
    final clientPart = json['client'] as Map<String, dynamic>?;

    // Lists
    final socialAccountsList = json['social_accounts'] as List<dynamic>? ?? [];
    final skillsList = json['skills'] as List<dynamic>? ?? [];
    final languagesList = json['languages'] as List<dynamic>? ?? [];
    final specialitiesList = json['specialities'] as List<dynamic>? ?? [];
    final wallets = json['wallets'] as List<dynamic>? ?? [];

    // Construct Company Name legacy field (can be removed later if UI switches to ClientInfo/FreelancerInfo)
    final company =
        clientPart?['company'] as Map<String, dynamic>? ??
        freelancerPart?['company'] as Map<String, dynamic>?;

    double totalBalance = 0.0;
    for (var wallet in wallets) {
      final balance = (wallet['balance'] as num?)?.toDouble() ?? 0.0;
      totalBalance += balance;
    }

    return UserProfileModel(
      id: userPart['id']?.toString() ?? '',
      userName: userPart['user_name'] as String? ?? '',
      email: userPart['email'] as String? ?? '',
      firstName: userPart['first_name'] as String? ?? '',
      lastName: userPart['last_name'] as String? ?? '',
      location: userPart['location'] as String? ?? '',
      phone: userPart['phone'] as String? ?? '',
      role: userPart['role'] as String? ?? '',
      isOnboarded: userPart['is_onboarded'] as bool? ?? false,
      companyName: company?['company_name'] as String?,
      totalWalletBalance: totalBalance,
      freelancerId: freelancerPart?['freelancer_id']?.toString(),
      socialAccounts: socialAccountsList
          .map((e) => SocialAccountModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      profilePictureUrl: userPart['profile_picture_url'] as String?,

      // New fields mapping
      freelancerInfo: freelancerPart != null
          ? FreelancerInfoModel.fromJson(freelancerPart)
          : null,
      clientInfo: clientPart != null
          ? ClientInfoModel.fromJson(clientPart)
          : null,
      skills: skillsList.map((e) => SkillInfoModel.fromJson(e)).toList(),
      languages: languagesList
          .map((e) => LanguageInfoModel.fromJson(e))
          .toList(),
      specialities: specialitiesList
          .map((e) => SpecialityInfoModel.fromJson(e))
          .toList(),
    );
  }

  String get fullName => '$firstName $lastName'.trim();
  String get displayName => fullName.isNotEmpty ? fullName : userName;

  @override
  List<Object?> get props => [
    id,
    userName,
    email,
    firstName,
    lastName,
    location,
    phone,
    role,
    isOnboarded,
    companyName,
    totalWalletBalance,
    freelancerId,
    socialAccounts,
    profilePictureUrl,
    freelancerInfo,
    clientInfo,
    skills,
    languages,
    specialities,
  ];
}
