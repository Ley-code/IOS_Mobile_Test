import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile_app/features/freelancer_profile/data/models/freelancer_profile_detail_model.dart';
import 'package:mobile_app/features/freelancer_profile/domain/usecases/get_freelancer_contracts.dart';
import 'package:mobile_app/features/freelancer_profile/domain/usecases/get_freelancer_portfolios.dart';
import 'package:mobile_app/features/freelancer_profile/domain/usecases/get_freelancer_profile.dart';
import 'package:mobile_app/features/freelancer_profile/domain/usecases/get_freelancer_ratings.dart';

part 'freelancer_profile_event.dart';
part 'freelancer_profile_state.dart';

class FreelancerProfileBloc
    extends Bloc<FreelancerProfileEvent, FreelancerProfileState> {
  final GetFreelancerProfile getFreelancerProfile;
  final GetFreelancerContracts getFreelancerContracts;
  final GetFreelancerRatings getFreelancerRatings;
  final GetFreelancerPortfolios getFreelancerPortfolios;

  FreelancerProfileBloc({
    required this.getFreelancerProfile,
    required this.getFreelancerContracts,
    required this.getFreelancerRatings,
    required this.getFreelancerPortfolios,
  }) : super(FreelancerProfileInitial()) {
    on<LoadFreelancerProfileEvent>(_onLoadFreelancerProfile);
    on<LoadFreelancerContractsEvent>(_onLoadFreelancerContracts);
    on<LoadFreelancerRatingsEvent>(_onLoadFreelancerRatings);
    on<LoadFreelancerPortfoliosEvent>(_onLoadFreelancerPortfolios);
  }

  Future<void> _onLoadFreelancerProfile(
    LoadFreelancerProfileEvent event,
    Emitter<FreelancerProfileState> emit,
  ) async {
    emit(FreelancerProfileLoading());
    final result = await getFreelancerProfile(
      GetFreelancerProfileParams(freelancerId: event.freelancerId),
    );
    result.fold(
      (failure) => emit(FreelancerProfileError(failure.message)),
      (profile) => emit(FreelancerProfileLoaded(profile)),
    );
  }

  Future<void> _onLoadFreelancerContracts(
    LoadFreelancerContractsEvent event,
    Emitter<FreelancerProfileState> emit,
  ) async {
    final result = await getFreelancerContracts(
      GetFreelancerContractsParams(freelancerId: event.freelancerId),
    );
    result.fold(
      (failure) => emit(FreelancerProfileError(failure.message)),
      (contracts) => emit(FreelancerContractsLoaded(contracts)),
    );
  }

  Future<void> _onLoadFreelancerRatings(
    LoadFreelancerRatingsEvent event,
    Emitter<FreelancerProfileState> emit,
  ) async {
    final result = await getFreelancerRatings(
      GetFreelancerRatingsParams(userId: event.userId),
    );
    result.fold(
      (failure) => emit(FreelancerProfileError(failure.message)),
      (ratings) => emit(FreelancerRatingsLoaded(ratings)),
    );
  }

  Future<void> _onLoadFreelancerPortfolios(
    LoadFreelancerPortfoliosEvent event,
    Emitter<FreelancerProfileState> emit,
  ) async {
    final result = await getFreelancerPortfolios(
      GetFreelancerPortfoliosParams(
        freelancerId: event.freelancerId,
        type: event.type,
        page: event.page,
        pageSize: event.pageSize,
      ),
    );
    result.fold(
      (failure) => emit(FreelancerProfileError(failure.message)),
      (portfolios) => emit(FreelancerPortfoliosLoaded(portfolios)),
    );
  }
}
