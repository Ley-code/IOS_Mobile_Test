part of 'network_bloc.dart';

abstract class NetworkState extends Equatable {
  const NetworkState();

  @override
  List<Object?> get props => [];
}

class NetworkInitial extends NetworkState {}

class NetworkLoading extends NetworkState {}

class NetworkStatsLoaded extends NetworkState {
  final int followers;
  final int following;

  const NetworkStatsLoaded({
    required this.followers,
    required this.following,
  });

  @override
  List<Object?> get props => [followers, following];
}

class FollowStatusLoaded extends NetworkState {
  final bool isFollowing;

  const FollowStatusLoaded(this.isFollowing);

  @override
  List<Object?> get props => [isFollowing];
}

class UserFollowed extends NetworkState {
  final String userId;

  const UserFollowed(this.userId);

  @override
  List<Object?> get props => [userId];
}

class UserUnfollowed extends NetworkState {
  final String userId;

  const UserUnfollowed(this.userId);

  @override
  List<Object?> get props => [userId];
}

class NetworkError extends NetworkState {
  final String message;

  const NetworkError(this.message);

  @override
  List<Object?> get props => [message];
}

class FollowersLoaded extends NetworkState {
  final List<NetworkUser> followers;

  const FollowersLoaded(this.followers);

  @override
  List<Object?> get props => [followers];
}

class FollowingLoaded extends NetworkState {
  final List<NetworkUser> following;

  const FollowingLoaded(this.following);

  @override
  List<Object?> get props => [following];
}