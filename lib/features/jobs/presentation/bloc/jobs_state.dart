import 'package:equatable/equatable.dart';
import 'package:mobile_app/features/jobs/domain/entities/job_entity.dart';

abstract class JobsState extends Equatable {
  const JobsState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class JobsInitial extends JobsState {}

/// Loading jobs list
class JobsLoading extends JobsState {}

/// Jobs loaded successfully
class JobsLoaded extends JobsState {
  final List<JobEntity> jobs;
  final List<JobEntity> filteredJobs;
  final String? searchKeyword;

  const JobsLoaded({
    required this.jobs,
    List<JobEntity>? filteredJobs,
    this.searchKeyword,
  }) : filteredJobs = filteredJobs ?? jobs;

  @override
  List<Object?> get props => [jobs, filteredJobs, searchKeyword];

  JobsLoaded copyWith({
    List<JobEntity>? jobs,
    List<JobEntity>? filteredJobs,
    String? searchKeyword,
  }) {
    return JobsLoaded(
      jobs: jobs ?? this.jobs,
      filteredJobs: filteredJobs ?? this.filteredJobs,
      searchKeyword: searchKeyword ?? this.searchKeyword,
    );
  }
}

/// Error loading jobs
class JobsError extends JobsState {
  final String message;

  const JobsError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Loading a specific job
class JobDetailLoading extends JobsState {}

/// Job detail loaded successfully
class JobDetailLoaded extends JobsState {
  final JobEntity job;

  const JobDetailLoaded(this.job);

  @override
  List<Object?> get props => [job];
}

/// Error loading job detail
class JobDetailError extends JobsState {
  final String message;

  const JobDetailError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Submitting proposal
class ProposalSubmitting extends JobsState {}

/// Proposal submitted successfully
class ProposalSubmitted extends JobsState {
  final String message;

  const ProposalSubmitted({this.message = 'Proposal submitted successfully!'});

  @override
  List<Object?> get props => [message];
}

/// Error submitting proposal
class ProposalError extends JobsState {
  final String message;

  const ProposalError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Loading user's own jobs (for business owners)
class MyJobsLoading extends JobsState {}

/// User's own jobs loaded
class MyJobsLoaded extends JobsState {
  final List<JobEntity> jobs;

  const MyJobsLoaded(this.jobs);

  @override
  List<Object?> get props => [jobs];
}

/// Error loading user's own jobs
class MyJobsError extends JobsState {
  final String message;

  const MyJobsError(this.message);

  @override
  List<Object?> get props => [message];
}
