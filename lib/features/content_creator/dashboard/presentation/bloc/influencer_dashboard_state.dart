import 'package:equatable/equatable.dart';
import 'package:mobile_app/features/content_creator/dashboard/domain/entities/portfolio_item_entity.dart';

abstract class InfluencerDashboardState extends Equatable {
  const InfluencerDashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends InfluencerDashboardState {}

class DashboardLoading extends InfluencerDashboardState {}

class DashboardLoaded extends InfluencerDashboardState {
  final List<PortfolioItemEntity> portfolioItems;
  final int profileCompletionPercentage;
  // Add other dashboard stats here later (Profile, Earnings, etc.)

  const DashboardLoaded({
    required this.portfolioItems,
    this.profileCompletionPercentage = 0,
  });

  @override
  List<Object?> get props => [portfolioItems, profileCompletionPercentage];
}

class DashboardError extends InfluencerDashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
