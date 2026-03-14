import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mobile_app/core/storage/token_storage.dart';
import 'package:mobile_app/core/network/api_client.dart';
import 'package:mobile_app/core/widgets/shimmer_loading.dart';
import 'package:mobile_app/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:mobile_app/features/chat/presentation/bloc/chat_state.dart';
import 'package:mobile_app/features/chat/data/models/conversation_model.dart';
import 'package:mobile_app/features/chat/domain/entities/conversation.dart';
import 'package:mobile_app/features/search/data/models/freelancer_profile_model.dart';
import 'package:mobile_app/features/business_owner/dashboard/presentation/pages/business_owner_message_details_page.dart';
import 'package:mobile_app/features/network/presentation/bloc/network_bloc.dart';
import 'package:mobile_app/features/freelancer_profile/presentation/bloc/freelancer_profile_bloc.dart';
import 'package:mobile_app/features/freelancer_profile/data/models/freelancer_profile_detail_model.dart';
import 'package:mobile_app/injection_container.dart' as di;
import 'dart:convert';

class FreelancerPublicProfilePage extends StatefulWidget {
  final FreelancerProfileModel freelancer;

  const FreelancerPublicProfilePage({super.key, required this.freelancer});

  @override
  State<FreelancerPublicProfilePage> createState() =>
      _FreelancerPublicProfilePageState();
}

class _FreelancerPublicProfilePageState
    extends State<FreelancerPublicProfilePage> {
  String? _currentUserEmail;
  bool? _isFollowing;
  int? _followersCount;

  // Profile data
  FreelancerProfileDetailModel? _profileDetail;
  List<ContractModel> _contracts = [];
  List<Map<String, dynamic>> _ratings = [];
  List<PortfolioItemModel> _portfolios = [];
  String _selectedPortfolioTab = 'all';

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
    _loadNetworkData();
    _loadProfileData();
  }

  void _loadProfileData() {
    final freelancerId = widget.freelancer.freelancerId;
    if (freelancerId.isNotEmpty) {
      context.read<FreelancerProfileBloc>().add(
        LoadFreelancerProfileEvent(freelancerId: freelancerId),
      );
      context.read<FreelancerProfileBloc>().add(
        LoadFreelancerContractsEvent(freelancerId: freelancerId),
      );
      context.read<FreelancerProfileBloc>().add(
        LoadFreelancerPortfoliosEvent(
          freelancerId: freelancerId,
          type: _selectedPortfolioTab == 'all' ? null : _selectedPortfolioTab,
        ),
      );
    }

    final userId = widget.freelancer.userId;
    if (userId.isNotEmpty) {
      context.read<FreelancerProfileBloc>().add(
        LoadFreelancerRatingsEvent(userId: userId),
      );
    }
  }

  void _loadNetworkData() {
    context.read<NetworkBloc>().add(
      CheckFollowStatusEvent(widget.freelancer.userId),
    );
    context.read<NetworkBloc>().add(
      LoadNetworkStatsEvent(widget.freelancer.userId),
    );
  }

  Future<void> _loadUserEmail() async {
    try {
      final apiClient = di.sl<ApiClient>();
      final response = await apiClient.get('/users/profile', requireAuth: true);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final user = json['user'] as Map<String, dynamic>?;
        setState(() {
          _currentUserEmail = user?['email'] as String?;
        });
      }
    } catch (e) {
      // Silently fail
    }
  }

  Future<void> _handleMessage() async {
    try {
      final tokenStorage = di.sl<TokenStorage>();
      final currentUserId = await tokenStorage.getUserId();

      if (currentUserId == null || widget.freelancer.userId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to get user information')),
        );
        return;
      }

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Call API directly to get/create conversation
      final apiClient = di.sl<ApiClient>();
      final response = await apiClient.post('/conversations', {
        'client_id': currentUserId,
        'freelancer_id': widget.freelancer.userId,
      }, requireAuth: true);

      if (Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final conversationData = data['conversation'] as Map<String, dynamic>?;
        final created = data['created'] as bool? ?? true;
        final message = data['message'] as String? ?? '';

        if (conversationData != null) {
          final conversationModel = ConversationModel.fromJson(
            conversationData,
          );
          final conversation = Conversation(
            id: conversationModel.id,
            clientId: conversationModel.clientId,
            freelancerId: conversationModel.freelancerId,
            jobId: conversationModel.jobId,
            proposalId: conversationModel.proposalId,
            rocketChatRoomId: conversationModel.rocketChatRoomId,
            rocketChatRoomName: conversationModel.rocketChatRoomName,
            createdAt: conversationModel.createdAt,
            updatedAt: conversationModel.updatedAt,
            lastMessageAt: conversationModel.lastMessageAt,
          );

          // If conversation already existed, navigate to messages tab
          if (!created && message.toLowerCase().contains('already exists')) {
            _navigateToMessagesTab(conversation);
          } else {
            // New conversation, navigate directly
            final userEmail = _currentUserEmail ?? '';
            if (mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<ChatBloc>(),
                    child: BusinessOwnerMessageDetailsPage(
                      conversation: conversation,
                      userEmail: userEmail,
                    ),
                  ),
                ),
              );
            }
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to start conversation')),
        );
      }
    } catch (e) {
      if (Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  void _navigateToMessagesTab(Conversation conversation) {
    final userEmail = _currentUserEmail ?? '';
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<ChatBloc>(),
          child: BusinessOwnerMessageDetailsPage(
            conversation: conversation,
            userEmail: userEmail,
          ),
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final months = [
      'january',
      'february',
      'march',
      'april',
      'may',
      'june',
      'july',
      'august',
      'september',
      'october',
      'november',
      'december',
    ];
    return 'Joined ${months[date.month - 1]} ${date.year}';
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

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<ChatBloc>()),
        BlocProvider(create: (_) => di.sl<NetworkBloc>()),
        // FreelancerProfileBloc is already provided globally in main.dart
        // Use BlocProvider.value to override with a fresh instance for this page
        BlocProvider(create: (_) => di.sl<FreelancerProfileBloc>()),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<NetworkBloc, NetworkState>(
            listener: (context, state) {
              if (state is FollowStatusLoaded) {
                setState(() {
                  _isFollowing = state.isFollowing;
                });
              } else if (state is NetworkStatsLoaded) {
                setState(() {
                  _followersCount = state.followers;
                });
              } else if (state is UserFollowed) {
                setState(() {
                  _isFollowing = true;
                  if (_followersCount != null) {
                    _followersCount = _followersCount! + 1;
                  }
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User followed successfully')),
                );
              } else if (state is UserUnfollowed) {
                setState(() {
                  _isFollowing = false;
                  if (_followersCount != null && _followersCount! > 0) {
                    _followersCount = _followersCount! - 1;
                  }
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User unfollowed successfully')),
                );
              } else if (state is NetworkError) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
              }
            },
          ),
          BlocListener<FreelancerProfileBloc, FreelancerProfileState>(
            listener: (context, state) {
              if (state is FreelancerProfileLoaded) {
                setState(() {
                  _profileDetail = state.profile;
                });
              } else if (state is FreelancerContractsLoaded) {
                setState(() {
                  _contracts = state.contracts;
                });
              } else if (state is FreelancerRatingsLoaded) {
                setState(() {
                  _ratings = state.ratings;
                });
              } else if (state is FreelancerPortfoliosLoaded) {
                setState(() {
                  _portfolios = state.portfolios;
                });
              } else if (state is FreelancerProfileError) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
              }
            },
          ),
          BlocListener<ChatBloc, ChatState>(
            listener: (context, state) {
              if (state is ConversationStarted) {
                if (Navigator.of(context, rootNavigator: true).canPop()) {
                  Navigator.of(context, rootNavigator: true).pop();
                }

                final userEmail = _currentUserEmail ?? '';
                if (mounted) {
                  final conversation = Conversation(
                    id: state.conversation.id,
                    clientId: state.conversation.clientId,
                    freelancerId: state.conversation.freelancerId,
                    jobId: state.conversation.jobId,
                    proposalId: state.conversation.proposalId,
                    rocketChatRoomId: state.conversation.rocketChatRoomId,
                    rocketChatRoomName: state.conversation.rocketChatRoomName,
                    createdAt: state.conversation.createdAt,
                    updatedAt: state.conversation.updatedAt,
                    lastMessageAt: state.conversation.lastMessageAt,
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<ChatBloc>(),
                        child: BusinessOwnerMessageDetailsPage(
                          conversation: conversation,
                          userEmail: userEmail,
                        ),
                      ),
                    ),
                  );
                }
              } else if (state is ConversationError ||
                  state is RoomError ||
                  state is ChatConnectionError) {
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
              'Discover Talent',
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.notifications_outlined, color: textColor),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Banner
                _buildWelcomeBanner(cardColor, accent, textColor, subtleText),

                const SizedBox(height: 16),

                // Profile Card
                _buildProfileCard(cardColor, accent, textColor, subtleText),

                const SizedBox(height: 16),

                // Availability Status
                _buildAvailabilityCard(
                  cardColor,
                  accent,
                  textColor,
                  subtleText,
                ),

                const SizedBox(height: 16),

                // Followers Card (only for content creators)
                if (_profileDetail?.isContentCreator ?? false)
                  _buildFollowersCard(cardColor, accent, textColor, subtleText),

                if (_profileDetail?.isContentCreator ?? false)
                  const SizedBox(height: 16),

                // Stats Cards (Active Collaborations & Completed Projects)
                _buildStatsCards(cardColor, accent, textColor, subtleText),

                const SizedBox(height: 16),

                // Introduction
                if (_profileDetail?.introduction != null &&
                    _profileDetail!.introduction!.isNotEmpty)
                  _buildIntroductionCard(
                    cardColor,
                    accent,
                    textColor,
                    subtleText,
                  ),

                if (_profileDetail?.introduction != null &&
                    _profileDetail!.introduction!.isNotEmpty)
                  const SizedBox(height: 16),

                // Portfolio Showcase
                _buildPortfolioShowcase(
                  cardColor,
                  accent,
                  textColor,
                  subtleText,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeBanner(
    Color cardColor,
    Color accent,
    Color textColor,
    Color subtleText,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: accent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome, Visitor!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Explore ${_profileDetail?.firstName ?? widget.freelancer.firstName}\'s public portfolio and recent achievements.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildProfileCard(
    Color cardColor,
    Color accent,
    Color textColor,
    Color subtleText,
  ) {
    // Use local variables as single source of truth
    final profile = _profileDetail;
    final rating = profile?.averageRating ?? 0.0;
    final reviewCount = profile?.reviewCount ?? _ratings.length;

    // Get profile picture URL - prioritize _profileDetail, but immediately fallback to widget
    final profilePictureUrl =
        _profileDetail?.profilePictureUrl ??
        widget.freelancer.profilePictureUrl;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Profile Picture
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [accent.withOpacity(0.3), accent.withOpacity(0.1)],
              ),
            ),
            child: profilePictureUrl != null && profilePictureUrl.isNotEmpty
                ? ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: profilePictureUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: accent,
                        ),
                      ),
                      errorWidget: (context, url, error) {
                        // Debug: Print error details
                        print('Profile Image Error - URL: $url, Error: $error');
                        return Center(
                          child: Text(
                            (profile?.firstName ?? widget.freelancer.firstName)
                                    .isNotEmpty
                                ? (profile?.firstName ??
                                          widget.freelancer.firstName)[0]
                                      .toUpperCase()
                                : 'U',
                            style: TextStyle(
                              color: accent,
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : Center(
                    child: Text(
                      (profile?.firstName ?? widget.freelancer.firstName)
                              .isNotEmpty
                          ? (profile?.firstName ??
                                    widget.freelancer.firstName)[0]
                                .toUpperCase()
                          : 'U',
                      style: TextStyle(
                        color: accent,
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          // Name
          Text(
            profile?.fullName ?? widget.freelancer.fullName,
            style: TextStyle(
              color: textColor,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          // Rating
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star, color: Colors.amber, size: 18),
              const SizedBox(width: 4),
              Text(
                '${rating.toStringAsFixed(1)} ($reviewCount reviews)',
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Username
          Text(
            '@${profile?.userName ?? widget.freelancer.userName}',
            style: TextStyle(color: subtleText, fontSize: 14),
          ),
          const SizedBox(height: 8),
          // Role
          Text(
            profile?.headline ?? 'Freelancer',
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          // Location
          if (profile?.location != null || widget.freelancer.location != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_on, color: subtleText, size: 16),
                const SizedBox(width: 4),
                Text(
                  profile?.location ?? widget.freelancer.location!,
                  style: TextStyle(color: subtleText, fontSize: 12),
                ),
              ],
            ),
          // Joined Date
          if (profile?.createdAt != null) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_today, color: subtleText, size: 14),
                const SizedBox(width: 4),
                Text(
                  _formatDate(profile!.createdAt),
                  style: TextStyle(color: subtleText, fontSize: 12),
                ),
              ],
            ),
          ],
          const SizedBox(height: 20),
          // Action Buttons
          Row(
            children: [
              // Follow Button
              Expanded(
                child: BlocBuilder<NetworkBloc, NetworkState>(
                  builder: (context, state) {
                    final isLoading = state is NetworkLoading;
                    final isFollowing = _isFollowing ?? false;

                    return ElevatedButton.icon(
                      onPressed: isLoading
                          ? null
                          : () {
                              if (isFollowing) {
                                context.read<NetworkBloc>().add(
                                  UnfollowUserEvent(widget.freelancer.userId),
                                );
                              } else {
                                context.read<NetworkBloc>().add(
                                  FollowUserEvent(widget.freelancer.userId),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isFollowing
                            ? Colors.transparent
                            : accent,
                        foregroundColor: isFollowing ? accent : Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: accent, width: 2),
                        ),
                      ),
                      icon: isLoading
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: isFollowing ? accent : Colors.white,
                              ),
                            )
                          : Icon(
                              isFollowing
                                  ? Icons.person_remove
                                  : Icons.person_add,
                              size: 18,
                            ),
                      label: Text(
                        isFollowing ? 'Unfollow' : 'Follow',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              // Message Button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _handleMessage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: Icon(Icons.message, size: 18),
                  label: const Text(
                    'Direct Message',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilityCard(
    Color cardColor,
    Color accent,
    Color textColor,
    Color subtleText,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline, color: accent, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: textColor, fontSize: 14),
                children: [
                  TextSpan(
                    text:
                        '${_profileDetail?.firstName ?? widget.freelancer.firstName} is currently ',
                  ),
                  TextSpan(
                    text: 'Open to Work',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: accent,
                    ),
                  ),
                  const TextSpan(text: ' for new jobs starting next month.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFollowersCard(
    Color cardColor,
    Color accent,
    Color textColor,
    Color subtleText,
  ) {
    final totalFollowers = _profileDetail?.totalFollowers ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.camera_alt_outlined, color: accent, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Followers Across All Platforms',
                  style: TextStyle(color: subtleText, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatNumber(totalFollowers),
                  style: TextStyle(
                    color: textColor,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.trending_up, color: Colors.green, size: 24),
        ],
      ),
    );
  }

  Widget _buildStatsCards(
    Color cardColor,
    Color accent,
    Color textColor,
    Color subtleText,
  ) {
    final activeProjects = _contracts.where((c) => c.status == 'active').length;
    final completedProjects = _profileDetail?.projectsCompleted ?? 0;

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(Icons.work_outline, color: accent, size: 24),
                const SizedBox(height: 8),
                Text(
                  activeProjects.toString(),
                  style: TextStyle(
                    color: textColor,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Active Collaborations',
                  style: TextStyle(color: subtleText, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.green, size: 24),
                const SizedBox(height: 8),
                Text(
                  completedProjects.toString(),
                  style: TextStyle(
                    color: textColor,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Completed Projects',
                  style: TextStyle(color: subtleText, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIntroductionCard(
    Color cardColor,
    Color accent,
    Color textColor,
    Color subtleText,
  ) {
    final introduction = _profileDetail?.introduction ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Introduction',
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            introduction,
            style: TextStyle(color: textColor, fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioShowcase(
    Color cardColor,
    Color accent,
    Color textColor,
    Color subtleText,
  ) {
    // Use BlocBuilder to directly read from bloc state
    return BlocBuilder<FreelancerProfileBloc, FreelancerProfileState>(
      // Remove buildWhen to ensure we always rebuild when state changes
      // This ensures portfolios show on initial load
      builder: (context, state) {
        // Get portfolios from state or fallback to local _portfolios
        List<PortfolioItemModel> portfolios = [];
        bool isLoading = false;

        if (state is FreelancerPortfoliosLoaded) {
          portfolios = state.portfolios;
          isLoading =
              false; // Explicitly set loading to false when portfolios are loaded
          // Always update local state when portfolios are loaded to trigger parent rebuild
          // This ensures the UI updates when portfolios are loaded on initial page load
          if (_portfolios.length != portfolios.length ||
              !_portfolios.every(
                (p) => portfolios.any((p2) => p2.portfolioId == p.portfolioId),
              )) {
            // Use Future.microtask to ensure setState is called after current build
            Future.microtask(() {
              if (mounted) {
                setState(() {
                  _portfolios = List.from(portfolios);
                });
              }
            });
          }
        } else if (state is FreelancerProfileLoading) {
          isLoading = true;
        } else {
          // Fallback to local state if bloc state is not available
          portfolios = _portfolios;
          isLoading = false; // Not loading if we're using fallback
        }

        // Filter portfolios based on selected tab
        final filteredPortfolios = _selectedPortfolioTab == 'all'
            ? portfolios
            : portfolios
                  .where((p) => p.type.toLowerCase() == _selectedPortfolioTab)
                  .toList();

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Portfolio Showcase',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'view all',
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
              // Filter Tabs
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['all', 'video', 'image', 'audio'].map((tab) {
                    final isSelected =
                        _selectedPortfolioTab == tab.toLowerCase();
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedPortfolioTab = tab.toLowerCase();
                            });
                            final freelancerId = widget.freelancer.freelancerId;
                            if (freelancerId.isNotEmpty) {
                              context.read<FreelancerProfileBloc>().add(
                                LoadFreelancerPortfoliosEvent(
                                  freelancerId: freelancerId,
                                  type: _selectedPortfolioTab == 'all'
                                      ? null
                                      : _selectedPortfolioTab,
                                ),
                              );
                            }
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected ? accent : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? accent
                                    : subtleText.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              tab,
                              style: TextStyle(
                                color: isSelected ? Colors.white : textColor,
                                fontSize: 14,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              // Portfolio Items
              if (isLoading)
                Column(
                  children: List.generate(
                    3,
                    (index) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          ShimmerLoading(
                            width: 80,
                            height: 80,
                            borderRadius: 12,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ShimmerLoading(
                                  width: double.infinity,
                                  height: 16,
                                  borderRadius: 4,
                                ),
                                const SizedBox(height: 8),
                                ShimmerLoading(
                                  width: 200,
                                  height: 12,
                                  borderRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else if (filteredPortfolios.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'No portfolio items found',
                      style: TextStyle(color: subtleText, fontSize: 14),
                    ),
                  ),
                )
              else
                ...filteredPortfolios.take(3).map((portfolio) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: accent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child:
                              portfolio.thumbnailUrl != null &&
                                  portfolio.thumbnailUrl!.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: CachedNetworkImage(
                                    imageUrl: portfolio.thumbnailUrl!,
                                    fit: BoxFit.cover,
                                    errorWidget: (context, url, error) {
                                      // Debug: Print error details
                                      print(
                                        'Portfolio Image Error - URL: $url, Error: $error',
                                      );
                                      return Icon(
                                        Icons.image,
                                        color: accent,
                                        size: 32,
                                      );
                                    },
                                  ),
                                )
                              : Icon(
                                  portfolio.type == 'video'
                                      ? Icons.videocam
                                      : portfolio.type == 'audio'
                                      ? Icons.audiotrack
                                      : Icons.image,
                                  color: accent,
                                  size: 32,
                                ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                portfolio.title,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              if (portfolio.description != null)
                                Text(
                                  portfolio.description!,
                                  style: TextStyle(
                                    color: subtleText,
                                    fontSize: 12,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
            ],
          ),
        );
      },
    );
  }
}
