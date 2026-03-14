part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class LogInEvent extends AuthEvent {
  final LoginEntity logInEntity;

  const LogInEvent({required this.logInEntity});
  @override
  List<Object> get props => [logInEntity];
}

class BusinessSignUpEvent extends AuthEvent {
  final BusinessSignupEntity businessSignupEntity;

  const BusinessSignUpEvent({required this.businessSignupEntity});

  @override
  List<Object> get props => [businessSignupEntity];
}

class FreelancerSignUpEvent extends AuthEvent {
  final FreelancerSignupEntity freelancerSignupEntity;

  const FreelancerSignUpEvent({required this.freelancerSignupEntity});

  @override
  List<Object> get props => [freelancerSignupEntity];
}

class LogOutEvent extends AuthEvent {
  const LogOutEvent();
}

class ConnectInstagramEvent extends AuthEvent {
  final String code;
  final String state;

  const ConnectInstagramEvent({required this.code, required this.state});

  @override
  List<Object> get props => [code, state];
}

class ConsumeInstagramSessionEvent extends AuthEvent {
  final String sessionId;

  const ConsumeInstagramSessionEvent({required this.sessionId});

  @override
  List<Object> get props => [sessionId];
}

class FinalizeInstagramSessionEvent extends AuthEvent {
  final String sessionId;

  const FinalizeInstagramSessionEvent({required this.sessionId});

  @override
  List<Object> get props => [sessionId];
}