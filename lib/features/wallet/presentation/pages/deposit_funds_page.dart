import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:mobile_app/core/widgets/error_widget.dart';
import 'package:mobile_app/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:mobile_app/features/wallet/presentation/bloc/wallet_event.dart';
import 'package:mobile_app/features/wallet/presentation/bloc/wallet_state.dart';

class DepositFundsPage extends StatefulWidget {
  const DepositFundsPage({super.key});

  @override
  State<DepositFundsPage> createState() => _DepositFundsPageState();
}

class _DepositFundsPageState extends State<DepositFundsPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  double _selectedAmount = 0.0;
  String? _paymentIntentClientSecret;
  bool _isCardValid = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _setQuickAmount(double amount) {
    setState(() {
      _selectedAmount = amount;
      _amountController.text = amount.toStringAsFixed(2);
    });
  }

  void _depositFunds() {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text) ?? 0.0;
    context.read<WalletBloc>().add(DepositFunds(amount));
  }

  Future<void> _confirmPayment() async {
    if (_paymentIntentClientSecret == null) {
      ErrorSnackbar.show(context, message: 'Payment intent not created');
      return;
    }

    if (!_isCardValid) {
      ErrorSnackbar.show(context, message: 'Please enter valid card details');
      return;
    }

    try {
      // Confirm payment directly with the payment intent and card data from CardField
      final paymentIntent = await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: _paymentIntentClientSecret!,
        data: PaymentMethodParams.card(paymentMethodData: PaymentMethodData()),
      );

      // Check payment status
      if (paymentIntent.status.toString().toLowerCase() == 'succeeded') {
        // Payment confirmed successfully - notify bloc to refresh wallet
        await Future.delayed(
          const Duration(seconds: 2),
        ); // Allow webhook to process
        if (mounted) {
          context.read<WalletBloc>().add(const LoadWalletBalance());
          // Show success dialog
          final theme = Theme.of(context);
          final accent = theme.colorScheme.secondary;
          final cardColor = theme.cardColor;
          final textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;
          final subtleText =
              theme.textTheme.bodySmall?.color ?? Colors.white.withOpacity(0.7);
          _showSuccessDialog(
            context,
            theme,
            accent,
            cardColor,
            textColor,
            subtleText,
          );
        }
      } else {
        if (mounted) {
          SuccessSnackbar.show(
            context,
            message: 'Payment status: ${paymentIntent.status}',
          );
          Navigator.pop(context);
        }
      }
    } on StripeException catch (e) {
      ErrorSnackbar.show(
        context,
        message: e.error.message ?? 'Failed to process card',
      );
    } catch (e) {
      ErrorSnackbar.show(
        context,
        message: 'Failed to process card: ${e.toString()}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;
    final accent = theme.colorScheme.secondary;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;
    final subtleText =
        theme.textTheme.bodySmall?.color ?? Colors.white.withOpacity(0.7);
    final cardColor = theme.cardColor;

    return BlocListener<WalletBloc, WalletState>(
      listener: (context, state) {
        if (state is PaymentIntentCreated) {
          setState(() {
            _paymentIntentClientSecret = state.paymentIntentClientSecret;
          });
        } else if (state is DepositError) {
          ErrorSnackbar.show(context, message: state.message);
        }
      },
      child: Scaffold(
        backgroundColor: primary,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back, color: textColor),
          ),
          title: Text(
            'Deposit Funds',
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enter Amount',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add funds to your wallet',
                  style: TextStyle(color: subtleText, fontSize: 14),
                ),
                const SizedBox(height: 32),
                // Amount input
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}'),
                          ),
                        ],
                        style: TextStyle(
                          color: textColor,
                          fontSize: 48,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          prefixText: '\$ ',
                          prefixStyle: TextStyle(
                            color: accent,
                            fontSize: 48,
                            fontWeight: FontWeight.w700,
                          ),
                          border: InputBorder.none,
                          hintText: '0.00',
                          hintStyle: TextStyle(
                            color: subtleText.withOpacity(0.3),
                            fontSize: 48,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an amount';
                          }
                          final amount = double.tryParse(value);
                          if (amount == null || amount <= 0) {
                            return 'Please enter a valid amount';
                          }
                          if (amount < 10) {
                            return 'Minimum deposit is \$10';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Quick amount buttons
                Text(
                  'Quick Amounts',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _QuickAmountButton(
                        label: '\$50',
                        amount: 50.0,
                        isSelected: _selectedAmount == 50.0,
                        onTap: () => _setQuickAmount(50.0),
                        accent: accent,
                        textColor: textColor,
                        cardColor: cardColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _QuickAmountButton(
                        label: '\$100',
                        amount: 100.0,
                        isSelected: _selectedAmount == 100.0,
                        onTap: () => _setQuickAmount(100.0),
                        accent: accent,
                        textColor: textColor,
                        cardColor: cardColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _QuickAmountButton(
                        label: '\$500',
                        amount: 500.0,
                        isSelected: _selectedAmount == 500.0,
                        onTap: () => _setQuickAmount(500.0),
                        accent: accent,
                        textColor: textColor,
                        cardColor: cardColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Card input section (shown after payment intent is created)
                if (_paymentIntentClientSecret != null) ...[
                  Text(
                    'Card Details',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: CardFormField(
                      onCardChanged: (card) {
                        // Update card validity state
                        setState(() {
                          _isCardValid = card?.complete ?? false;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                // Deposit/Pay button
                BlocBuilder<WalletBloc, WalletState>(
                  builder: (context, state) {
                    final isProcessing = state is DepositProcessing;
                    final hasPaymentIntent = _paymentIntentClientSecret != null;
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isProcessing
                            ? null
                            : (hasPaymentIntent
                                  ? (_isCardValid ? _confirmPayment : null)
                                  : _depositFunds),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: accent.withOpacity(0.5),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: isProcessing
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                hasPaymentIntent
                                    ? 'Pay Now'
                                    : 'Continue to Payment',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog(
    BuildContext context,
    ThemeData theme,
    Color accent,
    Color cardColor,
    Color textColor,
    Color subtleText,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 48,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Deposit Successful!',
                style: TextStyle(
                  color: textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Your funds have been added to your wallet.',
                textAlign: TextAlign.center,
                style: TextStyle(color: subtleText, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Go back to wallet
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAmountButton extends StatelessWidget {
  final String label;
  final double amount;
  final bool isSelected;
  final VoidCallback onTap;
  final Color accent;
  final Color textColor;
  final Color cardColor;

  const _QuickAmountButton({
    required this.label,
    required this.amount,
    required this.isSelected,
    required this.onTap,
    required this.accent,
    required this.textColor,
    required this.cardColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? accent : cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? accent : accent.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : textColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
