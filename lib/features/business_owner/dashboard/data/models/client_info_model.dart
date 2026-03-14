import 'package:equatable/equatable.dart';
import 'common_models.dart';

class ClientInfoModel extends Equatable {
  final String id;
  final String? companyId;
  final CompanyInfoModel? company;
  final String businessName;
  final String companyWebsite;
  final String aboutBusiness;
  final String businessPhone;
  final List<ServiceInfoModel> servicesSeeking;

  const ClientInfoModel({
    required this.id,
    this.companyId,
    this.company,
    required this.businessName,
    required this.companyWebsite,
    required this.aboutBusiness,
    required this.businessPhone,
    this.servicesSeeking = const [],
  });

  factory ClientInfoModel.fromJson(Map<String, dynamic> json) {
    return ClientInfoModel(
      id: json['id'] ?? '',
      companyId: json['company_id'],
      company: json['company'] != null
          ? CompanyInfoModel.fromJson(json['company'])
          : null,
      businessName: json['business_name'] ?? '',
      companyWebsite: json['company_website'] ?? '',
      aboutBusiness: json['about_business'] ?? '',
      businessPhone: json['business_phone'] ?? '',
      servicesSeeking:
          (json['services_seeking'] as List<dynamic>?)
              ?.map((e) => ServiceInfoModel.fromJson(e))
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [
    id,
    companyId,
    company,
    businessName,
    companyWebsite,
    aboutBusiness,
    businessPhone,
    servicesSeeking,
  ];
}
