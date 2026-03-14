part of 'freelancer_profile_bloc.dart';

abstract class FreelancerProfileEvent extends Equatable {
  const FreelancerProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadFreelancerProfileEvent extends FreelancerProfileEvent {
  final String freelancerId;

  const LoadFreelancerProfileEvent({required this.freelancerId});

  @override
  List<Object?> get props => [freelancerId];
}

class LoadFreelancerContractsEvent extends FreelancerProfileEvent {
  final String freelancerId;

  const LoadFreelancerContractsEvent({required this.freelancerId});

  @override
  List<Object?> get props => [freelancerId];
}

class LoadFreelancerRatingsEvent extends FreelancerProfileEvent {
  final String userId;

  const LoadFreelancerRatingsEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class LoadFreelancerPortfoliosEvent extends FreelancerProfileEvent {
  final String freelancerId;
  final String? type;
  final int page;
  final int pageSize;

  const LoadFreelancerPortfoliosEvent({
    required this.freelancerId,
    this.type,
    this.page = 1,
    this.pageSize = 10,
  });

  @override
  List<Object?> get props => [freelancerId, type, page, pageSize];
}
