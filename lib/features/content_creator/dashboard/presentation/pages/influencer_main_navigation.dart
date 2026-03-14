import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/features/authentication/domain/entities/user_entity.dart';
import 'package:mobile_app/features/content_creator/dashboard/presentation/bloc/influencer_dashboard_bloc.dart';
import 'package:mobile_app/features/content_creator/projects/presentation/bloc/contract_bloc.dart';
import 'package:mobile_app/features/jobs/presentation/bloc/jobs_bloc.dart';
import 'package:mobile_app/features/search/presentation/bloc/search_bloc.dart';
import 'package:mobile_app/injection_container.dart' as di;
import 'influencer_dashboard.dart';
import 'influencer_message.dart';
import 'influencer_find_people.dart';
import 'influencer_profile.dart';

class InfluencerMainNavigation extends StatefulWidget {
  final UserRole userRole;

  const InfluencerMainNavigation({super.key, this.userRole = UserRole.creative});

  @override
  State<InfluencerMainNavigation> createState() =>
      _InfluencerMainNavigationState();
}

class _InfluencerMainNavigationState extends State<InfluencerMainNavigation> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // #region agent log
    try {
      print(
        '[DEBUG] InfluencerMainNavigation - initState called, userRole=${widget.userRole}',
      );
    } catch (e) {}
    // #endregion

    _pages = [
      InfluencerDashboardPage(userRole: widget.userRole),
      const InfluencerMessagePage(),
      const InfluencerFindPeoplePage(),
      const InfluencerProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // #region agent log
    try {
      print('[DEBUG] InfluencerMainNavigation - build called');
    } catch (e) {}
    // #endregion

    final theme = Theme.of(context);
    final primary = theme.primaryColor;
    final accent = theme.colorScheme.secondary;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;

    return MultiBlocProvider(
      providers: [
        BlocProvider<InfluencerDashboardBloc>(
          create: (_) => di.sl<InfluencerDashboardBloc>(),
        ),
        BlocProvider<ContractBloc>(create: (_) => di.sl<ContractBloc>()),
        BlocProvider<JobsBloc>(create: (_) => di.sl<JobsBloc>()),
        BlocProvider<SearchBloc>(create: (_) => di.sl<SearchBloc>()),
      ],
      child: Scaffold(
        backgroundColor: primary,
        body: IndexedStack(index: _selectedIndex, children: _pages),
        bottomNavigationBar: _buildBottomNav(primary, accent, textColor),
      ),
    );
  }

  Widget _buildBottomNav(Color primary, Color accent, Color textColor) {
    const items = [
      {'icon': Icons.dashboard_outlined, 'label': 'Dashboard'},
      {'icon': Icons.chat_bubble_outline, 'label': 'Messages'},
      {'icon': Icons.search, 'label': 'Search'},
      {'icon': Icons.person_outline, 'label': 'Profile'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: primary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            offset: const Offset(0, -2),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final isActive = _selectedIndex == index;
          final color = isActive ? accent : textColor.withOpacity(0.7);
          return GestureDetector(
            onTap: () => setState(() => _selectedIndex = index),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(items[index]['icon'] as IconData, color: color, size: 24),
                const SizedBox(height: 6),
                Text(
                  items[index]['label'] as String,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
