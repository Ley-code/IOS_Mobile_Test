import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/features/authentication/domain/entities/login_entity.dart';
import 'package:mobile_app/features/authentication/domain/entities/user_entity.dart';
import 'package:mobile_app/features/authentication/presentation/bloc/auth_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = theme.primaryColor;
    final accent = theme.colorScheme.secondary;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;
    final subtleText =
        theme.textTheme.bodySmall?.color ?? Colors.white.withOpacity(0.7);
    final cardColor = theme.cardColor;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        } else if (state is AuthSignedInState) {
          // Navigate to appropriate dashboard based on user role
          // Use WidgetsBinding to ensure navigation happens after current frame
          // Add a small delay to ensure state is fully processed
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            await Future.delayed(const Duration(milliseconds: 100));
            if (mounted && context.mounted) {
              try {
                if (state.userRole == 'freelancer') {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/influencer_dashboard_page',
                    (route) => false,
                    arguments: UserRole.creative,
                  );
                } else {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/business_owner_dashboard_page',
                    (route) => false,
                  );
                }
              } catch (e) {
                // If navigation fails, try again after a short delay
                await Future.delayed(const Duration(milliseconds: 300));
                if (mounted && context.mounted) {
                  if (state.userRole == 'freelancer') {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/influencer_dashboard_page',
                      (route) => false,
                      arguments: UserRole.creative,
                    );
                  } else {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/business_owner_dashboard_page',
                      (route) => false,
                    );
                  }
                }
              }
            }
          });
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoadingState;

        return Scaffold(
          backgroundColor: bg,
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo
                      Center(
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(color: Colors.transparent),
                          child: Image.asset('assets/images/networking.png'),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Title
                      Center(
                        child: Text(
                          'Welcome Back',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                      const SizedBox(height: 26),

                      // Form
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Email', style: TextStyle(color: subtleText)),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _emailController,
                              style: TextStyle(color: textColor),
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                hintText: 'Enter your email address',
                                hintStyle: TextStyle(
                                  color: subtleText.withOpacity(0.6),
                                ),
                                filled: true,
                                fillColor: cardColor,
                                prefixIcon: Icon(
                                  Icons.email,
                                  color: subtleText,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Please enter your email';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            Text(
                              'Password',
                              style: TextStyle(color: subtleText),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscure,
                              style: TextStyle(color: textColor),
                              decoration: InputDecoration(
                                hintText: 'Enter your password',
                                hintStyle: TextStyle(
                                  color: subtleText.withOpacity(0.6),
                                ),
                                filled: true,
                                fillColor: cardColor,
                                prefixIcon: Icon(Icons.lock, color: subtleText),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscure
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: subtleText,
                                  ),
                                  onPressed: () =>
                                      setState(() => _obscure = !_obscure),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Please enter your password';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/forgot_password_page',
                                  );
                                },
                                child: Text(
                                  'Forgot Password?',
                                  style: TextStyle(color: accent),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Login button
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          onPressed: isLoading
                              ? null
                              : () {
                                  if (_formKey.currentState?.validate() ??
                                      false) {
                                    context.read<AuthBloc>().add(
                                      LogInEvent(
                                        logInEntity: LoginEntity(
                                          email: _emailController.text.trim(),
                                          password: _passwordController.text,
                                        ),
                                      ),
                                    );
                                  }
                                },
                          child: isLoading
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
                                  'Login',
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Bottom note
                      Center(
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          children: [
                            Text(
                              "Don't have an account?",
                              style: TextStyle(color: subtleText),
                            ),
                            const SizedBox(width: 4),

                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/user_selection_page',
                                );
                              },
                              child: Text(
                                'Sign Up',
                                style: TextStyle(
                                  color: accent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
