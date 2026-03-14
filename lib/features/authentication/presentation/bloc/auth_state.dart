part of 'auth_bloc.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

final class AuthInitial extends AuthState {}

final class AuthLoadingState extends AuthState {}

final class AuthErrorState extends AuthState {
  final String message;

  const AuthErrorState({required this.message});

  @override
  List<Object> get props => [message];
}

final class AuthSignedUpState extends AuthState {
  final String userId;
  final String userRole;
  final String userName;

  const AuthSignedUpState({
    required this.userId,
    required this.userRole,
    required this.userName,
  });

  @override
  List<Object> get props => [userId, userRole, userName];
}

final class AuthSignedInState extends AuthState {
  final String userId;
  final String userRole;
  final String userName;

  const AuthSignedInState({
    required this.userId,
    required this.userRole,
    required this.userName,
  });

  @override
  List<Object> get props => [userId, userRole, userName];
}

final class AuthLogOutState extends AuthState {}

final class InstagramConnectedState extends AuthState {}

final class InstagramSessionConsumedState extends AuthState {
  final InstagramProfile profile;

  const InstagramSessionConsumedState({required this.profile});

  @override
  List<Object> get props => [profile];
}

final class InstagramSessionFinalizedState extends AuthState {}