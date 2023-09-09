

import 'package:cloud_firestore/cloud_firestore.dart';


enum MessageType {
  Text,
  Image,
  Unknown,
}

class ChatMessage {
  final String senderID;
  final MessageType type;
  final String content;
  final DateTime sentTime;

  ChatMessage({
    required this.content,
    required this.type,
    required this.senderID,
    required this.sentTime,
  });

  factory ChatMessage.fromJSON(Map<String, dynamic> json) {
    MessageType messageType;
    switch (json["type"]) {
      case "text":
        messageType = MessageType.Text;
        break;
      case "image":
        messageType = MessageType.Image;
      default:
        messageType = MessageType.Unknown;
    }
    return ChatMessage(
      content: json["content"],
      type: messageType,
      senderID: json["senderID"],
      sentTime: json["sentTime"].toDate(),
    );
  }
  Map<String, dynamic> toJson() {
    String messageType;
    switch (type) {
      case "text":
        messageType = "text";
        break;
      case "image":
        messageType = "image";
      default:
        messageType = "";
    }
    return {
      "content": content,
      "type": messageType,
      "senderID": senderID,
      "sentTime": Timestamp.fromDate(sentTime),
    };
  }
}
