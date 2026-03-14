import 'package:flutter/material.dart';

class RoleCard extends StatelessWidget {
  const RoleCard({super.key, 
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.accent,
    required this.onTap,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;
    final subtleText = theme.textTheme.bodySmall?.color ?? Colors.white.withOpacity(0.7);
    final cardColor = theme.cardColor;
    final Color border = selected ? accent : subtleText.withOpacity(0.3);
    final Color fill = selected ? accent.withOpacity(0.08) : Colors.transparent;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border, width: 1.5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: subtleText),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: subtleText,
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: border, width: 2),
                color: selected ? accent : Colors.transparent,
              ),
              child: selected
                  ? Icon(Icons.circle, size: 10, color: textColor)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}