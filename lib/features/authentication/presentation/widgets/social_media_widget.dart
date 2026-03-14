import 'package:flutter/material.dart';

/// A row widget for displaying a social media connection option.
///
/// Shows the platform icon, name, and a connect/connected button.
Widget socialRow(
  BuildContext context,
  String label,
  IconData icon, {
  required bool connected,
  VoidCallback? onTap, // Made nullable to support disabled state
}) {
  final theme = Theme.of(context);
  final textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;
  final cardColor = theme.cardColor;
  final accent = theme.colorScheme.secondary;

  return Container(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
    decoration: BoxDecoration(
      border: Border.all(
        color: connected ? accent.withOpacity(0.3) : cardColor,
      ),
      borderRadius: BorderRadius.circular(10),
      color: connected ? accent.withOpacity(0.05) : null,
    ),
    child: Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: cardColor,
          child: Icon(
            icon,
            color: connected ? accent : textColor.withOpacity(0.7),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: connected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
        const SizedBox(width: 12),
        if (connected)
          // Show connected indicator
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.green.shade400, size: 20),
              const SizedBox(width: 6),
              Text(
                'Connected',
                style: TextStyle(
                  color: Colors.green.shade400,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          )
        else
          // Show connect button
          SizedBox(
            height: 36,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                disabledBackgroundColor: accent.withOpacity(0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: const Text(
                'Connect',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

/// A card widget showing connected social account with stats.
Widget connectedCard(
  BuildContext context, {
  required String platform,
  required IconData icon,
  required String followers,
  required String likes,
  required String joinedYear,
}) {
  final theme = Theme.of(context);
  final textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;
  final subtleText =
      theme.textTheme.bodySmall?.color ?? Colors.white.withOpacity(0.7);
  final cardColor = theme.cardColor;
  final accent = theme.colorScheme.secondary;

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: accent.withOpacity(0.18)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: cardColor,
              child: Icon(icon, color: textColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                platform,
                style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 8),
            Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green.shade400,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  'Connected',
                  style: TextStyle(color: subtleText, fontSize: 13),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _statItem(followers, 'Followers', textColor, subtleText),
            _statItem(likes, 'Likes', textColor, subtleText),
            _statItem(joinedYear, 'Opened In', textColor, subtleText),
          ],
        ),
      ],
    ),
  );
}

Widget _statItem(
  String value,
  String label,
  Color textColor,
  Color subtleText,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        value,
        style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
      ),
      const SizedBox(height: 4),
      Text(label, style: TextStyle(fontSize: 12, color: subtleText)),
    ],
  );
}
