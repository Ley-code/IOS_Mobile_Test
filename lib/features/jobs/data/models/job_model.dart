import 'package:mobile_app/features/jobs/domain/entities/job_entity.dart';

class JobModel extends JobEntity {
  const JobModel({
    required super.jobId,
    required super.userId,
    required super.jobTitle,
    required super.jobDescription,
    super.categoryId,
    super.categoryName,
    super.expectedDurationId,
    super.mainSkillId,
    required super.payoutTypes,
    required super.payoutRates,
    required super.minimumBudget,
    required super.maximumBudget,
    required super.jobStatus,
    required super.createdAt,
    required super.skills,
    required super.platforms,
    required super.clientName,
    super.clientCompany,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    // Parse payout_types
    List<String> payoutTypes = [];
    if (json['payout_types'] != null) {
      payoutTypes = (json['payout_types'] as List)
          .map((e) => e.toString())
          .toList();
    }

    // Parse payout_rates
    Map<String, dynamic> payoutRates = {};
    if (json['payout_rates'] != null) {
      payoutRates = Map<String, dynamic>.from(json['payout_rates']);
    }

    // Parse skills
    List<String> skills = [];
    if (json['skills'] != null) {
      skills = (json['skills'] as List).map((e) => e.toString()).toList();
    }

    // Parse platforms
    List<String> platforms = [];
    if (json['platforms'] != null) {
      platforms = (json['platforms'] as List).map((e) => e.toString()).toList();
    }

    // Parse created_at
    DateTime createdAt;
    try {
      createdAt = DateTime.parse(json['created_at'] as String);
    } catch (e) {
      createdAt = DateTime.now();
    }

    return JobModel(
      jobId: json['job_id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      jobTitle: json['job_title'] as String? ?? '',
      jobDescription: json['job_description'] as String? ?? '',
      categoryId: json['category_id'] as String?,
      categoryName: json['category_name'] as String?,
      expectedDurationId: json['expected_duration_id'] as String?,
      mainSkillId: json['main_skill_id'] as String?,
      payoutTypes: payoutTypes,
      payoutRates: payoutRates,
      minimumBudget: (json['minimum_budget'] as num?)?.toDouble() ?? 0.0,
      maximumBudget: (json['maximum_budget'] as num?)?.toDouble() ?? 0.0,
      jobStatus: json['job_status'] as String? ?? 'open',
      createdAt: createdAt,
      skills: skills,
      platforms: platforms,
      clientName: json['client_name'] as String? ?? '',
      clientCompany: json['client_company'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'job_id': jobId,
      'user_id': userId,
      'job_title': jobTitle,
      'job_description': jobDescription,
      'category_id': categoryId,
      'category_name': categoryName,
      'expected_duration_id': expectedDurationId,
      'main_skill_id': mainSkillId,
      'payout_types': payoutTypes,
      'payout_rates': payoutRates,
      'minimum_budget': minimumBudget,
      'maximum_budget': maximumBudget,
      'job_status': jobStatus,
      'created_at': createdAt.toIso8601String(),
      'skills': skills,
      'platforms': platforms,
      'client_name': clientName,
      'client_company': clientCompany,
    };
  }
}
