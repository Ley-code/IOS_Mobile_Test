import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/features/chat/domain/entities/conversation.dart';
import 'package:mobile_app/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:mobile_app/features/chat/presentation/bloc/chat_event.dart';
import 'package:mobile_app/features/chat/presentation/bloc/chat_state.dart';
import 'package:mobile_app/core/storage/token_storage.dart';
import 'package:mobile_app/features/chat/presentation/widgets/message_tile.dart';
import 'package:mobile_app/injection_container.dart' as di;

class MessagesListPage extends StatefulWidget {
  final Widget Function(BuildContext, Conversation, String)
  messageDetailsBuilder;
  final String? userEmail;

  const MessagesListPage({
    super.key,
    required this.messageDetailsBuilder,
    this.userEmail,
  });

  @override
  State<MessagesListPage> createState() => _MessagesListPageState();
}

class _MessagesListPageState extends State<MessagesListPage>
    with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _userId;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadUserInfo();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadConversations();
    }
  }

  Future<void> _loadUserInfo() async {
    final tokenStorage = di.sl<TokenStorage>();
    _userId = await tokenStorage.getUserId();
    _userRole = await tokenStorage.getUserRole();
    _loadConversations();
  }

  void _loadConversations() {
    if (_userId != null && _userRole != null) {
      context.read<ChatBloc>().add(
        LoadConversations(userId: _userId!, role: _userRole!.toLowerCase()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;
    final accent = theme.colorScheme.secondary;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;
    final subtleText =
        theme.textTheme.bodySmall?.color ?? Colors.white.withOpacity(0.7);
    final cardColor = theme.cardColor;

    return Scaffold(
      backgroundColor: primary,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Messages',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Search bar
                  Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() => _searchQuery = value.toLowerCase());
                      },
                      style: TextStyle(color: textColor, fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'Search conversations...',
                        hintStyle: TextStyle(color: subtleText, fontSize: 15),
                        prefixIcon: Icon(
                          Icons.search,
                          color: subtleText,
                          size: 22,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                                icon: Icon(
                                  Icons.close,
                                  color: subtleText,
                                  size: 20,
                                ),
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Messages list
            Expanded(
              child: BlocBuilder<ChatBloc, ChatState>(
                buildWhen: (previous, current) => true,
                builder: (context, state) {
                  if (state is ConversationsLoading) {
                    return Center(
                      child: CircularProgressIndicator(color: accent),
                    );
                  }

                  if (state is ConversationsError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, color: accent, size: 48),
                          const SizedBox(height: 16),
                          Text(
                            state.message,
                            style: TextStyle(color: textColor),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadConversations,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is ConversationsLoaded) {
                    final conversations = state.conversations;
                    final filtered = _searchQuery.isEmpty
                        ? conversations
                        : conversations.where((conv) => true).toList();

                    if (filtered.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: () async {
                          _loadConversations();
                          await Future.delayed(
                            const Duration(milliseconds: 500),
                          );
                        },
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.6,
                            child: _buildEmptyState(textColor, subtleText),
                          ),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        if (_userId != null && _userRole != null) {
                          context.read<ChatBloc>().add(
                            RefreshConversations(
                              userId: _userId!,
                              role: _userRole!.toLowerCase(),
                            ),
                          );
                        }
                        await Future.delayed(const Duration(milliseconds: 500));
                      },
                      child: ListView.builder(
                        key: ValueKey('conversations_${filtered.length}'),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final conv = filtered[index];
                          return MessageTile(
                            key: ValueKey('conversation_${conv.id}'),
                            conversation: conv,
                            accent: accent,
                            textColor: textColor,
                            subtleText: subtleText,
                            cardColor: cardColor,
                            currentUserId: _userId ?? '',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => widget.messageDetailsBuilder(
                                    context,
                                    conv,
                                    widget.userEmail ?? '',
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    );
                  }

                  // Initial state
                  return RefreshIndicator(
                    onRefresh: () async {
                      _loadConversations();
                      await Future.delayed(const Duration(milliseconds: 500));
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: _buildEmptyState(textColor, subtleText),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(Color textColor, Color subtleText) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: subtleText.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No messages found',
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try a different search term'
                : 'Start a conversation',
            style: TextStyle(color: subtleText, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
