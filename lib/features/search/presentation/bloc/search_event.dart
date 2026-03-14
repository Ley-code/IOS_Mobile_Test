part of 'search_bloc.dart';

sealed class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class SearchJobsEvent extends SearchEvent {
  final String? searchTerm;
  final int page;
  final int pageSize;

  const SearchJobsEvent({
    this.searchTerm,
    this.page = 1,
    this.pageSize = 20,
  });

  @override
  List<Object?> get props => [searchTerm, page, pageSize];
}

class SearchFreelancersEvent extends SearchEvent {
  final String? searchTerm;
  final int page;
  final int pageSize;

  const SearchFreelancersEvent({
    this.searchTerm,
    this.page = 1,
    this.pageSize = 20,
  });

  @override
  List<Object?> get props => [searchTerm, page, pageSize];
}

class ClearSearchEvent extends SearchEvent {
  const ClearSearchEvent();
}

class LoadAllFreelancersEvent extends SearchEvent {
  const LoadAllFreelancersEvent();
}

