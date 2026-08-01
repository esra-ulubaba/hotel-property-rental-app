import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:otel_ve_emlak_kiralama/models/user_objects.dart';
import 'package:timeago/timeago.dart' as timeAgo ;
import '../constants/app_constants.dart';

class Conversation {
  String? id;
  Contact? otherContact;
  List<Message>? messages;
  Message? lastMessage;

  Conversation() {
    messages = [];
  }

  getConversationInfoFromFirestore(DocumentSnapshot snap) {
    id = snap.id;

    String lastMessageText = snap['lastMessageText'] ?? "";
    Timestamp lastMessageDateTimestamp = snap['lastMessageDateTime'] ?? Timestamp.now();
    DateTime lastMessageDateTime = lastMessageDateTimestamp.toDate();
    lastMessage = Message();
    lastMessage!.dateTime = lastMessageDateTime;
    lastMessage!.text = lastMessageText;

    List<String> userIDs = List<String>.from(snap['userIDs']) ?? [];
    List<String> userNames = List<String>.from(snap['userNames']) ?? [];

    otherContact = Contact();

    for(String userID in userIDs){
      if(userID != AppConstants.currentUser.id){
        otherContact!.id = userID;
        break;
      }
    }

    for(String name in userNames){
      if(name != AppConstants.currentUser.getFullName()){
        otherContact!.firstName = name.split(" ")[0];
        otherContact!.lastName = name.split(" ")[1];
      }
    }
  }

  addConversationToFirestore(Contact otherContact) async {
    List<String> userNames = [
      AppConstants.currentUser.getFullName(),
      otherContact.getFullName(),
    ];

    List<String> userIDs = [
      AppConstants.currentUser.id!,
      otherContact.id!,
    ];

    Map<String,dynamic> initialConversationData = {
      'lastMessageDateTime': DateTime.now(),
      'lastMessageText': "",
      'userNames':userNames,
      'userIDs': userIDs,
    };
    DocumentReference reference = await FirebaseFirestore.instance.collection('conversations').add(initialConversationData);
    id = reference.id;
  }

  addMessageToFirestore(String messageText) async {
    Map<String, dynamic> messageData = {
      'dateTime': DateTime.now(),
      'senderID': AppConstants.currentUser.id,
      'text': messageText
    };
    await FirebaseFirestore.instance.collection('conversations/$id/messages').add(messageData);

    Map<String,dynamic> conversationData = {
      'lastMessageDateTime': DateTime.now(),
      'lastMessageText': messageText
    };
    await FirebaseFirestore.instance.doc('conversations/$id').update(conversationData);
  }
}



class Message {
  Contact? sender;
  String? text;
  DateTime? dateTime;

  Message();

  String getMessageDateTime() {
    return timeAgo.format(dateTime!);
  }

  getMessageInfoFromFirestore(DocumentSnapshot snapshot){
    Timestamp lastMessageTimeStamp = snapshot['dateTime'] ?? Timestamp.now();
    dateTime = lastMessageTimeStamp.toDate();
    String senderID = snapshot['senderID'] ?? "";
    sender = Contact(id: senderID);
    text = snapshot['text'] ?? "";
  }
}