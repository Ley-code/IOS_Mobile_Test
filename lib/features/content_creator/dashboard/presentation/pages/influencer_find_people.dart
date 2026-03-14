import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/core/widgets/shimmer_loading.dart';
import 'package:mobile_app/core/widgets/error_widget.dart';
import 'package:mobile_app/features/jobs/domain/entities/job_entity.dart';
import 'package:mobile_app/features/jobs/presentation/bloc/jobs_bloc.dart';
import 'package:mobile_app/features/jobs/presentation/bloc/jobs_event.dart';
import 'package:mobile_app/features/jobs/presentation/bloc/jobs_state.dart';
import 'package:mobile_app/features/jobs/presentation/pages/job_detail_page.dart';
import 'package:mobile_app/features/search/data/models/freelancer_profile_model.dart';
import 'package:mobile_app/features/search/presentation/bloc/search_bloc.dart';

class InfluencerFindPeoplePage extends StatefulWidget {
  const InfluencerFindPeoplePage({super.key});

  @override
  State<InfluencerFindPeoplePage> createState() =>
      _InfluencerFindPeoplePageState();
}

class _InfluencerFindPeoplePageState extends State<InfluencerFindPeoplePage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchType = 'people'; // 'jobs' or 'people'
  String? _currentSearchTerm;
  String _sortBy = 'Most Recent';
  double? _minBudget;
  double? _maxBudget;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      final searchTerm = _searchController.text.trim();
      _currentSearchTerm = searchTerm.isEmpty ? null : searchTerm;
      if (_searchType == 'people') {
        setState(() {}); // Rebuild to apply filter
      } else if (_searchType == 'jobs') {
        // Trigger search for jobs
        context.read<JobsBloc>().add(SearchJobs(keyword: _currentSearchTerm));
      }
    });
    // Load all freelancers when page opens (for 'people' search)
    context.read<SearchBloc>().add(const LoadAllFreelancersEvent());
    // Load jobs when page opens
    context.read<JobsBloc>().add(const LoadJobs());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    final searchTerm = _searchController.text.trim();
    _currentSearchTerm = searchTerm.isEmpty ? null : searchTerm;

    if (_searchType == 'jobs') {
      context.read<JobsBloc>().add(SearchJobs(
        keyword: _currentSearchTerm,
        minBudget: _minBudget,
        maxBudget: _maxBudget,
      ));
    } else {
      setState(() {}); // Rebuild to apply filter for people
    }
  }

  Future<void> _onRefresh() async {
    if (_searchType == 'people') {
      context.read<SearchBloc>().add(const LoadAllFreelancersEvent());
    } else {
      context.read<JobsBloc>().add(const RefreshJobs());
    }
  }

  void _applyFilters(double? min, double? max) {
    setState(() {
      _minBudget = min;
      _maxBudget = max;
    });
    if (_searchType == 'jobs') {
      context.read<JobsBloc>().add(SearchJobs(
        keyword: _currentSearchTerm,
        minBudget: min,
        maxBudget: max,
      ));
    }
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
      body: SafeArea(
        child: Column(
          children: [
            _header(cardColor, textColor, accent),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _searchTypeToggle(accent, textColor, subtleText),
                  const SizedBox(height: 12),
                  _searchBar(cardColor, subtleText, accent, textColor),
                  if (_searchType == 'jobs') ...[
                    const SizedBox(height: 12),
                    Row(
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
                              style: TextStyle(color: subtleText, fontSize: 12),
                            );
                          },
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => _showFilterSheet(context),
                              icon: Icon(Icons.tune, color: accent, size: 20),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: DropdownButton<String>(
                                value: _sortBy,
                                dropdownColor: cardColor,
                                underline: const SizedBox(),
                                isDense: true,
                                icon: Icon(Icons.keyboard_arrow_down,
                                    color: accent, size: 18),
                                style: TextStyle(color: textColor, fontSize: 12),
                                items: [
                                  'Most Recent',
                                  'Highest Budget',
                                  'Lowest Budget'
                                ]
                                    .map((e) => DropdownMenuItem(
                                        value: e, child: Text(e)))
                                    .toList(),
                                onChanged: (value) {
                                  setState(() => _sortBy = value!);
                                  // TODO: Implement sorting
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                color: accent,
                backgroundColor: cardColor,
                child: _buildContent(
                  cardColor,
                  accent,
                  textColor,
                  subtleText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(Color dividerColor, Color textColor, Color accent) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border(
          bottom: BorderSide(color: dividerColor.withOpacity(0.5), width: 0.8),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Find Work',
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchTypeToggle(Color accent, Color textColor, Color subtleText) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _toggleButton(
              'Search People',
              _searchType == 'people',
              accent,
              textColor,
              () {
                setState(() {
                  _searchType = 'people';
                  _currentSearchTerm = null;
                  _searchController.clear();
                });
                context.read<SearchBloc>().add(const LoadAllFreelancersEvent());
              },
            ),
          ),
          Expanded(
            child: _toggleButton(
              'Search Jobs',
              _searchType == 'jobs',
              accent,
              textColor,
              () {
                setState(() {
                  _searchType = 'jobs';
                  _currentSearchTerm = null;
                  _searchController.clear();
                });
                context.read<JobsBloc>().add(const LoadJobs());
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _toggleButton(
    String label,
    bool isSelected,
    Color accent,
    Color textColor,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? accent : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : textColor.withOpacity(0.7),
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _searchBar(
    Color cardColor,
    Color subtleText,
    Color accent,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      height: 44,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: subtleText, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: textColor, fontSize: 14),
              decoration: InputDecoration(
                hintText: _searchType == 'jobs'
                    ? 'Search jobs by title, description...'
                    : 'Search by name, skills, or location',
                hintStyle: TextStyle(color: subtleText, fontSize: 14),
                border: InputBorder.none,
                isCollapsed: true,
              ),
              onSubmitted: (_) => _performSearch(),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: Icon(Icons.clear, color: subtleText, size: 20),
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _currentSearchTerm = null;
                });
                if (_searchType == 'jobs') {
                  context.read<JobsBloc>().add(const LoadJobs());
                } else {
                  context.read<SearchBloc>().add(const ClearSearchEvent());
                }
              },
            ),
          IconButton(
            icon: Icon(Icons.search, color: accent, size: 24),
            onPressed: _performSearch,
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    Color cardColor,
    Color accent,
    Color textColor,
    Color subtleText,
  ) {
    if (_searchType == 'jobs') {
      return BlocBuilder<JobsBloc, JobsState>(
        builder: (context, state) {
          if (state is JobsLoading) {
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              itemCount: 5,
              itemBuilder: (context, index) => const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: ShimmerCard(height: 150),
              ),
            );
          }

          if (state is JobsError) {
            return AppErrorWidget(
              message: 'Failed to load jobs',
              details: state.message,
              onRetry: () => context.read<JobsBloc>().add(const LoadJobs()),
            );
          }

          if (state is JobsLoaded) {
            if (state.filteredJobs.isEmpty) {
              return AppErrorWidget.empty(
                message: 'No jobs found',
                details: _currentSearchTerm != null
                    ? 'Try adjusting your search or filters'
                    : 'Check back later for new opportunities',
              );
            }

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              itemCount: state.filteredJobs.length,
              itemBuilder: (context, index) {
                final job = state.filteredJobs[index];
                return _jobCard(job, cardColor, accent, textColor, subtleText);
              },
            );
          }

          return const SizedBox();
        },
      );
    } else {
      return BlocBuilder<SearchBloc, SearchState>(
        builder: (context, state) {
          if (state is SearchLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          List<FreelancerProfileModel> freelancers = [];
          if (state is SearchFreelancersLoaded) {
            freelancers = state.freelancers;
          } else if (state is AllFreelancersLoaded) {
            freelancers = state.freelancers;
            if (_currentSearchTerm != null && _currentSearchTerm!.isNotEmpty) {
              final searchLower = _currentSearchTerm!.toLowerCase();
              freelancers = freelancers.where((f) {
                final name = '${f.firstName} ${f.lastName}'.toLowerCase();
                final userName = f.userName.toLowerCase();
                final email = f.email.toLowerCase();
                return name.contains(searchLower) ||
                    userName.contains(searchLower) ||
                    email.contains(searchLower);
              }).toList();
            }
          }

          if (freelancers.isNotEmpty) {
            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              itemCount: freelancers.length,
              itemBuilder: (context, index) {
                final freelancer = freelancers[index];
                return _freelancerCard(
                  freelancer,
                  cardColor,
                  accent,
                  textColor,
                  subtleText,
                );
              },
            );
          }

          return _emptyState(
            'No ${_searchType == 'jobs' ? 'jobs' : 'freelancers'} found',
            _currentSearchTerm != null && _currentSearchTerm!.isNotEmpty
                ? 'Try adjusting your search terms'
                : 'No ${_searchType == 'jobs' ? 'jobs' : 'freelancers'} available',
            subtleText,
            textColor,
          );
        },
      );
    }
  }

  Widget _emptyState(
    String title,
    String subtitle,
    Color subtleText,
    Color textColor,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 64, color: subtleText),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              color: textColor,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              subtitle,
              style: TextStyle(color: subtleText, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _jobCard(
    JobEntity job,
    Color cardColor,
    Color accent,
    Color textColor,
    Color subtleText,
  ) {
    return GestureDetector(
      onTap: () {
        final jobsBloc = context.read<JobsBloc>();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider.value(
              value: jobsBloc,
              child: JobDetailPage(job: job),
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                  icon: Icon(Icons.bookmark_border, color: subtleText),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              job.jobTitle,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (job.jobDescription.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                job.jobDescription,
                style: TextStyle(color: subtleText, fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.attach_money, color: accent, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      job.budgetRange,
                      style: TextStyle(
                        color: accent,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                if (job.skills.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${job.skills.length} skill${job.skills.length > 1 ? 's' : ''}',
                      style: TextStyle(color: accent, fontSize: 11),
                    ),
                  ),
              ],
            ),
            if (job.skills.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: job.skills.take(3).map((skill) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      skill,
                      style: TextStyle(color: accent, fontSize: 11),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _freelancerCard(
    FreelancerProfileModel freelancer,
    Color cardColor,
    Color accent,
    Color textColor,
    Color subtleText,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: accent.withOpacity(0.2),
            child: Text(
              freelancer.firstName.isNotEmpty
                  ? freelancer.firstName[0].toUpperCase()
                  : 'U',
              style: TextStyle(color: accent, fontSize: 20),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  freelancer.fullName,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (freelancer.userName.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    '@${freelancer.userName}',
                    style: TextStyle(color: subtleText, fontSize: 12),
                  ),
                ],
                if (freelancer.introduction != null &&
                    freelancer.introduction!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    freelancer.introduction!,
                    style: TextStyle(color: subtleText, fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (freelancer.skills.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: freelancer.skills.take(3).map((skill) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          skill.skillName,
                          style: TextStyle(color: accent, fontSize: 11),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.cardColor;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;
    final accent = theme.colorScheme.secondary;
    final minController = TextEditingController(
      text: _minBudget?.toStringAsFixed(0) ?? '',
    );
    final maxController = TextEditingController(
      text: _maxBudget?.toStringAsFixed(0) ?? '',
    );

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
                      controller: minController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        hintText: 'Min',
                        hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
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
                      controller: maxController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        hintText: 'Max',
                        hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
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
                      onPressed: () {
                        minController.clear();
                        maxController.clear();
                        setState(() {
                          _minBudget = null;
                          _maxBudget = null;
                        });
                        Navigator.pop(context);
                        context.read<JobsBloc>().add(const LoadJobs());
                      },
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
                        final min = minController.text.isNotEmpty
                            ? double.tryParse(minController.text)
                            : null;
                        final max = maxController.text.isNotEmpty
                            ? double.tryParse(maxController.text)
                            : null;
                        Navigator.pop(context);
                        _applyFilters(min, max);
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
