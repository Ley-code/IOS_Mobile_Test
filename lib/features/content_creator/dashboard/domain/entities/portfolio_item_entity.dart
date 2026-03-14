import 'package:equatable/equatable.dart';

class PortfolioItemEntity extends Equatable {
  final String? id;
  final String title;
  final String description;
  final String type;
  final String? link;

  const PortfolioItemEntity({
    this.id,
    required this.title,
    required this.description,
    required this.type,
    this.link,
  });

  @override
  List<Object?> get props => [id, title, description, type, link];
}
