import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:otel_ve_emlak_kiralama/constants/app_constants.dart';
import 'package:otel_ve_emlak_kiralama/models/messaging_objects.dart';
import 'package:otel_ve_emlak_kiralama/pages/guest/chats_page.dart';
import 'package:otel_ve_emlak_kiralama/widgets/conversation_list_tile_ui.dart';

class InboxPage extends StatefulWidget {
  const InboxPage({super.key});

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('conversations')
          .where('userIDs', arrayContains: AppConstants.currentUser.id).snapshots(),
      builder: (context, snapshots) {
        switch (snapshots.connectionState) {
          case ConnectionState.waiting:
            return const Center(child: CircularProgressIndicator());

          default:
            return ListView.builder(
                itemCount: snapshots.data!.docs.length,
                itemExtent: MediaQuery.of(context).size.height / 9,
                itemBuilder: (context, index) {
                  DocumentSnapshot eachConversation = snapshots.data!.docs[index];

                  Conversation conversation = Conversation();
                  conversation.getConversationInfoFromFirestore(eachConversation);

                  return InkResponse(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ChatsPage(conversation: conversation)),
                      );
                    },
                    child: ConversationListTileUi(
                      conversation: conversation,
                    ),
                  );
                }
            );
        }
      },
    );
  }
}
