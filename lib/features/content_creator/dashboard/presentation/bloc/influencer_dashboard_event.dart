import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:mobile_app/features/content_creator/dashboard/domain/entities/portfolio_item_entity.dart';

abstract class InfluencerDashboardEvent extends Equatable {
  const InfluencerDashboardEvent();

  @override
  List<Object> get props => [];
}

class LoadDashboardData extends InfluencerDashboardEvent {
  const LoadDashboardData();
}

class RefreshDashboardData extends InfluencerDashboardEvent {
  const RefreshDashboardData();
}

class AddPortfolioItemEvent extends InfluencerDashboardEvent {
  final PortfolioItemEntity item;
  final File? coverImage;

  const AddPortfolioItemEvent(this.item, {this.coverImage});

  @override
  List<Object> get props => [item, coverImage ?? ''];
}

class UpdatePortfolioItemEvent extends InfluencerDashboardEvent {
  final PortfolioItemEntity item;

  const UpdatePortfolioItemEvent(this.item);

  @override
  List<Object> get props => [item];
}

class DeletePortfolioItemEvent extends InfluencerDashboardEvent {
  final String portfolioId;

  const DeletePortfolioItemEvent(this.portfolioId);

  @override
  List<Object> get props => [portfolioId];
}
