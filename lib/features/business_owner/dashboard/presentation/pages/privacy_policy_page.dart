import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;
    final cardColor = theme.cardColor;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;
    final subtleText =
        theme.textTheme.bodySmall?.color ?? Colors.white.withOpacity(0.7);

    return Scaffold(
      backgroundColor: primary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Data & Privacy Policy',
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy',
              style: TextStyle(
                color: textColor,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Last updated: ${DateTime.now().year}',
              style: TextStyle(color: subtleText, fontSize: 14),
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Information We Collect',
              'We collect information that you provide directly to us, including your name, email address, phone number, payment information, and any other information you choose to provide.',
              textColor,
              subtleText,
            ),
            const SizedBox(height: 20),
            _buildSection(
              'How We Use Your Information',
              'We use the information we collect to provide, maintain, and improve our services, process transactions, send you technical notices and support messages, and communicate with you about products and services.',
              textColor,
              subtleText,
            ),
            const SizedBox(height: 20),
            _buildSection(
              'Information Sharing',
              'We do not sell, trade, or rent your personal information to third parties. We may share your information only with service providers who assist us in operating our platform and conducting our business.',
              textColor,
              subtleText,
            ),
            const SizedBox(height: 20),
            _buildSection(
              'Data Security',
              'We implement appropriate technical and organizational security measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction.',
              textColor,
              subtleText,
            ),
            const SizedBox(height: 20),
            _buildSection(
              'Your Rights',
              'You have the right to access, update, or delete your personal information at any time. You can also opt-out of certain communications from us.',
              textColor,
              subtleText,
            ),
            const SizedBox(height: 20),
            _buildSection(
              'Cookies',
              'We use cookies and similar tracking technologies to track activity on our platform and hold certain information. You can instruct your browser to refuse all cookies or to indicate when a cookie is being sent.',
              textColor,
              subtleText,
            ),
            const SizedBox(height: 20),
            _buildSection(
              'Contact Us',
              'If you have any questions about this Privacy Policy, please contact us at privacy@vyrl.space',
              textColor,
              subtleText,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    String title,
    String content,
    Color textColor,
    Color subtleText,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(color: subtleText, fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }
}
