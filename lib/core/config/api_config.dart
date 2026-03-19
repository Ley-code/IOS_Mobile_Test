import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  // Base URL for the backend API
  //
  // For local development:
  // - If running on emulator/simulator: use 'http://localhost:8080/api/v1' or 'http://10.0.2.2:8080/api/v1' (Android emulator)
  // - If running on physical device: use 'http://YOUR_PC_IP_ADDRESS:8080/api/v1'
  //   Example: 'http://192.168.1.100:8080/api/v1'
  //
  // To find your PC's IP address:
  // - Windows: Run 'ipconfig' in CMD and look for IPv4 Address
  // - Mac/Linux: Run 'ifconfig' or 'ip addr' and look for inet address
  //
  // Make sure your phone and PC are on the same WiFi network!

  // For emulator/simulator (use localhost):
  // static const String baseUrl = 'http://localhost:8080/api/v1';
  // For Android emulator specifically, use: 'http://10.0.2.2:8080/api/v1'

  // For physical device (use your PC's IP address):
  // Replace 192.168.1.2 with your actual PC IP address if different
  static const String baseUrl = 'https://vyrl.space/api/v1';

  // API endpoints
  static const String signupEndpoint = '/auth/signup';
  static const String instagramCallbackEndpoint = '/instagram/callback';
  static const String instagramSessionEndpoint =
      '/auth/instagram/consume-session';
  static const String instagramFinalizeEndpoint = '/instagram/finalize';
  static const String loginEndpoint = '/auth/login';
  static const String forgotPasswordEndpoint = '/auth/forgot-password';
  static const String resetPasswordEndpoint = '/auth/reset-password';
  // User endpoints
  static const String userProfileEndpoint = '/users/profile';
  static const String clientJobsEndpoint = '/users/clients/jobs';
  static const String userFreelancerProfileEndpoint =
      '/users/freelancers/profile';
  static const String updateFreelancerProfileEndpoint = '/users/freelancer';
  static const String updateClientProfileEndpoint = '/users/client';
  static const String profileCompletionEndpoint = '/users/profile/completion';

  // Search endpoints
  static const String filterJobsEndpoint = '/jobs/filter';
  static const String filterFreelancersEndpoint = '/freelancers/filter';
  static const String getAllFreelancersEndpoint = '/freelancers';
  static const String freelancerMePortfoliosEndpoint =
      '/freelancers/me/portfolios';
  // Job creation endpoint
  static const String createJobEndpoint = '/jobs';
  static const String jobCategoriesEndpoint = '/jobs/categories';

  // Portfolio endpoints
  static const String portfoliosEndpoint = '/portfolios';
  static const String freelancerMeEndpoint = '/freelancers/me';
  static const String freelancerPortfoliosEndpoint =
      '/freelancers/:freelancerId/portfolios';

  // Contract endpoints
  static const String contractsEndpoint = '/contracts';
  static const String myContractsEndpoint = '/contracts/mine';
  static const String contractByIdEndpoint =
      '/contracts'; // Use with /:contractId

  // Chat/Conversation endpoints
  static const String conversationsEndpoint = '/conversations';
  static const String createRoomEndpoint = '/conversations/:id/create-room';
  static const String rocketChatInfoEndpoint =
      '/conversations/:id/rocketchat-info';
  static const String rocketChatLoginEndpoint = '/rocketchat/login';
  static const String userConversationsEndpoint =
      '/users/:userId/conversations';

  // Rocket.Chat server URL
  static const String rocketChatServerUrl = 'wss://chat.vyrl.space/websocket';
  static const String rocketChatApiUrl = 'https://chat.vyrl.space/api/v1';

  // Stripe Configuration
  // For now, this should match your Stripe publishable key from backend
  // You can get this from your Stripe dashboard or backend config
  static String get stripePublishableKey =>
    "pk_test_51SODKJ30YQc6nJL4XocadTeOlNvSwrNwE2YHJa4Rs3iBV5o3J2MM7UzWwlBxQujixISwIUKtTqEcxdIwBi0deEK80027ZCf7ry";

  // Payment endpoints
  static const String depositEndpoint = '/payments/deposit';
  static const String fundContractEndpoint = '/payments/contract/fund';
  static const String releaseEscrowEndpoint =
      '/payments/contract/release-escrow';
  static const String withdrawalRequestEndpoint =
      '/payments/withdrawal-request';

  // Helper method to build full URL
  static String buildUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }
}
