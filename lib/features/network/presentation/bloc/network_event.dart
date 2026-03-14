part of 'network_bloc.dart';

abstract class NetworkEvent extends Equatable {
  const NetworkEvent();

  @override
  List<Object?> get props => [];
}

class FollowUserEvent extends NetworkEvent {
  final String userId;

  const FollowUserEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class UnfollowUserEvent extends NetworkEvent {
  final String userId;

  const UnfollowUserEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class LoadNetworkStatsEvent extends NetworkEvent {
  final String userId;

  const LoadNetworkStatsEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class CheckFollowStatusEvent extends NetworkEvent {
  final String userId;

  const CheckFollowStatusEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class LoadFollowersEvent extends NetworkEvent {
  final String userId;

  const LoadFollowersEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class LoadFollowingEvent extends NetworkEvent {
  final String userId;

  const LoadFollowingEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}