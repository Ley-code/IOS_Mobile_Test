part of 'dashboard_bloc.dart';

sealed class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object> get props => [];
}

class LoadDashboardData extends DashboardEvent {
  const LoadDashboardData();
}

class RefreshDashboardData extends DashboardEvent {
  const RefreshDashboardData();
}

class UpdateClientProfileEvent extends DashboardEvent {
  final UpdateClientParams params;
  const UpdateClientProfileEvent({required this.params});

  @override
  List<Object> get props => [params];
}

class UpdateFreelancerProfileEvent extends DashboardEvent {
  final UpdateFreelancerParams params;
  const UpdateFreelancerProfileEvent({required this.params});

  @override
  List<Object> get props => [params];
}
