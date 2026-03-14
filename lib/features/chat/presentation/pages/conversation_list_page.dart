import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:mobile_app/features/chat/presentation/bloc/chat_event.dart';
import 'package:mobile_app/features/chat/presentation/bloc/chat_state.dart';
import 'package:mobile_app/features/chat/presentation/pages/chat_page.dart';
import 'package:mobile_app/injection_container.dart';
import 'package:mobile_app/features/chat/domain/entities/conversation.dart';

class ConversationListPage extends StatefulWidget {
  final String userId;
  final String role; // 'client' or 'freelancer'

  const ConversationListPage({
    super.key,
    required this.userId,
    required this.role,
  });

  @override
  State<ConversationListPage> createState() => _ConversationListPageState();
}

class _ConversationListPageState extends State<ConversationListPage> {
  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  void _loadConversations() {
    context.read<ChatBloc>().add(
      LoadConversations(userId: widget.userId, role: widget.role),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
      ),
      body: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          if (state is ConversationsLoading || state is ChatInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ConversationsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadConversations,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (state is ConversationsLoaded) {
            if (state.conversations.isEmpty) {
              return const Center(child: Text('No conversations yet'));
            }
            return ListView.separated(
              itemCount: state.conversations.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final conversation = state.conversations[index];
                return _buildConversationTile(conversation);
              },
            );
          }
          // For any other state, show loading to be safe
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildConversationTile(Conversation conversation) {
    // Determine the other party's name (in a real app, this would be fetched or included in the model)
    // For now, we'll use a placeholder or derived info
    final otherUserId = widget.role == 'client'
        ? conversation.freelancerId
        : conversation.clientId;

    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.person)),
      title: Text(
        'User: ${otherUserId.substring(0, 8)}...',
      ), // Truncated ID for now
      subtitle: Text(
        conversation.lastMessageAt != null
            ? 'Last active: ${_formatDate(conversation.lastMessageAt!)}'
            : 'No messages yet',
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider(
              create: (_) => sl<ChatBloc>(),
              child: ChatPage(
                conversationId: conversation.id,
                currentUserId: widget.userId,
                currentUserEmail: 'user@example.com', // TODO: Get actual email
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    // Simple date formatting
    return '${date.day}/${date.month} ${date.hour}:${date.minute}';
  }
}
