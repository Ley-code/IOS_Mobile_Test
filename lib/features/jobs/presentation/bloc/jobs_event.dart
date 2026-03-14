import 'package:equatable/equatable.dart';
import 'package:mobile_app/features/jobs/domain/entities/proposal_entity.dart';

abstract class JobsEvent extends Equatable {
  const JobsEvent();

  @override
  List<Object?> get props => [];
}

/// Load all available jobs
class LoadJobs extends JobsEvent {
  const LoadJobs();
}

/// Refresh jobs list
class RefreshJobs extends JobsEvent {
  const RefreshJobs();
}

/// Load a specific job by ID
class LoadJobById extends JobsEvent {
  final String jobId;

  const LoadJobById(this.jobId);

  @override
  List<Object?> get props => [jobId];
}

/// Submit a proposal for a job
class SubmitJobProposal extends JobsEvent {
  final ProposalEntity proposal;

  const SubmitJobProposal(this.proposal);

  @override
  List<Object?> get props => [proposal];
}

/// Load jobs created by the current business owner
class LoadMyJobs extends JobsEvent {
  const LoadMyJobs();
}

/// Search/filter jobs
class SearchJobs extends JobsEvent {
  final String? keyword;
  final List<String>? categories;
  final List<String>? skills;
  final double? minBudget;
  final double? maxBudget;

  const SearchJobs({
    this.keyword,
    this.categories,
    this.skills,
    this.minBudget,
    this.maxBudget,
  });

  @override
  List<Object?> get props => [
    keyword,
    categories,
    skills,
    minBudget,
    maxBudget,
  ];
}

/// Clear selected job
class ClearSelectedJob extends JobsEvent {
  const ClearSelectedJob();
}
