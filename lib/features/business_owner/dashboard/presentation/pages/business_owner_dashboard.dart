import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/features/business_owner/dashboard/data/models/job_model.dart';
import 'package:mobile_app/features/business_owner/dashboard/data/models/user_profile_model.dart';
import 'package:mobile_app/features/business_owner/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:mobile_app/features/business_owner/dashboard/presentation/pages/project_details_page.dart';
import 'package:mobile_app/features/business_owner/dashboard/presentation/pages/business_owner_profile.dart';
import 'package:mobile_app/features/business_owner/dashboard/presentation/pages/edit_profile_modal.dart';
import 'package:cached_network_image/cached_network_image.dart';

class BusinessOwnerPage extends StatefulWidget {
  const BusinessOwnerPage({super.key});

  @override
  State<BusinessOwnerPage> createState() => _BusinessOwnerPageState();
}

class _BusinessOwnerPageState extends State<BusinessOwnerPage> {
  bool _showProTip = true;

  @override
  void initState() {
    super.initState();
    // Load dashboard data when page is initialized
    context.read<DashboardBloc>().add(const LoadDashboardData());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;
    final accent = theme.colorScheme.secondary;
    final cardColor = theme.cardColor;
    final deepCard = Color.lerp(primary, Colors.black, 0.08)!;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;
    final subtleText =
        theme.textTheme.bodySmall?.color ?? Colors.white.withOpacity(0.7);

    return BlocConsumer<DashboardBloc, DashboardState>(
      listener: (context, state) {
        if (state is DashboardError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: () {
                  context.read<DashboardBloc>().add(const LoadDashboardData());
                },
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is DashboardLoading;
        final hasError = state is DashboardError;
        final hasData = state is DashboardLoaded;
        DashboardLoaded? loadedState;
        if (state is DashboardLoaded) {
          loadedState = state;
        }

        return Scaffold(
          backgroundColor: primary,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            toolbarHeight: 72,
            titleSpacing: 0,
            title: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: accent.withOpacity(0.2),
                    backgroundImage:
                        loadedState?.profile.profilePictureUrl != null &&
                            loadedState!.profile.profilePictureUrl!.isNotEmpty
                        ? CachedNetworkImageProvider(
                            loadedState.profile.profilePictureUrl!,
                          )
                        : null,
                    child:
                        loadedState?.profile.profilePictureUrl == null ||
                            loadedState?.profile.profilePictureUrl?.isEmpty ==
                                true
                        ? Icon(Icons.person, size: 22, color: accent)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Welcome back,',
                          style: TextStyle(color: subtleText, fontSize: 13),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          loadedState != null
                              ? loadedState.profile.fullName
                              : isLoading
                              ? 'Loading...'
                              : 'User',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(24),
                      splashColor: accent.withOpacity(0.3),
                      highlightColor: accent.withOpacity(0.1),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: Icon(Icons.notifications_none, color: textColor),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              context.read<DashboardBloc>().add(const RefreshDashboardData());
              // Wait a bit for the refresh to complete
              await Future.delayed(const Duration(milliseconds: 500));
            },
            color: accent,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isLoading && !hasData)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (hasError && !hasData)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Failed to load dashboard',
                              style: TextStyle(color: textColor, fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                                context.read<DashboardBloc>().add(
                                  const LoadDashboardData(),
                                );
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else ...[
                    _welcomeCard(
                      accent,
                      loadedState != null
                          ? loadedState.profile.fullName
                          : 'User',
                      textColor,
                      loadedState?.profileCompletionPercentage ?? 0,
                      loadedState?.profile,
                    ),
                    const SizedBox(height: 12),
                    if (_showProTip) ...[
                      _proTipCard(deepCard, accent, subtleText),
                      const SizedBox(height: 12),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/wallet_page');
                            },
                            child: _metricCard(
                              cardColor,
                              icon: Icons.account_balance_wallet_outlined,
                              title: 'Wallet',
                              value: loadedState != null
                                  ? '\$${loadedState.profile.totalWalletBalance.toStringAsFixed(0)}'
                                  : '\$0',
                              subtitle: 'Available Balance',
                              accent: accent,
                              logoColor: Colors.green,
                              textColor: textColor,
                              subtleText: subtleText,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _metricCard(
                            cardColor,
                            icon: Icons.work_outline,
                            title: 'Projects',
                            value: loadedState != null
                                ? '${loadedState.jobs.where((j) => j.isOpen).length}'
                                : '0',
                            subtitle: 'Open Jobs',
                            accent: accent,
                            logoColor: Colors.blue,
                            textColor: textColor,
                            subtleText: subtleText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _metricCard(
                            cardColor,
                            icon: Icons.payments_outlined,
                            title: 'Total Budget',
                            value: loadedState != null
                                ? '\$${loadedState.jobs.fold<double>(0, (sum, job) => sum + job.maximumBudget).toStringAsFixed(0)}'
                                : '\$0',
                            subtitle: 'Across all jobs',
                            accent: accent,
                            logoColor: Colors.greenAccent,
                            textColor: textColor,
                            subtleText: subtleText,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _metricCard(
                            cardColor,
                            icon: Icons.check_circle_outline,
                            title: 'Total Contracts',
                            value: loadedState != null
                                ? '${loadedState.jobs.length}'
                                : '0',
                            subtitle: 'All contracts',
                            accent: accent,
                            logoColor: Colors.green,
                            textColor: textColor,
                            subtleText: subtleText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Quick Actions',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/create_project_page_1',
                                );
                              },
                              borderRadius: BorderRadius.circular(14),
                              splashColor: accent.withOpacity(0.4),
                              highlightColor: accent.withOpacity(0.15),
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: _quickActionCard(
                                  accent,
                                  icon: Icons.add_circle_outline,
                                  label: 'New Project',
                                  textColor: textColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                // final walletBloc = context.read<WalletBloc>();
                                // walletBloc.add(const LoadWalletBalance());
                                // walletBloc.add(
                                //   const LoadTransactions(limit: 10),
                                // );
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (context) => BlocProvider.value(
                                //       value: walletBloc,
                                //       child: const WalletPage(),
                                //     ),
                                //   ),
                                // );

                                Navigator.pushNamed(
                                  context,
                                  '/deposit_funds_page',
                                );
                              },
                              borderRadius: BorderRadius.circular(14),
                              splashColor: accent.withOpacity(0.4),
                              highlightColor: accent.withOpacity(0.15),
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: _quickActionCard(
                                  accent,
                                  icon: Icons.account_balance_wallet,
                                  label: 'Add Funds',
                                  textColor: textColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Open Job Posts',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (loadedState != null) ...[
                      if (loadedState.jobs.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.work_outline,
                                  color: subtleText,
                                  size: 48,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No jobs yet',
                                  style: TextStyle(
                                    color: subtleText,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Create your first job post to get started',
                                  style: TextStyle(
                                    color: subtleText,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      else ...[
                        ...loadedState.jobs
                            .where((job) => job.isOpen)
                            .take(5)
                            .map(
                              (job) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _jobCard(
                                  cardColor,
                                  accent,
                                  job,
                                  textColor,
                                  subtleText,
                                ),
                              ),
                            ),
                      ],
                    ] else ...[
                      if (isLoading) ...[
                        _jobCard(
                          cardColor,
                          accent,
                          null,
                          textColor,
                          subtleText,
                        ),
                        const SizedBox(height: 12),
                        _jobCard(
                          cardColor,
                          accent,
                          null,
                          textColor,
                          subtleText,
                        ),
                      ],
                    ],
                    const SizedBox(height: 24),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _welcomeCard(
    Color accent,
    String userName,
    Color textColor,
    int completionPercentage,
    UserProfileModel? profile,
  ) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: accent.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back, ${userName.split(' ').first}!',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Complete your profile to attract more freelancers',
                          style: TextStyle(color: textColor, fontSize: 12),
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () async {
                            // Navigate to profile page
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    BusinessOwnerProfilePage(),
                              ),
                            );

                            // Refresh completion percentage after returning from profile
                            if (context.mounted) {
                              context.read<DashboardBloc>().add(
                                const LoadDashboardData(),
                              );

                              // Show edit modal after navigation if profile is loaded
                              if (profile != null) {
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  if (context.mounted) {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (context) =>
                                          EditProfileModal(profile: profile),
                                    );
                                  }
                                });
                              }
                            }
                          },
                          borderRadius: BorderRadius.circular(8),
                          splashColor: Colors.white.withOpacity(0.3),
                          highlightColor: Colors.white.withOpacity(0.1),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Text(
                              'Continue',
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: completionPercentage / 100.0,
                      minHeight: 8,
                      backgroundColor: Colors.white.withOpacity(0.25),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$completionPercentage% Completed',
                    style: TextStyle(color: textColor, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _proTipCard(Color cardColor, Color accent, Color subtleText) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.tips_and_updates, color: accent, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pro Tip:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Verify your account to get 30% recognition by influencers',
                  style: TextStyle(
                    color: subtleText,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  _showProTip = false;
                });
              },
              borderRadius: BorderRadius.circular(20),
              splashColor: accent.withOpacity(0.3),
              highlightColor: accent.withOpacity(0.1),
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Icon(Icons.close, color: subtleText, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricCard(
    Color cardColor, {
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color accent,
    required Color logoColor,
    required Color textColor,
    required Color subtleText,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: logoColor),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(color: subtleText, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _quickActionCard(
    Color accent, {
    required IconData icon,
    required String label,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withOpacity(0.35)),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 400),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withOpacity(0.4),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _jobCard(
    Color cardColor,
    Color accent,
    JobModel? job,
    Color textColor,
    Color subtleText,
  ) {
    if (job == null) {
      // Loading skeleton
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 80,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              width: 150,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: 200,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProjectDetailsPage(job: job)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    job.jobStatus.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      // Add delete/close action here
                    },
                    borderRadius: BorderRadius.circular(14),
                    splashColor: Colors.redAccent.withOpacity(0.3),
                    highlightColor: Colors.redAccent.withOpacity(0.1),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              job.jobTitle,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            if (job.jobDescription.isNotEmpty) ...[
              Text(
                job.jobDescription,
                style: TextStyle(color: subtleText, fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.budgetRange,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (job.clientCompany != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          job.clientCompany!,
                          style: TextStyle(color: subtleText, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                if (job.skills.isNotEmpty) ...[
                  const SizedBox(width: 8),
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}
