import 'package:mobile_app/features/content_creator/dashboard/domain/entities/portfolio_item_entity.dart';

class PortfolioItemModel extends PortfolioItemEntity {
  const PortfolioItemModel({
    super.id,
    required super.title,
    required super.description,
    required super.type,
    super.link,
  });

  factory PortfolioItemModel.fromJson(Map<String, dynamic> json) {
    return PortfolioItemModel(
      id: json['portfolio_id'] ?? '',
      title: json['portfolio_title'] ?? '',
      description: json['portfolio_description'] ?? '',
      type: json['portfolio_type'] ?? 'image',
      link: json['thumbnail_url'],
    );
  }

  Map<String, dynamic> toJson() {
    // Convert display type (Images/Videos/Audios) to backend type (image/video/audio)
    String backendType = type.toLowerCase();
    if (backendType == 'images') backendType = 'image';
    if (backendType == 'videos') backendType = 'video';
    if (backendType == 'audios') backendType = 'audio';

    final Map<String, dynamic> data = {
      'portfolio_title': title,
      'portfolio_description': description,
      'portfolio_type': backendType,
    };

    // Only include thumbnail_url if it's not null
    if (link != null && link!.isNotEmpty) {
      data['thumbnail_url'] = link;
    }

    return data;
  }
}
