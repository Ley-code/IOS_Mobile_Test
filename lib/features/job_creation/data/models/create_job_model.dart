class CreateJobModel {
  final String jobTitle;
  final String jobDescription;
  final double minimumBudget;
  final double maximumBudget;
  final List<String> payoutTypes;
  final Map<String, double> payoutRates;
  final String jobStatus;
  final List<String>? skills;
  final List<String>? platforms;
  final String? expectedDurationId;
  final String? mainSkillId;
  final String? categoryId;

  CreateJobModel({
    required this.jobTitle,
    required this.jobDescription,
    required this.minimumBudget,
    required this.maximumBudget,
    required this.payoutTypes,
    required this.payoutRates,
    required this.jobStatus,
    this.skills,
    this.platforms,
    this.expectedDurationId,
    this.mainSkillId,
    this.categoryId,
  });

  Map<String, dynamic> toJson() {
    return {
      'job_title': jobTitle,
      'job_description': jobDescription,
      'minimum_budget': minimumBudget,
      'maximum_budget': maximumBudget,
      'payout_types': payoutTypes,
      'payout_rates': payoutRates,
      'job_status': jobStatus,
      if (skills != null && skills!.isNotEmpty) 'skills': skills,
      if (platforms != null && platforms!.isNotEmpty) 'platforms': platforms,
      if (expectedDurationId != null)
        'expected_duration_id': expectedDurationId,
      if (mainSkillId != null) 'main_skill_id': mainSkillId,
      if (categoryId != null) 'category_id': categoryId,
    };
  }
}
