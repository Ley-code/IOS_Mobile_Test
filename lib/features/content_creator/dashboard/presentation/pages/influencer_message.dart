import 'package:flutter/material.dart';
import 'package:mobile_app/features/chat/presentation/widgets/messages_list_page.dart';
import 'package:mobile_app/features/content_creator/dashboard/presentation/pages/message_details_page.dart';

class InfluencerMessagePage extends StatelessWidget {
  const InfluencerMessagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MessagesListPage(
      userEmail: _getUserEmail(context),
      messageDetailsBuilder: (context, conversation, userEmail) {
        // ChatBloc is provided globally in main.dart, no need for BlocProvider
        return MessageDetailsPage(
          conversation: conversation,
          userEmail: userEmail,
        );
      },
    );
  }

  String? _getUserEmail(BuildContext context) {
    // This will be loaded asynchronously, but for now return null
    // The MessagesListPage will handle loading it if needed
    return null;
  }
}
