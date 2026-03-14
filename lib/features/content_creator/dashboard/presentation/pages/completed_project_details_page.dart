import 'package:flutter/material.dart';

class CompletedProjectDetailsPage extends StatelessWidget {
  final String contractId;
  
  const CompletedProjectDetailsPage({super.key, required this.contractId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;
    final cardColor = theme.cardColor;
    final accent = theme.colorScheme.secondary;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;
    final subtleText =
        theme.textTheme.bodySmall?.color ?? Colors.white.withOpacity(0.7);

    return Scaffold(
      backgroundColor: primary,
      appBar: AppBar(
        title: Text('E-commerce Redesign', style: TextStyle(color: textColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _headerCard(cardColor, accent, textColor, subtleText),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TOTAL PAID',
                        style: TextStyle(color: subtleText, fontSize: 10),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$4,500.00',
                        style: TextStyle(
                          color: accent,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TIMELINE',
                        style: TextStyle(color: subtleText, fontSize: 10),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Sep 12 - Nov 01',
                        style: TextStyle(color: textColor, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 16),
                  const SizedBox(width: 8),
                  const Text(
                    'Completed',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Project Description',
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Redesign of the main product landing page including mobile optimization and SEO overhaul. The goal was to increase conversion rates by 20% through a cleaner UI and faster load times. Delivered full Figma mockups and React implementation.',
              style: TextStyle(color: subtleText, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 32),
            _feedbackCard(
              tileColor: Color(0xFF1E2130),
              accent: Colors.amber,
              textColor: textColor,
              subtleText: subtleText,
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerCard(
    Color cardColor,
    Color accent,
    Color textColor,
    Color subtleText,
  ) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 20,
          backgroundImage: AssetImage('assets/images/deal.png'),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Jane Doe',
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Business Owner',
              style: TextStyle(color: subtleText, fontSize: 12),
            ),
          ],
        ),
        const Spacer(),
        Icon(Icons.chevron_right, color: subtleText),
      ],
    );
  }

  Widget _feedbackCard({
    required Color tileColor,
    required Color accent,
    required Color textColor,
    required Color subtleText,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: tileColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.verified, color: accent, size: 20),
              const SizedBox(width: 8),
              Text(
                'Client Feedback',
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (index) => Icon(Icons.star, color: accent, size: 28),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '"Excellent work! Delivered ahead of schedule and the designs were exactly what we needed. Communication was seamless throughout the entire process."',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor.withOpacity(0.9),
              fontSize: 14,
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              '5.0 RATING',
              style: TextStyle(
                color: subtleText,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
