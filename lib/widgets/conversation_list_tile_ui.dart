import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import '../models/messaging_objects.dart';


class ConversationListTileUi extends StatefulWidget {
  final Conversation? conversation;

  const ConversationListTileUi({super.key, this.conversation,});

  @override
  State<ConversationListTileUi> createState() => _ConversationListTileUiState();
}

class _ConversationListTileUiState extends State<ConversationListTileUi> {
  Conversation? _conversation;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _conversation = widget.conversation;

    getOtherContactProfileImage();
  }

  getOtherContactProfileImage() {
    _conversation!.otherContact!.getImageFromStorage().whenComplete((){
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: GestureDetector(
        onTap: () {},
        child: CircleAvatar(
          backgroundImage: _conversation!.otherContact!.displayImage,
          radius: MediaQuery.of(context).size.width / 14.0,
        ),
      ),
      title: Text(
        _conversation!.otherContact!.getFullName(),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18.5,
        ),
      ),
      subtitle: AutoSizeText(
        widget.conversation!.lastMessage!.text!,
        minFontSize: 16,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        widget.conversation!.lastMessage!.getMessageDateTime(),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
      contentPadding: const EdgeInsets.fromLTRB(25, 15, 25, 15),
    );
  }
}
