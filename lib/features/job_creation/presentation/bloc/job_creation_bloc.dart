import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile_app/features/job_creation/data/models/create_job_model.dart';
import 'package:mobile_app/features/job_creation/data/repositories/job_creation_repository.dart';

part 'job_creation_event.dart';
part 'job_creation_state.dart';

class JobCreationBloc extends Bloc<JobCreationEvent, JobCreationState> {
  final JobCreationRepository repository;

  JobCreationBloc({required this.repository}) : super(JobCreationInitial()) {
    on<CreateJobEvent>(_onCreateJob);
  }

  Future<void> _onCreateJob(
    CreateJobEvent event,
    Emitter<JobCreationState> emit,
  ) async {
    emit(JobCreationLoading());
    
    final result = await repository.createJob(event.jobModel);

    result.fold(
      (failure) => emit(JobCreationError(message: failure.message)),
      (success) => emit(JobCreationSuccess(message: success['message'] as String? ?? 'Job created successfully')),
    );
  }
}

