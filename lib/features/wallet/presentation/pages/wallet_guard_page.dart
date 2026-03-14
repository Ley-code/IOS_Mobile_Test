import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/core/widgets/error_widget.dart';
import 'package:mobile_app/core/widgets/shimmer_loading.dart';
import 'package:mobile_app/features/payments/domain/entities/stripe_account_entity.dart';
import 'package:mobile_app/features/payments/presentation/bloc/payment_bloc.dart';
import 'package:mobile_app/features/payments/presentation/bloc/payment_event.dart';
import 'package:mobile_app/features/payments/presentation/bloc/payment_state.dart';
import 'package:mobile_app/features/payments/presentation/pages/connect_stripe_page.dart';
import 'package:mobile_app/features/wallet/presentation/pages/wallet_page.dart';

/// WalletGuardPage is responsible for checking Stripe account status
/// and routing to either WalletPage (if connected) or ConnectStripePage (if not).
/// This separates PaymentBloc concerns from WalletBloc concerns.
class WalletGuardPage extends StatefulWidget {
  const WalletGuardPage({super.key});

  @override
  State<WalletGuardPage> createState() => _WalletGuardPageState();
}

class _WalletGuardPageState extends State<WalletGuardPage> {
  StripeAccountEntity? _lastKnownAccount;

  @override
  void initState() {
    super.initState();
    // Load Stripe account status on init
    context.read<PaymentBloc>().add(const LoadStripeAccountStatus());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;

    return BlocBuilder<PaymentBloc, PaymentState>(
      builder: (context, paymentState) {
        // Update last known account when we get account data
        if (paymentState is StripeAccountLoaded) {
          _lastKnownAccount = paymentState.account;
        }

        // Determine what to show based on state
        Widget body;
        String appBarTitle = 'Wallet';

        if (paymentState is StripeAccountLoaded) {
          // We have account data - route based on connection status
          if (paymentState.account.isConnected) {
            // Connected - show wallet page
            return const WalletPage();
          } else {
            // Not connected - show connect stripe page
            body = const ConnectStripePage();
            appBarTitle = 'Connect Stripe';
          }
        } else if (paymentState is PaymentError) {
          // Error state
          body = AppErrorWidget(
            message: 'Failed to verify account status',
            details: paymentState.message,
            onRetry: () {
              context.read<PaymentBloc>().add(const LoadStripeAccountStatus());
            },
          );
          appBarTitle = 'Wallet Error';
        } else if (_lastKnownAccount != null) {
          // We're loading but have previous account data - persist the view
          if (_lastKnownAccount!.isConnected) {
            // Was connected - show wallet page
            return const WalletPage();
          } else {
            // Was not connected - show connect stripe page
            body = const ConnectStripePage();
            appBarTitle = 'Connect Stripe';
          }
        } else {
          // Initial loading - no previous data - show shimmer
          body = SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const ShimmerCard(height: 120),
                const SizedBox(height: 16),
                const ShimmerCard(height: 80),
                const SizedBox(height: 16),
                const ShimmerCard(height: 200),
              ],
            ),
          );
        }

        // Return scaffold with body (for non-connected states or loading)
        return Scaffold(
          backgroundColor: primary,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back, color: textColor),
            ),
            title: Text(
              appBarTitle,
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          body: body,
        );
      },
    );
  }
}
