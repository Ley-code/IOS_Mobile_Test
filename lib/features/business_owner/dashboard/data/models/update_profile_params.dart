class UpdateFreelancerParams {
  final String userId;
  final String? introduction;
  final String? headline;
  final String? introductionVideo;
  final String? companyId;
  final List<String>? skills;
  final List<String>? specialities;

  UpdateFreelancerParams({
    required this.userId,
    this.introduction,
    this.headline,
    this.introductionVideo,
    this.companyId,
    this.skills,
    this.specialities,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      if (introduction != null) 'introduction': introduction,
      if (headline != null) 'headline': headline,
      if (introductionVideo != null) 'introduction_video': introductionVideo,
      if (companyId != null) 'company_id': companyId,
      if (skills != null) 'skills': skills,
      if (specialities != null) 'specialities': specialities,
    };
  }
}

class UpdateClientParams {
  final String userId;
  final String? companyId;
  final String? businessName;
  final String? companyWebsite;
  final String? aboutBusiness;
  final String? businessPhone;
  final List<String>? servicesSeeking;

  UpdateClientParams({
    required this.userId,
    this.companyId,
    this.businessName,
    this.companyWebsite,
    this.aboutBusiness,
    this.businessPhone,
    this.servicesSeeking,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      if (companyId != null) 'company_id': companyId,
      if (businessName != null) 'business_name': businessName,
      if (companyWebsite != null) 'company_website': companyWebsite,
      if (aboutBusiness != null) 'about_business': aboutBusiness,
      if (businessPhone != null) 'business_phone': businessPhone,
      if (servicesSeeking != null) 'services_seeking': servicesSeeking,
    };
  }
}
