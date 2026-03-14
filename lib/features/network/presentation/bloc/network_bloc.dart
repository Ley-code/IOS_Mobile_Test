import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile_app/features/network/domain/entities/network_entity.dart';
import 'package:mobile_app/features/network/domain/usecases/follow_user.dart';
import 'package:mobile_app/features/network/domain/usecases/unfollow_user.dart';
import 'package:mobile_app/features/network/domain/usecases/get_network_stats.dart';
import 'package:mobile_app/features/network/domain/usecases/check_follow_status.dart';
import 'package:mobile_app/features/network/domain/usecases/get_followers.dart';
import 'package:mobile_app/features/network/domain/usecases/get_following.dart';

part 'network_event.dart';
part 'network_state.dart';

class NetworkBloc extends Bloc<NetworkEvent, NetworkState> {
  final FollowUser followUserUseCase;
  final UnfollowUser unfollowUserUseCase;
  final GetNetworkStats getNetworkStatsUseCase;
  final CheckFollowStatus checkFollowStatusUseCase;
  final GetFollowers getFollowersUseCase;
  final GetFollowing getFollowingUseCase;

  NetworkBloc({
    required this.followUserUseCase,
    required this.unfollowUserUseCase,
    required this.getNetworkStatsUseCase,
    required this.checkFollowStatusUseCase,
    required this.getFollowersUseCase,
    required this.getFollowingUseCase,
  }) : super(NetworkInitial()) {
    on<FollowUserEvent>(_onFollowUser);
    on<UnfollowUserEvent>(_onUnfollowUser);
    on<LoadNetworkStatsEvent>(_onLoadNetworkStats);
    on<CheckFollowStatusEvent>(_onCheckFollowStatus);
    on<LoadFollowersEvent>(_onLoadFollowers);
    on<LoadFollowingEvent>(_onLoadFollowing);
  }

  Future<void> _onFollowUser(
    FollowUserEvent event,
    Emitter<NetworkState> emit,
  ) async {
    emit(NetworkLoading());
    final result = await followUserUseCase(event.userId);
    result.fold(
      (failure) => emit(NetworkError(failure.message)),
      (_) => emit(UserFollowed(event.userId)),
    );
  }

  Future<void> _onUnfollowUser(
    UnfollowUserEvent event,
    Emitter<NetworkState> emit,
  ) async {
    emit(NetworkLoading());
    final result = await unfollowUserUseCase(event.userId);
    result.fold(
      (failure) => emit(NetworkError(failure.message)),
      (_) => emit(UserUnfollowed(event.userId)),
    );
  }

  Future<void> _onLoadNetworkStats(
    LoadNetworkStatsEvent event,
    Emitter<NetworkState> emit,
  ) async {
    emit(NetworkLoading());
    final result = await getNetworkStatsUseCase(event.userId);
    result.fold(
      (failure) => emit(NetworkError(failure.message)),
      (stats) => emit(
        NetworkStatsLoaded(
          followers: stats.followers,
          following: stats.following,
        ),
      ),
    );
  }

  Future<void> _onCheckFollowStatus(
    CheckFollowStatusEvent event,
    Emitter<NetworkState> emit,
  ) async {
    emit(NetworkLoading());
    final result = await checkFollowStatusUseCase(event.userId);
    result.fold(
      (failure) => emit(NetworkError(failure.message)),
      (isFollowing) => emit(FollowStatusLoaded(isFollowing)),
    );
  }

  Future<void> _onLoadFollowers(
    LoadFollowersEvent event,
    Emitter<NetworkState> emit,
  ) async {
    // Don't emit loading if we're already in a loaded state
    if (state is! NetworkLoading) {
      emit(NetworkLoading());
    }
    final result = await getFollowersUseCase(
      GetFollowersParams(userId: event.userId),
    );
    result.fold(
      (failure) => emit(NetworkError(failure.message)),
      (followers) => emit(FollowersLoaded(followers)),
    );
  }

  Future<void> _onLoadFollowing(
    LoadFollowingEvent event,
    Emitter<NetworkState> emit,
  ) async {
    // Don't emit loading if we're already in a loaded state
    if (state is! NetworkLoading) {
      emit(NetworkLoading());
    }
    final result = await getFollowingUseCase(
      GetFollowingParams(userId: event.userId),
    );
    result.fold(
      (failure) => emit(NetworkError(failure.message)),
      (following) => emit(FollowingLoaded(following)),
    );
  }
}
