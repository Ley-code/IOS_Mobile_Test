import 'package:mobile_app/features/proposals/domain/entities/proposal_with_user_entity.dart';

class ProposalWithUserModel extends ProposalWithUserEntity {
  const ProposalWithUserModel({
    required super.proposalId,
    required super.jobId,
    required super.userId,
    required super.proposalText,
    required super.proposalRate,
    super.statusId,
    required super.createdAt,
    required super.user,
  });

  factory ProposalWithUserModel.fromJson(Map<String, dynamic> json) {
    // Parse proposal_rate
    Map<String, dynamic> proposalRate = {};
    if (json['proposal_rate'] != null) {
      proposalRate = Map<String, dynamic>.from(json['proposal_rate']);
    }

    // Parse created_at
    DateTime createdAt;
    try {
      createdAt = DateTime.parse(json['created_at'] as String);
    } catch (e) {
      createdAt = DateTime.now();
    }

    // Parse user
    ProposalUserModel user;
    if (json['user'] != null) {
      user = ProposalUserModel.fromJson(json['user'] as Map<String, dynamic>);
    } else {
      throw Exception('User data is required');
    }

    return ProposalWithUserModel(
      proposalId: json['proposal_id'] as String? ?? '',
      jobId: json['job_id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      proposalText: json['proposal_text'] as String? ?? '',
      proposalRate: proposalRate,
      statusId: json['status_id'] as String?,
      createdAt: createdAt,
      user: user,
    );
  }
}

class ProposalUserModel extends ProposalUserEntity {
  const ProposalUserModel({
    required super.id,
    required super.userName,
    required super.email,
    required super.firstName,
    required super.lastName,
    required super.location,
    super.phone,
    required super.role,
    super.profilePictureUrl,
    required super.createdAt,
  });

  factory ProposalUserModel.fromJson(Map<String, dynamic> json) {
    DateTime createdAt;
    try {
      createdAt = DateTime.parse(json['created_at'] as String);
    } catch (e) {
      createdAt = DateTime.now();
    }

    return ProposalUserModel(
      id: json['id'] as String? ?? '',
      userName: json['user_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      location: json['location'] as String? ?? 'Not specified',
      phone: json['phone'] as String?,
      role: json['role'] as String? ?? 'freelancer',
      profilePictureUrl: json['profile_picture_url'] as String?,
      createdAt: createdAt,
    );
  }
}














