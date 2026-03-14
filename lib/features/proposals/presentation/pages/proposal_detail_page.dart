import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/core/storage/token_storage.dart';
import 'package:mobile_app/core/widgets/error_widget.dart';
import 'package:mobile_app/features/business_owner/dashboard/data/models/job_model.dart';
import 'package:mobile_app/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:mobile_app/features/chat/presentation/bloc/chat_event.dart';
import 'package:mobile_app/features/chat/presentation/bloc/chat_state.dart';
import 'package:mobile_app/features/proposals/domain/entities/proposal_with_user_entity.dart';
import 'package:mobile_app/features/proposals/presentation/bloc/proposals_bloc.dart';
import 'package:mobile_app/features/proposals/presentation/bloc/proposals_state.dart';
import 'package:mobile_app/features/proposals/presentation/pages/make_offer_page.dart';
import 'package:mobile_app/features/business_owner/dashboard/presentation/pages/business_owner_message_details_page.dart';
import 'package:mobile_app/core/network/api_client.dart';
import 'package:mobile_app/injection_container.dart' as di;
import 'dart:convert';
import 'package:intl/intl.dart';

class ProposalDetailPage extends StatefulWidget {
  final ProposalWithUserEntity proposal;
  final JobModel job;

  const ProposalDetailPage({
    super.key,
    required this.proposal,
    required this.job,
  });

  @override
  State<ProposalDetailPage> createState() => _ProposalDetailPageState();
}

class _ProposalDetailPageState extends State<ProposalDetailPage> {
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;
    final accent = theme.colorScheme.secondary;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;
    final subtleText =
        theme.textTheme.bodySmall?.color ?? Colors.white.withOpacity(0.7);
    final cardColor = theme.cardColor;

    return BlocProvider(
      create: (_) => di.sl<ChatBloc>(),
      child: MultiBlocListener(
        listeners: [
          BlocListener<ProposalsBloc, ProposalsState>(
            listener: (context, state) {
              if (state is OfferSubmitted) {
                _showSuccessDialog(context, theme, accent, cardColor, textColor,
                    subtleText);
              } else if (state is OfferError) {
                ErrorSnackbar.show(context, message: state.message);
              }
            },
          ),
          BlocListener<ChatBloc, ChatState>(
            listener: (context, state) async {
              if (state is ConversationStarted) {
                // Close loading dialog first
                if (Navigator.of(context, rootNavigator: true).canPop()) {
                  Navigator.of(context, rootNavigator: true).pop();
                }
                
                // Get user email and navigate directly to chat page
                // The chat page will handle room initialization and WebSocket connection
                final userEmail = await _getCurrentUserEmail();
                if (mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<ChatBloc>(),
                        child: BusinessOwnerMessageDetailsPage(
                          conversation: state.conversation,
                          userEmail: userEmail ?? '',
                        ),
                      ),
                    ),
                  );
                }
              } else if (state is ConversationError || 
                       state is RoomError || 
                       state is ChatConnectionError) {
                // Close loading dialog on any error
                if (Navigator.of(context, rootNavigator: true).canPop()) {
                  Navigator.of(context, rootNavigator: true).pop();
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      state is ConversationError
                          ? state.message
                          : state is RoomError
                              ? state.message
                              : (state as ChatConnectionError).message,
                    ),
                  ),
                );
              }
            },
          ),
        ],
        child: Scaffold(
        backgroundColor: primary,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back, color: textColor),
          ),
          title: Text(
            'Proposal Details',
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Campaign Summary Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Campaign Summary',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _InfoRow(
                      label: 'Budget Range',
                      value: widget.job.budgetRange,
                      textColor: textColor,
                      subtleText: subtleText,
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(
                      label: 'Status',
                      value: widget.job.jobStatus.toUpperCase(),
                      valueWidget: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: widget.job.isOpen
                              ? Colors.green.withOpacity(0.2)
                              : Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.job.isOpen ? 'Open' : 'Closed',
                          style: TextStyle(
                            color: widget.job.isOpen ? Colors.green : Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      textColor: textColor,
                      subtleText: subtleText,
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(
                      label: 'Posted',
                      value: DateFormat('M/d/yyyy').format(
                        DateTime.parse(widget.job.createdAt),
                      ),
                      textColor: textColor,
                      subtleText: subtleText,
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(
                      label: 'Payout Structure',
                      value: '${widget.proposal.primaryPayoutType}: ${widget.proposal.formattedRate}',
                      textColor: textColor,
                      subtleText: subtleText,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Creator Proposal Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Creator info
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: accent.withOpacity(0.2),
                          backgroundImage:
                              widget.proposal.user.profilePictureUrl != null
                                  ? NetworkImage(
                                      widget.proposal.user.profilePictureUrl!)
                                  : null,
                          child: widget.proposal.user.profilePictureUrl == null
                              ? Text(
                                  widget.proposal.user.initials,
                                  style: TextStyle(
                                    color: accent,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      widget.proposal.user.displayName,
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'Pending',
                                      style: TextStyle(
                                        color: Colors.orange,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '@${widget.proposal.user.userName}',
                                style: TextStyle(color: subtleText, fontSize: 14),
                              ),
                              if (widget.proposal.user.location != 'Not specified') ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.location_on,
                                        color: subtleText, size: 14),
                                    const SizedBox(width: 4),
                                    Text(
                                      widget.proposal.user.location,
                                      style: TextStyle(
                                        color: subtleText,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    Divider(color: subtleText.withOpacity(0.2)),
                    const SizedBox(height: 20),

                    // Proposal Message
                    Text(
                      'Proposal Message',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        widget.proposal.proposalText,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Proposed Rates
                    Text(
                      '\$ Proposed Rates:',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.proposal.primaryPayoutType,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            widget.proposal.formattedRate,
                            style: TextStyle(
                              color: accent,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                    Divider(color: subtleText.withOpacity(0.2)),
                    const SizedBox(height: 20),

                    // Submitted date
                    Row(
                      children: [
                        Icon(Icons.calendar_today,
                            color: subtleText, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Submitted ${DateFormat('M/d/yyyy').format(widget.proposal.createdAt)}',
                          style: TextStyle(color: subtleText, fontSize: 13),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              // TODO: View profile
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: textColor,
                              side: BorderSide(color: accent),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('View Profile'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _handleMessage(context, widget.proposal, widget.job),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: textColor,
                              side: BorderSide(color: accent),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Message'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BlocProvider.value(
                                value: context.read<ProposalsBloc>(),
                                child: MakeOfferPage(
                                  proposal: widget.proposal,
                                  job: widget.job,
                                ),
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Make Offer',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }

  Future<void> _handleMessage(
    BuildContext context,
    ProposalWithUserEntity proposal,
    JobModel job,
  ) async {
    try {
      final tokenStorage = di.sl<TokenStorage>();
      final currentUserId = await tokenStorage.getUserId();
      
      if (currentUserId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to get user information')),
        );
        return;
      }

      final chatBloc = context.read<ChatBloc>();
      
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Start conversation - the BlocListener will handle navigation
      chatBloc.add(StartConversation(
        clientId: currentUserId,
        freelancerId: proposal.user.id,
        jobId: job.jobId,
        proposalId: proposal.proposalId,
      ));
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<String?> _getCurrentUserEmail() async {
    try {
      final apiClient = di.sl<ApiClient>();
      final response = await apiClient.get(
        '/users/profile',
        requireAuth: true,
      );
      
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final user = json['user'] as Map<String, dynamic>?;
        return user?['email'] as String?;
      }
    } catch (e) {
      // Return null if unable to get email
    }
    return null;
  }

  void _showSuccessDialog(
    BuildContext context,
    ThemeData theme,
    Color accent,
    Color cardColor,
    Color textColor,
    Color subtleText,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 48,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Offer Sent!',
                style: TextStyle(
                  color: textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Your offer has been sent to the creator. They will be notified and can respond to your offer.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: subtleText,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Go back to proposal detail
                    Navigator.pop(context); // Go back to applicants list
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? valueWidget;
  final Color textColor;
  final Color subtleText;

  const _InfoRow({
    required this.label,
    this.value,
    this.valueWidget,
    required this.textColor,
    required this.subtleText,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: subtleText,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        valueWidget ??
            Text(
              value ?? '',
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
      ],
    );
  }
}

