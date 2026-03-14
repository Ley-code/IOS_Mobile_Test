import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mobile_app/core/network/api_client.dart';
import 'package:mobile_app/features/business_owner/dashboard/data/models/job_model.dart';
import 'package:mobile_app/features/business_owner/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:mobile_app/features/proposals/presentation/pages/job_applicants_page.dart';
import 'package:mobile_app/features/proposals/presentation/bloc/proposals_bloc.dart';
import 'package:mobile_app/injection_container.dart' as di;

class ProjectDetailsPage extends StatefulWidget {
  final JobModel job;

  const ProjectDetailsPage({super.key, required this.job});

  @override
  State<ProjectDetailsPage> createState() => _ProjectDetailsPageState();
}

class _ProjectDetailsPageState extends State<ProjectDetailsPage> {
  JobModel? _jobDetails;

  @override
  void initState() {
    super.initState();
    // Initialize with widget.job as fallback
    _jobDetails = widget.job;
    // Try to load fresh data from API in background (don't show loading)
    _loadJobDetails();
  }

  Future<void> _loadJobDetails() async {
    // Don't set loading to true - show existing data while loading in background

    try {
      final apiClient = di.sl<ApiClient>();
      final response = await apiClient.get(
        '/jobs/${widget.job.jobId}',
        requireAuth: true,
      );

      if (response.statusCode == 200) {
        try {
          final json = jsonDecode(response.body) as Map<String, dynamic>;
          // Handle nested response structure if present
          final jobJson = json['job'] as Map<String, dynamic>? ?? json;
          setState(() {
            _jobDetails = JobModel.fromJson(jobJson);
          });
        } catch (e) {
          // If parsing fails, keep using the widget.job data
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Using cached job data. Error: ${e.toString()}'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to load job details. Using cached data.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteJob() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        final cardColor = theme.cardColor;
        final subtleText =
            theme.textTheme.bodySmall?.color ?? Colors.white.withOpacity(0.7);

        return AlertDialog(
          backgroundColor: cardColor,
          title: Text(
            'Delete Project',
            style: TextStyle(color: Colors.redAccent),
          ),
          content: Text(
            'Are you sure you want to delete this project? This action cannot be undone.',
            style: TextStyle(color: subtleText),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel', style: TextStyle(color: subtleText)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      final apiClient = di.sl<ApiClient>();
      final response = await apiClient.delete(
        '/jobs/${widget.job.jobId}',
        requireAuth: true,
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Project deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          // Refresh dashboard
          context.read<DashboardBloc>().add(const LoadDashboardData());
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to delete project'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _repostJob() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        final cardColor = theme.cardColor;
        final textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;
        final subtleText =
            theme.textTheme.bodySmall?.color ?? Colors.white.withOpacity(0.7);

        return AlertDialog(
          backgroundColor: cardColor,
          title: Text('Repost Project', style: TextStyle(color: textColor)),
          content: Text(
            'This will create a new job post with the same details. Continue?',
            style: TextStyle(color: subtleText),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel', style: TextStyle(color: subtleText)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Repost', style: TextStyle(color: textColor)),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    final job = _jobDetails ?? widget.job;

    try {
      final apiClient = di.sl<ApiClient>();
      final jobData = {
        'job_title': job.jobTitle,
        'job_description': job.jobDescription,
        'minimum_budget': job.minimumBudget,
        'maximum_budget': job.maximumBudget,
        'payout_types': ['per_project'],
        'payout_rates': {'per_project': job.maximumBudget},
        'job_status': 'open',
      };

      final response = await apiClient.post(
        '/jobs',
        jobData,
        requireAuth: true,
      );

      if (response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Project reposted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          // Refresh dashboard
          context.read<DashboardBloc>().add(const LoadDashboardData());
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to repost project'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _editProject() {
    // Navigate to edit flow - for now, navigate to create project page
    // In a full implementation, you'd navigate to an edit page with pre-filled data
    Navigator.pushNamed(context, '/create_project_page_1');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;
    final cardColor = theme.cardColor;
    final accent = theme.colorScheme.secondary;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;
    final subtleText =
        theme.textTheme.bodySmall?.color ?? Colors.white.withOpacity(0.7);

    final job = _jobDetails ?? widget.job;

    // Ensure we have visible colors
    final safePrimary = primary == Colors.black || primary.value == 0xFF000000
        ? Colors.grey[900]!
        : primary;
    final safeTextColor =
        textColor == Colors.black || textColor.value == 0xFF000000
        ? Colors.white
        : textColor;

    return Scaffold(
      backgroundColor: safePrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: safeTextColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Project Details',
          style: TextStyle(
            color: safeTextColor,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: safeTextColor),
            onPressed: _editProject,
            tooltip: 'Edit Project',
          ),
        ],
      ),
      body: _buildBody(
        job,
        safePrimary,
        safeTextColor,
        cardColor,
        accent,
        subtleText,
      ),
    );
  }

  Widget _buildBody(
    JobModel job,
    Color safePrimary,
    Color safeTextColor,
    Color cardColor,
    Color accent,
    Color subtleText,
  ) {
    if (job.jobTitle.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: safeTextColor),
            const SizedBox(height: 16),
            Text(
              'Unable to load project details',
              style: TextStyle(color: safeTextColor, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Job ID: ${job.jobId}',
              style: TextStyle(color: subtleText, fontSize: 12),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                _loadJobDetails();
              },
              child: Text('Retry', style: TextStyle(color: accent)),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Badge
          if (job.jobStatus.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                job.jobStatus.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          const SizedBox(height: 16),
          // Title
          Text(
            job.jobTitle.isEmpty ? 'Untitled Project' : job.jobTitle,
            style: TextStyle(
              color: safeTextColor,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          // Budget
          Text(
            job.budgetRange,
            style: TextStyle(
              color: accent,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          // Description
          _buildSection(
            'Description',
            job.jobDescription.isEmpty
                ? 'No description provided'
                : job.jobDescription,
            cardColor,
            safeTextColor,
            subtleText,
          ),
          const SizedBox(height: 16),
          // Details
          _buildDetailsSection(
            job,
            cardColor,
            safeTextColor,
            subtleText,
            accent,
          ),
          const SizedBox(height: 24),
          // Action Buttons
          _buildActionButtons(
            job,
            cardColor,
            accent,
            safeTextColor,
            subtleText,
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    String title,
    String content,
    Color cardColor,
    Color textColor,
    Color subtleText,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
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
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(color: subtleText, fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(
    JobModel job,
    Color cardColor,
    Color textColor,
    Color subtleText,
    Color accent,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Project Details',
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Status', job.jobStatus, textColor, subtleText),
          const SizedBox(height: 12),
          _buildDetailRow(
            'Created',
            _formatDate(job.createdAt),
            textColor,
            subtleText,
          ),
          if (job.skills.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildDetailRow(
              'Skills',
              job.skills.join(', '),
              textColor,
              subtleText,
            ),
          ],
          if (job.platforms.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildDetailRow(
              'Platforms',
              job.platforms.join(', '),
              textColor,
              subtleText,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    Color textColor,
    Color subtleText,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(label, style: TextStyle(color: subtleText, fontSize: 14)),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    JobModel job,
    Color cardColor,
    Color accent,
    Color textColor,
    Color subtleText,
  ) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider(
                    create: (_) => di.sl<ProposalsBloc>(),
                    child: JobApplicantsPage(job: job),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: accent,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'View Proposals',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _repostJob,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: accent),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Repost',
                  style: TextStyle(
                    color: accent,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: _deleteJob,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.redAccent),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Delete',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }
}
