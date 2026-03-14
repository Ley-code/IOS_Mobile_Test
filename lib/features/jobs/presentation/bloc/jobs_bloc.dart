import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/core/usecase/usecase.dart';
import 'package:mobile_app/features/jobs/domain/usecases/get_jobs.dart';
import 'package:mobile_app/features/jobs/domain/usecases/get_job_by_id.dart';
import 'package:mobile_app/features/jobs/domain/usecases/submit_proposal.dart';
import 'package:mobile_app/features/jobs/domain/usecases/get_my_jobs.dart';
import 'package:mobile_app/features/jobs/presentation/bloc/jobs_event.dart';
import 'package:mobile_app/features/jobs/presentation/bloc/jobs_state.dart';

class JobsBloc extends Bloc<JobsEvent, JobsState> {
  final GetJobs getJobs;
  final GetJobById getJobById;
  final SubmitProposal submitProposal;
  final GetMyJobs getMyJobs;

  JobsBloc({
    required this.getJobs,
    required this.getJobById,
    required this.submitProposal,
    required this.getMyJobs,
  }) : super(JobsInitial()) {
    on<LoadJobs>(_onLoadJobs);
    on<RefreshJobs>(_onRefreshJobs);
    on<LoadJobById>(_onLoadJobById);
    on<SubmitJobProposal>(_onSubmitProposal);
    on<LoadMyJobs>(_onLoadMyJobs);
    on<SearchJobs>(_onSearchJobs);
    on<ClearSelectedJob>(_onClearSelectedJob);
  }

  Future<void> _onLoadJobs(LoadJobs event, Emitter<JobsState> emit) async {
    emit(JobsLoading());

    final result = await getJobs(NoParams());

    result.fold(
      (failure) => emit(JobsError(failure.message)),
      (jobs) => emit(JobsLoaded(jobs: jobs)),
    );
  }

  Future<void> _onRefreshJobs(
    RefreshJobs event,
    Emitter<JobsState> emit,
  ) async {
    final result = await getJobs(NoParams());

    result.fold(
      (failure) => emit(JobsError(failure.message)),
      (jobs) => emit(JobsLoaded(jobs: jobs)),
    );
  }

  Future<void> _onLoadJobById(
    LoadJobById event,
    Emitter<JobsState> emit,
  ) async {
    emit(JobDetailLoading());

    final result = await getJobById(event.jobId);

    result.fold(
      (failure) => emit(JobDetailError(failure.message)),
      (job) => emit(JobDetailLoaded(job)),
    );
  }

  Future<void> _onSubmitProposal(
    SubmitJobProposal event,
    Emitter<JobsState> emit,
  ) async {
    emit(ProposalSubmitting());

    final result = await submitProposal(event.proposal);

    result.fold(
      (failure) => emit(ProposalError(failure.message)),
      (_) => emit(const ProposalSubmitted()),
    );
  }

  Future<void> _onLoadMyJobs(LoadMyJobs event, Emitter<JobsState> emit) async {
    emit(MyJobsLoading());

    final result = await getMyJobs(NoParams());

    result.fold(
      (failure) => emit(MyJobsError(failure.message)),
      (jobs) => emit(MyJobsLoaded(jobs)),
    );
  }

  void _onSearchJobs(SearchJobs event, Emitter<JobsState> emit) {
    if (state is JobsLoaded) {
      final currentState = state as JobsLoaded;
      var filtered = currentState.jobs;

      // Filter by keyword
      if (event.keyword != null && event.keyword!.isNotEmpty) {
        final keyword = event.keyword!.toLowerCase();
        filtered = filtered.where((job) {
          return job.jobTitle.toLowerCase().contains(keyword) ||
              job.jobDescription.toLowerCase().contains(keyword) ||
              job.clientName.toLowerCase().contains(keyword);
        }).toList();
      }

      // Filter by categories
      if (event.categories != null && event.categories!.isNotEmpty) {
        filtered = filtered.where((job) {
          if (job.categoryName == null) return false;
          return event.categories!.contains(job.categoryName);
        }).toList();
      }

      // Filter by skills
      if (event.skills != null && event.skills!.isNotEmpty) {
        filtered = filtered.where((job) {
          return job.skills.any((skill) => event.skills!.contains(skill));
        }).toList();
      }

      // Filter by budget range
      if (event.minBudget != null) {
        filtered = filtered
            .where((job) => job.maximumBudget >= event.minBudget!)
            .toList();
      }
      if (event.maxBudget != null) {
        filtered = filtered
            .where((job) => job.minimumBudget <= event.maxBudget!)
            .toList();
      }

      emit(
        currentState.copyWith(
          filteredJobs: filtered,
          searchKeyword: event.keyword,
        ),
      );
    }
  }

  void _onClearSelectedJob(ClearSelectedJob event, Emitter<JobsState> emit) {
    if (state is JobDetailLoaded) {
      emit(JobsInitial());
    }
  }
}
