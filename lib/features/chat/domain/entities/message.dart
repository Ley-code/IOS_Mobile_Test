import 'package:equatable/equatable.dart';

class Message extends Equatable {
  final String id;
  final String roomId;
  final String text;
  final DateTime timestamp;
  final String userId;
  final String username;
  final String userName;
  final bool isTemp;
  final bool isSending;
  final bool isFailed;

  const Message({
    required this.id,
    required this.roomId,
    required this.text,
    required this.timestamp,
    required this.userId,
    required this.username,
    required this.userName,
    this.isTemp = false,
    this.isSending = false,
    this.isFailed = false,
  });

  @override
  List<Object?> get props => [
        id,
        roomId,
        text,
        timestamp,
        userId,
        username,
        userName,
        isTemp,
        isSending,
        isFailed,
      ];
}

