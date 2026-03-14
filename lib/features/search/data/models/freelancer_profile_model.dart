class SkillInfo { 
  final String skillId;
  final String skillName;

  SkillInfo({required this.skillId, required this.skillName});
}

class FreelancerProfileModel {
  final String freelancerId;
  final String userId;
  final String userName;
  final String email;
  final String firstName;
  final String lastName;
  final String? introduction;
  final String? introductionVideo;
  final List<SkillInfo> skills;
  final List<String> platforms;
  final String? companyName;
  final String? profilePictureUrl;
  final String? location;

  FreelancerProfileModel({
    required this.freelancerId,
    required this.userId,
    required this.userName,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.introduction,
    this.introductionVideo,
    required this.skills,
    required this.platforms,
    this.companyName,
    this.profilePictureUrl,
    this.location,
  });

  factory FreelancerProfileModel.fromJson(Map<String, dynamic> json) {
    // Handle both direct user object and nested user object
    final userData = json['user'] as Map<String, dynamic>? ?? json;
    
    return FreelancerProfileModel(
      freelancerId: json['freelancer_id']?.toString() ?? '',
      userId: userData['id']?.toString() ?? userData['user_id']?.toString() ?? '',
      userName: userData['user_name'] as String? ?? json['user_name'] as String? ?? '',
      email: userData['email'] as String? ?? json['email'] as String? ?? '',
      firstName: userData['first_name'] as String? ?? json['first_name'] as String? ?? '',
      lastName: userData['last_name'] as String? ?? json['last_name'] as String? ?? '',
      introduction: json['introduction'] as String?,
      introductionVideo: json['introduction_video'] as String?,
      skills: (json['skills'] as List<dynamic>?)
              ?.map((s) => SkillInfo(skillId: s['skill_id'], skillName: s['skill_name']))
              .toList() ??
          [],
      platforms: (json['platforms'] as List<dynamic>?)
              ?.map((p) => p.toString())
              .toList() ??
          [],
      companyName: json['company_name'] as String?,
      profilePictureUrl: userData['profile_picture_url'] as String? ?? json['profile_picture_url'] as String?,
      location: userData['location'] as String? ?? json['location'] as String?,
    );
  }

  String get fullName => '$firstName $lastName'.trim();
}

