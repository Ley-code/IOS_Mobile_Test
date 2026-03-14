import 'package:equatable/equatable.dart';

class ConversationModel extends Equatable {
  final String id;
  final String clientId;
  final String freelancerId;
  final String? jobId;
  final String? proposalId;
  final String? rocketChatRoomId;
  final String? rocketChatRoomName;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastMessageAt;

  const ConversationModel({
    required this.id,
    required this.clientId,
    required this.freelancerId,
    this.jobId,
    this.proposalId,
    this.rocketChatRoomId,
    this.rocketChatRoomName,
    this.createdAt,
    this.updatedAt,
    this.lastMessageAt,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id']?.toString() ?? json['conversation_id']?.toString() ?? '',
      clientId: json['client_id']?.toString() ?? '',
      freelancerId: json['freelancer_id']?.toString() ?? '',
      jobId: json['job_id']?.toString(),
      proposalId: json['proposal_id']?.toString(),
      rocketChatRoomId: json['rocketchat_room_id'] as String?,
      rocketChatRoomName: json['rocketchat_room_name'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.parse(json['last_message_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_id': clientId,
      'freelancer_id': freelancerId,
      if (jobId != null) 'job_id': jobId,
      if (proposalId != null) 'proposal_id': proposalId,
      if (rocketChatRoomId != null) 'rocketchat_room_id': rocketChatRoomId,
      if (rocketChatRoomName != null)
        'rocketchat_room_name': rocketChatRoomName,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      if (lastMessageAt != null)
        'last_message_at': lastMessageAt!.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    clientId,
    freelancerId,
    jobId,
    proposalId,
    rocketChatRoomId,
    rocketChatRoomName,
    createdAt,
    updatedAt,
    lastMessageAt,
  ];
}
