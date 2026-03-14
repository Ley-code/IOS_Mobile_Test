part of 'job_creation_bloc.dart';

sealed class JobCreationState extends Equatable {
  const JobCreationState();

  @override
  List<Object> get props => [];
}

class JobCreationInitial extends JobCreationState {}

class JobCreationLoading extends JobCreationState {}

class JobCreationSuccess extends JobCreationState {
  final String message;

  const JobCreationSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

class JobCreationError extends JobCreationState {
  final String message;

  const JobCreationError({required this.message});

  @override
  List<Object> get props => [message];
}

