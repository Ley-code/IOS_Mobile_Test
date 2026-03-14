import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mobile_app/core/network/api_client.dart';
import 'package:mobile_app/core/config/api_config.dart';
import 'package:mobile_app/core/widgets/shimmer_loading.dart';
import 'package:mobile_app/core/widgets/error_widget.dart';
import 'package:mobile_app/features/authentication/domain/entities/user_entity.dart';
import 'package:mobile_app/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:mobile_app/features/business_owner/dashboard/data/models/user_profile_model.dart';
import 'package:mobile_app/features/content_creator/dashboard/domain/entities/portfolio_item_entity.dart';
import 'package:mobile_app/features/content_creator/dashboard/presentation/widgets/portfolio_detail_modal.dart';
import 'package:mobile_app/features/content_creator/dashboard/presentation/bloc/influencer_dashboard_bloc.dart';
import 'package:mobile_app/features/content_creator/dashboard/presentation/bloc/influencer_dashboard_event.dart';
import 'package:mobile_app/features/content_creator/dashboard/presentation/bloc/influencer_dashboard_state.dart';
import 'package:mobile_app/features/content_creator/dashboard/presentation/pages/active_projects_page.dart';
import 'package:mobile_app/features/content_creator/dashboard/presentation/pages/add_work_page.dart';
import 'package:mobile_app/features/content_creator/dashboard/presentation/pages/completed_projects_page.dart';
import 'package:mobile_app/features/content_creator/projects/presentation/bloc/contract_bloc.dart';
import 'package:mobile_app/features/content_creator/projects/presentation/bloc/contract_event.dart';
import 'package:mobile_app/features/content_creator/projects/presentation/bloc/contract_state.dart';
import 'package:mobile_app/features/wallet/presentation/pages/wallet_guard_page.dart';
import 'package:mobile_app/injection_container.dart' as di;
import 'package:mobile_app/features/offers/presentation/bloc/offers_bloc.dart';
import 'package:mobile_app/features/offers/presentation/bloc/offers_event.dart';
import 'package:mobile_app/features/offers/presentation/pages/offers_list_page.dart';
import 'package:mobile_app/features/content_creator/dashboard/presentation/pages/influencer_profile.dart';
import 'package:mobile_app/features/business_owner/dashboard/presentation/pages/edit_profile_modal.dart';
import 'dart:convert';

class InfluencerDashboardPage extends StatefulWidget {
  final UserRole userRole;

  const InfluencerDashboardPage({super.key, required this.userRole});

  @override
  State<InfluencerDashboardPage> createState() =>
      _InfluencerDashboardPageState();
}

class _InfluencerDashboardPageState extends State<InfluencerDashboardPage> {
  bool _isPrivateView = true;
  bool _showProTip = true;
  bool _showSwitchModal = false;
  String _selectedTab = 'All';
  UserProfileModel? _userProfile;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    // Load user profile
    await _loadUserProfile();
    // Load dashboard data
    context.read<InfluencerDashboardBloc>().add(const LoadDashboardData());
    // Load contracts for project counts
    context.read<ContractBloc>().add(const LoadMyContracts(activeOnly: false));
  }

  Future<void> _loadUserProfile() async {
    try {
      final apiClient = di.sl<ApiClient>();

      // 1. Get basic profile
      final response = await apiClient.get(
        ApiConfig.userProfileEndpoint,
        requireAuth: true,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        var userProfile = UserProfileModel.fromJson(jsonResponse);

        // 2. If freelancer, fetch full profile for social stats
        if (userProfile.role == 'freelancer' &&
            userProfile.freelancerId != null) {
          try {
            final fullResponse = await apiClient.get(
              '/users/freelancers/profile/${userProfile.freelancerId}',
              requireAuth: true,
            );

            if (fullResponse.statusCode == 200) {
              final fullJson =
                  jsonDecode(fullResponse.body) as Map<String, dynamic>;
              userProfile = UserProfileModel.fromJson(fullJson);
            }
          } catch (e) {
            // Fallback to basic profile if full fetch fails
            print('Failed to fetch full profile: $e');
          }
        }

        if (mounted) {
          setState(() {
            _userProfile = userProfile;
          });
        }
      }
    } catch (e) {
      // Silently fail - user profile is optional
      print('Error loading profile: $e');
    }
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    }
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  String _getTotalFollowers() {
    if (_userProfile == null) return "0";
    int total = 0;
    for (var account in _userProfile!.socialAccounts) {
      total += account.followerCount;
    }
    return _formatNumber(total);
  }

  Future<void> _onRefresh() async {
    // Refresh all data: user profile, portfolios, and contracts
    await _loadUserProfile();
    context.read<InfluencerDashboardBloc>().add(const RefreshDashboardData());
    context.read<ContractBloc>().add(const LoadMyContracts(activeOnly: false));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, authState) {
        // Refresh profile when Instagram session is finalized
        if (authState is InstagramSessionFinalizedState) {
          _loadUserProfile();
        }
      },
      child: BlocConsumer<InfluencerDashboardBloc, InfluencerDashboardState>(
        listener: (context, state) {
          if (state is DashboardError) {
            ErrorSnackbar.show(
              context,
              message: state.message,
              onRetry: () {
                context.read<InfluencerDashboardBloc>().add(
                  const LoadDashboardData(),
                );
              },
            );
          }
        },
        builder: (context, state) {
          List<PortfolioItemEntity> portfolioItems = [];
          bool isLoadingPortfolio = false;
          int profileCompletionPercentage = 0;

          if (state is DashboardLoading) {
            isLoadingPortfolio = true;
          } else if (state is DashboardLoaded) {
            portfolioItems = state.portfolioItems;
            profileCompletionPercentage = state.profileCompletionPercentage;
          }

          final theme = Theme.of(context);
          final primary = theme.primaryColor;
          final accent = theme.colorScheme.secondary;
          final textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;
          final subtleText =
              theme.textTheme.bodySmall?.color ?? Colors.white.withOpacity(0.7);
          final cardColor = theme.cardColor;
          final deepCard = Color.lerp(primary, Colors.black, 0.08)!;
          final isContentCreator = widget.userRole == UserRole.contentCreator;

          return Scaffold(
            backgroundColor: primary,
            appBar: _buildAppBar(accent, textColor, subtleText),
            body: Stack(
              children: [
                RefreshIndicator(
                  onRefresh: _onRefresh,
                  color: accent,
                  backgroundColor: cardColor,
                  child: _buildMainContent(
                    cardColor: cardColor,
                    accent: accent,
                    textColor: textColor,
                    subtleText: subtleText,
                    deepCard: deepCard,
                    isContentCreator: isContentCreator,
                    portfolioItems: portfolioItems,
                    isLoadingPortfolio: isLoadingPortfolio,
                    profileCompletionPercentage: profileCompletionPercentage,
                  ),
                ),
                if (_showSwitchModal)
                  _buildSwitchModal(cardColor, accent, textColor, subtleText),
              ],
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    Color accent,
    Color textColor,
    Color subtleText,
  ) {
    return AppBar(
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
              backgroundImage:
                  _userProfile?.profilePictureUrl != null &&
                      _userProfile!.profilePictureUrl!.isNotEmpty
                  ? CachedNetworkImageProvider(_userProfile!.profilePictureUrl!)
                  : null,
              child:
                  _userProfile?.profilePictureUrl == null ||
                      _userProfile!.profilePictureUrl!.isEmpty
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
                    _isPrivateView
                        ? 'Welcome back, ${_userProfile?.displayName ?? 'User'}'
                        : 'Viewing as Public, ${_userProfile?.displayName ?? 'User'}',
                    style: TextStyle(color: subtleText, fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _userProfile?.displayName ?? 'User',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            _buildViewToggle(accent),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.notifications_none, color: textColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewToggle(Color accent) {
    return GestureDetector(
      onTap: () => setState(() => _showSwitchModal = true),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: accent.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: accent.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isPrivateView ? Icons.lock_outline : Icons.visibility_outlined,
              color: accent,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              _isPrivateView ? 'private view' : 'public view',
              style: TextStyle(
                color: accent,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent({
    required Color cardColor,
    required Color accent,
    required Color textColor,
    required Color subtleText,
    required Color deepCard,
    required bool isContentCreator,
    required List<PortfolioItemEntity> portfolioItems,
    required bool isLoadingPortfolio,
    required int profileCompletionPercentage,
  }) {
    return SingleChildScrollView(
      physics:
          const AlwaysScrollableScrollPhysics(), // Enable pull-to-refresh even when content is short
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isPrivateView) ...[
            _welcomeCardPrivate(accent, textColor, profileCompletionPercentage),
            const SizedBox(height: 12),
            if (_showProTip) ...[
              _proTipCard(deepCard, accent, textColor, subtleText),
              const SizedBox(height: 12),
            ],
            _earningsSummary(cardColor, accent, textColor, subtleText),
            const SizedBox(height: 12),
          ] else ...[
            _welcomeCardPublic(accent, textColor),
            const SizedBox(height: 12),
            _availabilityCard(cardColor, accent, textColor, subtleText),
            const SizedBox(height: 12),
          ],
          if (isContentCreator) ...[
            _followersCard(cardColor, accent, textColor, subtleText),
            const SizedBox(height: 12),
          ],
          _projectSummary(cardColor, accent, textColor, subtleText),
          if (_isPrivateView) ...[
            const SizedBox(height: 16),
            _quickActions(cardColor, accent, textColor),
            const SizedBox(height: 16),
          ],
          const SizedBox(height: 16),
          _portfolioShowcase(
            cardColor,
            accent,
            textColor,
            subtleText,
            portfolioItems,
            isLoadingPortfolio,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSwitchModal(
    Color cardColor,
    Color accent,
    Color textColor,
    Color subtleText,
  ) {
    return GestureDetector(
      onTap: () => setState(() => _showSwitchModal = false),
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8),
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Switch View',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      IconButton(
                        onPressed: () =>
                            setState(() => _showSwitchModal = false),
                        icon: Icon(Icons.close, color: textColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose how you want to see your dashboard',
                    style: TextStyle(color: subtleText, fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  _viewOption(
                    title: 'Private Dashboard',
                    subtitle: 'Manage earnings, projects, and analytics.',
                    icon: Icons.lock_outline,
                    accent: accent,
                    cardColor: cardColor,
                    textColor: textColor,
                    subtleText: subtleText,
                    isActive: _isPrivateView,
                    onTap: () {
                      setState(() {
                        _isPrivateView = true;
                        _showSwitchModal = false;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _viewOption(
                    title: 'Public Profile',
                    subtitle: 'View how clients and fans see your portfolio.',
                    icon: Icons.visibility_outlined,
                    accent: accent,
                    cardColor: cardColor,
                    textColor: textColor,
                    subtleText: subtleText,
                    isActive: !_isPrivateView,
                    onTap: () {
                      setState(() {
                        _isPrivateView = false;
                        _showSwitchModal = false;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => setState(() => _showSwitchModal = false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Apply Changes',
                        style: TextStyle(
                          color: textColor,
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
        ),
      ),
    );
  }

  Widget _viewOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accent,
    required Color cardColor,
    required Color textColor,
    required Color subtleText,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isActive ? accent.withOpacity(0.2) : cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive ? accent : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: accent, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isActive) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: accent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'ACTIVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: subtleText, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _welcomeCardPrivate(Color accent, Color textColor, int completionPercentage) {
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
                    'Welcome back, ${_userProfile?.firstName ?? 'User'}!',
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
                          'Complete your profile to attract more clients',
                          style: TextStyle(color: textColor, fontSize: 12),
                        ),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          foregroundColor: textColor,
                        ),
                        onPressed: () async {
                          // Navigate to profile page
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => InfluencerProfilePage(),
                            ),
                          );
                          
                          // Refresh completion percentage after returning from profile
                          if (context.mounted) {
                            context.read<InfluencerDashboardBloc>().add(
                              const LoadDashboardData(),
                            );
                            
                            // Show edit modal after navigation if profile is loaded
                            if (_userProfile != null) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (context.mounted) {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (context) => EditProfileModal(profile: _userProfile),
                                  );
                                }
                              });
                            }
                          }
                        },
                        child: const Text('Continue'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: completionPercentage / 100.0,
                      minHeight: 8,
                      backgroundColor: textColor.withOpacity(0.25),
                      valueColor: AlwaysStoppedAnimation<Color>(textColor),
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

  Widget _welcomeCardPublic(Color accent, Color textColor) {
    return Container(
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
            'Welcome, Visitor!',
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Explore ${_userProfile?.displayName ?? 'User'}\'s public portfolio and recent achievements.',
            style: TextStyle(color: textColor, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: textColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '85% Match',
              style: TextStyle(
                color: textColor,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _proTipCard(
    Color cardColor,
    Color accent,
    Color textColor,
    Color subtleText,
  ) {
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
                Text(
                  'Pro Tip:',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Verify your account to get 30% recognition by clients',
                  style: TextStyle(
                    color: subtleText,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => setState(() => _showProTip = false),
            icon: Icon(Icons.close, color: subtleText, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _earningsSummary(
    Color cardColor,
    Color accent,
    Color textColor,
    Color subtleText,
  ) {
    return Row(
      children: [
        Expanded(
          child: _metricCard(
            cardColor,
            icon: Icons.account_balance_wallet_outlined,
            title: 'Total Earnings',
            value: '\$0',
            accent: accent,
            iconColor: Colors.green,
            textColor: textColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _metricCard(
            cardColor,
            icon: Icons.hourglass_empty_outlined,
            title: 'Pending Payments',
            value: '\$0',
            accent: accent,
            iconColor: accent,
            textColor: textColor,
          ),
        ),
      ],
    );
  }

  Widget _availabilityCard(
    Color cardColor,
    Color accent,
    Color textColor,
    Color subtleText,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.check_circle, color: accent, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${_userProfile?.firstName ?? 'User'} is currently Open to Work for new jobs starting next month.',
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _followersCard(
    Color cardColor,
    Color accent,
    Color textColor,
    Color subtleText,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Followers Across All Platforms',
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                _getTotalFollowers(),
                style: TextStyle(
                  color: textColor,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.camera_alt, color: accent, size: 20),
              const Spacer(),
              Icon(Icons.trending_up, color: accent, size: 20),
            ],
          ),
          if (_isPrivateView) ...[
            const SizedBox(height: 16),
            _followerPlatforms(cardColor, accent, textColor, subtleText),
          ],
        ],
      ),
    );
  }

  Widget _followerPlatforms(
    Color cardColor,
    Color accent,
    Color textColor,
    Color subtleText,
  ) {
    // Map platform names to FontAwesome brand icons
    Widget getPlatformIcon(String name, double size) {
      final lower = name.toLowerCase();
      Color iconColor = accent;

      if (lower.contains('instagram')) {
        return FaIcon(FontAwesomeIcons.instagram, color: iconColor, size: size);
      } else if (lower.contains('tiktok')) {
        return FaIcon(FontAwesomeIcons.tiktok, color: iconColor, size: size);
      } else if (lower.contains('facebook')) {
        return FaIcon(FontAwesomeIcons.facebook, color: iconColor, size: size);
      } else if (lower.contains('twitter') || lower.contains('x')) {
        return FaIcon(FontAwesomeIcons.xTwitter, color: iconColor, size: size);
      } else if (lower.contains('youtube')) {
        return FaIcon(FontAwesomeIcons.youtube, color: iconColor, size: size);
      } else if (lower.contains('linkedin')) {
        return FaIcon(FontAwesomeIcons.linkedin, color: iconColor, size: size);
      } else {
        return Icon(Icons.link, color: iconColor, size: size);
      }
    }

    final socialAccounts = _userProfile?.socialAccounts ?? [];

    if (socialAccounts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            "No linked accounts",
            style: TextStyle(color: subtleText, fontSize: 13),
          ),
        ),
      );
    }

    return Column(
      children: socialAccounts.map((account) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              getPlatformIcon(account.platformName, 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  account.platformName,
                  style: TextStyle(color: textColor, fontSize: 14),
                ),
              ),
              Text(
                _formatNumber(account.followerCount),
                style: TextStyle(
                  color: accent,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _projectSummary(
    Color cardColor,
    Color accent,
    Color textColor,
    Color subtleText,
  ) {
    return BlocBuilder<ContractBloc, ContractState>(
      builder: (context, contractState) {
        // Show shimmer while loading
        if (contractState is ContractLoading) {
          return const ShimmerMetricCardsRow();
        }

        int activeCount = 0;
        int completedCount = 0;

        if (contractState is ContractsLoaded) {
          activeCount = contractState.contracts
              .where((c) => c.status == 'active')
              .length;
          completedCount = contractState.contracts
              .where((c) => c.status == 'completed')
              .length;
        }

        return Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ActiveProjectsPage(),
                    ),
                  );
                },
                child: _metricCard(
                  cardColor,
                  icon: Icons.work_outline,
                  title: _isPrivateView
                      ? 'Active Projects'
                      : 'Active Collaborations',
                  value: activeCount.toString(),
                  accent: accent,
                  iconColor: accent,
                  textColor: textColor,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CompletedProjectsPage(),
                    ),
                  );
                },
                child: _metricCard(
                  cardColor,
                  icon: Icons.check_circle_outline,
                  title: 'Completed Projects',
                  value: completedCount.toString(),
                  accent: accent,
                  iconColor: accent,
                  textColor: textColor,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _metricCard(
    Color cardColor, {
    required IconData icon,
    required String title,
    required String value,
    required Color accent,
    required Color iconColor,
    required Color textColor,
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
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
        ],
      ),
    );
  }

  Widget _quickActions(Color cardColor, Color accent, Color textColor) {
    final actions = [
      {'icon': Icons.add_circle_outline, 'label': 'Add work', 'color': accent},
      {
        'icon': Icons.account_balance_wallet,
        'label': 'Earnings',
        'color': Colors.green,
      },
      {
        'icon': Icons.local_offer_outlined,
        'label': 'Offers',
        'color': Colors.orange,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: actions.map((action) {
            return Expanded(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    if (action['label'] == 'Add work') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddWorkPage(),
                        ),
                      );
                    } else if (action['label'] == 'Earnings') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WalletGuardPage(),
                        ),
                      );
                    } else if (action['label'] == 'Offers') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BlocProvider(
                            create: (_) =>
                                di.sl<OffersBloc>()..add(const LoadOffers()),
                            child: const OffersListPage(),
                          ),
                        ),
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(14),
                  splashColor: (action['color'] as Color).withOpacity(0.3),
                  highlightColor: (action['color'] as Color).withOpacity(0.1),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: (action['color'] as Color).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: (action['color'] as Color).withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: action['color'] as Color,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: (action['color'] as Color).withOpacity(
                                  0.4,
                                ),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Icon(
                            action['icon'] as IconData,
                            color: textColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          action['label'] as String,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _portfolioShowcase(
    Color cardColor,
    Color accent,
    Color textColor,
    Color subtleText,
    List<PortfolioItemEntity> items,
    bool isLoading,
  ) {
    final filteredItems = _selectedTab == 'All'
        ? items
        : items.where((item) => item.type == _selectedTab).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Portfolio Showcase',
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                _isPrivateView ? 'Add Work' : 'view all',
                style: TextStyle(
                  color: accent,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ['All', 'Videos', 'Images', 'Audios'].map((tab) {
              final isSelected = tab == _selectedTab;
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => setState(() => _selectedTab = tab),
                  borderRadius: BorderRadius.circular(20),
                  splashColor: accent.withOpacity(0.3),
                  highlightColor: accent.withOpacity(0.1),
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? accent : cardColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      tab,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        if (isLoading)
          Column(children: List.generate(3, (index) => const ShimmerListItem()))
        else if (filteredItems.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(Icons.folder_open_outlined, size: 48, color: subtleText),
                  const SizedBox(height: 12),
                  Text(
                    'No portfolio items yet',
                    style: TextStyle(color: subtleText, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  if (_isPrivateView)
                    TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddWorkPage(),
                          ),
                        );
                      },
                      icon: Icon(Icons.add, color: accent),
                      label: Text(
                        'Add your first work',
                        style: TextStyle(color: accent),
                      ),
                    ),
                ],
              ),
            ),
          )
        else
          ...filteredItems.map((item) {
            return GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => PortfolioDetailModal(
                    item: item,
                    isEditable: _isPrivateView,
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: item.link != null && item.link!.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: item.link!,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: accent.withOpacity(0.2),
                                  child: Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: accent,
                                      ),
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: accent.withOpacity(0.2),
                                  child: Icon(
                                    _getIconForType(item.type),
                                    color: accent,
                                    size: 30,
                                  ),
                                ),
                              )
                            : Icon(
                                _getIconForType(item.type),
                                color: accent,
                                size: 30,
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.description,
                            style: TextStyle(color: subtleText, fontSize: 12),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'Videos':
        return Icons.videocam;
      case 'Images':
        return Icons.image;
      case 'Audios':
        return Icons.audiotrack;
      default:
        return Icons.folder;
    }
  }
}
