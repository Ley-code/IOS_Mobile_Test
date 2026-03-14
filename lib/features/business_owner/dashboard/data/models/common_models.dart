import 'package:equatable/equatable.dart';

class SkillInfoModel extends Equatable {
  final String skillId;
  final String skillName;

  const SkillInfoModel({required this.skillId, required this.skillName});

  factory SkillInfoModel.fromJson(Map<String, dynamic> json) {
    return SkillInfoModel(
      skillId: json['skill_id'] ?? '',
      skillName: json['skill_name'] ?? '',
    );
  }

  @override
  List<Object?> get props => [skillId, skillName];
}

class SpecialityInfoModel extends Equatable {
  final String specialityId;
  final String specialityName;
  final String specialityDescription;

  const SpecialityInfoModel({
    required this.specialityId,
    required this.specialityName,
    required this.specialityDescription,
  });

  factory SpecialityInfoModel.fromJson(Map<String, dynamic> json) {
    return SpecialityInfoModel(
      specialityId: json['speciality_id'] ?? '',
      specialityName: json['speciality_name'] ?? '',
      specialityDescription: json['speciality_description'] ?? '',
    );
  }

  @override
  List<Object?> get props => [
    specialityId,
    specialityName,
    specialityDescription,
  ];
}

class ServiceInfoModel extends Equatable {
  final String serviceId;
  final String serviceName;
  final String serviceDescription;
  final String serviceIcon;

  const ServiceInfoModel({
    required this.serviceId,
    required this.serviceName,
    required this.serviceDescription,
    required this.serviceIcon,
  });

  factory ServiceInfoModel.fromJson(Map<String, dynamic> json) {
    return ServiceInfoModel(
      serviceId: json['service_id'] ?? '',
      serviceName: json['service_name'] ?? '',
      serviceDescription: json['service_description'] ?? '',
      serviceIcon: json['service_icon'] ?? '',
    );
  }

  @override
  List<Object?> get props => [
    serviceId,
    serviceName,
    serviceDescription,
    serviceIcon,
  ];
}

class LanguageInfoModel extends Equatable {
  final String languageId;
  final String languageName;
  // TODO: Add proficiency level if needed

  const LanguageInfoModel({
    required this.languageId,
    required this.languageName,
  });

  factory LanguageInfoModel.fromJson(Map<String, dynamic> json) {
    return LanguageInfoModel(
      languageId: json['language_id'] ?? '',
      languageName: json['language_name'] ?? '',
    );
  }

  @override
  List<Object?> get props => [languageId, languageName];
}

class CompanyInfoModel extends Equatable {
  final String id;
  final String companyName;
  final String companyLocation;
  final String companyLogo;

  const CompanyInfoModel({
    required this.id,
    required this.companyName,
    required this.companyLocation,
    required this.companyLogo,
  });

  factory CompanyInfoModel.fromJson(Map<String, dynamic> json) {
    return CompanyInfoModel(
      id: json['id'] ?? '',
      companyName: json['company_name'] ?? '',
      companyLocation: json['company_location'] ?? '',
      companyLogo: json['company_logo'] ?? '',
    );
  }

  @override
  List<Object?> get props => [id, companyName, companyLocation, companyLogo];
}
