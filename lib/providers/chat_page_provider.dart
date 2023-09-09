import 'dart:async';

//Package
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

//Services
import '../services/cloud_storage_service.dart';
import '../services/database_services.dart';
import '../services/media_service.dart';
import '../services/navigation.service.dart';

//Provider
import '../providers/authentication_provider.dart';

//Models
import '../models/chat_message.dart';

class ChatPageProvider extends ChangeNotifier {
  late DatabaseService _db;
  late CloudStorageService _storage;
  late MediaSevice _media;
  late NavigationService _navigation;

  AuthenticationProvider _auth;
  ScrollController _messageListViewController;

  String _chatId;
  List<ChatMessage>? message;
  String? _message;

  late StreamSubscription _messageStram;
  late StreamSubscription _keyboardVisibilityStream;
  late KeyboardVisibilityController _keyboardVisibilityController;

  String get messages {
    return messages;
  }

  void set messages(String _value) {
    _message = _value;
  }

  ChatPageProvider(this._chatId, this._auth, this._messageListViewController) {
    _db = GetIt.instance.get<DatabaseService>();
    _media = GetIt.instance.get<MediaSevice>();
    _navigation = GetIt.instance.get<NavigationService>();
    _keyboardVisibilityController = KeyboardVisibilityController();
    listenToMessage();
    listenToKeboardChanges();
  }
  @override
  void dispose() {
    _messageStram.cancel();
    super.dispose();
  }

  void listenToMessage() {
    try {
      _messageStram = _db.streamMessageForChat(_chatId).listen((_snapshot) {
        List<ChatMessage> _messages = _snapshot.docs.map(
          (_m) {
            Map<String, dynamic> _messageData =
                _m.data() as Map<String, dynamic>;
            return ChatMessage.fromJSON(_messageData);
          },
        ).toList();
        message = _messages;
        notifyListeners();
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          if (_messageListViewController.hasClients) {
            _messageListViewController
                .jumpTo(_messageListViewController.position.maxScrollExtent);
          }
        });
      });
    } catch (e) {
      print('Error getting Message');
      print(e);
    }
  }

  void listenToKeboardChanges() {
    _keyboardVisibilityStream = _keyboardVisibilityController.onChange.listen(
      (_event) {
        _db.updateChatData(
          _chatId,
          {"is_activity": _event},
        );
      },
    );
  }

  void sendTextMessage() {
    if (message != null) {
      ChatMessage _messageToSent = ChatMessage(
        content: _message!,
        type: MessageType.Text,
        senderID: _auth.user.uid,
        sentTime: DateTime.now(),
      );
      _db.addMessageToChat(_chatId, _messageToSent);
    }
  }

  void sendImageMessage() async {
    try {
      PlatformFile? _file = await _media.pickImageFromLibrary();
      if (_file != null) {
        String? _downloadURL = await _storage.saveChatImageToStorage(
            _chatId, _auth.user.uid, _file);
        ChatMessage _messageToSent = ChatMessage(
          content: _message!,
          type: MessageType.Image,
          senderID: _auth.user.uid,
          sentTime: DateTime.now(),
        );
        _db.addMessageToChat(_chatId, _messageToSent);
      }
    } catch (e) {
      print('Error Sending Message');
      print(e);
    }
  }

  void deleChat() {
    goBack();
    _db.deleteChat(_chatId);
  }

  void goBack() {
    _navigation.goBack();
  }
}
