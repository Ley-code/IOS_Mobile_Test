import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mobile_app/core/widgets/error_widget.dart';
import 'package:mobile_app/features/offers/domain/entities/received_offer_entity.dart';
import 'package:mobile_app/features/offers/presentation/bloc/offers_bloc.dart';
import 'package:mobile_app/features/offers/presentation/bloc/offers_event.dart';
import 'package:mobile_app/features/offers/presentation/bloc/offers_state.dart';
import 'package:mobile_app/features/offers/presentation/pages/offer_detail_page.dart';

class OffersListPage extends StatefulWidget {
  const OffersListPage({super.key});

  @override
  State<OffersListPage> createState() => _OffersListPageState();
}

class _OffersListPageState extends State<OffersListPage> {
  @override
  void initState() {
    super.initState();
    context.read<OffersBloc>().add(const LoadOffers());
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
          'Offers',
          style: TextStyle(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: BlocConsumer<OffersBloc, OffersState>(
        listener: (context, state) {
          if (state is OffersError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is OffersLoading) {
            return Center(child: CircularProgressIndicator(color: accent));
          }

          if (state is OffersError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () {
                context.read<OffersBloc>().add(const LoadOffers());
              },
            );
          }

          if (state is OffersLoaded) {
            if (state.offers.isEmpty) {
              return AppErrorWidget.empty(
                message: 'No Offers Yet',
                details:
                    'You don\'t have any offers at the moment. Check back later!',
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<OffersBloc>().add(const RefreshOffers());
                await Future.delayed(const Duration(milliseconds: 500));
              },
              color: accent,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.offers.length,
                itemBuilder: (context, index) {
                  final offer = state.offers[index];
                  return _buildOfferCard(
                    offer,
                    cardColor,
                    accent,
                    textColor,
                    subtleText,
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildOfferCard(
    ReceivedOfferEntity offer,
    Color cardColor,
    Color accent,
    Color textColor,
    Color subtleText,
  ) {
    final payoutRates = offer.payoutRates;
    final rateEntries = payoutRates.entries.toList();
    final firstRate = rateEntries.isNotEmpty ? rateEntries.first : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withOpacity(0.2), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BlocProvider.value(
                  value: context.read<OffersBloc>(),
                  child: OfferDetailPage(offerId: offer.offerId),
                ),
              ),
            ).then((_) {
              // Refresh offers list when returning from detail page
              // in case an offer was accepted
              context.read<OffersBloc>().add(const RefreshOffers());
            });
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.local_offer, color: accent, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getOfferTitle(offer),
                            style: TextStyle(
                              color: textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat(
                              'MMM d, y • h:mm a',
                            ).format(offer.createdAt),
                            style: TextStyle(color: subtleText, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: subtleText, size: 20),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(color: subtleText.withOpacity(0.2)),
                const SizedBox(height: 12),
                Text(
                  offer.offerMessage,
                  style: TextStyle(color: textColor, fontSize: 14, height: 1.5),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (firstRate != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.attach_money, color: accent, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          '${firstRate.key.replaceAll('_', ' ')}: \$${firstRate.value}',
                          style: TextStyle(
                            color: accent,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getOfferTitle(ReceivedOfferEntity offer) {
    // Use the first payout rate to create a meaningful title
    final payoutRates = offer.payoutRates;
    if (payoutRates.isNotEmpty) {
      final firstRate = payoutRates.entries.first;
      final rateType = firstRate.key.replaceAll('_', ' ');
      final rateValue = firstRate.value;
      return 'Offer: \$$rateValue per $rateType';
    }

    // Fallback: truncate offer message if no payout rates
    if (offer.offerMessage.isNotEmpty) {
      final truncated = offer.offerMessage.length > 30
          ? '${offer.offerMessage.substring(0, 30)}...'
          : offer.offerMessage;
      return truncated;
    }

    return 'New Offer';
  }
}
