import '../models/chat_message.dart';
import '../models/chat_user.dart';

class Chat {
  final String uid;
  final String currentUserId;
  final bool activity;
  final bool group;
  final List<ChatUser> member;
  List<ChatMessage> message;
  late final List<ChatUser> _recipients;

  Chat({
    required this.uid,
    required this.currentUserId,
    required this.member,
    required this.message,
    required this.activity,
    required this.group,
  }) {
    _recipients = member.where((_i) => _i.uid != currentUserId).toList();
  }

  List<ChatUser> recipients() {
    return _recipients;
  }

  String title() {
    return !group
        ? _recipients.first.name
        : _recipients.map((_user) => _user.name).join(",");
  }

  String imageURL() {
    return !group
        ? _recipients.first.imageURL
        : "https://images.unsplash.com/photo-1575936123452-b67c3203c357?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=870&q=80";
  }
}
