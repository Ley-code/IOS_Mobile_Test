import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/core/network/api_client.dart';
import 'package:mobile_app/core/storage/token_storage.dart';
import 'package:mobile_app/features/chat/data/models/rocket_chat_message_model.dart';
import 'package:mobile_app/features/chat/domain/entities/conversation.dart';
import 'package:mobile_app/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:mobile_app/features/chat/presentation/bloc/chat_event.dart';
import 'package:mobile_app/features/chat/presentation/bloc/chat_state.dart';
import 'package:mobile_app/injection_container.dart' as di;
import 'package:uuid/uuid.dart';

class MessageDetailsPage extends StatefulWidget {
  final Conversation conversation;
  final String userEmail;

  const MessageDetailsPage({
    super.key,
    required this.conversation,
    required this.userEmail,
  });

  @override
  State<MessageDetailsPage> createState() => _MessageDetailsPageState();
}

class _MessageDetailsPageState extends State<MessageDetailsPage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final List<RocketChatMessageModel> _messages = [];
  bool _isTyping = false;
  bool _isConnected = false;
  String? _currentUserId;
  String? _rocketChatUserId;
  final _uuid = const Uuid();
  String? _otherParticipantName;
  String? _otherParticipantProfilePicture;
  late final ChatBloc _chatBloc;

  @override
  void initState() {
    super.initState();
    _chatBloc = context.read<ChatBloc>();
    WidgetsBinding.instance.addObserver(this);
    _loadUserInfo();
    _messageController.addListener(_onTypingChanged);
    _initializeChat();
    _loadOtherParticipantInfo();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    if (mounted) {
      _chatBloc.add(const DisconnectWebSocket());
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Reload conversations when app resumes
      final chatBloc = context.read<ChatBloc>();
      final tokenStorage = di.sl<TokenStorage>();
      tokenStorage.getUserId().then((userId) {
        tokenStorage.getUserRole().then((role) {
          if (userId != null && role != null) {
            chatBloc.add(
              LoadConversations(userId: userId, role: role.toLowerCase()),
            );
          }
        });
      });
    }
  }

  Future<void> _loadUserInfo() async {
    final tokenStorage = di.sl<TokenStorage>();
    _currentUserId = await tokenStorage.getUserId();
  }

  Future<void> _loadOtherParticipantInfo() async {
    try {
      final tokenStorage = di.sl<TokenStorage>();
      final currentUserId = await tokenStorage.getUserId();
      if (currentUserId == null) return;

      final otherUserId = currentUserId == widget.conversation.clientId
          ? widget.conversation.freelancerId
          : widget.conversation.clientId;

      final apiClient = di.sl<ApiClient>();
      final response = await apiClient.get(
        '/users/profile/$otherUserId',
        requireAuth: true,
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final user = json['user'] as Map<String, dynamic>? ?? json;
        final firstName = user['first_name'] as String? ?? '';
        final lastName = user['last_name'] as String? ?? '';
        final userName = user['user_name'] as String? ?? '';

        if (mounted) {
          setState(() {
            _otherParticipantName = firstName.isNotEmpty || lastName.isNotEmpty
                ? '$firstName $lastName'.trim()
                : (userName.isNotEmpty ? userName : 'User');
            _otherParticipantProfilePicture =
                user['profile_picture_url'] as String?;
          });
        }
      }
    } catch (e) {
      // Fallback to default
      if (mounted) {
        setState(() {
          _otherParticipantName = 'User';
        });
      }
    }
  }

  Future<void> _initializeChat() async {
    // Step 1: Initialize room if not already done
    if (widget.conversation.rocketChatRoomId == null) {
      context.read<ChatBloc>().add(
        InitializeChatRoomEvent(widget.conversation.id),
      );

      // Wait for room initialization
      await Future.delayed(const Duration(seconds: 1));
    }

    // Step 2: Connect to WebSocket
    context.read<ChatBloc>().add(
      ConnectWebSocket(
        conversationId: widget.conversation.id,
        userEmail: widget.userEmail,
      ),
    );
  }

  void _onTypingChanged() {
    final hasText = _messageController.text.isNotEmpty;
    if (hasText != _isTyping) {
      setState(() => _isTyping = hasText);
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
          );
        }
      });
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty || !_isConnected) return;

    final messageText = _messageController.text.trim();
    final roomId = widget.conversation.rocketChatRoomId;

    if (roomId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Room not initialized yet')));
      return;
    }

    HapticFeedback.lightImpact();

    // Create optimistic message
    final tempMessage = RocketChatMessageModel(
      id: _uuid.v4(),
      roomId: roomId,
      message: messageText,
      timestamp: DateTime.now(),
      user: RocketChatUserModel(
        id: _rocketChatUserId ?? _currentUserId ?? '',
        username: widget.userEmail.split('@').first,
        name: widget.userEmail,
      ),
      isTemp: true,
      isSending: true,
    );

    setState(() {
      _messages.add(tempMessage);
    });
    _messageController.clear();
    _scrollToBottom();

    // Send message via BLoC
    context.read<ChatBloc>().add(
      SendMessage(roomId: roomId, message: messageText),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;
    final cardColor = theme.cardColor;
    final accent = theme.colorScheme.secondary;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;
    final subtleText =
        theme.textTheme.bodySmall?.color ?? Colors.white.withOpacity(0.7);
    final name = _otherParticipantName ?? 'User';

    return BlocListener<ChatBloc, ChatState>(
      listener: (context, state) {
        if (state is ChatConnected) {
          setState(() {
            _isConnected = true;
            _rocketChatUserId = state.userId;
          });
        } else if (state is ChatDisconnected) {
          setState(() => _isConnected = false);
        } else if (state is MessagesLoaded) {
          setState(() {
            _messages.clear();
            _messages.addAll(state.messages);
          });
          _scrollToBottom();
        } else if (state is MessageSent) {
          // Replace temp message with actual message from server
          setState(() {
            final sentMessage = state.message;

            // Find and replace the temp message
            final tempIndex = _messages.indexWhere(
              (m) =>
                  m.isTemp &&
                  (m.message == sentMessage.message || m.id == sentMessage.id),
            );

            if (tempIndex != -1) {
              // Replace temp message with actual message
              _messages[tempIndex] = sentMessage;
            } else if (!_messages.any((m) => m.id == sentMessage.id)) {
              // If temp message not found, add the sent message
              _messages.add(sentMessage);
              _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
            }
          });
          _scrollToBottom();
        } else if (state is MessageError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
          // Mark message as failed
          setState(() {
            final index = _messages.indexWhere((m) => m.isTemp && m.isSending);
            if (index != -1) {
              _messages[index] = _messages[index].copyWith(
                isSending: false,
                isFailed: true,
              );
            }
          });
        } else if (state is MessageReceived) {
          // New message received via WebSocket
          final newMessage = state.message;

          setState(() {
            // Check if this message already exists (by ID)
            final existingIndex = _messages.indexWhere(
              (m) => m.id == newMessage.id,
            );

            if (existingIndex != -1) {
              // Message already exists, replace it (might be replacing a temp message)
              _messages[existingIndex] = newMessage;
            } else {
              // Check if this is a response to a temp message we sent (by message text)
              final tempIndex = _messages.indexWhere(
                (m) =>
                    m.isTemp &&
                    m.message == newMessage.message &&
                    (m.isSending || !m.isSending),
              );

              if (tempIndex != -1) {
                // Replace temp message with real message
                _messages[tempIndex] = newMessage;
              } else {
                // New message from other user or new message
                _messages.add(newMessage);
                _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
              }
            }
          });
          _scrollToBottom();
        }
      },
      child: Scaffold(
        backgroundColor: primary,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Container(
            decoration: BoxDecoration(
              color: cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.arrow_back, color: textColor),
                    ),
                    const SizedBox(width: 4),
                    // Avatar
                    Stack(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            gradient: _otherParticipantProfilePicture == null
                                ? LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      accent.withOpacity(0.3),
                                      accent.withOpacity(0.1),
                                    ],
                                  )
                                : null,
                          ),
                          child: _otherParticipantProfilePicture != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: CachedNetworkImage(
                                    imageUrl: _otherParticipantProfilePicture!,
                                    width: 44,
                                    height: 44,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: accent,
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        _buildAvatarPlaceholder(name, accent),
                                  ),
                                )
                              : _buildAvatarPlaceholder(name, accent),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: _isConnected
                                      ? const Color(0xFF4CAF50)
                                      : subtleText,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _isConnected ? 'Active now' : 'Connecting...',
                                style: TextStyle(
                                  color: _isConnected
                                      ? const Color(0xFF4CAF50)
                                      : subtleText,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // TODO: Call feature
                      },
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.videocam, color: textColor, size: 20),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // TODO: More options
                      },
                      icon: Icon(Icons.more_vert, color: textColor),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            // Messages
            Expanded(
              child: BlocBuilder<ChatBloc, ChatState>(
                builder: (context, state) {
                  if (state is ChatConnecting || state is RoomInitializing) {
                    return Center(
                      child: CircularProgressIndicator(color: accent),
                    );
                  }

                  if (_messages.isEmpty && state is ChatConnected) {
                    return Center(
                      child: Text(
                        'No messages yet. Start the conversation!',
                        style: TextStyle(color: subtleText),
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      // Use RocketChat ID if available, otherwise fall back to App ID
                      final isMe =
                          (_rocketChatUserId != null &&
                              message.user.id == _rocketChatUserId) ||
                          message.user.id == _currentUserId;
                      final showAvatar =
                          !isMe &&
                          (index == 0 ||
                              _messages[index - 1].user.id != message.user.id);

                      return _MessageBubble(
                        message: message,
                        isMe: isMe,
                        showAvatar: showAvatar,
                        senderName: name,
                        senderProfilePicture: _otherParticipantProfilePicture,
                        accent: accent,
                        cardColor: cardColor,
                        textColor: textColor,
                        subtleText: subtleText,
                      );
                    },
                  );
                },
              ),
            ),

            // Input area
            _buildInputArea(cardColor, accent, textColor, subtleText, primary),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarPlaceholder(String name, Color accent) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'U',
        style: TextStyle(
          color: accent,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildInputArea(
    Color cardColor,
    Color accent,
    Color textColor,
    Color subtleText,
    Color primary,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      decoration: BoxDecoration(
        color: cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Attachment button
            IconButton(
              onPressed: () {
                // TODO: Attachment options
              },
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.add, color: textColor, size: 20),
              ),
            ),

            // Message input
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (!_focusNode.hasFocus) {
                    _focusNode.requestFocus();
                  }
                },
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 120),
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: _messageController,
                    focusNode: _focusNode,
                    style: TextStyle(color: textColor, fontSize: 15),
                    maxLines: null,
                    minLines: 1,
                    textInputAction: TextInputAction.newline,
                    enabled: true,
                    onSubmitted: (_) {
                      if (_isConnected && _isTyping) {
                        _sendMessage();
                      }
                    },
                    decoration: InputDecoration(
                      hintText: _isConnected
                          ? 'Type a message...'
                          : 'Connecting...',
                      hintStyle: TextStyle(
                        color: subtleText.withOpacity(0.6),
                        fontSize: 15,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          // TODO: Emoji picker
                        },
                        icon: Icon(
                          Icons.emoji_emotions_outlined,
                          color: subtleText,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Send button
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              child: IconButton(
                onPressed: _isConnected && _isTyping ? _sendMessage : null,
                icon: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (_isConnected && _isTyping)
                        ? accent
                        : accent.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.send, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final RocketChatMessageModel message;
  final bool isMe;
  final bool showAvatar;
  final String senderName;
  final String? senderProfilePicture;
  final Color accent;
  final Color cardColor;
  final Color textColor;
  final Color subtleText;

  const _MessageBubble({
    required this.message,
    required this.isMe,
    required this.showAvatar,
    required this.senderName,
    this.senderProfilePicture,
    required this.accent,
    required this.cardColor,
    required this.textColor,
    required this.subtleText,
  });

  Widget _buildMessageAvatar(String name, Color accent) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: senderProfilePicture == null
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [accent.withOpacity(0.3), accent.withOpacity(0.1)],
              )
            : null,
      ),
      child: senderProfilePicture != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: senderProfilePicture!,
                width: 32,
                height: 32,
                fit: BoxFit.cover,
                placeholder: (context, url) => Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: accent,
                  ),
                ),
                errorWidget: (context, url, error) => Center(
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'U',
                    style: TextStyle(
                      color: accent,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            )
          : Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'U',
                style: TextStyle(
                  color: accent,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 8,
        left: isMe ? 50 : 0,
        right: isMe ? 0 : 50,
      ),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe && showAvatar) ...[
            _buildMessageAvatar(senderName, accent),
            const SizedBox(width: 8),
          ] else if (!isMe) ...[
            const SizedBox(width: 40),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isMe ? accent : cardColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isMe ? 20 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.message,
                    style: TextStyle(
                      color: isMe ? Colors.white : textColor,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        message.formattedTime,
                        style: TextStyle(
                          color: isMe
                              ? Colors.white.withOpacity(0.7)
                              : subtleText,
                          fontSize: 11,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        if (message.isSending)
                          SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white.withOpacity(0.7),
                              ),
                            ),
                          )
                        else if (message.isFailed)
                          Icon(
                            Icons.error_outline,
                            size: 14,
                            color: Colors.red.withOpacity(0.7),
                          )
                        else
                          Icon(
                            Icons.done,
                            size: 14,
                            color: Colors.white.withOpacity(0.7),
                          ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
