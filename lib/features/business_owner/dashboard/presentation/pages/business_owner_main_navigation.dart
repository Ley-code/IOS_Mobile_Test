import 'package:flutter/material.dart';
import 'business_owner_dashboard.dart';
import 'business_owner_message.dart';
import 'business_owner_find_people.dart';
import 'business_owner_profile.dart';

class BusinessOwnerMainNavigation extends StatefulWidget {
  const BusinessOwnerMainNavigation({super.key});

  @override
  State<BusinessOwnerMainNavigation> createState() =>
      _BusinessOwnerMainNavigationState();
}

class _BusinessOwnerMainNavigationState
    extends State<BusinessOwnerMainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const BusinessOwnerPage(),
    const BusinessOwnerMessagePage(),
    const BusinessOwnerFindPeoplePage(),
    const BusinessOwnerProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;
    final accent = theme.colorScheme.secondary;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;

    return Scaffold(
      backgroundColor: primary,
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: _buildBottomNav(primary, accent, textColor),
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
          return InkWell(
            onTap: () => setState(() => _selectedIndex = index),
            borderRadius: BorderRadius.circular(10),
            splashColor: accent.withOpacity(0.3),
            highlightColor: accent.withOpacity(0.1),
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
