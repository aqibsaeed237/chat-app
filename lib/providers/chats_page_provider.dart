import 'dart:async';

//Packages

import 'package:chatapp/pages/chats_page.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//Services
import '../services/database_services.dart';

//Provider
import '../providers/authentication_provider.dart';
import '../providers/chats_page_provider.dart';

//Models
import '../models/chat_user.dart';
import '../models/chat_message.dart';
import '../models/chat.dart';

class ChatsPageProvider extends ChangeNotifier {
  late AuthenticationProvider auth;
  late DatabaseService db;
  List<Chat>? chats;

  late StreamSubscription chatStream;

  ChatsPageProvider(this.auth) {
    db = GetIt.instance.get<DatabaseService>();
    getChat();
  }
  @override
  void dispose() {
    chatStream.cancel();
    super.dispose();
  }

  void getChat() async {
    try {
      chatStream = db.getChatsForUser(auth.user.uid).listen((snapshot) async {
        chats = await Future.wait(
          snapshot.docs.map(
            (_d) async {
              Map<String, dynamic> _chatData =
                  _d.data() as Map<String, dynamic>;
              //get user in chat
              List<ChatUser> _member = [];
              for (var uid in _chatData["member"]) {
                DocumentSnapshot _userSnapshot = await db.getUser(uid);
                Map<String, dynamic> _userData =
                    _userSnapshot.data() as Map<String, dynamic>;
                _userData["uid"] = _userSnapshot.id;
                _member.add(
                  ChatUser.fromJSON(_userData),
                );
              }
              //Get Last message from chat
              List<ChatMessage> _messages = [];
              QuerySnapshot _chatMessage =
                  await db.getLastMessageFromChat(_d.id);
              if (_chatMessage.docs.isNotEmpty) {
                Map<String, dynamic> _messageData =
                    _chatMessage.docs.first.data()! as Map<String, dynamic>;
                ChatMessage _message = ChatMessage.fromJSON(_messageData);
                _messages.add(_message);
              }

              // return chat instance
              return Chat(
                uid: _d.id,
                currentUserId: auth.user.uid,
                member: _member,
                message: [],
                activity: _chatData["is_activity"],
                group: _chatData["is_group"],
              );
            },
          ).toList(),
        );
        notifyListeners();
      });
    } catch (e) {
      print("Error occouring");
      print(e);
    }
  }
}
