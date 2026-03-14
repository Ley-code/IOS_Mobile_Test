import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

class RocketChatUserModel extends Equatable {
  final String id;
  final String username;
  final String name;

  const RocketChatUserModel({
    required this.id,
    required this.username,
    required this.name,
  });

  factory RocketChatUserModel.fromJson(Map<String, dynamic> json) {
    return RocketChatUserModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      username: json['username'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'username': username,
      'name': name,
    };
  }

  @override
  List<Object?> get props => [id, username, name];
}

class RocketChatMessageModel extends Equatable {
  final String id;
  final String roomId;
  final String message;
  final DateTime timestamp;
  final RocketChatUserModel user;
  final bool isTemp;
  final bool isSending;
  final bool isFailed;

  const RocketChatMessageModel({
    required this.id,
    required this.roomId,
    required this.message,
    required this.timestamp,
    required this.user,
    this.isTemp = false,
    this.isSending = false,
    this.isFailed = false,
  });

  factory RocketChatMessageModel.fromJson(Map<String, dynamic> json) {
    final ts = json['ts'];
    DateTime timestamp;
    if (ts is Map) {
      timestamp = DateTime.fromMillisecondsSinceEpoch(
        (ts['\$date'] as num?)?.toInt() ?? DateTime.now().millisecondsSinceEpoch,
      );
    } else if (ts is String) {
      timestamp = DateTime.parse(ts);
    } else {
      timestamp = DateTime.now();
    }

    return RocketChatMessageModel(
      id: json['_id'] as String? ?? '',
      roomId: json['rid'] as String? ?? '',
      message: json['msg'] as String? ?? '',
      timestamp: timestamp,
      user: RocketChatUserModel.fromJson(
        json['u'] as Map<String, dynamic>? ?? {},
      ),
      isTemp: json['temp'] as bool? ?? false,
      isSending: json['sending'] as bool? ?? false,
      isFailed: json['failed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'rid': roomId,
      'msg': message,
      'ts': {
        '\$date': timestamp.millisecondsSinceEpoch,
      },
      'u': user.toJson(),
      'temp': isTemp,
      'sending': isSending,
      'failed': isFailed,
    };
  }

  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      return DateFormat('h:mm a').format(timestamp);
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE').format(timestamp);
    } else {
      return DateFormat('MMM d, y').format(timestamp);
    }
  }

  RocketChatMessageModel copyWith({
    String? id,
    String? roomId,
    String? message,
    DateTime? timestamp,
    RocketChatUserModel? user,
    bool? isTemp,
    bool? isSending,
    bool? isFailed,
  }) {
    return RocketChatMessageModel(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      user: user ?? this.user,
      isTemp: isTemp ?? this.isTemp,
      isSending: isSending ?? this.isSending,
      isFailed: isFailed ?? this.isFailed,
    );
  }

  @override
  List<Object?> get props => [
        id,
        roomId,
        message,
        timestamp,
        user,
        isTemp,
        isSending,
        isFailed,
      ];
}

