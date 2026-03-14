import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/core/widgets/shimmer_loading.dart';
import 'package:mobile_app/core/widgets/error_widget.dart';
import 'package:mobile_app/features/jobs/domain/entities/job_entity.dart';
import 'package:mobile_app/features/jobs/presentation/bloc/jobs_bloc.dart';
import 'package:mobile_app/features/jobs/presentation/bloc/jobs_event.dart';
import 'package:mobile_app/features/jobs/presentation/bloc/jobs_state.dart';
import 'package:mobile_app/features/jobs/presentation/pages/job_detail_page.dart';

class BrowseJobsPage extends StatefulWidget {
  const BrowseJobsPage({super.key});

  @override
  State<BrowseJobsPage> createState() => _BrowseJobsPageState();
}

class _BrowseJobsPageState extends State<BrowseJobsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _sortBy = 'Most Recent';

  @override
  void initState() {
    super.initState();
    context.read<JobsBloc>().add(const LoadJobs());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    context.read<JobsBloc>().add(SearchJobs(keyword: query));
  }

  Future<void> _onRefresh() async {
    context.read<JobsBloc>().add(const RefreshJobs());
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
        title: Text(
          'Find Work',
          style: TextStyle(
            color: textColor,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _showFilterSheet(context),
            icon: Icon(Icons.tune, color: textColor),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearch,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  hintText: 'Search by keyword, skill or client...',
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
          ),

          // Sort dropdown
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                BlocBuilder<JobsBloc, JobsState>(
                  builder: (context, state) {
                    int count = 0;
                    if (state is JobsLoaded) {
                      count = state.filteredJobs.length;
                    }
                    return Text(
                      '$count jobs available',
                      style: TextStyle(color: subtleText, fontSize: 14),
                    );
                  },
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: DropdownButton<String>(
                    value: _sortBy,
                    dropdownColor: cardColor,
                    underline: const SizedBox(),
                    isDense: true,
                    icon: Icon(Icons.keyboard_arrow_down, color: accent),
                    style: TextStyle(color: textColor, fontSize: 13),
                    items: ['Most Recent', 'Highest Budget', 'Lowest Budget']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (value) {
                      setState(() => _sortBy = value!);
                      // TODO: Implement sorting
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Jobs list
          Expanded(
            child: BlocBuilder<JobsBloc, JobsState>(
              builder: (context, state) {
                if (state is JobsLoading) {
                  return _buildLoadingState();
                }

                if (state is JobsError) {
                  return AppErrorWidget(
                    message: 'Failed to load jobs',
                    details: state.message,
                    onRetry: () =>
                        context.read<JobsBloc>().add(const LoadJobs()),
                  );
                }

                if (state is JobsLoaded) {
                  if (state.filteredJobs.isEmpty) {
                    return AppErrorWidget.empty(
                      message: 'No jobs found',
                      details: state.searchKeyword != null
                          ? 'Try adjusting your search or filters'
                          : 'Check back later for new opportunities',
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _onRefresh,
                    color: accent,
                    backgroundColor: cardColor,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: state.filteredJobs.length,
                      itemBuilder: (context, index) {
                        final job = state.filteredJobs[index];
                        return _JobCard(
                          job: job,
                          onTap: () => _navigateToJobDetail(job),
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
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 5,
      itemBuilder: (context, index) => const Padding(
        padding: EdgeInsets.only(bottom: 16),
        child: ShimmerCard(height: 180),
      ),
    );
  }

  void _navigateToJobDetail(JobEntity job) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JobDetailPage(job: job),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.cardColor;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;
    final accent = theme.colorScheme.secondary;

    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Filters',
                style: TextStyle(
                  color: textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Budget Range',
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        hintText: 'Min',
                        hintStyle:
                            TextStyle(color: textColor.withOpacity(0.5)),
                        prefixText: '\$ ',
                        prefixStyle: TextStyle(color: accent),
                        filled: true,
                        fillColor: theme.primaryColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text('-', style: TextStyle(color: textColor, fontSize: 20)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        hintText: 'Max',
                        hintStyle:
                            TextStyle(color: textColor.withOpacity(0.5)),
                        prefixText: '\$ ',
                        prefixStyle: TextStyle(color: accent),
                        filled: true,
                        fillColor: theme.primaryColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: textColor,
                        side: BorderSide(color: textColor.withOpacity(0.3)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Clear'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // TODO: Apply filters
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _JobCard extends StatelessWidget {
  final JobEntity job;
  final VoidCallback onTap;

  const _JobCard({
    required this.job,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.secondary;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;
    final subtleText =
        theme.textTheme.bodySmall?.color ?? Colors.white.withOpacity(0.7);
    final cardColor = theme.cardColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            // Client info and bookmark
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: accent.withOpacity(0.2),
                  child: Text(
                    (job.clientName.isNotEmpty ? job.clientName[0] : 'C')
                        .toUpperCase(),
                    style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.clientName.isNotEmpty ? job.clientName : 'Client',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        job.timeAgo,
                        style: TextStyle(color: subtleText, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // TODO: Bookmark job
                  },
                  icon: Icon(
                    Icons.bookmark_border,
                    color: subtleText,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Job title
            Text(
              job.jobTitle,
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 8),

            // Budget
            Row(
              children: [
                Icon(Icons.attach_money, color: accent, size: 18),
                const SizedBox(width: 4),
                Text(
                  'Budget: ${job.budgetRange}',
                  style: TextStyle(
                    color: accent,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Description
            Text(
              job.jobDescription,
              style: TextStyle(
                color: subtleText,
                fontSize: 14,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 16),

            // Tags
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildTag(job.primaryPayoutType, accent, textColor),
                ...job.skills.take(3).map(
                      (skill) => _buildTag(skill, cardColor, textColor,
                          bordered: true),
                    ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String label, Color bgColor, Color textColor,
      {bool bordered = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bordered ? Colors.transparent : bgColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: bordered
            ? Border.all(color: textColor.withOpacity(0.2))
            : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: bordered ? textColor.withOpacity(0.8) : bgColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}














