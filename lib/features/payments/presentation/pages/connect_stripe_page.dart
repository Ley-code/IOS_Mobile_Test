import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mobile_app/core/widgets/error_widget.dart';
import 'package:mobile_app/features/payments/domain/entities/stripe_account_entity.dart';
import 'package:mobile_app/features/payments/presentation/bloc/payment_bloc.dart';
import 'package:mobile_app/features/payments/presentation/bloc/payment_event.dart';
import 'package:mobile_app/features/payments/presentation/bloc/payment_state.dart';

class ConnectStripePage extends StatefulWidget {
  const ConnectStripePage({super.key});

  @override
  State<ConnectStripePage> createState() => _ConnectStripePageState();
}

class _ConnectStripePageState extends State<ConnectStripePage>
    with WidgetsBindingObserver {
  bool _isWaitingForOnboarding = false;
  bool _showConnectContent =
      false; // Track whether to show connect content or account status

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Note: WalletGuardPage handles LoadStripeAccountStatus, we don't need to call it here
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // When app comes back to foreground after user completes onboarding
    if (state == AppLifecycleState.resumed && _isWaitingForOnboarding) {
      _isWaitingForOnboarding = false;
      // Refresh status after a short delay to allow backend to process
      // This will trigger WalletGuardPage to re-check and potentially route to WalletPage
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          context.read<PaymentBloc>().add(const LoadStripeAccountStatus());
        }
      });
    }
  }

  Future<void> _launchUrl(String url) async {
    try {
      if (url.isEmpty) {
        if (mounted) {
          ErrorSnackbar.show(context, message: 'URL is empty');
        }
        return;
      }

      final uri = Uri.parse(url);
      final canLaunch = await canLaunchUrl(uri);

      if (canLaunch) {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        if (!launched && mounted) {
          ErrorSnackbar.show(context, message: 'Failed to open browser');
        }
      } else {
        if (mounted) {
          ErrorSnackbar.show(context, message: 'Could not open link');
        }
      }
    } catch (e) {
      if (mounted) {
        ErrorSnackbar.show(
          context,
          message: 'Error opening link: ${e.toString()}',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.secondary;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;
    final subtleText =
        theme.textTheme.bodySmall?.color ?? Colors.white.withOpacity(0.7);
    final cardColor = theme.cardColor;

    // No Scaffold - this widget is used inside WalletGuardPage's Scaffold
    return BlocConsumer<PaymentBloc, PaymentState>(
      listener: (context, state) {
        // Only handle local UI updates (URL launching, snackbars)
        // Don't trigger global loading states that would unmount this widget
        if (state is OnboardingLinkGenerated) {
          _isWaitingForOnboarding = true;
          if (state.url.isNotEmpty) {
            _launchUrl(state.url);
          } else {
            _isWaitingForOnboarding = false;
            ErrorSnackbar.show(context, message: 'Onboarding URL is empty');
          }
        } else if (state is DashboardLinkGenerated) {
          if (state.url.isNotEmpty) {
            _launchUrl(state.url);
          } else {
            ErrorSnackbar.show(context, message: 'Dashboard URL is empty');
          }
        } else if (state is PaymentError) {
          _isWaitingForOnboarding = false;
          ErrorSnackbar.show(context, message: state.message);
        }
      },
      buildWhen: (previous, current) {
        // Only rebuild for states that affect the UI content
        // Don't rebuild on PaymentLoading to prevent flickering
        return current is! PaymentLoading;
      },
      builder: (context, state) {
        // Handle account loaded state
        if (state is StripeAccountLoaded) {
          // If account is not connected or needs onboarding, show connect content
          // Also show connect content if user explicitly clicked "Complete Setup"
          if (!state.account.isConnected ||
              state.account.needsOnboarding ||
              _showConnectContent) {
            return _buildConnectContent(
              cardColor,
              accent,
              textColor,
              subtleText,
            );
          }
          // Otherwise show account status (for connected accounts that don't need onboarding)
          return _buildAccountContent(
            state.account,
            cardColor,
            accent,
            textColor,
            subtleText,
          );
        }

        // For all other states (including PaymentLoading, PaymentError, Initial),
        // show the connect content
        return _buildConnectContent(cardColor, accent, textColor, subtleText);
      },
    );
  }

  Widget _buildConnectContent(
    Color cardColor,
    Color accent,
    Color textColor,
    Color subtleText,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          // Stripe logo placeholder
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF635BFF).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.account_balance,
              size: 64,
              color: Color(0xFF635BFF),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Connect Your Bank Account',
            style: TextStyle(
              color: textColor,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Connect with Stripe to receive payments securely. Your funds will be deposited directly to your bank account.',
              style: TextStyle(color: subtleText, fontSize: 15, height: 1.5),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 40),
          // Features list
          _FeatureItem(
            icon: Icons.security,
            title: 'Secure Payments',
            description: 'Bank-level security for all transactions',
            accent: accent,
            textColor: textColor,
            subtleText: subtleText,
            cardColor: cardColor,
          ),
          const SizedBox(height: 12),
          _FeatureItem(
            icon: Icons.speed,
            title: 'Fast Transfers',
            description: 'Get paid within 2-3 business days',
            accent: accent,
            textColor: textColor,
            subtleText: subtleText,
            cardColor: cardColor,
          ),
          const SizedBox(height: 12),
          _FeatureItem(
            icon: Icons.track_changes,
            title: 'Easy Tracking',
            description: 'Monitor all your earnings in one place',
            accent: accent,
            textColor: textColor,
            subtleText: subtleText,
            cardColor: cardColor,
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                context.read<PaymentBloc>().add(const StartStripeOnboarding());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF635BFF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.link, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Connect with Stripe',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'By connecting, you agree to Stripe\'s Terms of Service',
            style: TextStyle(color: subtleText, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountContent(
    StripeAccountEntity account,
    Color cardColor,
    Color accent,
    Color textColor,
    Color subtleText,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Account status card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _getStatusColor(
                          account.status,
                        ).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getStatusIcon(account.status),
                        color: _getStatusColor(account.status),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Account Status',
                            style: TextStyle(color: subtleText, fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getStatusText(account.status),
                            style: TextStyle(
                              color: textColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Divider(color: subtleText.withOpacity(0.2)),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _StatusIndicator(
                      label: 'Payouts',
                      isEnabled: account.payoutsEnabled,
                      textColor: textColor,
                      subtleText: subtleText,
                    ),
                    const SizedBox(width: 24),
                    _StatusIndicator(
                      label: 'Charges',
                      isEnabled: account.chargesEnabled,
                      textColor: textColor,
                      subtleText: subtleText,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Bank account card
          if (account.defaultBankAccount != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.account_balance, color: accent, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          account.defaultBankAccount!.bankName,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          account.defaultBankAccount!.maskedNumber,
                          style: TextStyle(color: subtleText, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  if (account.defaultBankAccount!.isDefault)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Default',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Actions
          if (account.needsOnboarding)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Show the connect content page instead of immediately redirecting
                  setState(() {
                    _showConnectContent = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: textColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Complete Setup',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  context.read<PaymentBloc>().add(const OpenStripeDashboard());
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: textColor,
                  side: BorderSide(color: accent),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.open_in_new, size: 18),
                    const SizedBox(width: 8),
                    const Text(
                      'Open Stripe Dashboard',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(StripeAccountStatus status) {
    switch (status) {
      case StripeAccountStatus.active:
        return Colors.green;
      case StripeAccountStatus.pending:
        return Colors.orange;
      case StripeAccountStatus.restricted:
        return Colors.red;
      case StripeAccountStatus.notConnected:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(StripeAccountStatus status) {
    switch (status) {
      case StripeAccountStatus.active:
        return Icons.check_circle;
      case StripeAccountStatus.pending:
        return Icons.hourglass_empty;
      case StripeAccountStatus.restricted:
        return Icons.warning;
      case StripeAccountStatus.notConnected:
        return Icons.link_off;
    }
  }

  String _getStatusText(StripeAccountStatus status) {
    switch (status) {
      case StripeAccountStatus.active:
        return 'Active';
      case StripeAccountStatus.pending:
        return 'Pending Verification';
      case StripeAccountStatus.restricted:
        return 'Restricted';
      case StripeAccountStatus.notConnected:
        return 'Not Connected';
    }
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color accent;
  final Color textColor;
  final Color subtleText;
  final Color cardColor;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.accent,
    required this.textColor,
    required this.subtleText,
    required this.cardColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accent, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(color: subtleText, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  final String label;
  final bool isEnabled;
  final Color textColor;
  final Color subtleText;

  const _StatusIndicator({
    required this.label,
    required this.isEnabled,
    required this.textColor,
    required this.subtleText,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          isEnabled ? Icons.check_circle : Icons.cancel,
          color: isEnabled ? Colors.green : Colors.red,
          size: 18,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
