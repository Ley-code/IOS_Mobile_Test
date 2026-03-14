import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_app/core/network/api_client.dart';
import 'package:mobile_app/core/storage/token_storage.dart';
import 'package:mobile_app/core/theme/theme_bloc.dart';
import 'package:mobile_app/features/authentication/data/data_sources/remote/auth_remote_data_source.dart';
import 'package:mobile_app/features/authentication/data/data_sources/remote/auth_remote_data_source_impl.dart';
import 'package:mobile_app/features/authentication/data/repositories/auth_repo_impl.dart';
import 'package:mobile_app/features/authentication/domain/repository/auth_repo.dart';
import 'package:mobile_app/features/authentication/domain/usecases/business_sign_up_usecase.dart';
import 'package:mobile_app/features/authentication/domain/usecases/freelancer_sign_up_usecase.dart';
import 'package:mobile_app/features/authentication/domain/usecases/log_in_usecase.dart';
import 'package:mobile_app/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:mobile_app/features/authentication/domain/usecases/connect_instagram_usecase.dart';
import 'package:mobile_app/features/authentication/domain/usecases/consume_instagram_session_usecase.dart';
import 'package:mobile_app/features/authentication/domain/usecases/finalize_instagram_session_usecase.dart';
import 'package:mobile_app/features/business_owner/dashboard/data/data_sources/remote/dashboard_remote_data_source.dart';
import 'package:mobile_app/features/business_owner/dashboard/data/repositories/dashboard_repository.dart';
import 'package:mobile_app/features/business_owner/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:mobile_app/features/search/data/data_sources/remote/search_remote_data_source.dart';
import 'package:mobile_app/features/search/data/repositories/search_repository.dart';
import 'package:mobile_app/features/search/presentation/bloc/search_bloc.dart';
import 'package:mobile_app/features/job_creation/data/data_sources/remote/job_creation_remote_data_source.dart';
import 'package:mobile_app/features/job_creation/data/repositories/job_creation_repository.dart';
import 'package:mobile_app/features/job_creation/presentation/bloc/job_creation_bloc.dart';
import 'package:mobile_app/features/content_creator/dashboard/data/datasources/influencer_remote_data_source.dart';
import 'package:mobile_app/features/content_creator/dashboard/data/repositories/influencer_dashboard_repository_impl.dart';
import 'package:mobile_app/features/content_creator/dashboard/domain/repositories/influencer_dashboard_repository.dart';
import 'package:mobile_app/features/content_creator/dashboard/domain/usecases/add_portfolio_item.dart';
import 'package:mobile_app/features/content_creator/dashboard/domain/usecases/get_portfolio_items.dart';
import 'package:mobile_app/features/content_creator/dashboard/domain/usecases/update_portfolio_item.dart';
import 'package:mobile_app/features/content_creator/dashboard/domain/usecases/delete_portfolio_item.dart';
import 'package:mobile_app/features/content_creator/dashboard/domain/usecases/get_profile_completion.dart';
import 'package:mobile_app/features/content_creator/dashboard/presentation/bloc/influencer_dashboard_bloc.dart';
import 'package:mobile_app/features/content_creator/projects/data/datasources/contract_remote_data_source.dart';
import 'package:mobile_app/features/content_creator/projects/data/repositories/contract_repository_impl.dart';
import 'package:mobile_app/features/content_creator/projects/domain/repositories/contract_repository.dart';
import 'package:mobile_app/features/content_creator/projects/domain/usecases/get_contract_by_id.dart';
import 'package:mobile_app/features/content_creator/projects/domain/usecases/get_my_contracts.dart';
import 'package:mobile_app/features/content_creator/projects/presentation/bloc/contract_bloc.dart';
import 'package:mobile_app/features/jobs/data/datasources/jobs_remote_data_source.dart';
import 'package:mobile_app/features/jobs/data/repositories/jobs_repository_impl.dart';
import 'package:mobile_app/features/jobs/domain/repositories/jobs_repository.dart';
import 'package:mobile_app/features/jobs/domain/usecases/get_jobs.dart';
import 'package:mobile_app/features/jobs/domain/usecases/get_job_by_id.dart';
import 'package:mobile_app/features/jobs/domain/usecases/submit_proposal.dart';
import 'package:mobile_app/features/jobs/domain/usecases/get_my_jobs.dart';
import 'package:mobile_app/features/jobs/presentation/bloc/jobs_bloc.dart';
import 'package:mobile_app/features/payments/data/datasources/payment_remote_data_source.dart';
import 'package:mobile_app/features/payments/data/repositories/payment_repository_impl.dart';
import 'package:mobile_app/features/payments/domain/repositories/payment_repository.dart';
import 'package:mobile_app/features/payments/presentation/bloc/payment_bloc.dart';
import 'package:mobile_app/features/proposals/data/datasources/proposals_remote_data_source.dart';
import 'package:mobile_app/features/proposals/data/repositories/proposals_repository_impl.dart';
import 'package:mobile_app/features/proposals/domain/repositories/proposals_repository.dart';
import 'package:mobile_app/features/proposals/domain/usecases/get_job_proposals.dart';
import 'package:mobile_app/features/proposals/domain/usecases/submit_offer.dart';
import 'package:mobile_app/features/proposals/presentation/bloc/proposals_bloc.dart';
import 'package:mobile_app/features/offers/data/datasources/offers_remote_data_source.dart';
import 'package:mobile_app/features/offers/data/repositories/offers_repository_impl.dart';
import 'package:mobile_app/features/offers/domain/repositories/offers_repository.dart';
import 'package:mobile_app/features/offers/domain/usecases/get_offers.dart';
import 'package:mobile_app/features/offers/domain/usecases/get_offer_by_id.dart';
import 'package:mobile_app/features/offers/domain/usecases/accept_offer.dart';
import 'package:mobile_app/features/offers/presentation/bloc/offers_bloc.dart';
import 'package:mobile_app/features/wallet/data/datasources/wallet_remote_data_source.dart';
import 'package:mobile_app/features/wallet/data/repositories/wallet_repository_impl.dart';
import 'package:mobile_app/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:mobile_app/features/wallet/domain/usecases/deposit_funds.dart'
    show CreateDepositPaymentIntent;
import 'package:mobile_app/features/wallet/domain/usecases/get_transactions.dart';
import 'package:mobile_app/features/wallet/domain/usecases/get_wallet_balance.dart';
import 'package:mobile_app/features/wallet/domain/usecases/request_withdrawal.dart';
import 'package:mobile_app/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:mobile_app/features/chat/data/datasources/chat_local_data_source.dart';
import 'package:mobile_app/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:mobile_app/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:mobile_app/features/chat/data/services/rocket_chat_websocket_service.dart';
import 'package:mobile_app/features/chat/domain/repositories/chat_repository.dart';
import 'package:mobile_app/features/chat/domain/usecases/create_or_get_conversation.dart';
import 'package:mobile_app/features/chat/domain/usecases/get_user_conversations.dart';
import 'package:mobile_app/features/chat/domain/usecases/initialize_chat_room.dart';
import 'package:mobile_app/features/chat/domain/usecases/get_rocket_chat_connection_info.dart';
import 'package:mobile_app/features/chat/domain/usecases/login_to_rocket_chat.dart';
import 'package:mobile_app/features/chat/domain/usecases/get_participant_profile.dart';
import 'package:mobile_app/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:mobile_app/features/chat/presentation/bloc/participant_bloc.dart';
import 'package:mobile_app/features/network/data/datasources/network_remote_data_source.dart';
import 'package:mobile_app/features/network/data/repositories/network_repository_impl.dart';
import 'package:mobile_app/features/network/domain/repositories/network_repository.dart';
import 'package:mobile_app/features/network/domain/usecases/follow_user.dart';
import 'package:mobile_app/features/network/domain/usecases/unfollow_user.dart';
import 'package:mobile_app/features/network/domain/usecases/get_network_stats.dart';
import 'package:mobile_app/features/network/domain/usecases/check_follow_status.dart';
import 'package:mobile_app/features/network/domain/usecases/get_followers.dart';
import 'package:mobile_app/features/network/domain/usecases/get_following.dart';
import 'package:mobile_app/features/network/presentation/bloc/network_bloc.dart';
import 'package:mobile_app/features/freelancer_profile/data/data_sources/remote/freelancer_profile_remote_data_source.dart';
import 'package:mobile_app/features/freelancer_profile/data/repositories/freelancer_profile_repository_impl.dart';
import 'package:mobile_app/features/freelancer_profile/domain/repositories/freelancer_profile_repository.dart';
import 'package:mobile_app/features/freelancer_profile/domain/usecases/get_freelancer_profile.dart';
import 'package:mobile_app/features/freelancer_profile/domain/usecases/get_freelancer_contracts.dart';
import 'package:mobile_app/features/freelancer_profile/domain/usecases/get_freelancer_ratings.dart';
import 'package:mobile_app/features/freelancer_profile/domain/usecases/get_freelancer_portfolios.dart';
import 'package:mobile_app/features/freelancer_profile/presentation/bloc/freelancer_profile_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Core services
  sl.registerLazySingleton(() => TokenStorage());
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => ApiClient(client: sl(), tokenStorage: sl()));

  // Theme
  sl.registerFactory(() => ThemeBloc());

  //feature: Authentication
  //bloc
  sl.registerFactory(
    () => AuthBloc(
      logInUsecase: sl(),
      businessSignUpUseCase: sl(),
      freelancerSignUpUseCase: sl(),
      connectInstagramUseCase: sl(),
      consumeInstagramSessionUseCase: sl(),
      finalizeInstagramSessionUseCase: sl(),
      tokenStorage: sl(),
    ),
  );
  //usecases
  sl.registerLazySingleton(() => LogInUsecase(authRepository: sl()));
  sl.registerLazySingleton(() => BusinessSignUpUseCase(authRepository: sl()));
  sl.registerLazySingleton(() => FreelancerSignUpUseCase(authRepository: sl()));

  sl.registerLazySingleton(() => ConnectInstagramUseCase(sl()));
  sl.registerLazySingleton(() => ConsumeInstagramSessionUseCase(sl()));
  sl.registerLazySingleton(() => FinalizeInstagramSessionUseCase(sl()));
  //repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(authRemoteDataSource: sl(), tokenStorage: sl()),
  );

  //data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(apiClient: sl()),
  );

  //feature: Dashboard
  //bloc
  sl.registerFactory(
    () => DashboardBloc(
      repository: sl(),
      influencerRepository: sl<InfluencerDashboardRepository>(),
    ),
  );
  //repositories
  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(remoteDataSource: sl()),
  );
  //data sources
  sl.registerLazySingleton<DashboardRemoteDataSource>(
    () => DashboardRemoteDataSourceImpl(
      apiClient: sl(),
      tokenStorage: sl(),
      client: sl(),
    ),
  );

  //feature: Search
  //bloc
  sl.registerFactory(() => SearchBloc(repository: sl()));
  //repositories
  sl.registerLazySingleton<SearchRepository>(
    () => SearchRepositoryImpl(remoteDataSource: sl()),
  );
  //data sources
  sl.registerLazySingleton<SearchRemoteDataSource>(
    () => SearchRemoteDataSourceImpl(apiClient: sl()),
  );

  //feature: Job Creation
  //bloc
  sl.registerFactory(() => JobCreationBloc(repository: sl()));
  //repositories
  sl.registerLazySingleton<JobCreationRepository>(
    () => JobCreationRepositoryImpl(remoteDataSource: sl()),
  );
  //data sources
  sl.registerLazySingleton<JobCreationRemoteDataSource>(
    () => JobCreationRemoteDataSourceImpl(apiClient: sl()),
  );

  //feature: Influencer Dashboard
  //bloc
  sl.registerFactory(
    () => InfluencerDashboardBloc(
      getPortfolioItems: sl(),
      addPortfolioItem: sl(),
      updatePortfolioItem: sl(),
      deletePortfolioItem: sl(),
      getProfileCompletion: sl(),
    ),
  );
  //usecases
  sl.registerLazySingleton(() => GetPortfolioItems(sl()));
  sl.registerLazySingleton(() => AddPortfolioItem(sl()));
  sl.registerLazySingleton(() => UpdatePortfolioItem(sl()));
  sl.registerLazySingleton(() => DeletePortfolioItem(sl()));
  sl.registerLazySingleton(() => GetProfileCompletion(sl()));
  //repositories
  sl.registerLazySingleton<InfluencerDashboardRepository>(
    () => InfluencerDashboardRepositoryImpl(remoteDataSource: sl()),
  );
  //data sources
  sl.registerLazySingleton<InfluencerRemoteDataSource>(
    () => InfluencerRemoteDataSourceImpl(client: sl(), tokenStorage: sl()),
  );

  //feature: Contracts/Projects
  //bloc
  sl.registerFactory(
    () => ContractBloc(getMyContracts: sl(), getContractById: sl()),
  );
  //usecases
  sl.registerLazySingleton(() => GetMyContracts(sl()));
  sl.registerLazySingleton(() => GetContractById(sl()));
  //repositories
  sl.registerLazySingleton<ContractRepository>(
    () => ContractRepositoryImpl(remoteDataSource: sl()),
  );
  //data sources
  sl.registerLazySingleton<ContractRemoteDataSource>(
    () => ContractRemoteDataSourceImpl(client: sl(), tokenStorage: sl()),
  );

  //feature: Jobs Browsing
  //bloc
  sl.registerFactory(
    () => JobsBloc(
      getJobs: sl(),
      getJobById: sl(),
      submitProposal: sl(),
      getMyJobs: sl(),
    ),
  );
  //usecases
  sl.registerLazySingleton(() => GetJobs(sl()));
  sl.registerLazySingleton(() => GetJobById(sl()));
  sl.registerLazySingleton(() => SubmitProposal(sl()));
  sl.registerLazySingleton(() => GetMyJobs(sl()));
  //repositories
  sl.registerLazySingleton<JobsRepository>(
    () => JobsRepositoryImpl(remoteDataSource: sl()),
  );
  //data sources
  sl.registerLazySingleton<JobsRemoteDataSource>(
    () => JobsRemoteDataSourceImpl(client: sl(), tokenStorage: sl()),
  );

  //feature: Payments (Stripe)
  //bloc
  sl.registerFactory(() => PaymentBloc(repository: sl()));
  //repositories
  sl.registerLazySingleton<PaymentRepository>(
    () => PaymentRepositoryImpl(remoteDataSource: sl()),
  );
  //data sources
  sl.registerLazySingleton<PaymentRemoteDataSource>(
    () => PaymentRemoteDataSourceImpl(client: sl(), tokenStorage: sl()),
  );

  //feature: Proposals
  //bloc
  sl.registerFactory(
    () => ProposalsBloc(getJobProposals: sl(), submitOffer: sl()),
  );
  //usecases
  sl.registerLazySingleton(() => GetJobProposals(sl()));
  sl.registerLazySingleton(() => SubmitOffer(sl()));
  //repositories
  sl.registerLazySingleton<ProposalsRepository>(
    () => ProposalsRepositoryImpl(remoteDataSource: sl()),
  );
  //data sources
  sl.registerLazySingleton<ProposalsRemoteDataSource>(
    () => ProposalsRemoteDataSourceImpl(client: sl(), tokenStorage: sl()),
  );

  //feature: Offers
  //bloc
  sl.registerFactory(
    () => OffersBloc(getOffers: sl(), getOfferById: sl(), acceptOffer: sl()),
  );
  //usecases
  sl.registerLazySingleton(() => GetOffers(sl()));
  sl.registerLazySingleton(() => GetOfferById(sl()));
  sl.registerLazySingleton(() => AcceptOffer(sl()));
  //repositories
  sl.registerLazySingleton<OffersRepository>(
    () => OffersRepositoryImpl(remoteDataSource: sl()),
  );
  //data sources
  sl.registerLazySingleton<OffersRemoteDataSource>(
    () => OffersRemoteDataSourceImpl(client: sl(), tokenStorage: sl()),
  );

  //feature: Wallet
  //bloc
  sl.registerFactory(
    () => WalletBloc(
      getWalletBalance: sl(),
      getTransactions: sl(),
      requestWithdrawal: sl(),
      createDepositPaymentIntent: sl(),
    ),
  );
  //usecases
  sl.registerLazySingleton(() => GetWalletBalance(sl()));
  sl.registerLazySingleton(() => GetTransactions(sl()));
  sl.registerLazySingleton(() => RequestWithdrawal(sl()));
  sl.registerLazySingleton(() => CreateDepositPaymentIntent(sl()));
  //repositories
  sl.registerLazySingleton<WalletRepository>(
    () => WalletRepositoryImpl(remoteDataSource: sl()),
  );
  //data sources
  sl.registerLazySingleton<WalletRemoteDataSource>(
    () => WalletRemoteDataSourceImpl(client: sl(), tokenStorage: sl()),
  );

  //feature: Chat
  //bloc
  sl.registerFactory(
    () => ChatBloc(
      createOrGetConversation: sl(),
      getUserConversations: sl(),
      initializeChatRoom: sl(),
      getRocketChatConnectionInfo: sl(),
      loginToRocketChat: sl(),
      webSocketService: sl(),
      tokenStorage: sl(),
    ),
  );
  sl.registerFactory(() => ParticipantBloc(getParticipantProfile: sl()));
  //usecases
  sl.registerLazySingleton(() => CreateOrGetConversation(sl()));
  sl.registerLazySingleton(() => GetUserConversations(sl()));
  sl.registerLazySingleton(() => GetParticipantProfile(sl()));
  sl.registerLazySingleton(() => InitializeChatRoom(sl()));
  sl.registerLazySingleton(() => GetRocketChatConnectionInfo(sl()));
  sl.registerLazySingleton(() => LoginToRocketChat(sl()));
  //repositories
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );
  //data sources
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(client: sl(), tokenStorage: sl()),
  );
  sl.registerLazySingleton<ChatLocalDataSource>(
    () => ChatLocalDataSourceImpl(),
  );
  //services
  sl.registerLazySingleton(() => RocketChatWebSocketService());

  //feature: Network (Follow/Unfollow)
  //bloc
  sl.registerFactory(
    () => NetworkBloc(
      followUserUseCase: sl(),
      unfollowUserUseCase: sl(),
      getNetworkStatsUseCase: sl(),
      checkFollowStatusUseCase: sl(),
      getFollowersUseCase: sl(),
      getFollowingUseCase: sl(),
    ),
  );
  //usecases
  sl.registerLazySingleton(() => FollowUser(sl()));
  sl.registerLazySingleton(() => UnfollowUser(sl()));
  sl.registerLazySingleton(() => GetNetworkStats(sl()));
  sl.registerLazySingleton(() => CheckFollowStatus(sl()));
  sl.registerLazySingleton(() => GetFollowers(sl()));
  sl.registerLazySingleton(() => GetFollowing(sl()));
  //repositories
  sl.registerLazySingleton<NetworkRepository>(
    () => NetworkRepositoryImpl(remoteDataSource: sl()),
  );
  //data sources
  sl.registerLazySingleton<NetworkRemoteDataSource>(
    () => NetworkRemoteDataSourceImpl(apiClient: sl()),
  );

  //feature: Freelancer Profile
  //bloc
  sl.registerFactory(
    () => FreelancerProfileBloc(
      getFreelancerProfile: sl(),
      getFreelancerContracts: sl(),
      getFreelancerRatings: sl(),
      getFreelancerPortfolios: sl(),
    ),
  );
  //usecases
  sl.registerLazySingleton(() => GetFreelancerProfile(repository: sl()));
  sl.registerLazySingleton(() => GetFreelancerContracts(repository: sl()));
  sl.registerLazySingleton(() => GetFreelancerRatings(repository: sl()));
  sl.registerLazySingleton(() => GetFreelancerPortfolios(repository: sl()));
  //repositories
  sl.registerLazySingleton<FreelancerProfileRepository>(
    () => FreelancerProfileRepositoryImpl(remoteDataSource: sl()),
  );
  //data sources
  sl.registerLazySingleton<FreelancerProfileRemoteDataSource>(
    () => FreelancerProfileRemoteDataSourceImpl(apiClient: sl()),
  );
}
