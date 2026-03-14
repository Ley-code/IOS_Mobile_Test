import 'package:equatable/equatable.dart';

class Conversation extends Equatable {
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

  const Conversation({
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
