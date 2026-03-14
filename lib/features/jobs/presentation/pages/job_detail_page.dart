import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/features/jobs/domain/entities/job_entity.dart';
import 'package:mobile_app/features/jobs/presentation/bloc/jobs_bloc.dart';
import 'package:mobile_app/features/jobs/presentation/pages/submit_proposal_page.dart';
import 'package:intl/intl.dart';

class JobDetailPage extends StatelessWidget {
  final JobEntity job;

  const JobDetailPage({super.key, required this.job});

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
      body: CustomScrollView(
        slivers: [
          // App bar
          SliverAppBar(
            backgroundColor: primary,
            pinned: true,
            expandedHeight: 120,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.arrow_back, color: textColor, size: 20),
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  // TODO: Share job
                },
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.share, color: textColor, size: 20),
                ),
              ),
              IconButton(
                onPressed: () {
                  // TODO: Bookmark job
                },
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.bookmark_border,
                    color: textColor,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                padding: const EdgeInsets.fromLTRB(16, 80, 16, 8),
                alignment: Alignment.bottomLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: job.isOpen
                        ? Colors.green.withOpacity(0.2)
                        : Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    job.isOpen ? '● Open' : '● Closed',
                    style: TextStyle(
                      color: job.isOpen ? Colors.green : Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Job title
                  Text(
                    job.jobTitle,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Budget and date row
                  Row(
                    children: [
                      _InfoChip(
                        icon: Icons.attach_money,
                        label: job.budgetRange,
                        color: accent,
                      ),
                      const SizedBox(width: 12),
                      _InfoChip(
                        icon: Icons.calendar_today,
                        label: _formatDate(job.createdAt),
                        color: subtleText,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Description section
                  _SectionCard(
                    title: 'Project Description',
                    child: Text(
                      job.jobDescription,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 15,
                        height: 1.6,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Skills section
                  _SectionCard(
                    title: 'Skills Required',
                    child: job.skills.isNotEmpty
                        ? Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: job.skills
                                .map((skill) => _SkillTag(label: skill))
                                .toList(),
                          )
                        : Text(
                            'No specific skills listed',
                            style: TextStyle(
                              color: subtleText,
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                  ),

                  const SizedBox(height: 16),

                  // Payment section
                  _SectionCard(
                    title: 'Payment Structure',
                    child: Column(
                      children: [
                        _PaymentRow(
                          label: job.primaryPayoutType,
                          value: job.primaryPayoutRate != null
                              ? '\$${job.primaryPayoutRate!.toStringAsFixed(2)}'
                              : 'Negotiable',
                          isHighlighted: true,
                        ),
                        const SizedBox(height: 12),
                        Divider(color: subtleText.withOpacity(0.2)),
                        const SizedBox(height: 12),
                        _PaymentRow(
                          label: 'Estimated Budget',
                          value: job.budgetRange,
                          valueColor: accent,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Client section
                  _SectionCard(
                    title: 'About the Client',
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: accent.withOpacity(0.2),
                          child: Text(
                            (job.clientName.isNotEmpty
                                    ? job.clientName[0]
                                    : 'C')
                                .toUpperCase(),
                            style: TextStyle(
                              color: accent,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                job.clientName.isNotEmpty
                                    ? job.clientName
                                    : 'Client',
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                job.clientCompany ?? 'Individual Client',
                                style: TextStyle(
                                  color: subtleText,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Spacing for bottom button
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      // Apply button
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: primary,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: job.isOpen
                      ? () => _navigateToProposal(context)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'Apply Now',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  void _navigateToProposal(BuildContext context) {
    final jobsBloc = context.read<JobsBloc>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: jobsBloc,
          child: SubmitProposalPage(job: job),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = Theme.of(context).cardColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;
    final cardColor = theme.cardColor;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _SkillTag extends StatelessWidget {
  final String label;

  const _SkillTag({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.secondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: accent,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isHighlighted;

  const _PaymentRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;
    final subtleText =
        theme.textTheme.bodySmall?.color ?? Colors.white.withOpacity(0.7);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isHighlighted ? textColor : subtleText,
            fontSize: 14,
            fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? textColor,
            fontSize: isHighlighted ? 18 : 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
