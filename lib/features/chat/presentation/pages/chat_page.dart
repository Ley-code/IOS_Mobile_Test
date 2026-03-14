import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:mobile_app/features/chat/presentation/bloc/chat_event.dart';
import 'package:mobile_app/features/chat/presentation/bloc/chat_state.dart';
import 'package:mobile_app/features/chat/data/models/rocket_chat_message_model.dart';

class ChatPage extends StatefulWidget {
  final String conversationId;
  final String currentUserId;
  final String currentUserEmail; // Needed for Rocket.Chat login

  const ChatPage({
    super.key,
    required this.conversationId,
    required this.currentUserId,
    required this.currentUserEmail,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _roomId;
  String? _rocketChatUserId;

  @override
  void initState() {
    super.initState();
    // Initialize room and then connect
    context.read<ChatBloc>().add(
      InitializeChatRoomEvent(widget.conversationId),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    // Disconnect when leaving the page
    context.read<ChatBloc>().add(DisconnectWebSocket());
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty && _roomId != null) {
      context.read<ChatBloc>().add(
        SendMessage(roomId: _roomId!, message: text),
      );
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: BlocConsumer<ChatBloc, ChatState>(
        listener: (context, state) {
          if (state is RoomInitialized) {
            // Room ready, now connect to WebSocket
            context.read<ChatBloc>().add(
              ConnectWebSocket(
                conversationId: widget.conversationId,
                userEmail: widget.currentUserEmail,
              ),
            );
          } else if (state is ChatConnected) {
            _roomId = state.roomId;
            _rocketChatUserId = state.userId;
          } else if (state is ChatConnectionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Connection Error: ${state.message}')),
            );
          } else if (state is MessagesLoaded) {
            // Scroll to bottom when new messages arrive
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_scrollController.hasClients) {
                _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              }
            });
          }
        },
        buildWhen: (previous, current) {
          // Always rebuild on MessagesLoaded to ensure UI updates
          if (current is MessagesLoaded) {
            return true;
          }
          // Rebuild on other state changes too
          return previous != current;
        },
        builder: (context, state) {
          if (state is RoomInitializing || state is ChatConnecting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Connecting to secure chat...'),
                ],
              ),
            );
          }

          if (state is MessagesLoaded) {
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final message = state.messages[index];
                      return _buildMessageBubble(message);
                    },
                  ),
                ),
                _buildInputArea(),
              ],
            );
          }

          // Fallback for initial state after connection but before messages (rare)
          if (state is ChatConnected) {
            return Column(
              children: [
                const Expanded(
                  child: Center(child: Text('Connected. No messages yet.')),
                ),
                _buildInputArea(),
              ],
            );
          }

          return const Center(child: Text('Initializing...'));
        },
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send),
            color: Theme.of(context).primaryColor,
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(RocketChatMessageModel message) {
    // Determine if message is from me using the stored Rocket.Chat User ID
    final isMe =
        _rocketChatUserId != null && message.user.id == _rocketChatUserId;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue[100] : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Text(
                message.user.username,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            Text(message.message),
            Text(
              message.formattedTime,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
