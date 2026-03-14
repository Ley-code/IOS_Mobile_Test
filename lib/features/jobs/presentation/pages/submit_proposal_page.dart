import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/core/widgets/error_widget.dart';
import 'package:mobile_app/features/jobs/domain/entities/job_entity.dart';
import 'package:mobile_app/features/jobs/domain/entities/proposal_entity.dart';
import 'package:mobile_app/features/jobs/presentation/bloc/jobs_bloc.dart';
import 'package:mobile_app/features/jobs/presentation/bloc/jobs_event.dart';
import 'package:mobile_app/features/jobs/presentation/bloc/jobs_state.dart';
import 'package:intl/intl.dart';

class SubmitProposalPage extends StatefulWidget {
  final JobEntity job;

  const SubmitProposalPage({super.key, required this.job});

  @override
  State<SubmitProposalPage> createState() => _SubmitProposalPageState();
}

class _SubmitProposalPageState extends State<SubmitProposalPage> {
  final _formKey = GlobalKey<FormState>();
  final _proposalController = TextEditingController();
  final _rateController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill with client's offered rate if available
    if (widget.job.primaryPayoutRate != null) {
      _rateController.text = widget.job.primaryPayoutRate!.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _proposalController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  void _submitProposal() {
    if (!_formKey.currentState!.validate()) return;

    final rate = double.tryParse(_rateController.text) ?? 0.0;
    final payoutType = widget.job.payoutTypes.isNotEmpty
        ? widget.job.payoutTypes.first
        : 'per_project';

    final proposal = ProposalEntity(
      jobId: widget.job.jobId,
      proposalText: _proposalController.text.trim(),
      proposalRate: {payoutType: rate},
    );

    context.read<JobsBloc>().add(SubmitJobProposal(proposal));
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

    return BlocListener<JobsBloc, JobsState>(
      listener: (context, state) {
        if (state is ProposalSubmitting) {
          setState(() => _isSubmitting = true);
        } else if (state is ProposalSubmitted) {
          setState(() => _isSubmitting = false);
          _showSuccessDialog(context);
        } else if (state is ProposalError) {
          setState(() => _isSubmitting = false);
          ErrorSnackbar.show(context, message: state.message);
        }
      },
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
            'Submit Proposal',
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Apply for this Campaign',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Send your proposal to the client',
                  style: TextStyle(color: subtleText, fontSize: 14),
                ),

                const SizedBox(height: 24),

                // Campaign details card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.campaign, color: accent, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Campaign Details',
                            style: TextStyle(
                              color: subtleText,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.job.jobTitle,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _DetailChip(
                            icon: Icons.attach_money,
                            label: widget.job.budgetRange,
                            color: accent,
                          ),
                          const SizedBox(width: 12),
                          _DetailChip(
                            icon: Icons.calendar_today,
                            label: DateFormat(
                              'M/d/yyyy',
                            ).format(widget.job.createdAt),
                            color: subtleText,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Divider(color: subtleText.withOpacity(0.2)),
                      const SizedBox(height: 16),
                      Text(
                        'Description',
                        style: TextStyle(
                          color: subtleText,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.job.jobDescription,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 14,
                          height: 1.5,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Text(
                            "Client's Payout Structure",
                            style: TextStyle(
                              color: subtleText,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.job.primaryPayoutType,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            widget.job.primaryPayoutRate != null
                                ? '\$${widget.job.primaryPayoutRate!.toStringAsFixed(2)}'
                                : 'Negotiable',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Client info
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: accent.withOpacity(0.2),
                            child: Text(
                              (widget.job.clientName.isNotEmpty
                                      ? widget.job.clientName[0]
                                      : 'C')
                                  .toUpperCase(),
                              style: TextStyle(
                                color: accent,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.job.clientName.isNotEmpty
                                    ? widget.job.clientName
                                    : 'Client',
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (widget.job.clientCompany != null)
                                Text(
                                  widget.job.clientCompany!,
                                  style: TextStyle(
                                    color: subtleText,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Your proposal section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.edit_note, color: accent, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Your Proposal',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tell the client why you\'re the right fit',
                        style: TextStyle(color: subtleText, fontSize: 13),
                      ),
                      const SizedBox(height: 16),

                      // Proposal message
                      Text(
                        'Proposal Message *',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _proposalController,
                        maxLines: 5,
                        maxLength: 500,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          hintText:
                              'Explain why you\'re perfect for this job, your relevant experience, and how you\'ll deliver great results...',
                          hintStyle: TextStyle(
                            color: subtleText.withOpacity(0.7),
                            fontSize: 14,
                          ),
                          filled: true,
                          fillColor: primary,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          counterStyle: TextStyle(color: subtleText),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please write a proposal message';
                          }
                          if (value.trim().length < 50) {
                            return 'Proposal should be at least 50 characters';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Rate input
                      Text(
                        'Your Rate *',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Set your rate for ${widget.job.primaryPayoutType.toLowerCase()}',
                        style: TextStyle(color: subtleText, fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  widget.job.primaryPayoutType,
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (widget.job.primaryPayoutRate != null)
                                  Text(
                                    'Client offers: \$${widget.job.primaryPayoutRate!.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: subtleText,
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _rateController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d+\.?\d{0,2}'),
                                ),
                              ],
                              style: TextStyle(
                                color: textColor,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                              decoration: InputDecoration(
                                prefixText: '\$ ',
                                prefixStyle: TextStyle(
                                  color: accent,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                ),
                                filled: true,
                                fillColor: cardColor,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your rate';
                                }
                                final rate = double.tryParse(value);
                                if (rate == null || rate <= 0) {
                                  return 'Please enter a valid rate';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitProposal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: accent.withOpacity(0.5),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.send, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Submit Proposal',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.secondary;
    final cardColor = theme.cardColor;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;
    final subtleText =
        theme.textTheme.bodySmall?.color ?? Colors.white.withOpacity(0.7);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                'Proposal Submitted!',
                style: TextStyle(
                  color: textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Your proposal has been sent to the client. You\'ll be notified when they respond.',
                textAlign: TextAlign.center,
                style: TextStyle(color: subtleText, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Go back to job detail
                    Navigator.pop(context); // Go back to job list
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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

class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _DetailChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
