import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/core/widgets/shimmer_loading.dart';
import 'package:mobile_app/core/widgets/error_widget.dart';
import 'package:mobile_app/features/wallet/domain/entities/wallet_entity.dart';
import 'package:mobile_app/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:mobile_app/features/wallet/presentation/bloc/wallet_event.dart';
import 'package:mobile_app/features/wallet/presentation/bloc/wallet_state.dart';
import 'package:mobile_app/features/wallet/presentation/pages/deposit_funds_page.dart';
import 'package:mobile_app/features/wallet/presentation/pages/withdraw_funds_page.dart';
import 'package:mobile_app/features/wallet/presentation/pages/transaction_detail_page.dart';
import 'package:intl/intl.dart';

/// WalletPage is responsible for displaying wallet balance and transactions.
/// It only handles WalletBloc state - PaymentBloc concerns are handled by WalletGuardPage.
class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  @override
  void initState() {
    super.initState();
    // Load wallet data on init since we know Stripe is connected at this point
    context.read<WalletBloc>().add(const LoadWalletBalance());
    context.read<WalletBloc>().add(const LoadTransactions(limit: 10));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;
    final accent = theme.colorScheme.secondary;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;
    final cardColor = theme.cardColor;
    final subtleText =
        theme.textTheme.bodySmall?.color ?? Colors.white.withOpacity(0.7);

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
          'Your Funds',
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: BlocBuilder<WalletBloc, WalletState>(
        builder: (context, state) {
          if (state is WalletLoading || state is WalletInitial) {
            return _buildLoadingState(cardColor);
          }

          if (state is WalletError) {
            return AppErrorWidget(
              message: 'Failed to load wallet',
              details: state.message,
              onRetry: () {
                context.read<WalletBloc>().add(const LoadWalletBalance());
                context.read<WalletBloc>().add(
                  const LoadTransactions(limit: 10),
                );
              },
            );
          }

          if (state is WalletLoaded) {
            return _buildWalletContent(
              state.wallet,
              state.transactions,
              cardColor,
              accent,
              textColor,
              subtleText,
              primary,
            );
          }

          return _buildLoadingState(cardColor);
        },
      ),
    );
  }

  Widget _buildLoadingState(Color cardColor) {
    return SingleChildScrollView(
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

  Widget _buildWalletContent(
    WalletEntity wallet,
    List<TransactionEntity> transactions,
    Color cardColor,
    Color accent,
    Color textColor,
    Color subtleText,
    Color primary,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<WalletBloc>().add(const RefreshWallet());
      },
      color: accent,
      backgroundColor: cardColor,
      child: SingleChildScrollView(
        // Ensure the scroll view can always scroll, even if content is small,
        // so that the RefreshIndicator can be dragged.
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance cards
            Row(
              children: [
                Expanded(
                  child: _BalanceCard(
                    title: 'Available Balance',
                    amount: wallet.availableBalance,
                    color: Colors.green,
                    cardColor: cardColor,
                    textColor: textColor,
                    subtleText: subtleText,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _BalanceCard(
                    title: 'Funds in Escrow',
                    amount: wallet.fundsInEscrow,
                    color: Colors.orange,
                    cardColor: cardColor,
                    textColor: textColor,
                    subtleText: subtleText,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Quick Actions
            Text(
              'Quick Actions',
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: Icons.add_circle_outline,
                    label: 'Deposit Funds',
                    color: accent,
                    cardColor: cardColor,
                    textColor: textColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BlocProvider.value(
                            value: context.read<WalletBloc>(),
                            child: const DepositFundsPage(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.account_balance_wallet,
                    label: 'Withdraw Funds',
                    color: Colors.blue,
                    cardColor: cardColor,
                    textColor: textColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BlocProvider.value(
                            value: context.read<WalletBloc>(),
                            child: WithdrawFundsPage(
                              availableBalance: wallet.availableBalance,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Recent Transactions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Transactions',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // TODO: View all transactions
                  },
                  child: Text('View All', style: TextStyle(color: accent)),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (transactions.isEmpty)
              Container(
                width: double
                    .infinity, // Added to ensure empty state card fills width
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(Icons.receipt_long, size: 48, color: subtleText),
                    const SizedBox(height: 16),
                    Text(
                      'No transactions yet',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your transaction history will appear here',
                      style: TextStyle(color: subtleText, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              ...transactions.map(
                (transaction) => _TransactionCard(
                  transaction: transaction,
                  cardColor: cardColor,
                  accent: accent,
                  textColor: textColor,
                  subtleText: subtleText,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            TransactionDetailPage(transaction: transaction),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;
  final Color cardColor;
  final Color textColor;
  final Color subtleText;

  const _BalanceCard({
    required this.title,
    required this.amount,
    required this.color,
    required this.cardColor,
    required this.textColor,
    required this.subtleText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: subtleText,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color cardColor;
  final Color textColor;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.cardColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final TransactionEntity transaction;
  final Color cardColor;
  final Color accent;
  final Color textColor;
  final Color subtleText;
  final VoidCallback onTap;

  const _TransactionCard({
    required this.transaction,
    required this.cardColor,
    required this.accent,
    required this.textColor,
    required this.subtleText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = transaction.isPositive;
    final amountColor = isPositive ? Colors.green : Colors.red;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: amountColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getTransactionIcon(transaction.type),
                color: amountColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: amountColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          transaction.type.displayName,
                          style: TextStyle(
                            color: amountColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('MMM d').format(transaction.date),
                        style: TextStyle(color: subtleText, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Text(
              transaction.formattedAmount,
              style: TextStyle(
                color: amountColor,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTransactionIcon(TransactionType type) {
    switch (type) {
      case TransactionType.deposit:
        return Icons.add_circle;
      case TransactionType.withdrawal:
        return Icons.remove_circle;
      case TransactionType.escrowRelease:
        return Icons.lock_open;
      case TransactionType.payout:
        return Icons.account_balance_wallet;
      case TransactionType.fee:
        return Icons.receipt;
      case TransactionType.payment:
        return Icons.payment;
    }
  }
}
