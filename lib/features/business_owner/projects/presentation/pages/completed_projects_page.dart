import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/features/content_creator/projects/domain/entities/contract_entity.dart';
import 'package:mobile_app/features/content_creator/projects/presentation/bloc/contract_bloc.dart';
import 'package:mobile_app/features/content_creator/projects/presentation/bloc/contract_event.dart';
import 'package:mobile_app/features/content_creator/projects/presentation/bloc/contract_state.dart';

class BusinessOwnerCompletedProjectsPage extends StatefulWidget {
  const BusinessOwnerCompletedProjectsPage({super.key});

  @override
  State<BusinessOwnerCompletedProjectsPage> createState() => _BusinessOwnerCompletedProjectsPageState();
}

class _BusinessOwnerCompletedProjectsPageState extends State<BusinessOwnerCompletedProjectsPage> {
  @override
  void initState() {
    super.initState();
    // Load all contracts, we'll filter completed ones
    context.read<ContractBloc>().add(const LoadMyContracts(activeOnly: false));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;
    final cardColor = theme.cardColor;
    final accent = theme.colorScheme.secondary;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;
    final subtleText = theme.textTheme.bodySmall?.color ?? Colors.white.withOpacity(0.7);

    return Scaffold(
      backgroundColor: primary,
      appBar: AppBar(
        title: Text('Completed Projects', style: TextStyle(color: textColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: BlocConsumer<ContractBloc, ContractState>(
        listener: (context, state) {
          if (state is ContractError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ContractLoading) {
            return Center(
              child: CircularProgressIndicator(color: accent),
            );
          }

          if (state is ContractError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: accent, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: TextStyle(color: textColor),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ContractBloc>().add(const LoadMyContracts(activeOnly: false));
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          List<ContractEntity> contracts = [];
          if (state is ContractsLoaded) {
            // Filter only completed contracts
            contracts = state.contracts.where((c) => c.status == 'completed').toList();
            // Sort by completion date (most recent first)
            contracts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          }

          return contracts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline, color: subtleText, size: 64),
                      const SizedBox(height: 16),
                      Text(
                        'No completed projects',
                        style: TextStyle(color: subtleText, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Completed projects will appear here',
                        style: TextStyle(color: subtleText, fontSize: 12),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    context.read<ContractBloc>().add(const RefreshContracts(activeOnly: false));
                  },
                  color: accent,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    itemCount: contracts.length,
                    itemBuilder: (context, index) {
                      final contract = contracts[index];
                      return _projectCard(
                        contract: contract,
                        cardColor: cardColor,
                        accent: accent,
                        textColor: textColor,
                        subtleText: subtleText,
                      );
                    },
                  ),
                );
        },
      ),
    );
  }

  Widget _projectCard({
    required ContractEntity contract,
    required Color cardColor,
    required Color accent,
    required Color textColor,
    required Color subtleText,
  }) {
    // Calculate total budget
    double totalBudget = 0.0;
    contract.payoutRates.forEach((key, value) {
      totalBudget += value;
    });

    final budgetText = totalBudget > 0 
        ? '\$${totalBudget.toStringAsFixed(2)}'
        : 'N/A';

    final completionDate = _formatDate(contract.createdAt);

    // TODO: Get rating from contract or user profile
    final rating = 5.0;

    return GestureDetector(
      onTap: () {
        // TODO: Navigate to completed project details
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    contract.contractTerms.isNotEmpty 
                        ? (contract.contractTerms.length > 50 
                            ? '${contract.contractTerms.substring(0, 50)}...' 
                            : contract.contractTerms)
                        : 'Untitled Project',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  budgetText,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Freelancer: ${contract.freelancerName ?? 'Unknown'}',
                  style: TextStyle(
                    color: subtleText,
                    fontSize: 12,
                  ),
                ),
                Text(
                  completionDate,
                  style: TextStyle(
                    color: subtleText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'COMPLETED',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  rating.toStringAsFixed(1),
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 4),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      Icons.star,
                      color: index < rating.floor() ? Colors.amber : Colors.grey.withOpacity(0.3),
                      size: 14,
                    );
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else if (difference < 30) {
      final weeks = (difference / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}









