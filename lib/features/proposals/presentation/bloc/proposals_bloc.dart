import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/features/proposals/domain/usecases/get_job_proposals.dart';
import 'package:mobile_app/features/proposals/domain/usecases/submit_offer.dart';
import 'package:mobile_app/features/proposals/presentation/bloc/proposals_event.dart';
import 'package:mobile_app/features/proposals/presentation/bloc/proposals_state.dart';

class ProposalsBloc extends Bloc<ProposalsEvent, ProposalsState> {
  final GetJobProposals getJobProposals;
  final SubmitOffer submitOffer;

  ProposalsBloc({
    required this.getJobProposals,
    required this.submitOffer,
  }) : super(ProposalsInitial()) {
    on<LoadJobProposals>(_onLoadJobProposals);
    on<RefreshJobProposals>(_onRefreshJobProposals);
    on<SubmitProposalOffer>(_onSubmitOffer);
    on<FilterProposals>(_onFilterProposals);
  }

  Future<void> _onLoadJobProposals(
    LoadJobProposals event,
    Emitter<ProposalsState> emit,
  ) async {
    emit(ProposalsLoading());

    final result = await getJobProposals(event.jobId);

    result.fold(
      (failure) => emit(ProposalsError(failure.message)),
      (proposals) => emit(ProposalsLoaded(proposals: proposals)),
    );
  }

  Future<void> _onRefreshJobProposals(
    RefreshJobProposals event,
    Emitter<ProposalsState> emit,
  ) async {
    final result = await getJobProposals(event.jobId);

    result.fold(
      (failure) => emit(ProposalsError(failure.message)),
      (proposals) {
        if (state is ProposalsLoaded) {
          final currentState = state as ProposalsLoaded;
          emit(currentState.copyWith(proposals: proposals));
        } else {
          emit(ProposalsLoaded(proposals: proposals));
        }
      },
    );
  }

  Future<void> _onSubmitOffer(
    SubmitProposalOffer event,
    Emitter<ProposalsState> emit,
  ) async {
    emit(OfferSubmitting());

    final result = await submitOffer(event.offer);

    result.fold(
      (failure) => emit(OfferError(failure.message)),
      (_) => emit(const OfferSubmitted()),
    );
  }

  void _onFilterProposals(
    FilterProposals event,
    Emitter<ProposalsState> emit,
  ) {
    if (state is ProposalsLoaded) {
      final currentState = state as ProposalsLoaded;
      var filtered = currentState.proposals;

      // Apply search filter
      if (event.searchQuery != null && event.searchQuery!.isNotEmpty) {
        final query = event.searchQuery!.toLowerCase();
        filtered = filtered.where((proposal) {
          final name = proposal.user.displayName.toLowerCase();
          final userName = proposal.user.userName.toLowerCase();
          final proposalText = proposal.proposalText.toLowerCase();
          return name.contains(query) ||
              userName.contains(query) ||
              proposalText.contains(query);
        }).toList();
      }

      // Apply sort
      if (event.sortBy != null) {
        switch (event.sortBy) {
          case 'lowest_bid':
            filtered.sort((a, b) {
              final rateA = a.primaryPayoutRate ?? double.infinity;
              final rateB = b.primaryPayoutRate ?? double.infinity;
              return rateA.compareTo(rateB);
            });
            break;
          case 'highest_rating':
            // TODO: Add rating when available
            break;
          case 'best_match':
          default:
            // Keep original order or implement best match logic
            break;
        }
      }

      emit(currentState.copyWith(
        filteredProposals: filtered,
        sortBy: event.sortBy,
        searchQuery: event.searchQuery,
      ));
    }
  }
}














