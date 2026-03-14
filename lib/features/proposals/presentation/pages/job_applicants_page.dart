import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/core/widgets/shimmer_loading.dart';
import 'package:mobile_app/core/widgets/error_widget.dart';
import 'package:mobile_app/features/business_owner/dashboard/data/models/job_model.dart';
import 'package:mobile_app/features/proposals/domain/entities/proposal_with_user_entity.dart';
import 'package:mobile_app/features/proposals/presentation/bloc/proposals_bloc.dart';
import 'package:mobile_app/features/proposals/presentation/bloc/proposals_event.dart';
import 'package:mobile_app/features/proposals/presentation/bloc/proposals_state.dart';
import 'package:mobile_app/features/proposals/presentation/pages/proposal_detail_page.dart';

class JobApplicantsPage extends StatefulWidget {
  final JobModel job;

  const JobApplicantsPage({super.key, required this.job});

  @override
  State<JobApplicantsPage> createState() => _JobApplicantsPageState();
}

class _JobApplicantsPageState extends State<JobApplicantsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _sortBy = 'best_match';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    context.read<ProposalsBloc>().add(
      FilterProposals(
        searchQuery: query.isEmpty ? null : query,
        sortBy: _sortBy,
      ),
    );
  }

  void _onSortChanged(String? value) {
    if (value != null) {
      setState(() => _sortBy = value);
      context.read<ProposalsBloc>().add(
        FilterProposals(
          sortBy: value,
          searchQuery: _searchController.text.isEmpty
              ? null
              : _searchController.text,
        ),
      );
    }
  }

  Future<void> _onRefresh() async {
    context.read<ProposalsBloc>().add(RefreshJobProposals(widget.job.jobId));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;
    final accent = theme.colorScheme.secondary;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;
    final subtleText =
        theme.textTheme.bodySmall?.color ?? Colors.white.withOpacity(0.7);
    final cardColor = theme.cardColor;

    return Scaffold(
      backgroundColor: primary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: textColor),
        ),
        title: Text(
          widget.job.jobTitle,
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: BlocBuilder<ProposalsBloc, ProposalsState>(
        builder: (context, state) {
          // Auto-load proposals when state is initial
          if (state is ProposalsInitial) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted &&
                  context.read<ProposalsBloc>().state is ProposalsInitial) {
                context.read<ProposalsBloc>().add(
                  LoadJobProposals(widget.job.jobId),
                );
              }
            });
          }

          return Column(
            children: [
              // Header info
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BlocBuilder<ProposalsBloc, ProposalsState>(
                      builder: (context, state) {
                        int count = 0;
                        if (state is ProposalsLoaded) {
                          count = state.filteredProposals.length;
                        }
                        return Text(
                          '$count Proposals',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Review proposals from creators who want to help with your campaign',
                      style: TextStyle(color: subtleText, fontSize: 14),
                    ),
                  ],
                ),
              ),

              // Search and filter bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: _onSearch,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          hintText: 'Search applicants by name or handle...',
                          hintStyle: TextStyle(color: subtleText),
                          prefixIcon: Icon(Icons.search, color: subtleText),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    _onSearch('');
                                  },
                                  icon: Icon(Icons.clear, color: subtleText),
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Sort tabs
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _SortChip(
                            label: 'Best Match',
                            isSelected: _sortBy == 'best_match',
                            onTap: () => _onSortChanged('best_match'),
                            accent: accent,
                            textColor: textColor,
                          ),
                          const SizedBox(width: 8),
                          _SortChip(
                            label: 'Lowest Bid',
                            isSelected: _sortBy == 'lowest_bid',
                            onTap: () => _onSortChanged('lowest_bid'),
                            accent: accent,
                            textColor: textColor,
                          ),
                          const SizedBox(width: 8),
                          _SortChip(
                            label: 'Highest Rating',
                            isSelected: _sortBy == 'highest_rating',
                            onTap: () => _onSortChanged('highest_rating'),
                            accent: accent,
                            textColor: textColor,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Proposals list
              Expanded(
                child: Builder(
                  builder: (context) {
                    final state = context.watch<ProposalsBloc>().state;
                    if (state is ProposalsLoading) {
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: 3,
                        itemBuilder: (context, index) => const Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: ShimmerCard(height: 200),
                        ),
                      );
                    }

                    if (state is ProposalsError) {
                      return AppErrorWidget(
                        message: 'Failed to load proposals',
                        details: state.message,
                        onRetry: () => context.read<ProposalsBloc>().add(
                          LoadJobProposals(widget.job.jobId),
                        ),
                      );
                    }

                    if (state is ProposalsLoaded) {
                      if (state.filteredProposals.isEmpty) {
                        return AppErrorWidget.empty(
                          message: 'No proposals found',
                          details: state.searchQuery != null
                              ? 'Try adjusting your search'
                              : 'No one has applied yet',
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: _onRefresh,
                        color: accent,
                        backgroundColor: cardColor,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: state.filteredProposals.length,
                          itemBuilder: (context, index) {
                            final proposal = state.filteredProposals[index];
                            return _ProposalCard(
                              proposal: proposal,
                              job: widget.job,
                              accent: accent,
                              textColor: textColor,
                              subtleText: subtleText,
                              cardColor: cardColor,
                            );
                          },
                        ),
                      );
                    }

                    return const SizedBox();
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color accent;
  final Color textColor;

  const _SortChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.accent,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? accent : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? accent : textColor.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : textColor.withOpacity(0.7),
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _ProposalCard extends StatelessWidget {
  final ProposalWithUserEntity proposal;
  final JobModel job;
  final Color accent;
  final Color textColor;
  final Color subtleText;
  final Color cardColor;

  const _ProposalCard({
    required this.proposal,
    required this.job,
    required this.accent,
    required this.textColor,
    required this.subtleText,
    required this.cardColor,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info row
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: accent.withOpacity(0.2),
                backgroundImage: proposal.user.profilePictureUrl != null
                    ? NetworkImage(proposal.user.profilePictureUrl!)
                    : null,
                child: proposal.user.profilePictureUrl == null
                    ? Text(
                        proposal.user.initials,
                        style: TextStyle(
                          color: accent,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      proposal.user.displayName,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '@${proposal.user.userName}',
                      style: TextStyle(color: subtleText, fontSize: 13),
                    ),
                    if (proposal.user.location != 'Not specified') ...[
                      const SizedBox(height: 2),
                      Text(
                        proposal.user.location,
                        style: TextStyle(color: subtleText, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      proposal.formattedRate,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    proposal.timeAgo,
                    style: TextStyle(color: subtleText, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Proposal message
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primary.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              proposal.proposalText,
              style: TextStyle(color: textColor, fontSize: 14, height: 1.4),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    final proposalsBloc = context.read<ProposalsBloc>();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BlocProvider.value(
                          value: proposalsBloc,
                          child: ProposalDetailPage(
                            proposal: proposal,
                            job: job,
                          ),
                        ),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: textColor,
                    side: BorderSide(color: accent),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('View Proposal'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final proposalsBloc = context.read<ProposalsBloc>();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BlocProvider.value(
                          value: proposalsBloc,
                          child: ProposalDetailPage(
                            proposal: proposal,
                            job: job,
                          ),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Make Offer'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
