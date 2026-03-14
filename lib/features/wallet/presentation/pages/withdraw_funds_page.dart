import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/core/widgets/error_widget.dart';
import 'package:mobile_app/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:mobile_app/features/wallet/presentation/bloc/wallet_event.dart';
import 'package:mobile_app/features/wallet/presentation/bloc/wallet_state.dart';

class WithdrawFundsPage extends StatefulWidget {
  final double availableBalance;

  const WithdrawFundsPage({
    super.key,
    required this.availableBalance,
  });

  @override
  State<WithdrawFundsPage> createState() => _WithdrawFundsPageState();
}

class _WithdrawFundsPageState extends State<WithdrawFundsPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  double _selectedAmount = 0.0;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _setPercentage(double percentage) {
    final amount = widget.availableBalance * percentage;
    setState(() {
      _selectedAmount = amount;
      _amountController.text = amount.toStringAsFixed(2);
    });
  }

  void _withdrawFunds() {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text) ?? 0.0;
    context.read<WalletBloc>().add(RequestWithdrawal(amount));
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
        if (state is WithdrawalRequested) {
          _showSuccessDialog(context, theme, accent, cardColor, textColor,
              subtleText, state.transaction);
        } else if (state is WithdrawalError) {
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
            'Request Withdrawal',
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
                // Amount display
                Center(
                  child: Column(
                    children: [
                      Text(
                        '\$${_amountController.text.isEmpty ? "0.00" : _amountController.text}',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 56,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Available: \$${widget.availableBalance.toStringAsFixed(2)}',
                        style: TextStyle(color: subtleText, fontSize: 16),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Percentage buttons
                Row(
                  children: [
                    Expanded(
                      child: _PercentageButton(
                        label: '25%',
                        percentage: 0.25,
                        isSelected: _selectedAmount ==
                            widget.availableBalance * 0.25,
                        onTap: () => _setPercentage(0.25),
                        accent: accent,
                        textColor: textColor,
                        cardColor: cardColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _PercentageButton(
                        label: '50%',
                        percentage: 0.5,
                        isSelected:
                            _selectedAmount == widget.availableBalance * 0.5,
                        onTap: () => _setPercentage(0.5),
                        accent: accent,
                        textColor: textColor,
                        cardColor: cardColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _PercentageButton(
                        label: 'Max',
                        percentage: 1.0,
                        isSelected: _selectedAmount == widget.availableBalance,
                        onTap: () => _setPercentage(1.0),
                        accent: accent,
                        textColor: textColor,
                        cardColor: cardColor,
                      ),
                    ),
                  ],
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Enter Amount',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d{0,2}')),
                        ],
                        style: TextStyle(
                          color: textColor,
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          prefixText: '\$ ',
                          prefixStyle: TextStyle(
                            color: accent,
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                          ),
                          filled: true,
                          fillColor: primary,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          hintText: '0.00',
                          hintStyle: TextStyle(
                            color: subtleText.withOpacity(0.3),
                            fontSize: 32,
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
                          if (amount > widget.availableBalance) {
                            return 'Amount exceeds available balance';
                          }
                          if (amount < 10) {
                            return 'Minimum withdrawal is \$10';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          final amount = double.tryParse(value) ?? 0.0;
                          setState(() => _selectedAmount = amount);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Withdraw button
                BlocBuilder<WalletBloc, WalletState>(
                  builder: (context, state) {
                    final isProcessing = state is WithdrawalRequesting;
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isProcessing ? null : _withdrawFunds,
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
                                      Colors.white),
                                ),
                              )
                            : const Text(
                                'Transfer to Bank',
                                style: TextStyle(
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
    transaction,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
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
                'Withdrawal Requested!',
                style: TextStyle(
                  color: textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Your withdrawal request has been submitted. Funds will be transferred to your bank account within 2-3 business days.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: subtleText,
                  fontSize: 14,
                  height: 1.5,
                ),
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
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
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

class _PercentageButton extends StatelessWidget {
  final String label;
  final double percentage;
  final bool isSelected;
  final VoidCallback onTap;
  final Color accent;
  final Color textColor;
  final Color cardColor;

  const _PercentageButton({
    required this.label,
    required this.percentage,
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














