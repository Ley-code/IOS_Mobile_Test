import 'package:equatable/equatable.dart';

class ProposalWithUserEntity extends Equatable {
  final String proposalId;
  final String jobId;
  final String userId;
  final String proposalText;
  final Map<String, dynamic> proposalRate;
  final String? statusId;
  final DateTime createdAt;
  final ProposalUserEntity user;

  const ProposalWithUserEntity({
    required this.proposalId,
    required this.jobId,
    required this.userId,
    required this.proposalText,
    required this.proposalRate,
    this.statusId,
    required this.createdAt,
    required this.user,
  });

  /// Get the primary payout type from proposal rate
  String get primaryPayoutType {
    if (proposalRate.isEmpty) return 'Not specified';
    return proposalRate.keys.first.replaceAll('_', ' ').toUpperCase();
  }

  /// Get the primary payout rate
  double? get primaryPayoutRate {
    if (proposalRate.isEmpty) return null;
    final key = proposalRate.keys.first;
    final rate = proposalRate[key];
    if (rate == null) return null;
    return (rate as num).toDouble();
  }

  /// Get formatted rate string
  String get formattedRate {
    final rate = primaryPayoutRate;
    if (rate == null) return 'Negotiable';
    return '\$${rate.toStringAsFixed(2)}';
  }

  /// Get time ago string
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  @override
  List<Object?> get props => [
        proposalId,
        jobId,
        userId,
        proposalText,
        proposalRate,
        statusId,
        createdAt,
        user,
      ];
}

class ProposalUserEntity extends Equatable {
  final String id;
  final String userName;
  final String email;
  final String firstName;
  final String lastName;
  final String location;
  final String? phone;
  final String role;
  final String? profilePictureUrl;
  final DateTime createdAt;

  const ProposalUserEntity({
    required this.id,
    required this.userName,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.location,
    this.phone,
    required this.role,
    this.profilePictureUrl,
    required this.createdAt,
  });

  String get fullName => '$firstName $lastName';
  String get displayName => fullName.trim().isNotEmpty ? fullName : userName;
  String get initials {
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '${firstName[0]}${lastName[0]}'.toUpperCase();
    } else if (firstName.isNotEmpty) {
      return firstName[0].toUpperCase();
    } else if (userName.isNotEmpty) {
      return userName[0].toUpperCase();
    }
    return 'U';
  }

  @override
  List<Object?> get props => [
        id,
        userName,
        email,
        firstName,
        lastName,
        location,
        phone,
        role,
        profilePictureUrl,
        createdAt,
      ];
}














