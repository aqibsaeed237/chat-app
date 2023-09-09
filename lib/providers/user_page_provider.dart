// Packages

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

//Services

import '../services/database_services.dart';
import '../services/navigation.service.dart';

//Provider

import '../providers/authentication_provider.dart';

//Models

import '../models/chat_user.dart';
import '../models/chat.dart';

//Pages
import '../pages/chat_page.dart';

class UserPageProvider extends ChangeNotifier {
  AuthenticationProvider _auth;

  late UserPageProvider _pageProvider;
  late DatabaseService _database;
  late NavigationService _navigation;

  List<ChatUser>? users;
  late List<ChatUser> _selectedUsers;

  List<ChatUser> get selectedUsers {
    return _selectedUsers;
  }

  UserPageProvider(this._auth) {
    _selectedUsers = [];
    _database = GetIt.instance.get<DatabaseService>();
    _navigation = GetIt.instance.get<NavigationService>();
    getUsers();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void getUsers({String? name}) async {
    _selectedUsers = [];
    try {
      _database.getUsers(name: name).then(
        (_snapshot) {
          users = _snapshot.docs.map(
            (_doc) {
              Map<String, dynamic> _data = _doc.data() as Map<String, dynamic>;
              _data["uid"] = _doc.id;
              return ChatUser.fromJSON(_data);
            },
          ).toList();
          notifyListeners();
        },
      );
    } catch (e) {
      print("Error getting users.");
      print(e);
    }
  }

  void updateSelectedUser(ChatUser _user) {
    if (_selectedUsers.contains(_user)) {
      _selectedUsers.remove(_user);
    } else {
      _selectedUsers.add(_user);
    }
    notifyListeners();
  }

  void createChat() async {
    try {
      //Create Chat
      List<String> _membersId =
          _selectedUsers.map((_user) => _user.uid).toList();
      _membersId.add(_auth.user.uid);
      bool _isGroup = _selectedUsers.length > 1;
      DocumentReference? _doc = await _database.createChat(
        {
          "is_group": _isGroup,
          "is_activity": false,
          "members": _membersId,
        },
      );
      //Navigate To ChatPage
      List<ChatUser> _member = [];
      for (var _uid in _membersId) {
        DocumentSnapshot _userSnapShot = await _database.getUser(_uid);
        Map<String, dynamic> _userData =
            _userSnapShot.data() as Map<String, dynamic>;
        _userData["uid"] = _userSnapShot.id;
        _member.add(
          ChatUser.fromJSON(_userData),
        );
      }
      ChatPage _chatPage = ChatPage(
        chat: Chat(
            uid: _doc!.id,
            currentUserId: _auth.user.uid,
            member: _member,
            message: [],
            activity: false,
            group: _isGroup),
      );
      _selectedUsers = [];
      notifyListeners();
      _navigation.navigateToPage(_chatPage);
    } catch (e) {
      print(e);
    }
  }
}
