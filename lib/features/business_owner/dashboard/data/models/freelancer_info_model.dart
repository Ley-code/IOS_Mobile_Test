import 'package:equatable/equatable.dart';
import 'common_models.dart';

class FreelancerInfoModel extends Equatable {
  final String freelancerId;
  final String introduction;
  final String introductionVideo;
  final String? companyId;
  final CompanyInfoModel? company;
  final String creatorType;
  final String headline;

  const FreelancerInfoModel({
    required this.freelancerId,
    required this.introduction,
    required this.introductionVideo,
    this.companyId,
    this.company,
    required this.creatorType,
    required this.headline,
  });

  factory FreelancerInfoModel.fromJson(Map<String, dynamic> json) {
    return FreelancerInfoModel(
      freelancerId: json['freelancer_id'] ?? '',
      introduction: json['introduction'] ?? '',
      introductionVideo: json['introduction_video'] ?? '',
      companyId: json['company_id'],
      company: json['company'] != null
          ? CompanyInfoModel.fromJson(json['company'])
          : null,
      creatorType: json['creator_type'] ?? '',
      headline: json['headline'] ?? '',
    );
  }

  @override
  List<Object?> get props => [
    freelancerId,
    introduction,
    introductionVideo,
    companyId,
    company,
    creatorType,
    headline,
  ];
}
