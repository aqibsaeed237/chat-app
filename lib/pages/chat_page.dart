//Packages
import 'package:chatapp/providers/authentication_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//Widget
import '../widgets/top_bar.dart';
import '../widgets/custom_list_view_tile.dart';
import '../widgets/custom_input_fields.dart';

//Models
import '../models/chat_message.dart';
import '../models/chat.dart';

//Provider
import '../providers/chat_page_provider.dart';

class ChatPage extends StatefulWidget {
  final Chat chat;

  ChatPage({required this.chat});

  @override
  State<StatefulWidget> createState() {
    return _ChatPageState();
  }
}

class _ChatPageState extends State<ChatPage> {
  late double _deviceHeight;
  late double _deviceWidth;

  late GlobalKey<FormState> _messageFormState;
  late ScrollController _messageListViewController;

  late AuthenticationProvider _auth;
  late ChatPageProvider _pageProvider;

  @override
  void initState() {
    super.initState();
    _messageFormState = GlobalKey<FormState>();
    _messageListViewController = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.sizeOf(context).height;
    _deviceWidth = MediaQuery.sizeOf(context).width;
    _auth = Provider.of<AuthenticationProvider>(context);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ChatPageProvider>(
          create: (_) => ChatPageProvider(
              this.widget.chat.uid, _auth, _messageListViewController),
        ),
      ],
      child: _buildUi(),
    );
  }

  Widget _buildUi() {
    return Builder(
      builder: (BuildContext _context) {
        _pageProvider = _context.watch<ChatPageProvider>();
        return Scaffold(
          body: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: _deviceWidth * 0.03,
                  vertical: _deviceHeight * 0.02),
              height: _deviceHeight,
              width: _deviceWidth * 0.97,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TopBar(
                    this.widget.chat.title(),
                    fontSize: 10,
                    primaryAction: IconButton(
                      icon: Icon(Icons.delete),
                      color: Color.fromRGBO(0, 82, 218, 1.0),
                      onPressed: () {
                        _pageProvider.deleChat();
                      },
                    ),
                    secondaryAction: IconButton(
                      icon: Icon(Icons.arrow_back),
                      color: Color.fromRGBO(0, 82, 218, 1.0),
                      onPressed: () {
                        _pageProvider.goBack();
                      },
                    ),
                  ),
                  _messageListview(),
                  _sendMessageForm(),
                  _sendMessageButton(),
                  _imageMessageButton(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _messageListview() {
    if (_pageProvider.messages != null) {
      if (_pageProvider.messages.length != 0) {
        return Container(
          height: _deviceHeight * 0.74,
          child: ListView.builder(
            controller: _messageListViewController,
            itemCount: _pageProvider.message!.length,
            itemBuilder: (BuildContext _context, int _index) {
              ChatMessage _message = _pageProvider.message![_index];
              bool _isOwnMessage = _message.senderID == _auth.user.uid;
              return CustomChatListViewTile(
                  width: _deviceWidth * 0.80,
                  deviceHeight: _deviceHeight,
                  isOwnMessage: _isOwnMessage,
                  message: _message,
                  sender: widget.chat.member
                      .where((_m) => _m.uid == _message.senderID)
                      .first);
            },
          ),
        );
      } else {
        return Align(
          alignment: Alignment.center,
          child: Text(
            'Be the first to say Hi ',
            style: TextStyle(color: Colors.white),
          ),
        );
      }
    } else {
      return Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }
  }

  Widget _sendMessageForm() {
    return Container(
      height: _deviceHeight * 0.06,
      decoration: BoxDecoration(
        color: Color.fromRGBO(30, 29, 37, 1.0),
        borderRadius: BorderRadius.circular(100),
      ),
      margin: EdgeInsets.symmetric(
        horizontal: _deviceWidth * 0.04,
        vertical: _deviceHeight * 0.03,
      ),
      child: Form(
        key: _messageFormState,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _messageTextField(),
          ],
        ),
      ),
    );
  }

  Widget _messageTextField() {
    return SizedBox(
      width: _deviceWidth * 0.65,
      child: CustomTextFormField(
          onSaved: (_value) {
            _pageProvider.messages = _value;
          },
          //regex nothing will bw illegal value
          regEx: r"^(?!\s*$).+",
          hintText: "Type a message",
          obsecureText: false),
    );
  }

  Widget _sendMessageButton() {
    double _size = _deviceHeight * 0.04;
    return Container(
      height: _size,
      width: _size,
      child: IconButton(
        icon: const Icon(
          Icons.send,
          color: Colors.white,
        ),
        onPressed: () {
          if (_messageFormState.currentState!.validate()) {
            _messageFormState.currentState!.save();
            _pageProvider.sendTextMessage();
            _messageFormState.currentState!.reset();
          }
        },
      ),
    );
  }

  Widget _imageMessageButton() {
    double _size = _deviceHeight * 0.04;
    return Container(
      height: _size,
      width: _size,
      child: FloatingActionButton(
        backgroundColor: Color.fromRGBO(0, 82, 218, 1.0),
        onPressed: () {
          _pageProvider.sendImageMessage();
        },
        child: Icon(Icons.camera_enhance),
      ),
    );
  }
}
