import 'package:equatable/equatable.dart';

class ProposalEntity extends Equatable {
  final String? proposalId;
  final String jobId;
  final String proposalText;
  final Map<String, double> proposalRate;
  final String? status;
  final DateTime? createdAt;

  const ProposalEntity({
    this.proposalId,
    required this.jobId,
    required this.proposalText,
    required this.proposalRate,
    this.status,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
    proposalId,
    jobId,
    proposalText,
    proposalRate,
    status,
    createdAt,
  ];
}
