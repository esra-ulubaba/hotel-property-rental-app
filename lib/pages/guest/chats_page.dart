import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:otel_ve_emlak_kiralama/widgets/message_list_tile_ui.dart';

import '../../constants/app_constants.dart';
import '../../models/messaging_objects.dart';


class ChatsPage extends StatefulWidget {
  static final String routeName = '/conversationPageRoute';
  final Conversation? conversation;

  const ChatsPage({super.key, this.conversation,});

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  TextEditingController _controller = TextEditingController();
  Conversation? _conversation;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _conversation = widget.conversation;
  }

  _sendMessage() {
    String text = _controller.text;
    if (text.isEmpty) { return; }

    _conversation!.addMessageToFirestore(text).whenComplete(() {
      setState(() {
        _controller.text = "";
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_conversation!.otherContact!.getFullName()),
      ),
      body: Column(
        children: [

          //get messages
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection(
                  'conversations/${_conversation!.id}/messages'
              ).orderBy('dateTime').snapshots(),
              builder: (context, snapshots) {
                switch (snapshots.connectionState) {
                  case ConnectionState.waiting:
                    return const Center(child: CircularProgressIndicator());
                  default:
                    return ListView.builder(
                      itemCount: snapshots.data!.docs.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot snapshot = snapshots.data!.docs[index];
                        Message currentMessage = Message();
                        currentMessage.getMessageInfoFromFirestore(snapshot);
                        if (currentMessage.sender!.id == AppConstants.currentUser.id) {
                          currentMessage.sender = AppConstants.currentUser.createContactFromUser();
                        } else {
                          currentMessage.sender = _conversation!.otherContact;
                        }

                        //display messages using ui design
                        return MessageListTileUi(message: currentMessage,);
                      },
                    );
                }
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(bottom: 28, left: 6),
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                  )
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 5 / 6,
                    child: TextField(
                      decoration: const InputDecoration(
                          hintText: 'Mesajınızı yazın.',
                          contentPadding: EdgeInsets.all(20.0),
                          border: InputBorder.none
                      ),
                      minLines: 1,
                      maxLines: 5,
                      style: const TextStyle(
                          fontSize: 20.0
                      ),
                      controller: _controller,
                    ),
                  ),
                  Expanded(
                    child: IconButton(
                      onPressed: _sendMessage,
                      icon: const Icon(Icons.send, size: 50,),
                    ),
                  )
                ],
              ),
            ),
          ),

        ],
      ),
    );
  }
}
