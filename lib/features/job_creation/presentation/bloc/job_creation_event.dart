part of 'job_creation_bloc.dart';

sealed class JobCreationEvent extends Equatable {
  const JobCreationEvent();

  @override
  List<Object> get props => [];
}

class CreateJobEvent extends JobCreationEvent {
  final CreateJobModel jobModel;

  const CreateJobEvent({required this.jobModel});

  @override
  List<Object> get props => [jobModel];
}

