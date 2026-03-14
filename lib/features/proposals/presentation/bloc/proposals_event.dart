import 'package:equatable/equatable.dart';
import 'package:mobile_app/features/proposals/domain/entities/offer_entity.dart';

abstract class ProposalsEvent extends Equatable {
  const ProposalsEvent();

  @override
  List<Object?> get props => [];
}

class LoadJobProposals extends ProposalsEvent {
  final String jobId;

  const LoadJobProposals(this.jobId);

  @override
  List<Object?> get props => [jobId];
}

class RefreshJobProposals extends ProposalsEvent {
  final String jobId;

  const RefreshJobProposals(this.jobId);

  @override
  List<Object?> get props => [jobId];
}

class SubmitProposalOffer extends ProposalsEvent {
  final OfferEntity offer;

  const SubmitProposalOffer(this.offer);

  @override
  List<Object?> get props => [offer];
}

class FilterProposals extends ProposalsEvent {
  final String? sortBy; // 'best_match', 'lowest_bid', 'highest_rating'
  final String? searchQuery;

  const FilterProposals({this.sortBy, this.searchQuery});

  @override
  List<Object?> get props => [sortBy, searchQuery];
}














