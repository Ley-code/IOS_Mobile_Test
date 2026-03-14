import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile_app/features/business_owner/dashboard/data/models/job_model.dart';
import 'package:mobile_app/features/search/data/models/freelancer_profile_model.dart';
import 'package:mobile_app/features/search/data/repositories/search_repository.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchRepository repository;

  SearchBloc({required this.repository}) : super(SearchInitial()) {
    on<SearchJobsEvent>(_onSearchJobs);
    on<SearchFreelancersEvent>(_onSearchFreelancers);
    on<LoadAllFreelancersEvent>(_onLoadAllFreelancers);
    on<ClearSearchEvent>(_onClearSearch);
  }

  Future<void> _onSearchJobs(
    SearchJobsEvent event,
    Emitter<SearchState> emit,
  ) async {
    emit(SearchLoading());
    
    final result = await repository.searchJobs(
      searchTerm: event.searchTerm,
      page: event.page,
      pageSize: event.pageSize,
    );

    result.fold(
      (failure) => emit(SearchError(message: failure.message)),
      (data) {
        final jobsJson = data['jobs'] as List<dynamic>? ?? [];
        final jobs = jobsJson
            .map((j) => JobModel.fromJson(j as Map<String, dynamic>))
            .toList();
        final pagination = data['pagination'] as Map<String, dynamic>? ?? {};
        
        emit(SearchJobsLoaded(
          jobs: jobs,
          pagination: pagination,
          searchTerm: event.searchTerm,
        ));
      },
    );
  }

  Future<void> _onSearchFreelancers(
    SearchFreelancersEvent event,
    Emitter<SearchState> emit,
  ) async {
    emit(SearchLoading());
    
    final result = await repository.searchFreelancers(
      searchTerm: event.searchTerm,
      page: event.page,
      pageSize: event.pageSize,
    );

    result.fold(
      (failure) => emit(SearchError(message: failure.message)),
      (data) {
        final freelancersJson = data['freelancers'] as List<dynamic>? ?? [];
        final freelancers = freelancersJson
            .map((f) => FreelancerProfileModel.fromJson(f as Map<String, dynamic>))
            .toList();
        final pagination = data['pagination'] as Map<String, dynamic>? ?? {};
        
        emit(SearchFreelancersLoaded(
          freelancers: freelancers,
          pagination: pagination,
          searchTerm: event.searchTerm,
        ));
      },
    );
  }

  Future<void> _onLoadAllFreelancers(
    LoadAllFreelancersEvent event,
    Emitter<SearchState> emit,
  ) async {
    emit(SearchLoading());
    
    final result = await repository.getAllFreelancers();

    result.fold(
      (failure) => emit(SearchError(message: failure.message)),
      (freelancersData) {
        final freelancers = freelancersData
            .map((f) => FreelancerProfileModel.fromJson(f))
            .toList();
        
        emit(AllFreelancersLoaded(freelancers: freelancers));
      },
    );
  }

  void _onClearSearch(
    ClearSearchEvent event,
    Emitter<SearchState> emit,
  ) {
    emit(SearchInitial());
  }
}

