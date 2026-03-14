import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/core/widgets/error_widget.dart';
import 'package:mobile_app/features/business_owner/dashboard/data/models/job_model.dart';
import 'package:mobile_app/features/proposals/domain/entities/offer_entity.dart';
import 'package:mobile_app/features/proposals/domain/entities/proposal_with_user_entity.dart';
import 'package:mobile_app/features/proposals/presentation/bloc/proposals_bloc.dart';
import 'package:mobile_app/features/proposals/presentation/bloc/proposals_event.dart';
import 'package:mobile_app/features/proposals/presentation/bloc/proposals_state.dart';
import 'package:intl/intl.dart';

class MakeOfferPage extends StatefulWidget {
  final ProposalWithUserEntity proposal;
  final JobModel job;

  const MakeOfferPage({super.key, required this.proposal, required this.job});

  @override
  State<MakeOfferPage> createState() => _MakeOfferPageState();
}

class _MakeOfferPageState extends State<MakeOfferPage> {
  final _formKey = GlobalKey<FormState>();
  final _offerMessageController = TextEditingController();
  final _rateController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill with default message
    _offerMessageController.text =
        "We'd like to offer you this campaign at your requested rates.";
    // Pre-fill with proposal rate
    if (widget.proposal.primaryPayoutRate != null) {
      _rateController.text = widget.proposal.primaryPayoutRate!.toStringAsFixed(
        2,
      );
    }
    // Listen to rate changes to update summary
    _rateController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _offerMessageController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  void _submitOffer() {
    if (!_formKey.currentState!.validate()) return;

    final rate = double.tryParse(_rateController.text) ?? 0.0;
    final payoutType = widget.proposal.proposalRate.keys.isNotEmpty
        ? widget.proposal.proposalRate.keys.first
        : 'per_project';

    final offer = OfferEntity(
      proposalId: widget.proposal.proposalId,
      offerMessage: _offerMessageController.text.trim(),
      payoutRates: {payoutType: rate},
    );

    context.read<ProposalsBloc>().add(SubmitProposalOffer(offer));
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

    return BlocListener<ProposalsBloc, ProposalsState>(
      listener: (context, state) {
        if (state is OfferSubmitting) {
          setState(() => _isSubmitting = true);
        } else if (state is OfferSubmitted) {
          setState(() => _isSubmitting = false);
          // Show success dialog
          _showSuccessDialog();
        } else if (state is OfferError) {
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
            'Make Offer',
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
                Text(
                  'Send an offer to',
                  style: TextStyle(color: subtleText, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.proposal.user.displayName,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 24),

                // Proposal Details Card
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
                          Icon(Icons.info_outline, color: accent, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Proposal Details',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Creator info
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: accent.withOpacity(0.2),
                            backgroundImage:
                                widget.proposal.user.profilePictureUrl != null
                                ? NetworkImage(
                                    widget.proposal.user.profilePictureUrl!,
                                  )
                                : null,
                            child:
                                widget.proposal.user.profilePictureUrl == null
                                ? Text(
                                    widget.proposal.user.initials,
                                    style: TextStyle(
                                      color: accent,
                                      fontSize: 16,
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
                                  widget.proposal.user.displayName,
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (widget.proposal.user.location !=
                                    'Not specified')
                                  Text(
                                    widget.proposal.user.location,
                                    style: TextStyle(
                                      color: subtleText,
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Divider(color: subtleText.withOpacity(0.2)),
                      const SizedBox(height: 16),
                      Text(
                        'Campaign',
                        style: TextStyle(
                          color: subtleText,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.job.jobTitle,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.job.jobDescription,
                        style: TextStyle(
                          color: subtleText,
                          fontSize: 14,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 16),
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
                            ).format(DateTime.parse(widget.job.createdAt)),
                            color: subtleText,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Divider(color: subtleText.withOpacity(0.2)),
                      const SizedBox(height: 16),
                      Text(
                        'Proposal Message',
                        style: TextStyle(
                          color: subtleText,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.proposal.proposalText,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 14,
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '\$ Freelancer\'s Proposed Rates:',
                              style: TextStyle(
                                color: subtleText,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${widget.proposal.primaryPayoutType}: ${widget.proposal.formattedRate}',
                              style: TextStyle(
                                color: accent,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Your Offer Card
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
                            'Your Offer',
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
                        'Set your terms and rates',
                        style: TextStyle(color: subtleText, fontSize: 13),
                      ),
                      const SizedBox(height: 20),

                      // Offer Message
                      Text(
                        'Offer Message',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _offerMessageController,
                        maxLines: 4,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          hintText: 'Enter your offer message...',
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
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter an offer message';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Payout Rates
                      Text(
                        'Payout Rates',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Set your rates for ${widget.proposal.primaryPayoutType.toLowerCase()}',
                        style: TextStyle(color: subtleText, fontSize: 13),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.proposal.primaryPayoutType,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
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
                                  return 'Please enter a rate';
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

                      const SizedBox(height: 20),

                      // Your Offer Rates Summary
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Your Offer Rates',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${widget.proposal.primaryPayoutType}: \$${_rateController.text.isEmpty ? "0.00" : _rateController.text}',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
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
                    onPressed: _isSubmitting ? null : _submitOffer,
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
                                'Send Offer',
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

  void _showSuccessDialog() {
    final theme = Theme.of(context);
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
                'Offer Created Successfully!',
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
                style: TextStyle(color: subtleText, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    if (mounted) {
                      Navigator.pop(context); // Go back
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Done',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
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
