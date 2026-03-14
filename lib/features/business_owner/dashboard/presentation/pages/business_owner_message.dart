import 'package:flutter/material.dart';
import 'package:mobile_app/features/chat/presentation/widgets/messages_list_page.dart';
import 'package:mobile_app/features/business_owner/dashboard/presentation/pages/business_owner_message_details_page.dart';

class BusinessOwnerMessagePage extends StatelessWidget {
  const BusinessOwnerMessagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MessagesListPage(
      messageDetailsBuilder: (context, conversation, userEmail) {
        // ChatBloc is provided globally in main.dart, no need for BlocProvider
        return BusinessOwnerMessageDetailsPage(
          conversation: conversation,
          userEmail: userEmail,
        );
      },
    );
  }
}
