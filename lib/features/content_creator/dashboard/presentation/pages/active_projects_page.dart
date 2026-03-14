import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/features/content_creator/dashboard/presentation/pages/project_details_page.dart';
import 'package:mobile_app/features/content_creator/projects/domain/entities/contract_entity.dart';
import 'package:mobile_app/features/content_creator/projects/presentation/bloc/contract_bloc.dart';
import 'package:mobile_app/features/content_creator/projects/presentation/bloc/contract_event.dart';
import 'package:mobile_app/features/content_creator/projects/presentation/bloc/contract_state.dart';

class ActiveProjectsPage extends StatefulWidget {
  const ActiveProjectsPage({super.key});

  @override
  State<ActiveProjectsPage> createState() => _ActiveProjectsPageState();
}

class _ActiveProjectsPageState extends State<ActiveProjectsPage> {
  @override
  void initState() {
    super.initState();
    // Load active contracts only
    context.read<ContractBloc>().add(const LoadMyContracts(activeOnly: true));
  }

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
        title: Text('Active Projects', style: TextStyle(color: textColor)),
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
            return Center(child: CircularProgressIndicator(color: accent));
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
                      context.read<ContractBloc>().add(
                        const LoadMyContracts(activeOnly: true),
                      );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          List<ContractEntity> contracts = [];
          if (state is ContractsLoaded) {
            contracts = state.contracts;
            // Only show active contracts
            contracts = contracts
                .where((contract) => contract.status == 'active')
                .toList();
          }

          return Column(
            children: [
              Expanded(
                child: contracts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.work_outline,
                              color: subtleText,
                              size: 64,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No active projects',
                              style: TextStyle(color: subtleText, fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Projects you\'re working on will appear here',
                              style: TextStyle(color: subtleText, fontSize: 12),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          context.read<ContractBloc>().add(
                            const RefreshContracts(activeOnly: true),
                          );
                        },
                        color: accent,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
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
                      ),
              ),
            ],
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
    // All contracts shown are active
    const String statusDisplay = 'ACTIVE';
    const Color statusColor = Colors.green;

    // Calculate total budget from payout rates
    double totalBudget = 0.0;
    contract.payoutRates.forEach((key, value) {
      totalBudget += value;
    });

    // Format budget
    final budgetText = totalBudget > 0
        ? '\$${totalBudget.toStringAsFixed(2)}'
        : 'N/A';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ProjectDetailsPage(contractId: contract.contractId),
          ),
        );
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
                Icon(Icons.chat_bubble_outline, color: accent, size: 20),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Client: ${contract.clientName ?? 'Unknown'}',
              style: TextStyle(color: subtleText, fontSize: 12),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        statusDisplay,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
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
          ],
        ),
      ),
    );
  }
}
