import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/features/job_creation/data/models/job_form_data.dart';
import 'package:mobile_app/features/job_creation/data/models/create_job_model.dart';
import 'package:mobile_app/features/job_creation/presentation/bloc/job_creation_bloc.dart';
import 'package:mobile_app/features/business_owner/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:mobile_app/features/search/presentation/bloc/search_bloc.dart';

class CreateProjectPage2 extends StatefulWidget {
  final JobFormData? jobFormData;

  const CreateProjectPage2({super.key, this.jobFormData});

  @override
  State<CreateProjectPage2> createState() => _CreateProjectPage2State();
}

class _CreateProjectPage2State extends State<CreateProjectPage2> {
  final _minBudgetController = TextEditingController();
  final _maxBudgetController = TextEditingController();
  final _keyDeliverableController = TextEditingController();
  final _perProjectController = TextEditingController();

  bool _budgetNegotiable = true;
  final int _duration = 14;
  final String _durationUnit = 'Days';

  final Map<String, bool> _rewardActions = {
    'Per Like': false,
    'Per Share': true,
    'Per Comment': false,
    'Per Post': false,
    'Per Project': false,
  };

  final Map<String, TextEditingController> _rewardControllers = {
    'Per Like': TextEditingController(text: '5.00'),
    'Per Share': TextEditingController(text: '5.00'),
    'Per Comment': TextEditingController(text: '5.00'),
    'Per Post': TextEditingController(text: '5.00'),
    'Per Project': TextEditingController(text: '5.00'),
  };

  @override
  void dispose() {
    _minBudgetController.dispose();
    _maxBudgetController.dispose();
    _keyDeliverableController.dispose();
    _perProjectController.dispose();
    for (var controller in _rewardControllers.values) {
      controller.dispose();
    }
    super.dispose();
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

    return BlocListener<JobCreationBloc, JobCreationState>(
      listener: (context, state) {
        if (state is JobCreationSuccess) {
          // Refresh dashboard and search
          context.read<DashboardBloc>().add(const RefreshDashboardData());
          context.read<SearchBloc>().add(const ClearSearchEvent());

          // Navigate back to dashboard
          Navigator.of(context).pop(); // Pop page 2
          Navigator.of(context).pop(); // Pop page 1, back to dashboard

          // Show success message
          Future.delayed(const Duration(milliseconds: 300), () {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: accent,
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.only(top: 100, left: 16, right: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          });
        } else if (state is JobCreationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      },
      child: BlocBuilder<JobCreationBloc, JobCreationState>(
        builder: (context, state) {
          final isLoading = state is JobCreationLoading;

          return Scaffold(
            backgroundColor: primary,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: textColor),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.elasticOut,
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: value,
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: accent.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: accent.withOpacity(0.3),
                                        blurRadius: 20,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.business_center,
                                    color: accent,
                                    size: 40,
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Create New Project',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Fill in the following details for the project.',
                            style: TextStyle(color: subtleText, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Logistics & Budget',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildBudgetFields(cardColor, textColor, subtleText),
                    const SizedBox(height: 16),
                    _buildBudgetNegotiable(cardColor, accent, textColor),
                    const SizedBox(height: 32),
                    Text(
                      'Reward Actions',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Select the actions you want to reward and set a rate for each (optional).',
                      style: TextStyle(color: subtleText, fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    ..._buildRewardActions(
                      cardColor,
                      accent,
                      textColor,
                      subtleText,
                    ),
                    const SizedBox(height: 32),
                    _buildDuration(cardColor, accent, textColor, subtleText),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _postProject,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 8,
                          shadowColor: accent.withOpacity(0.5),
                        ),
                        child: isLoading
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
                            : const Text(
                                'Post Project',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBudgetFields(
    Color cardColor,
    Color textColor,
    Color subtleText,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Budget(\$)',
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: _minBudgetController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: textColor, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: '\$Min',
                    hintStyle: TextStyle(color: subtleText, fontSize: 14),
                    border: InputBorder.none,
                    isCollapsed: true,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text('-', style: TextStyle(color: textColor, fontSize: 18)),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: _maxBudgetController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: textColor, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: '\$Max',
                    hintStyle: TextStyle(color: subtleText, fontSize: 14),
                    border: InputBorder.none,
                    isCollapsed: true,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBudgetNegotiable(
    Color cardColor,
    Color accent,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.chat_bubble_outline, color: accent, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Budget is Negotiable',
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Switch(
            value: _budgetNegotiable,
            onChanged: (value) => setState(() => _budgetNegotiable = value),
            activeThumbColor: accent,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildRewardActions(
    Color cardColor,
    Color accent,
    Color textColor,
    Color subtleText,
  ) {
    return _rewardActions.entries.map((entry) {
      final action = entry.key;
      final isSelected = entry.value;
      final controller = _rewardControllers[action]!;

      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: Duration(
          milliseconds:
              300 + (_rewardActions.keys.toList().indexOf(action) * 100),
        ),
        curve: Curves.easeOut,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(10),
                  border: isSelected
                      ? Border.all(color: accent.withOpacity(0.5), width: 1)
                      : null,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _rewardActions[action] = !isSelected;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: isSelected ? accent : Colors.transparent,
                          border: Border.all(
                            color: isSelected ? accent : subtleText,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      action,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: 100,
                      child: TextField(
                        controller: controller,
                        keyboardType: TextInputType.number,
                        enabled: isSelected,
                        style: TextStyle(
                          color: isSelected ? textColor : subtleText,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          prefixText: '\$ ',
                          prefixStyle: TextStyle(
                            color: isSelected ? textColor : subtleText,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          isCollapsed: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }).toList();
  }

  Widget _buildDuration(
    Color cardColor,
    Color accent,
    Color textColor,
    Color subtleText,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Duration',
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$_duration',
                      style: TextStyle(color: textColor, fontSize: 14),
                    ),
                    Icon(Icons.arrow_drop_down, color: subtleText),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _durationUnit,
                      style: TextStyle(color: textColor, fontSize: 14),
                    ),
                    Icon(Icons.arrow_drop_down, color: subtleText),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
  void _postProject() {
    // Validate required fields
    if (widget.jobFormData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete the previous step'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_minBudgetController.text.trim().isEmpty ||
        _maxBudgetController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both minimum and maximum budget'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final minBudget = double.tryParse(_minBudgetController.text.trim());
    final maxBudget = double.tryParse(_maxBudgetController.text.trim());

    if (minBudget == null || maxBudget == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid budget amounts'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (minBudget > maxBudget) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Minimum budget cannot be greater than maximum budget'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Build payout types and rates from selected reward actions
    final payoutTypes = <String>[];
    final payoutRates = <String, double>{};

    _rewardActions.forEach((action, isSelected) {
      if (isSelected) {
        final rateText = _rewardControllers[action]!.text.trim();
        final rate = double.tryParse(rateText) ?? 0.0;
        if (rate > 0) {
          // Map UI action names to backend payout types
          // Backend expects lowercase with underscores
          String payoutType = action.toLowerCase().replaceAll(' ', '_');
          payoutTypes.add(payoutType);
          payoutRates[payoutType] = rate;
        }
      }
    });

    // Backend requires at least one payout type, so add default if none selected
    if (payoutTypes.isEmpty) {
      payoutTypes.add('per_project');
      payoutRates['per_project'] = maxBudget;
    }

    // Create job model
    final jobModel = CreateJobModel(
      jobTitle: widget.jobFormData!.projectTitle,
      jobDescription: widget.jobFormData!.description,
      minimumBudget: minBudget,
      maximumBudget: maxBudget,
      payoutTypes: payoutTypes,
      payoutRates: payoutRates,
      jobStatus: 'open',
      categoryId: widget.jobFormData!.selectedCategoryId,
      // Note: Skills and platforms need to be UUIDs from backend
      // For now, sending null since UI selection returns names, not UUIDs
      // These will be properly mapped when skill/platform selection is complete
      skills: null,
      platforms: null,
      // Note: expectedDurationId and mainSkillId would need to be mapped from UI selections
      // For now, leaving them null as they're optional
    );

    // Trigger job creation
    context.read<JobCreationBloc>().add(CreateJobEvent(jobModel: jobModel));
  }
}
