import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mobile_app/features/search/data/models/freelancer_profile_model.dart';
import 'package:mobile_app/features/search/presentation/bloc/search_bloc.dart';
import 'package:mobile_app/features/business_owner/dashboard/presentation/pages/freelancer_public_profile_page.dart';
import 'package:mobile_app/core/widgets/shimmer_loading.dart';

class BusinessOwnerFindPeoplePage extends StatefulWidget {
  const BusinessOwnerFindPeoplePage({super.key});

  @override
  State<BusinessOwnerFindPeoplePage> createState() =>
      _BusinessOwnerFindPeoplePageState();
}

class _BusinessOwnerFindPeoplePageState
    extends State<BusinessOwnerFindPeoplePage> {
  final TextEditingController _searchController = TextEditingController();
  String? _currentSearchTerm;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      // Update search term and filter in real-time for people search
      final searchTerm = _searchController.text.trim();
      _currentSearchTerm = searchTerm.isEmpty ? null : searchTerm;
      setState(() {}); // Rebuild to apply filter
    });
    // Load all freelancers when page opens (for 'people' search)
    context.read<SearchBloc>().add(const LoadAllFreelancersEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    final searchTerm = _searchController.text.trim();
    _currentSearchTerm = searchTerm.isEmpty ? null : searchTerm;
    // For people search, filter locally if all freelancers are loaded
    setState(() {});
  }

  Future<void> _onRefresh() async {
    context.read<SearchBloc>().add(const LoadAllFreelancersEvent());
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

    return BlocConsumer<SearchBloc, SearchState>(
      listener: (context, state) {
        if (state is SearchError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      },
      builder: (context, state) {
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
                      _searchBar(cardColor, subtleText, accent, textColor),
                    ],
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _onRefresh,
                    color: accent,
                    backgroundColor: cardColor,
                    child: _buildContent(
                      state,
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
      },
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
              'Search',
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
                hintText: 'Search by name, skills, or location',
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
                context.read<SearchBloc>().add(const ClearSearchEvent());
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
    SearchState state,
    Color cardColor,
    Color accent,
    Color textColor,
    Color subtleText,
  ) {
    if (state is SearchLoading) {
      // Show shimmer loading for freelancer cards
      return ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        itemCount: 5, // Show 5 shimmer cards
        itemBuilder: (context, index) => _buildShimmerFreelancerCard(cardColor),
      );
    }

    // Handle freelancers - both SearchFreelancersLoaded and AllFreelancersLoaded
    List<FreelancerProfileModel> freelancers = [];
    if (state is SearchFreelancersLoaded) {
      freelancers = state.freelancers;
    } else if (state is AllFreelancersLoaded) {
      freelancers = state.freelancers;
      // Filter by search term if provided
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

    // Show freelancers if we have any
    if (freelancers.isNotEmpty) {
      return ListView.builder(
        physics:
            const AlwaysScrollableScrollPhysics(), // Enable pull-to-refresh
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

    // Show empty state for freelancers if loaded but empty
    if (state is AllFreelancersLoaded || state is SearchFreelancersLoaded) {
      return _emptyState(
        'No freelancers found',
        _currentSearchTerm != null && _currentSearchTerm!.isNotEmpty
            ? 'Try adjusting your search terms'
            : 'No freelancers available',
        subtleText,
        textColor,
      );
    }

    // If we're in initial state and haven't loaded yet, show loading
    return const Center(child: CircularProgressIndicator());
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

  Widget _freelancerCard(
    FreelancerProfileModel freelancer,
    Color cardColor,
    Color accent,
    Color textColor,
    Color subtleText,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                FreelancerPublicProfilePage(freelancer: freelancer),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Profile picture with fallback
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [accent.withOpacity(0.3), accent.withOpacity(0.1)],
                ),
              ),
              child: _buildProfilePicture(freelancer, accent),
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
      ),
    );
  }

  Widget _buildProfilePicture(FreelancerProfileModel freelancer, Color accent) {
    // Check if profile picture URL is valid
    final profilePicUrl = freelancer.profilePictureUrl;
    final hasValidUrl =
        profilePicUrl != null &&
        profilePicUrl.isNotEmpty &&
        (profilePicUrl.startsWith('http://') ||
            profilePicUrl.startsWith('https://'));

    if (hasValidUrl) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: CachedNetworkImage(
          imageUrl: profilePicUrl,
          fit: BoxFit.cover,
          width: 60,
          height: 60,
          placeholder: (context, url) => Center(
            child: CircularProgressIndicator(strokeWidth: 2, color: accent),
          ),
          errorWidget: (context, url, error) =>
              _buildInitialAvatar(freelancer, accent),
        ),
      );
    } else {
      return _buildInitialAvatar(freelancer, accent);
    }
  }

  Widget _buildInitialAvatar(FreelancerProfileModel freelancer, Color accent) {
    final initial = freelancer.firstName.isNotEmpty
        ? freelancer.firstName[0].toUpperCase()
        : (freelancer.userName.isNotEmpty
              ? freelancer.userName[0].toUpperCase()
              : 'U');

    return Center(
      child: Text(
        initial,
        style: TextStyle(
          color: accent,
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildShimmerFreelancerCard(Color cardColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          // Shimmer avatar
          ShimmerLoading(width: 60, height: 60, borderRadius: 16),
          const SizedBox(width: 16),
          // Shimmer content
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
                ShimmerLoading(width: 100, height: 12, borderRadius: 4),
                const SizedBox(height: 8),
                ShimmerLoading(
                  width: double.infinity,
                  height: 12,
                  borderRadius: 4,
                ),
                const SizedBox(height: 4),
                ShimmerLoading(width: 150, height: 12, borderRadius: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
