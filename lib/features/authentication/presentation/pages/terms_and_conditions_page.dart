import 'package:flutter/material.dart';
import 'package:mobile_app/features/authentication/domain/entities/business_sign_up_entity.dart';
import 'package:mobile_app/features/authentication/domain/entities/freelancer_sign_up_entity.dart';
import 'package:mobile_app/features/authentication/domain/entities/user_entity.dart';
import 'package:mobile_app/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TermsAndConditionsPage extends StatefulWidget {
  final BusinessSignupEntity? businessSignupEntity;
  final FreelancerSignupEntity? freelancerSignupEntity;
  final UserRole? selectedRole;

  const TermsAndConditionsPage({
    super.key,
    this.businessSignupEntity,
    this.freelancerSignupEntity,
    this.selectedRole,
  });

  @override
  State<TermsAndConditionsPage> createState() => _TermsAndConditionsPageState();
}

class _TermsAndConditionsPageState extends State<TermsAndConditionsPage> {
  bool _isSigningUp = false;
  final Map<String, String> _sections = {
    'Terms of Service':
        'These Terms of Service govern your access to and use of the platform, including all features, content and services. By creating an account you agree to comply with these terms. The platform reserves the right to suspend or terminate accounts that violate these terms.\n\nUsers must provide accurate information and maintain the security of their credentials. Certain services are subject to additional terms, which will be provided where applicable. Continued use of the service constitutes acceptance of these terms.',

    'Privacy Policy':
        'We collect and process personal data in order to provide the service, to improve and personalise the user experience, and to communicate with users about relevant updates. Personal data may include contact details, usage information and content provided by the user.\n\nWe implement administrative, technical, and physical safeguards designed to protect your information in accordance with applicable laws. We may share data with service providers and where required by law. For more details about data retention and your rights, please contact support.',

    'Community Guidelines':
        'Our community thrives when members are respectful and constructive. Do not post content that is abusive, illegal, hateful, or infringes on others’ rights. Users should avoid harassment, doxxing, and sharing private information.\n\nContent that promotes violence, illegal activity, or discrimination is strictly prohibited. Repeated violations may result in content removal, account suspension, or banning from the platform.',

    'Payment and Refund Policy':
        'Payments are processed through our payment partners and are subject to the payment provider terms. Fees for services and any platform commissions are described at the point of purchase.\n\nRefunds are evaluated on a case-by-case basis in accordance with the purchase terms and applicable law. To request a refund, contact support with your purchase details and reason for the request.',

    'Intellectual Property Policy':
        'All content, trademarks and other intellectual property visible on the platform are the property of their respective owners. Users are granted a limited licence to use the platform for creating and sharing content.\n\nYou must not upload content that you do not own or have license to use. If you believe your intellectual property has been infringed, submit a takedown request including ownership information and a description of the infringing material.',

    'Dispute Resolution':
        'If a dispute arises between users or between a user and the platform, first attempt to resolve it through our support channels. If the dispute cannot be resolved, it may be referred to mediation or arbitration according to the jurisdiction specified in these terms.\n\nLegal claims must be brought within the period specified in the applicable laws; otherwise, they may be barred. This section does not limit your rights under mandatory consumer protection laws.',
  };

  bool _agreed = false;
  final ScrollController _scrollController = ScrollController();
  final Map<String, bool> _expanded = {};
  final Map<String, GlobalKey> _itemKeys = {};

  @override
  void initState() {
    super.initState();
    // initialize expanded map and keys
    for (final k in _sections.keys) {
      _expanded[k] = false;
      _itemKeys[k] = GlobalKey();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = theme.colorScheme.primary;
    final accent = theme.colorScheme.secondary;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;
    final subtleText =
        theme.textTheme.bodySmall?.color ?? Colors.white.withOpacity(0.7);
    final cardColor = theme.cardColor;

    return Scaffold(
      backgroundColor: bg,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          // #region agent log
          try {
            print(
              '[DEBUG] Terms page listener - state type: ${state.runtimeType}',
            );
          } catch (e) {}
          // #endregion

          if (state is AuthErrorState) {
            setState(() => _isSigningUp = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
              ),
            );
          } else if (state is AuthSignedUpState) {
            // #region agent log
            try {
              print(
                '[DEBUG] Terms page - AuthSignedUpState received: userId=${state.userId}, role=${state.userRole}',
              );
            } catch (e) {}
            // #endregion

            setState(() => _isSigningUp = false);

            // Navigate immediately - don't wait for snackbar
            if (mounted && context.mounted) {
              try {
                // #region agent log
                try {
                  print(
                    '[DEBUG] Terms page - Attempting navigation, role=${state.userRole}',
                  );
                } catch (e) {}
                // #endregion

                if (state.userRole == 'freelancer') {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/influencer_dashboard_page',
                    (route) => false,
                    arguments: widget.selectedRole ?? UserRole.contentCreator,
                  );
                  // #region agent log
                  try {
                    print(
                      '[DEBUG] Terms page - Navigation to influencer dashboard called',
                    );
                  } catch (e) {}
                  // #endregion
                } else {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/business_owner_dashboard_page',
                    (route) => false,
                  );
                  // #region agent log
                  try {
                    print(
                      '[DEBUG] Terms page - Navigation to business owner dashboard called',
                    );
                  } catch (e) {}
                  // #endregion
                }
              } catch (e) {
                // #region agent log
                try {
                  print('[DEBUG] Terms page - Navigation error: $e');
                } catch (e2) {}
                // #endregion

                // Show error snackbar if navigation fails
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Navigation error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          }
        },
        builder: (context, state) {
          if (state is AuthLoadingState) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Pinned header: back + progress
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 8.0,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(Icons.arrow_back, color: textColor),
                          onPressed: () => Navigator.of(context).maybePop(),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: 1.0,
                              minHeight: 6,
                              backgroundColor: cardColor,
                              valueColor: AlwaysStoppedAnimation<Color>(accent),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text('4/4', style: TextStyle(color: subtleText)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Avatar, title, description
                  Center(
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: cardColor,
                              child: Icon(
                                Icons.business_center,
                                color: accent,
                                size: 32,
                              ),
                            ),
                            Positioned(
                              right: -4,
                              bottom: -4,
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: accent,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: theme.colorScheme.primary,
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  Icons.add,
                                  size: 18,
                                  color: textColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Legal & Terms',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Please review the following legal documents before creating your account. Your agreement is required to proceed.',
                          style: TextStyle(color: subtleText),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Sections list (use ExpansionTile for reliable header taps)
                  Expanded(
                    child: ListView(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      children: _sections.keys.map((title) {
                        final text = _sections[title]!;
                        return Card(
                          color: Colors.transparent,
                          elevation: 0,
                          child: ExpansionTile(
                            key: _itemKeys[title],
                            tilePadding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                            collapsedIconColor: subtleText,
                            iconColor: accent,
                            backgroundColor: Colors.transparent,
                            initiallyExpanded: _expanded[title] ?? false,
                            onExpansionChanged: (open) {
                              setState(() => _expanded[title] = open);
                              if (open) {
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  final ctx = _itemKeys[title]?.currentContext;
                                  if (ctx != null) {
                                    Scrollable.ensureVisible(
                                      ctx,
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      alignment: 0.1,
                                    );
                                  }
                                });
                              }
                            },
                            title: Text(
                              title,
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0,
                                  vertical: 8.0,
                                ),
                                child: Text(
                                  text,
                                  style: TextStyle(
                                    color: subtleText,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  // Agreement + button
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: _agreed,
                              onChanged: (v) =>
                                  setState(() => _agreed = v ?? false),
                              activeColor: accent,
                            ),
                            Expanded(
                              child: Wrap(
                                children: [
                                  Text(
                                    'I agree to the ',
                                    style: TextStyle(color: subtleText),
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      final key = 'Terms of Service';
                                      setState(
                                        () => _expanded.updateAll(
                                          (k, v) => false,
                                        ),
                                      );
                                      setState(() => _expanded[key] = true);
                                      await Future.delayed(
                                        const Duration(milliseconds: 100),
                                      );
                                      final ctx =
                                          _itemKeys[key]?.currentContext;
                                      if (ctx != null) {
                                        Scrollable.ensureVisible(
                                          ctx,
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          alignment: 0.1,
                                        );
                                      }
                                    },
                                    child: Text(
                                      'Terms of Service',
                                      style: TextStyle(color: accent),
                                    ),
                                  ),
                                  Text(
                                    ' and ',
                                    style: TextStyle(color: subtleText),
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      final key = 'Privacy Policy';
                                      setState(
                                        () => _expanded.updateAll(
                                          (k, v) => false,
                                        ),
                                      );
                                      setState(() => _expanded[key] = true);
                                      await Future.delayed(
                                        const Duration(milliseconds: 100),
                                      );
                                      final ctx =
                                          _itemKeys[key]?.currentContext;
                                      if (ctx != null) {
                                        Scrollable.ensureVisible(
                                          ctx,
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          alignment: 0.1,
                                        );
                                      }
                                    },
                                    child: Text(
                                      'Privacy Policy',
                                      style: TextStyle(color: accent),
                                    ),
                                  ),
                                  Text(
                                    '.',
                                    style: TextStyle(color: subtleText),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed:
                                _agreed &&
                                    !_isSigningUp &&
                                    (widget.businessSignupEntity != null ||
                                        widget.freelancerSignupEntity != null)
                                ? () {
                                    setState(() => _isSigningUp = true);
                                    // Trigger signup event
                                    if (widget.businessSignupEntity != null) {
                                      context.read<AuthBloc>().add(
                                        BusinessSignUpEvent(
                                          businessSignupEntity:
                                              widget.businessSignupEntity!,
                                        ),
                                      );
                                    } else if (widget.freelancerSignupEntity !=
                                        null) {
                                      context.read<AuthBloc>().add(
                                        FreelancerSignUpEvent(
                                          freelancerSignupEntity:
                                              widget.freelancerSignupEntity!,
                                        ),
                                      );
                                    }
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  _agreed &&
                                      !_isSigningUp &&
                                      (widget.businessSignupEntity != null ||
                                          widget.freelancerSignupEntity != null)
                                  ? accent
                                  : cardColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: (state is AuthLoadingState || _isSigningUp)
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        textColor,
                                      ),
                                    ),
                                  )
                                : Text(
                                    'Create Account',
                                    style: TextStyle(
                                      color: textColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
