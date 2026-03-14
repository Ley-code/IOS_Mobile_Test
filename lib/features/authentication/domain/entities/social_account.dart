class SocialAccount {
  final String accountId;
  final String platformName;
  final String? username;
  final String? profilePictureUrl;
  final int? followerCount;
  final String? accessToken;

  SocialAccount({
    required this.accountId,
    required this.platformName,
    this.username,
    this.profilePictureUrl,
    this.followerCount,
    this.accessToken,
  });
}
