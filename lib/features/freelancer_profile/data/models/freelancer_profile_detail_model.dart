class FreelancerProfileDetailModel {
  final String freelancerId;
  final String userId;
  final String firstName;
  final String lastName;
  final String userName;
  final String? profilePictureUrl;
  final String? location;
  final String? headline;
  final String? introduction;
  final String? creatorType;
  final DateTime? createdAt;
  final double averageRating;
  final int reviewCount;
  final int projectsCompleted;
  final int totalFollowers;
  final List<SocialAccountModel> socialAccounts;

  FreelancerProfileDetailModel({
    required this.freelancerId,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.userName,
    this.profilePictureUrl,
    this.location,
    this.headline,
    this.introduction,
    this.creatorType,
    this.createdAt,
    this.averageRating = 0.0,
    this.reviewCount = 0,
    this.projectsCompleted = 0,
    this.totalFollowers = 0,
    this.socialAccounts = const [],
  });

  factory FreelancerProfileDetailModel.fromJson(Map<String, dynamic> json) {
    final userData = json['user'] as Map<String, dynamic>? ?? json;

    // Calculate total followers from social accounts
    final socialAccountsList = json['social_accounts'] as List<dynamic>? ?? [];
    final socialAccounts = socialAccountsList
        .map((e) => SocialAccountModel.fromJson(e as Map<String, dynamic>))
        .toList();
    final totalFollowers = socialAccounts.fold<int>(
      0,
      (sum, account) => sum + account.followerCount,
    );

    return FreelancerProfileDetailModel(
      freelancerId: json['freelancer_id']?.toString() ?? '',
      userId:
          userData['id']?.toString() ?? userData['user_id']?.toString() ?? '',
      firstName:
          userData['first_name'] as String? ??
          json['first_name'] as String? ??
          '',
      lastName:
          userData['last_name'] as String? ??
          json['last_name'] as String? ??
          '',
      userName:
          userData['user_name'] as String? ??
          json['user_name'] as String? ??
          '',
      profilePictureUrl:
          userData['profile_picture_url'] as String? ??
          json['profile_picture_url'] as String?,
      location: userData['location'] as String? ?? json['location'] as String?,
      headline: json['headline'] as String?,
      introduction: json['introduction'] as String?,
      creatorType: json['creator_type'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (json['review_count'] as int?) ?? 0,
      projectsCompleted: (json['projects_completed'] as int?) ?? 0,
      totalFollowers: totalFollowers,
      socialAccounts: socialAccounts,
    );
  }

  String get fullName => '$firstName $lastName'.trim();
  bool get isContentCreator => creatorType == 'content_creator';
}

class SocialAccountModel {
  final String accountId;
  final String platformName;
  final int followerCount;

  SocialAccountModel({
    required this.accountId,
    required this.platformName,
    required this.followerCount,
  });

  factory SocialAccountModel.fromJson(Map<String, dynamic> json) {
    return SocialAccountModel(
      accountId: json['account_id']?.toString() ?? '',
      platformName: json['platform_name'] as String? ?? '',
      followerCount: (json['follower_count'] as int?) ?? 0,
    );
  }
}

class ContractModel {
  final String contractId;
  final String status;

  ContractModel({required this.contractId, required this.status});

  factory ContractModel.fromJson(Map<String, dynamic> json) {
    return ContractModel(
      contractId:
          json['contract_id']?.toString() ?? json['id']?.toString() ?? '',
      status: json['status'] as String? ?? 'unknown',
    );
  }
}

class PortfolioItemModel {
  final String portfolioId;
  final String title;
  final String? description;
  final String type;
  final String? thumbnailUrl;
  final DateTime? createdAt;

  PortfolioItemModel({
    required this.portfolioId,
    required this.title,
    this.description,
    required this.type,
    this.thumbnailUrl,
    this.createdAt,
  });

  factory PortfolioItemModel.fromJson(Map<String, dynamic> json) {
    return PortfolioItemModel(
      portfolioId:
          json['portfolio_id']?.toString() ?? json['id']?.toString() ?? '',
      title:
          json['portfolio_title'] as String? ?? json['title'] as String? ?? '',
      description:
          json['portfolio_description'] as String? ??
          json['description'] as String?,
      type:
          json['portfolio_type'] as String? ??
          json['type'] as String? ??
          'image',
      thumbnailUrl:
          json['thumbnail_url'] as String? ?? json['media_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }
}
