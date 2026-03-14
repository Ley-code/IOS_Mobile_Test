import 'package:equatable/equatable.dart';
import 'package:mobile_app/features/proposals/domain/entities/proposal_with_user_entity.dart';

abstract class ProposalsState extends Equatable {
  const ProposalsState();

  @override
  List<Object?> get props => [];
}

class ProposalsInitial extends ProposalsState {}

class ProposalsLoading extends ProposalsState {}

class ProposalsLoaded extends ProposalsState {
  final List<ProposalWithUserEntity> proposals;
  final List<ProposalWithUserEntity> filteredProposals;
  final String? sortBy;
  final String? searchQuery;

  const ProposalsLoaded({
    required this.proposals,
    List<ProposalWithUserEntity>? filteredProposals,
    this.sortBy,
    this.searchQuery,
  }) : filteredProposals = filteredProposals ?? proposals;

  @override
  List<Object?> get props => [proposals, filteredProposals, sortBy, searchQuery];

  ProposalsLoaded copyWith({
    List<ProposalWithUserEntity>? proposals,
    List<ProposalWithUserEntity>? filteredProposals,
    String? sortBy,
    String? searchQuery,
  }) {
    return ProposalsLoaded(
      proposals: proposals ?? this.proposals,
      filteredProposals: filteredProposals ?? this.filteredProposals,
      sortBy: sortBy ?? this.sortBy,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class ProposalsError extends ProposalsState {
  final String message;

  const ProposalsError(this.message);

  @override
  List<Object?> get props => [message];
}

class OfferSubmitting extends ProposalsState {}

class OfferSubmitted extends ProposalsState {
  final String message;

  const OfferSubmitted({this.message = 'Offer sent successfully!'});

  @override
  List<Object?> get props => [message];
}

class OfferError extends ProposalsState {
  final String message;

  const OfferError(this.message);

  @override
  List<Object?> get props => [message];
}














