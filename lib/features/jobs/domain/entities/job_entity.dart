import 'package:equatable/equatable.dart';

class JobEntity extends Equatable {
  final String jobId;
  final String userId;
  final String jobTitle;
  final String jobDescription;
  final String? categoryId;
  final String? categoryName;
  final String? expectedDurationId;
  final String? mainSkillId;
  final List<String> payoutTypes;
  final Map<String, dynamic> payoutRates;
  final double minimumBudget;
  final double maximumBudget;
  final String jobStatus;
  final DateTime createdAt;
  final List<String> skills;
  final List<String> platforms;
  final String clientName;
  final String? clientCompany;

  const JobEntity({
    required this.jobId,
    required this.userId,
    required this.jobTitle,
    required this.jobDescription,
    this.categoryId,
    this.categoryName,
    this.expectedDurationId,
    this.mainSkillId,
    required this.payoutTypes,
    required this.payoutRates,
    required this.minimumBudget,
    required this.maximumBudget,
    required this.jobStatus,
    required this.createdAt,
    required this.skills,
    required this.platforms,
    required this.clientName,
    this.clientCompany,
  });

  /// Get the primary payout type display name
  String get primaryPayoutType {
    if (payoutTypes.isEmpty) return 'Not specified';
    return payoutTypes.first.replaceAll('_', ' ').toUpperCase();
  }

  /// Get the primary payout rate
  double? get primaryPayoutRate {
    if (payoutTypes.isEmpty || payoutRates.isEmpty) return null;
    final key = payoutTypes.first;
    final rate = payoutRates[key];
    if (rate == null) return null;
    return (rate as num).toDouble();
  }

  /// Format budget range as string
  String get budgetRange =>
      '\$${minimumBudget.toInt()} - \$${maximumBudget.toInt()}';

  /// Check if job is open
  bool get isOpen => jobStatus.toLowerCase() == 'open';

  /// Get time ago string
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  @override
  List<Object?> get props => [
    jobId,
    userId,
    jobTitle,
    jobDescription,
    categoryId,
    categoryName,
    expectedDurationId,
    mainSkillId,
    payoutTypes,
    payoutRates,
    minimumBudget,
    maximumBudget,
    jobStatus,
    createdAt,
    skills,
    platforms,
    clientName,
    clientCompany,
  ];
}
