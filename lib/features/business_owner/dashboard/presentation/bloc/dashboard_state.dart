part of 'dashboard_bloc.dart';

sealed class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardRefreshing extends DashboardState {
  final UserProfileModel profile;
  final List<JobModel> jobs;
  final int profileCompletionPercentage;

  const DashboardRefreshing({
    required this.profile,
    required this.jobs,
    this.profileCompletionPercentage = 0,
  });

  @override
  List<Object> get props => [profile, jobs, profileCompletionPercentage];
}

class DashboardLoaded extends DashboardState {
  final UserProfileModel profile;
  final List<JobModel> jobs;
  final int profileCompletionPercentage;

  const DashboardLoaded({
    required this.profile,
    required this.jobs,
    this.profileCompletionPercentage = 0,
  });

  @override
  List<Object> get props => [profile, jobs, profileCompletionPercentage];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError({required this.message});

  @override
  List<Object> get props => [message];
}

class ProfileUpdating extends DashboardState {
  final UserProfileModel profile;
  final List<JobModel> jobs;

  const ProfileUpdating({required this.profile, required this.jobs});

  @override
  List<Object> get props => [profile, jobs];
}

class ProfileUpdateSuccess extends DashboardState {
  final UserProfileModel profile;
  final List<JobModel> jobs;

  const ProfileUpdateSuccess({required this.profile, required this.jobs});

  @override
  List<Object> get props => [profile, jobs];
}

class ProfileUpdateError extends DashboardState {
  final String message;
  final UserProfileModel profile;
  final List<JobModel> jobs;

  const ProfileUpdateError({
    required this.message,
    required this.profile,
    required this.jobs,
  });

  @override
  List<Object> get props => [message, profile, jobs];
}
