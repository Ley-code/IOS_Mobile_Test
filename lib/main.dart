import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/features/authentication/domain/entities/business_sign_up_entity.dart';
import 'package:mobile_app/features/authentication/domain/entities/freelancer_sign_up_entity.dart';
import 'package:mobile_app/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:mobile_app/features/authentication/presentation/pages/Business_owner_onboarding_page_2.dart';
import 'package:mobile_app/features/authentication/presentation/pages/Freelancer_onboarding_page_1.dart';
import 'package:mobile_app/features/authentication/presentation/pages/business_owner_onboarding_page_1.dart';
import 'package:mobile_app/features/authentication/presentation/pages/Freelancer_onboarding_page_2.dart';
import 'package:mobile_app/features/authentication/presentation/pages/content_creator_page_socialmedia.dart';
import 'package:mobile_app/features/authentication/presentation/pages/forgot_password_page.dart';
import 'package:mobile_app/features/authentication/presentation/pages/login_page.dart';
import 'package:mobile_app/features/authentication/presentation/pages/slider_page.dart';
import 'package:mobile_app/features/authentication/presentation/pages/splash_page.dart';
import 'package:mobile_app/features/authentication/presentation/pages/user_selection_page.dart'
    hide UserRole;
import 'package:mobile_app/features/authentication/presentation/pages/terms_and_conditions_page.dart';
import 'package:mobile_app/features/authentication/domain/entities/user_entity.dart'
    show UserRole;
import 'package:mobile_app/features/business_owner/dashboard/presentation/pages/business_owner_main_navigation.dart';
import 'package:mobile_app/features/business_owner/dashboard/presentation/pages/create_project_page_1.dart';
import 'package:mobile_app/features/business_owner/dashboard/presentation/pages/create_project_page_2.dart';
import 'package:mobile_app/features/business_owner/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:mobile_app/features/job_creation/data/models/job_form_data.dart';
import 'package:mobile_app/features/offers/presentation/bloc/offers_bloc.dart';
import 'package:mobile_app/features/proposals/presentation/bloc/proposals_bloc.dart';
import 'package:mobile_app/features/search/presentation/bloc/search_bloc.dart';
import 'package:mobile_app/features/job_creation/presentation/bloc/job_creation_bloc.dart';
import 'package:mobile_app/features/content_creator/dashboard/presentation/pages/influencer_main_navigation.dart';
import 'package:mobile_app/features/content_creator/dashboard/presentation/bloc/influencer_dashboard_bloc.dart';
import 'package:mobile_app/features/content_creator/projects/presentation/bloc/contract_bloc.dart';
import 'package:mobile_app/features/payments/presentation/bloc/payment_bloc.dart';
import 'package:mobile_app/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/core/theme/theme_bloc.dart';
import 'package:mobile_app/core/services/deep_link_service.dart';
import 'package:mobile_app/features/wallet/presentation/pages/deposit_funds_page.dart';
import 'package:mobile_app/features/wallet/presentation/pages/wallet_guard_page.dart';
import 'package:mobile_app/injection_container.dart';
import 'package:mobile_app/injection_container.dart' as di;
import 'package:mobile_app/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:mobile_app/features/chat/presentation/bloc/participant_bloc.dart';
import 'package:mobile_app/features/network/presentation/bloc/network_bloc.dart';
import 'package:mobile_app/features/freelancer_profile/presentation/bloc/freelancer_profile_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:mobile_app/core/config/api_config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Make status bar transparent and icons light so the app can draw behind it.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );

  // Initialize Stripe with publishable key
  Stripe.publishableKey = ApiConfig.stripePublishableKey;
  await Stripe.instance.applySettings();

  await di.init();

  // Initialize deep link service to listen for Instagram OAuth callbacks
  await DeepLinkService().init();
  

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<ThemeBloc>(create: (context) => sl<ThemeBloc>()),
        BlocProvider<AuthBloc>(create: (context) => sl<AuthBloc>()),
        BlocProvider<DashboardBloc>(create: (context) => sl<DashboardBloc>()),
        BlocProvider<SearchBloc>(create: (context) => sl<SearchBloc>()),
        BlocProvider<JobCreationBloc>(
          create: (context) => sl<JobCreationBloc>(),
        ),
        BlocProvider<InfluencerDashboardBloc>(
          create: (context) => sl<InfluencerDashboardBloc>(),
        ),
        BlocProvider<ContractBloc>(create: (context) => sl<ContractBloc>()),
        BlocProvider<ProposalsBloc>(create: (context) => sl<ProposalsBloc>()),
        BlocProvider<OffersBloc>(create: (context) => sl<OffersBloc>()),
        BlocProvider<PaymentBloc>(create: (context) => sl<PaymentBloc>()),
        BlocProvider<WalletBloc>(create: (context) => sl<WalletBloc>()),
        BlocProvider<ChatBloc>(create: (context) => sl<ChatBloc>()),
        BlocProvider<ParticipantBloc>(create: (context) => sl<ParticipantBloc>()),
        BlocProvider<NetworkBloc>(create: (context) => sl<NetworkBloc>()),
        BlocProvider<FreelancerProfileBloc>(
          create: (context) => sl<FreelancerProfileBloc>(),
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          final mode = (themeState as ThemeLoaded).mode;

          return MaterialApp(
            theme: AppTheme.getThemeData(AppThemeMode.light),
            darkTheme: AppTheme.getThemeData(AppThemeMode.dark),
            themeMode: mode == AppThemeMode.dark
                ? ThemeMode.dark
                : ThemeMode.light,
            initialRoute: '/splash_page',
            onGenerateRoute: (settings) {
              if (settings.name == '/splash_page') {
                return createRoute(const SplashPage());
              } else if (settings.name == '/slider_page') {
                return createRoute(const SliderPage());
              } else if (settings.name == '/user_selection_page') {
                return createRoute(const UserSelectionPage());
              } else if (settings.name == '/login_page') {
                return createRoute(const LoginPage());
              } else if (settings.name == '/forgot_password_page') {
                return createRoute(const ForgotPasswordPage());
              } else if (settings.name == '/freelancer_onboarding_page_1') {
                // UserRole from user_selection_page.dart
                final args = settings.arguments as dynamic;
                return createRoute(
                  FreelancerOnboardingPage1(selectedRole: args),
                );
              } else if (settings.name == '/freelancer_onboarding_page_2') {
                final args = settings.arguments as Map<String, dynamic>?;
                return createRoute(
                  FreelancerOnboardingPage2(partialData: args),
                );
              } else if (settings.name == '/content_creator_page_socialmedia') {
                final args = settings.arguments as FreelancerSignupEntity?;
                return createRoute(ContentCreatorSocialMediaPage(entity: args));
              } else if (settings.name == '/business_owner_onboarding_page_1') {
                return createRoute(const BusinessOwnerOnboardingPage1());
              } else if (settings.name == '/business_owner_onboarding_page_2') {
                final args = settings.arguments as BusinessSignupEntity?;
                return createRoute(
                  BusinessOwnerOnboardingPage2(businessSignUpEntity: args!),
                );
              } else if (settings.name == '/deposit_funds_page') {
                return createRoute(const DepositFundsPage());
              } else if (settings.name == '/wallet_page') {
                return createRoute(const WalletGuardPage());
              } else if (settings.name == '/terms_and_conditions_page') {
                // Handle both BusinessSignupEntity and UserRole arguments
                dynamic args = settings.arguments;
                BusinessSignupEntity? businessEntity;
                FreelancerSignupEntity? freelancerEntity;
                UserRole? selectedRole; // UserRole from user_entity.dart

                if (args is BusinessSignupEntity) {
                  businessEntity = args;
                } else if (args is FreelancerSignupEntity) {
                  freelancerEntity = args;
                } else if (args is Map) {
                  businessEntity =
                      args['businessEntity'] as BusinessSignupEntity?;
                  selectedRole = args['selectedRole'] as UserRole?;
                } else if (args != null) {
                  // Check if it's UserRole from user_entity.dart
                  // contentCreator from user_selection_page maps to influencer in user_entity
                  final roleStr = args.toString();
                  if (roleStr.contains('contentCreator') ||
                      roleStr.contains('influencer')) {
                    selectedRole = UserRole.contentCreator;
                  } else if (roleStr.contains('businessOwner')) {
                    selectedRole = UserRole.businessOwner;
                  } else if (roleStr.contains('photographer') ||
                      roleStr.contains('videographer') ||
                      roleStr.contains('designer') ||
                      roleStr.contains('creative')) {
                    selectedRole = UserRole.creative;
                  }
                }

                return createRoute(
                  TermsAndConditionsPage(
                    businessSignupEntity: businessEntity,
                    freelancerSignupEntity: freelancerEntity,
                    selectedRole: selectedRole,
                  ),
                );
              } else if (settings.name == '/business_owner_dashboard_page') {
                return createRoute(const BusinessOwnerMainNavigation());
              } else if (settings.name == '/influencer_dashboard_page') {
                final args = settings.arguments as UserRole?;
                return createRoute(
                  InfluencerMainNavigation(
                    userRole: args ?? UserRole.contentCreator,
                  ),
                );
              } else if (settings.name == '/create_project_page_1') {
                return createRoute(const CreateProjectPage1());
              } else if (settings.name == '/create_project_page_2') {
                final args = settings.arguments as JobFormData;
                return createRoute(CreateProjectPage2(jobFormData: args));
              }
              return null;
            },
            title: 'Flutter App',
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    ),
  );
}

PageRouteBuilder createRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      const curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(position: animation.drive(tween), child: child);
    },
  );
}
