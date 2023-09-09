// Packages
import 'package:chatapp/models/chat_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Model

const String USER_COLLECTION = "Users";
const String CHAT_COLLECTION = "Chats";
const String MESSAGE_COLLECTION = "messages";

class DatabaseService {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  DatabaseService() {}

  Future<DocumentSnapshot> getUser(String uid) {
    return db.collection(USER_COLLECTION).doc(uid).get();
  }

  Future<QuerySnapshot> getUsers({String? name}) {
    Query _query = db.collection(USER_COLLECTION);
    if (name != null) {
      _query = _query
          .where("name", isGreaterThanOrEqualTo: name)
          .where("name", isLessThanOrEqualTo: name + "z");
    }
    return _query.get();
  }

  Stream<QuerySnapshot> getChatsForUser(String uid) {
    return db
        .collection(CHAT_COLLECTION)
        .where("member", arrayContains: uid)
        .snapshots();
  }

  Future<QuerySnapshot> getLastMessageFromChat(String chatId) {
    return db
        .collection(CHAT_COLLECTION)
        .doc(chatId)
        .collection(MESSAGE_COLLECTION)
        .orderBy("sent_time", descending: true)
        .limit(1)
        .get();
  }

  Stream<QuerySnapshot> streamMessageForChat(String _chatId) {
    return db
        .collection(CHAT_COLLECTION)
        .doc(_chatId)
        .collection(MESSAGE_COLLECTION)
        .orderBy("sent_time", descending: false)
        .snapshots();
  }

  Future<void> deleteChat(String _chatId) async {
    try {
      await db.collection(CHAT_COLLECTION).doc(_chatId).delete();
    } catch (e) {
      print(e);
    }
  }

  Future<void> addMessageToChat(String _chatId, ChatMessage _message) async {
    try {
      await db
          .collection(CHAT_COLLECTION)
          .doc(_chatId)
          .collection(MESSAGE_COLLECTION)
          .add(
            _message.toJson(),
          );
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateChatData(
      String _chatId, Map<String, dynamic> _data) async {
    try {
      await db.collection(CHAT_COLLECTION).doc(_chatId).update(_data);
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateUserLastSeenTime(String uid) async {
    try {
      await db.collection(USER_COLLECTION).doc(uid).update(
        {
          "last_active": DateTime.now().toUtc(),
        },
      );
    } catch (e) {
      print(e);
    }
  }

  Future<void> createUser(
      String uid, String email, String name, String imageURL) async {
    try {
      await db.collection(USER_COLLECTION).doc(uid).set(
        {
          "email": email,
          "image": imageURL,
          "last_active": DateTime.now().toUtc(),
          "name": name,
        },
      );
    } catch (e) {
      print(e);
    }
  }

  Future<DocumentReference?> createChat(Map<String, dynamic> _data) async {
    try {
      DocumentReference _chat = await db.collection(CHAT_COLLECTION).add(_data);
      return _chat;
    } catch (e) {
      print(e);
    }
  }
}
