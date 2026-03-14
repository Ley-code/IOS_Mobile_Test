import 'package:equatable/equatable.dart';

class SocialAccountModel extends Equatable {
  final String accountId;
  final String platformId;
  final String platformName;
  final String platformLogo;
  final String accountUrl;
  final int followerCount;
  final String username;
  final String displayName;

  const SocialAccountModel({
    required this.accountId,
    required this.platformId,
    required this.platformName,
    required this.platformLogo,
    required this.accountUrl,
    required this.followerCount,
    required this.username,
    required this.displayName,
  });

  factory SocialAccountModel.fromJson(Map<String, dynamic> json) {
    return SocialAccountModel(
      accountId: json['account_id']?.toString() ?? '',
      platformId: json['platform_id']?.toString() ?? '',
      platformName: json['platform_name'] as String? ?? '',
      platformLogo: json['platform_logo'] as String? ?? '',
      accountUrl: json['account_url'] as String? ?? '',
      followerCount: (json['follower_count'] as num?)?.toInt() ?? 0,
      username: json['username'] as String? ?? '',
      displayName: json['display_name'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [
    accountId,
    platformId,
    platformName,
    platformLogo,
    accountUrl,
    followerCount,
    username,
    displayName,
  ];
}
