class JobModel {
  final String jobId;
  final String userId;
  final String jobTitle;
  final String jobDescription;
  final double minimumBudget;
  final double maximumBudget;
  final String jobStatus;
  final String createdAt;
  final List<String> skills;
  final List<String> platforms;
  final String? clientName;
  final String? clientCompany;

  JobModel({
    required this.jobId,
    required this.userId,
    required this.jobTitle,
    required this.jobDescription,
    required this.minimumBudget,
    required this.maximumBudget,
    required this.jobStatus,
    required this.createdAt,
    required this.skills,
    required this.platforms,
    this.clientName,
    this.clientCompany,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      jobId: json['job_id'].toString(),
      userId: json['user_id'].toString(),
      jobTitle: json['job_title'] as String? ?? '',
      jobDescription: json['job_description'] as String? ?? '',
      minimumBudget: (json['minimum_budget'] as num?)?.toDouble() ?? 0.0,
      maximumBudget: (json['maximum_budget'] as num?)?.toDouble() ?? 0.0,
      jobStatus: json['job_status'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
      skills: (json['skills'] as List<dynamic>?)?.map((s) => s.toString()).toList() ?? [],
      platforms: (json['platforms'] as List<dynamic>?)?.map((p) => p.toString()).toList() ?? [],
      clientName: json['client_name'] as String?,
      clientCompany: json['client_company'] as String?,
    );
  }

  String get budgetRange {
    if (minimumBudget == maximumBudget) {
      return '\$${minimumBudget.toStringAsFixed(0)}';
    }
    return '\$${minimumBudget.toStringAsFixed(0)} - \$${maximumBudget.toStringAsFixed(0)}';
  }

  bool get isOpen => jobStatus.toLowerCase() == 'open';
}

