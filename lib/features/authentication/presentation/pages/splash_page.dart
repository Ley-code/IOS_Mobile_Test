import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/core/storage/token_storage.dart';
import 'package:mobile_app/injection_container.dart' as di;

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkAuthenticationAndNavigate();
  }

  Future<void> _checkAuthenticationAndNavigate() async {
    // Wait for minimum splash screen duration (2 seconds for better UX)
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    try {
      final tokenStorage = di.sl<TokenStorage>();
      final isAuthenticated = await tokenStorage.isAuthenticated();

      if (isAuthenticated) {
        // User is logged in, get their role and navigate to appropriate dashboard
        final userRole = await tokenStorage.getUserRole();
        
        if (!mounted) return;

        // Navigate based on user role
        if (userRole == 'freelancer') {
          Navigator.pushReplacementNamed(context, '/influencer_dashboard_page');
        } else {
          // Default to business owner dashboard for 'client' or any other role
          Navigator.pushReplacementNamed(context, '/business_owner_dashboard_page');
        }
      } else {
        // User is not authenticated, navigate to slider page
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/slider_page');
      }
    } catch (e) {
      // If there's any error checking authentication, navigate to slider page
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/slider_page');
    }
  }

  bool get _isiOS => !kIsWeb && Platform.isIOS;

  @override
  Widget build(BuildContext context) {
    final bool isiOS = _isiOS;
    final Color primary = Theme.of(context).primaryColor;

    // Use a Cupertino scaffold on iOS for more native look, otherwise Material Scaffold
    return isiOS
        ? CupertinoPageScaffold(
            backgroundColor: primary,
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: _buildBody(context, isiOS, primary),
            ),
          )
        : Scaffold(
            extendBodyBehindAppBar: true,
            backgroundColor: primary,
            body: _buildBody(context, isiOS, primary),
          );
  }

  Widget _buildBody(BuildContext context, bool isiOS, Color primary) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/splash_image.png',
            width: 220,
            height: 220,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 20),
          // White circular background to match your design
          Container(
            width: 75,
            height: 75,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isiOS
                  ? const CupertinoActivityIndicator(radius: 14)
                  : CircularProgressIndicator(
                      strokeWidth: 6,
                      valueColor: AlwaysStoppedAnimation<Color>(primary),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
