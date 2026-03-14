import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mobile_app/core/storage/token_storage.dart';
import 'package:mobile_app/core/widgets/shimmer_loading.dart';
import 'package:mobile_app/features/network/domain/entities/network_entity.dart';
import 'package:mobile_app/features/network/presentation/bloc/network_bloc.dart';
import 'package:mobile_app/injection_container.dart' as di;

class NetworkPage extends StatefulWidget {
  const NetworkPage({super.key});

  @override
  State<NetworkPage> createState() => _NetworkPageState();
}

class _NetworkPageState extends State<NetworkPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _currentUserId;
  int _followersCount = 0;
  int _followingCount = 0;
  List<NetworkUser> _followers = [];
  List<NetworkUser> _following = [];
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCurrentUserId().then((_) {
      // Load data after the first frame to ensure context is available
      if (mounted && _currentUserId != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _refreshData(_currentUserId!);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUserId() async {
    final tokenStorage = di.sl<TokenStorage>();
    final userId = await tokenStorage.getUserId();
    setState(() {
      _currentUserId = userId;
    });
  }

  Future<void> _refreshData(String userId) async {
    if (!mounted) return;
    final bloc = context.read<NetworkBloc>();
    bloc.add(LoadNetworkStatsEvent(userId));
    bloc.add(LoadFollowersEvent(userId));
    bloc.add(LoadFollowingEvent(userId));
  }

  Future<void> _onRefresh() async {
    if (_currentUserId != null) {
      await _refreshData(_currentUserId!);
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

    return BlocListener<NetworkBloc, NetworkState>(
      listener: (context, state) {
        if (state is NetworkStatsLoaded) {
          if (mounted) {
            setState(() {
              _followersCount = state.followers;
              _followingCount = state.following;
            });
          }
        } else if (state is FollowersLoaded) {
          if (mounted) {
            setState(() {
              _followers = state.followers;
            });
          }
        } else if (state is FollowingLoaded) {
          if (mounted) {
            setState(() {
              _following = state.following;
            });
          }
        } else if (state is UserFollowed || state is UserUnfollowed) {
          // Reload data after follow/unfollow
          if (_currentUserId != null && mounted) {
            _refreshData(_currentUserId!);
          }
        } else if (state is NetworkError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
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
            'My Network',
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: accent,
            labelColor: accent,
            unselectedLabelColor: subtleText,
            tabs: const [
              Tab(text: 'Following'),
              Tab(text: 'Followers'),
            ],
          ),
        ),
        body: BlocBuilder<NetworkBloc, NetworkState>(
          builder: (context, state) {
            final isLoading = state is NetworkLoading;
            return Column(
              children: [
                // Network Stats Card
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        'Followers',
                        _followersCount,
                        textColor,
                        subtleText,
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: subtleText.withOpacity(0.3),
                      ),
                      _buildStatItem(
                        'Following',
                        _followingCount,
                        textColor,
                        subtleText,
                      ),
                    ],
                  ),
                ),
                // Tab Content with Pull to Refresh
                Expanded(
                  child: RefreshIndicator(
                    key: _refreshIndicatorKey,
                    onRefresh: _onRefresh,
                    color: accent,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildFollowingList(
                          cardColor,
                          accent,
                          textColor,
                          subtleText,
                          isLoading,
                        ),
                        _buildFollowersList(
                          cardColor,
                          accent,
                          textColor,
                          subtleText,
                          isLoading,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    int count,
    Color textColor,
    Color subtleText,
  ) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            color: textColor,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: subtleText, fontSize: 14)),
      ],
    );
  }

  Widget _buildFollowingList(
    Color cardColor,
    Color accent,
    Color textColor,
    Color subtleText,
    bool isLoading,
  ) {
    if (isLoading && _following.isEmpty) {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 5,
        itemBuilder: (context, index) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              ShimmerLoading(width: 50, height: 50, borderRadius: 25),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerLoading(width: 150, height: 16, borderRadius: 4),
                    const SizedBox(height: 8),
                    ShimmerLoading(width: 100, height: 12, borderRadius: 4),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_following.isEmpty && !isLoading) {
      return ListView(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: subtleText),
                  const SizedBox(height: 16),
                  Text(
                    'You are not following anyone yet',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Explore profiles to start building your network',
                    style: TextStyle(color: subtleText, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _following.length,
      itemBuilder: (context, index) {
        final user = _following[index];
        return _buildUserCard(
          user: user,
          cardColor: cardColor,
          accent: accent,
          textColor: textColor,
          subtleText: subtleText,
          showUnfollow: true,
        );
      },
    );
  }

  Widget _buildFollowersList(
    Color cardColor,
    Color accent,
    Color textColor,
    Color subtleText,
    bool isLoading,
  ) {
    if (isLoading && _followers.isEmpty) {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 5,
        itemBuilder: (context, index) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              ShimmerLoading(width: 50, height: 50, borderRadius: 25),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerLoading(width: 150, height: 16, borderRadius: 4),
                    const SizedBox(height: 8),
                    ShimmerLoading(width: 100, height: 12, borderRadius: 4),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_followers.isEmpty && !isLoading) {
      return ListView(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: subtleText),
                  const SizedBox(height: 16),
                  Text(
                    'No followers yet',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start connecting with others to grow your network',
                    style: TextStyle(color: subtleText, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _followers.length,
      itemBuilder: (context, index) {
        final user = _followers[index];
        return _buildUserCard(
          user: user,
          cardColor: cardColor,
          accent: accent,
          textColor: textColor,
          subtleText: subtleText,
          showUnfollow: false,
        );
      },
    );
  }

  Widget _buildUserCard({
    required NetworkUser user,
    required Color cardColor,
    required Color accent,
    required Color textColor,
    required Color subtleText,
    required bool showUnfollow,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Profile Picture
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [accent.withOpacity(0.3), accent.withOpacity(0.1)],
              ),
            ),
            child:
                user.profilePictureUrl != null &&
                    user.profilePictureUrl!.isNotEmpty
                ? ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: user.profilePictureUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: accent,
                        ),
                      ),
                      errorWidget: (context, url, error) => Center(
                        child: Text(
                          user.firstName.isNotEmpty
                              ? user.firstName[0].toUpperCase()
                              : 'U',
                          style: TextStyle(
                            color: accent,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      user.firstName.isNotEmpty
                          ? user.firstName[0].toUpperCase()
                          : 'U',
                      style: TextStyle(
                        color: accent,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.userName.isNotEmpty ? '@${user.userName}' : 'User',
                  style: TextStyle(color: subtleText, fontSize: 12),
                ),
              ],
            ),
          ),
          // Unfollow Button (only in Following tab)
          if (showUnfollow)
            TextButton(
              onPressed: () {
                context.read<NetworkBloc>().add(UnfollowUserEvent(user.id));
              },
              style: TextButton.styleFrom(
                foregroundColor: accent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              child: const Text('Unfollow'),
            ),
        ],
      ),
    );
  }
}
 