part of 'search_bloc.dart';

sealed class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object> get props => [];
}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchJobsLoaded extends SearchState {
  final List<JobModel> jobs;
  final Map<String, dynamic> pagination;
  final String? searchTerm;

  const SearchJobsLoaded({
    required this.jobs,
    required this.pagination,
    this.searchTerm,
  });

  @override
  List<Object> get props => [jobs, pagination];
}

class SearchFreelancersLoaded extends SearchState {
  final List<FreelancerProfileModel> freelancers;
  final Map<String, dynamic> pagination;
  final String? searchTerm;

  const SearchFreelancersLoaded({
    required this.freelancers,
    required this.pagination,
    this.searchTerm,
  });

  @override
  List<Object> get props => [freelancers, pagination];
}

class AllFreelancersLoaded extends SearchState {
  final List<FreelancerProfileModel> freelancers;

  const AllFreelancersLoaded({required this.freelancers});

  @override
  List<Object> get props => [freelancers];
}

class SearchError extends SearchState {
  final String message;

  const SearchError({required this.message});

  @override
  List<Object> get props => [message];
}

