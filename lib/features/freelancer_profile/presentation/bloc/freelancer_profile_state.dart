part of 'freelancer_profile_bloc.dart';

abstract class FreelancerProfileState extends Equatable {
  const FreelancerProfileState();

  @override
  List<Object?> get props => [];
}

class FreelancerProfileInitial extends FreelancerProfileState {}

class FreelancerProfileLoading extends FreelancerProfileState {}

class FreelancerProfileLoaded extends FreelancerProfileState {
  final FreelancerProfileDetailModel profile;

  const FreelancerProfileLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}

class FreelancerContractsLoaded extends FreelancerProfileState {
  final List<ContractModel> contracts;

  const FreelancerContractsLoaded(this.contracts);

  @override
  List<Object?> get props => [contracts];
}

class FreelancerRatingsLoaded extends FreelancerProfileState {
  final List<Map<String, dynamic>> ratings;

  const FreelancerRatingsLoaded(this.ratings);

  @override
  List<Object?> get props => [ratings];
}

class FreelancerPortfoliosLoaded extends FreelancerProfileState {
  final List<PortfolioItemModel> portfolios;

  FreelancerPortfoliosLoaded(this.portfolios);

  @override
  List<Object?> get props => [portfolios];
}

class FreelancerProfileError extends FreelancerProfileState {
  final String message;

  const FreelancerProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
