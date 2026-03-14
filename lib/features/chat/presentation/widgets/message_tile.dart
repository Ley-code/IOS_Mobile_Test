import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/core/utils/utils.dart';
import 'package:mobile_app/features/chat/domain/entities/conversation.dart';
import 'package:mobile_app/features/chat/presentation/bloc/participant_bloc.dart';
import 'package:mobile_app/features/chat/presentation/bloc/participant_event.dart';
import 'package:mobile_app/features/chat/presentation/bloc/participant_state.dart';

class MessageTile extends StatefulWidget {
  final Conversation conversation;
  final Color accent;
  final Color textColor;
  final Color subtleText;
  final Color cardColor;
  final String currentUserId;
  final VoidCallback onTap;

  const MessageTile({
    super.key,
    required this.conversation,
    required this.accent,
    required this.textColor,
    required this.subtleText,
    required this.cardColor,
    required this.currentUserId,
    required this.onTap,
  });

  @override
  State<MessageTile> createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {
  String _getOtherUserId() {
    return widget.currentUserId == widget.conversation.clientId
        ? widget.conversation.freelancerId
        : widget.conversation.clientId;
  }

  @override
  void initState() {
    super.initState();
    // Load participant profile after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final otherUserId = _getOtherUserId();
        final participantBloc = context.read<ParticipantBloc>();

        // Check if already cached, if not load it
        if (participantBloc.getCachedProfile(otherUserId) == null) {
          participantBloc.add(LoadParticipantProfile(otherUserId));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final otherUserId = _getOtherUserId();
    final participantBloc = context.read<ParticipantBloc>();

    return BlocBuilder<ParticipantBloc, ParticipantState>(
      buildWhen: (previous, current) {
        // Only rebuild if this specific user's profile is loaded or if it's an error for this user
        if (current is ParticipantLoaded && current.profile.id == otherUserId) {
          return true;
        }
        if (current is ParticipantError && current.userId == otherUserId) {
          return true;
        }
        return false;
      },
      builder: (context, state) {
        String name = 'User';
        String? profilePictureUrl;

        // Check cache first
        final cachedProfile = participantBloc.getCachedProfile(otherUserId);
        if (cachedProfile != null) {
          name = cachedProfile.name;
          profilePictureUrl = cachedProfile.profilePictureUrl;
        } else if (state is ParticipantLoaded &&
            state.profile.id == otherUserId) {
          name = state.profile.name;
          profilePictureUrl = state.profile.profilePictureUrl;
        } else if (state is ParticipantError && state.userId == otherUserId) {
          name = 'User';
        }

        final time = formatTime(
          widget.conversation.lastMessageAt ?? widget.conversation.updatedAt,
        );
        final lastMsg = widget.conversation.lastMessageAt != null
            ? 'Last message ${time.isNotEmpty ? "at $time" : ""}'
            : 'Tap to open conversation';

        return GestureDetector(
          onTap: widget.onTap,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: widget.cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: profilePictureUrl == null
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              widget.accent.withOpacity(0.3),
                              widget.accent.withOpacity(0.1),
                            ],
                          )
                        : null,
                  ),
                  child: profilePictureUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: CachedNetworkImage(
                            imageUrl: profilePictureUrl,
                            width: 52,
                            height: 52,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: widget.accent,
                              ),
                            ),
                            errorWidget: (context, url, error) =>
                                _buildAvatarPlaceholder(name, widget.accent),
                          ),
                        )
                      : _buildAvatarPlaceholder(name, widget.accent),
                ),
                const SizedBox(width: 14),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: TextStyle(
                                color: widget.textColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            time,
                            style: TextStyle(
                              color: widget.subtleText,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        lastMsg,
                        style: TextStyle(
                          color: widget.subtleText,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          height: 1.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvatarPlaceholder(String name, Color accent) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'U',
        style: TextStyle(
          color: accent,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
