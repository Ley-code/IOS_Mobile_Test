import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/core/usecase/usecase.dart';
import 'package:mobile_app/features/content_creator/dashboard/domain/usecases/add_portfolio_item.dart';
import 'package:mobile_app/features/content_creator/dashboard/domain/usecases/get_portfolio_items.dart';
import 'package:mobile_app/features/content_creator/dashboard/domain/usecases/update_portfolio_item.dart';
import 'package:mobile_app/features/content_creator/dashboard/domain/usecases/delete_portfolio_item.dart';
import 'package:mobile_app/features/content_creator/dashboard/domain/usecases/get_profile_completion.dart';
import 'package:mobile_app/features/content_creator/dashboard/presentation/bloc/influencer_dashboard_event.dart';
import 'package:mobile_app/features/content_creator/dashboard/presentation/bloc/influencer_dashboard_state.dart';

class InfluencerDashboardBloc
    extends Bloc<InfluencerDashboardEvent, InfluencerDashboardState> {
  final GetPortfolioItems getPortfolioItems;
  final AddPortfolioItem addPortfolioItem;
  final UpdatePortfolioItem updatePortfolioItem;
  final DeletePortfolioItem deletePortfolioItem;
  final GetProfileCompletion getProfileCompletion;

  InfluencerDashboardBloc({
    required this.getPortfolioItems,
    required this.addPortfolioItem,
    required this.updatePortfolioItem,
    required this.deletePortfolioItem,
    required this.getProfileCompletion,
  }) : super(DashboardInitial()) {
    on<LoadDashboardData>(_onLoadDashboardData);
    on<RefreshDashboardData>(_onRefreshDashboardData);
    on<AddPortfolioItemEvent>(_onAddPortfolioItem);
    on<UpdatePortfolioItemEvent>(_onUpdatePortfolioItem);
    on<DeletePortfolioItemEvent>(_onDeletePortfolioItem);
  }

  Future<void> _onLoadDashboardData(
    LoadDashboardData event,
    Emitter<InfluencerDashboardState> emit,
  ) async {
    emit(DashboardLoading());
    final portfolioResult = await getPortfolioItems(NoParams());
    final completionResult = await getProfileCompletion(NoParams());
    
    portfolioResult.fold(
      (failure) => emit(const DashboardError('Failed to load dashboard data')),
      (items) {
        completionResult.fold(
          (failure) => emit(DashboardLoaded(
            portfolioItems: items,
            profileCompletionPercentage: 0,
          )),
          (percentage) => emit(DashboardLoaded(
            portfolioItems: items,
            profileCompletionPercentage: percentage,
          )),
        );
      },
    );
  }

  Future<void> _onRefreshDashboardData(
    RefreshDashboardData event,
    Emitter<InfluencerDashboardState> emit,
  ) async {
    // Keep current state if loaded, or show loading? Usually refresh keeps content.
    // But for simplicity, we can emit loading or just fetch.
    // If we want to show pull-to-refresh spinner, the UI handles that.

    final portfolioResult = await getPortfolioItems(NoParams());
    final completionResult = await getProfileCompletion(NoParams());
    
    portfolioResult.fold(
      (failure) => emit(const DashboardError('Failed to refresh data')),
      (items) {
        completionResult.fold(
          (failure) => emit(DashboardLoaded(
            portfolioItems: items,
            profileCompletionPercentage: 0,
          )),
          (percentage) => emit(DashboardLoaded(
            portfolioItems: items,
            profileCompletionPercentage: percentage,
          )),
        );
      },
    );
  }

  Future<void> _onAddPortfolioItem(
    AddPortfolioItemEvent event,
    Emitter<InfluencerDashboardState> emit,
  ) async {
    emit(DashboardLoading());
    final result = await addPortfolioItem(
      AddPortfolioItemParams(item: event.item, coverImage: event.coverImage),
    );
    result.fold(
      (failure) => emit(
        DashboardError('Failed to add portfolio item: ${failure.message}'),
      ),
      (_) {
        // After successful add, refresh the portfolio list
        add(const LoadDashboardData());
      },
    );
  }

  Future<void> _onUpdatePortfolioItem(
    UpdatePortfolioItemEvent event,
    Emitter<InfluencerDashboardState> emit,
  ) async {
    emit(DashboardLoading());
    final result = await updatePortfolioItem(event.item);
    result.fold(
      (failure) => emit(
        DashboardError('Failed to update portfolio item: ${failure.message}'),
      ),
      (_) {
        add(const LoadDashboardData());
      },
    );
  }

  Future<void> _onDeletePortfolioItem(
    DeletePortfolioItemEvent event,
    Emitter<InfluencerDashboardState> emit,
  ) async {
    emit(DashboardLoading());
    final result = await deletePortfolioItem(event.portfolioId);
    result.fold(
      (failure) => emit(
        DashboardError('Failed to delete portfolio item: ${failure.message}'),
      ),
      (_) {
        add(const LoadDashboardData());
      },
    );
  }
}
