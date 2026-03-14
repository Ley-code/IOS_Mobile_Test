import 'package:mobile_app/features/jobs/domain/entities/proposal_entity.dart';

class ProposalModel extends ProposalEntity {
  const ProposalModel({
    super.proposalId,
    required super.jobId,
    required super.proposalText,
    required super.proposalRate,
    super.status,
    super.createdAt,
  });

  factory ProposalModel.fromJson(Map<String, dynamic> json) {
    // Parse proposal_rate
    Map<String, double> proposalRate = {};
    if (json['proposal_rate'] != null) {
      final rateMap = json['proposal_rate'] as Map<String, dynamic>;
      proposalRate = rateMap.map(
        (key, value) => MapEntry(key, (value as num).toDouble()),
      );
    }

    // Parse created_at
    DateTime? createdAt;
    if (json['created_at'] != null) {
      try {
        createdAt = DateTime.parse(json['created_at'] as String);
      } catch (e) {
        createdAt = null;
      }
    }

    return ProposalModel(
      proposalId: json['proposal_id'] as String?,
      jobId: json['job_id'] as String? ?? '',
      proposalText: json['proposal_text'] as String? ?? '',
      proposalRate: proposalRate,
      status: json['status'] as String?,
      createdAt: createdAt,
    );
  }

  factory ProposalModel.fromEntity(ProposalEntity entity) {
    return ProposalModel(
      proposalId: entity.proposalId,
      jobId: entity.jobId,
      proposalText: entity.proposalText,
      proposalRate: entity.proposalRate,
      status: entity.status,
      createdAt: entity.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'job_id': jobId,
      'proposal_text': proposalText,
      'proposal_rate': proposalRate,
    };
  }
}
