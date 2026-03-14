import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile_app/features/business_owner/dashboard/data/models/job_model.dart';
import 'package:mobile_app/features/business_owner/dashboard/data/models/user_profile_model.dart';
import 'package:mobile_app/features/business_owner/dashboard/data/models/update_profile_params.dart';
import 'package:mobile_app/features/business_owner/dashboard/data/repositories/dashboard_repository.dart';
import 'package:mobile_app/features/content_creator/dashboard/domain/repositories/influencer_dashboard_repository.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepository repository;
  final InfluencerDashboardRepository? influencerRepository;

  DashboardBloc({required this.repository, this.influencerRepository})
    : super(DashboardInitial()) {
    on<LoadDashboardData>(_onLoadDashboardData);
    on<RefreshDashboardData>(_onRefreshDashboardData);
    on<UpdateClientProfileEvent>(_onUpdateClientProfile);
    on<UpdateFreelancerProfileEvent>(_onUpdateFreelancerProfile);
  }

  Future<void> _onLoadDashboardData(
    LoadDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());

    final profileResult = await repository.getUserProfile();
    final jobsResult = await repository.getClientJobs();
    final completionResult = await repository.getProfileCompletionPercentage();

    profileResult.fold(
      (failure) => emit(DashboardError(message: failure.message)),
      (profile) {
        jobsResult.fold(
          (failure) => emit(DashboardError(message: failure.message)),
          (jobs) {
            completionResult.fold(
              (failure) => emit(
                DashboardLoaded(
                  profile: profile,
                  jobs: jobs,
                  profileCompletionPercentage: 0,
                ),
              ),
              (percentage) => emit(
                DashboardLoaded(
                  profile: profile,
                  jobs: jobs,
                  profileCompletionPercentage: percentage,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _onRefreshDashboardData(
    RefreshDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    if (state is DashboardLoaded) {
      emit(
        DashboardRefreshing(
          profile: (state as DashboardLoaded).profile,
          jobs: (state as DashboardLoaded).jobs,
          profileCompletionPercentage:
              (state as DashboardLoaded).profileCompletionPercentage,
        ),
      );
    } else {
      emit(DashboardLoading());
    }

    final profileResult = await repository.getUserProfile();
    final jobsResult = await repository.getClientJobs();
    final completionResult = await repository.getProfileCompletionPercentage();

    profileResult.fold(
      (failure) => emit(DashboardError(message: failure.message)),
      (profile) {
        jobsResult.fold(
          (failure) => emit(DashboardError(message: failure.message)),
          (jobs) {
            completionResult.fold(
              (failure) => emit(
                DashboardLoaded(
                  profile: profile,
                  jobs: jobs,
                  profileCompletionPercentage: 0,
                ),
              ),
              (percentage) => emit(
                DashboardLoaded(
                  profile: profile,
                  jobs: jobs,
                  profileCompletionPercentage: percentage,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _onUpdateClientProfile(
    UpdateClientProfileEvent event,
    Emitter<DashboardState> emit,
  ) async {
    print('==== _onUpdateClientProfile HANDLER CALLED ====');
    final currentState = state;
    print('Current state: $currentState');
    if (currentState is! DashboardLoaded &&
        currentState is! DashboardRefreshing &&
        currentState is! ProfileUpdating &&
        currentState is! ProfileUpdateSuccess) {
      print('ERROR: State is not valid for update, returning early');
      return;
    }

    final profile = _getCurrentProfile(currentState);
    final jobs = _getCurrentJobs(currentState);

    if (profile == null || jobs == null) {
      print('ERROR: profile or jobs is null');
      return;
    }

    print('Emitting ProfileUpdating state');
    emit(ProfileUpdating(profile: profile, jobs: jobs));

    final result = await repository.updateClientProfile(event.params);

    if (result.isLeft()) {
      result.fold(
        (failure) => emit(
          ProfileUpdateError(
            message: failure.message,
            profile: profile,
            jobs: jobs,
          ),
        ),
        (_) {},
      );
    } else {
      // Success - refresh profile and completion percentage after update
      final profileResult = await repository.getUserProfile();
      final completionResult = await repository
          .getProfileCompletionPercentage();

      profileResult.fold(
        (failure) => emit(ProfileUpdateSuccess(profile: profile, jobs: jobs)),
        (newProfile) {
          completionResult.fold(
            (failure) =>
                emit(ProfileUpdateSuccess(profile: newProfile, jobs: jobs)),
            (percentage) {
              // After successful update, reload dashboard to get updated completion
              add(const LoadDashboardData());
            },
          );
        },
      );
    }
  }

  Future<void> _onUpdateFreelancerProfile(
    UpdateFreelancerProfileEvent event,
    Emitter<DashboardState> emit,
  ) async {
    print('==== _onUpdateFreelancerProfile HANDLER CALLED ====');
    final currentState = state;
    print('Current state: $currentState');
    if (currentState is! DashboardLoaded &&
        currentState is! DashboardRefreshing &&
        currentState is! ProfileUpdating &&
        currentState is! ProfileUpdateSuccess) {
      print('ERROR: State is not valid for update, returning early');
      return;
    }

    final profile = _getCurrentProfile(currentState);
    final jobs = _getCurrentJobs(currentState);

    if (profile == null || jobs == null) {
      print('ERROR: profile or jobs is null');
      return;
    }

    print('Emitting ProfileUpdating state');
    emit(ProfileUpdating(profile: profile, jobs: jobs));

    if (influencerRepository == null) {
      emit(
        ProfileUpdateError(
          message: 'Influencer repository not available',
          profile: profile,
          jobs: jobs,
        ),
      );
      return;
    }

    final result = await influencerRepository!.updateFreelancerProfile(
      event.params,
    );

    if (result.isLeft()) {
      result.fold(
        (failure) => emit(
          ProfileUpdateError(
            message: failure.message,
            profile: profile,
            jobs: jobs,
          ),
        ),
        (_) {},
      );
    } else {
      // Success - refresh profile and completion percentage after update
      // Reload dashboard to get updated completion
      add(const LoadDashboardData());
    }
  }

  UserProfileModel? _getCurrentProfile(DashboardState state) {
    if (state is DashboardLoaded) return state.profile;
    if (state is DashboardRefreshing) return state.profile;
    if (state is ProfileUpdating) return state.profile;
    if (state is ProfileUpdateSuccess) return state.profile;
    if (state is ProfileUpdateError) return state.profile;
    return null;
  }

  List<JobModel>? _getCurrentJobs(DashboardState state) {
    if (state is DashboardLoaded) return state.jobs;
    if (state is DashboardRefreshing) return state.jobs;
    if (state is ProfileUpdating) return state.jobs;
    if (state is ProfileUpdateSuccess) return state.jobs;
    if (state is ProfileUpdateError) return state.jobs;
    return null;
  }
}
