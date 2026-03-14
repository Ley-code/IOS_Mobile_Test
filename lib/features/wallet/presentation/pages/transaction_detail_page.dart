import 'package:flutter/material.dart';
import 'package:mobile_app/features/wallet/domain/entities/wallet_entity.dart';
import 'package:intl/intl.dart';

class TransactionDetailPage extends StatelessWidget {
  final TransactionEntity transaction;

  const TransactionDetailPage({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;
    final accent = theme.colorScheme.secondary;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;
    final subtleText =
        theme.textTheme.bodySmall?.color ?? Colors.white.withOpacity(0.7);
    final cardColor = theme.cardColor;
    final isPositive = transaction.isPositive;
    final amountColor = isPositive ? Colors.green : Colors.red;

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
          'Transaction Details',
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Success icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: amountColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getTransactionIcon(transaction.type),
                color: amountColor,
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isPositive ? 'Payment Received' : 'Payment Sent',
              style: TextStyle(
                color: textColor,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${DateFormat('MMM d, yyyy').format(transaction.date)} at ${DateFormat('h:mm a').format(transaction.date)}',
              style: TextStyle(color: subtleText, fontSize: 14),
            ),
            const SizedBox(height: 32),
            // Amount
            Text(
              transaction.formattedAmount,
              style: TextStyle(
                color: amountColor,
                fontSize: 48,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 32),
            // Details card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (transaction.transactionId != null) ...[
                    _DetailRow(
                      label: 'TRANSACTION ID',
                      value: transaction.transactionId!,
                      textColor: textColor,
                      subtleText: subtleText,
                    ),
                    const SizedBox(height: 16),
                  ],
                  _DetailRow(
                    label: 'Date',
                    value: DateFormat('MMM d, yyyy').format(transaction.date),
                    textColor: textColor,
                    subtleText: subtleText,
                  ),
                  const SizedBox(height: 16),
                  _DetailRow(
                    label: 'Type',
                    value: transaction.type.displayName,
                    textColor: textColor,
                    subtleText: subtleText,
                  ),
                  if (transaction.projectName != null) ...[
                    const SizedBox(height: 16),
                    _DetailRow(
                      label: 'Project',
                      value: transaction.projectName!,
                      valueWidget: Text(
                        transaction.projectName!,
                        style: TextStyle(
                          color: accent,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      textColor: textColor,
                      subtleText: subtleText,
                    ),
                  ],
                  if (transaction.paymentMethod != null) ...[
                    const SizedBox(height: 16),
                    _DetailRow(
                      label: 'Payment Method',
                      value: transaction.paymentMethod!,
                      textColor: textColor,
                      subtleText: subtleText,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Download receipt button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  // TODO: Download PDF receipt
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: textColor,
                  side: BorderSide(color: accent),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.download, color: accent),
                    const SizedBox(width: 8),
                    const Text(
                      'Download PDF Receipt',
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

class _DetailRow extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? valueWidget;
  final Color textColor;
  final Color subtleText;

  const _DetailRow({
    required this.label,
    this.value,
    this.valueWidget,
    required this.textColor,
    required this.subtleText,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: subtleText,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child:
                valueWidget ??
                Text(
                  value ?? '',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.right,
                ),
          ),
        ),
      ],
    );
  }
}













